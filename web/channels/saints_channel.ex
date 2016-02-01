require IEx
require Poison
defmodule Saints.SaintsChannel do
  use Saints.Web, :channel
  alias Saints.Donor

  def join("donors:list", payload, socket) do
    if authorized?(payload) do
      send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    push socket, "set_donors", %{donors: ready_page(%{"page" => 1, "name" => ""})}
    {:noreply, socket}
  end

  defp ready_page(request) do
    get_page(request) |> jsonify_page
  end

  defp get_page(request) do
    split_name = request["name"] |> String.split(~r{[\,\s]+})
    last_name = hd split_name
    first_name = if split_name |> tl |> length > 0, do: split_name|>tl|>hd, else: ""
    resp = 
      ( from s in Saints.Donor, 
          where: (ilike(s.last_name, ^("#{last_name}%")) and ilike(s.first_name, ^("#{first_name}%"))),
          order_by: [asc: s.last_name, asc: s.first_name],
          preload: [:address, :phone, :note]
      ) 
      |> Repo.paginate(page: max(1, request["page"])) # one is the lowest page number
    
    {request["name"], resp}
  end

  defp jsonify_page({name, resp}) do
    %{  searchName: name,
        page: %{totalPages: resp.total_pages,
            totalEntries:   resp.total_entries,
            pageSize:       resp.page_size,
            pageNumber:     resp.page_number
        },
        donors: resp.entries
    }
  end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client

  def handle_in("request_page", [page, name], socket) do
    push socket, "set_donors", %{donors: ready_page(%{"page" => page, "name" => name})}
    {:noreply, socket}    
  end

  def handle_in("update_donor", donor, socket) do
    vp = %{"first_name" => donor["firstName"], "middle_name" => donor["middleName"], "last_name"=>donor["lastName"], "name_ext"=>donor["nameExt"], "address"=>donor["address"], "phone"=>donor["phone"], "note"=>donor["note"]}
    changeset = Repo.one(from u in Saints.Donor, where: u.id == ^donor["id"], preload: [:address, :phone, :note])
      |> Saints.Donor.changeset(vp)
    case Repo.update(changeset) do
      {:ok, donor} ->
        push socket, "ok_donor", %{donor: donor}
        {:noreply, socket}
      {:error, changeset} ->
        {:error, %{reason: "database failure"}}
    end
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (donors:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
