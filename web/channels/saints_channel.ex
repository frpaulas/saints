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
          order_by: [asc: s.last_name, asc: s.first_name]
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
    db_donor = %{ "first_name" => donor["firstName"], 
            "middle_name" => donor["middleName"], 
            "last_name"=>donor["lastName"], 
            "name_ext"=>donor["nameExt"] #, 
          }
    changeset = Repo.one(from u in Saints.Donor, where: u.id == ^donor["id"], preload: [:addresses, :phones, :notes])
      |> Saints.Donor.changename(db_donor)
    case Repo.update(changeset) do
      {:ok, donor} ->
        push socket, "ok_donor", %{donor: donor}
        {:noreply, socket}
      {:error, changeset} ->
        {:error, %{reason: "DB failed to update donor"}}
    end
  end

  def handle_in("update_note", note, socket) do
    changeset = Repo.one(from n in Saints.Note, where: n.id == ^note["id"])
      |> Saints.Note.changeset(note)
    case Repo.update(changeset) do
      {:ok, note} -> 
        pushDonor note.donor_id, socket
      {:error, changeset} ->
        {:error, %{reason: "DB failed to update note"}}
    end
  end

  def handle_in("update_address", address, socket) do
    changeset = Repo.one(from a in Saints.Address, where: a.id == ^address["id"])
      |> Saints.Address.changeset(address)
    case Repo.update(changeset) do
      {:ok, address} ->
        pushDonor address.donor_id, socket
      {:error, changeset} ->
        {:error, %{reason: "DB failed to update address"}}
    end
  end

  def handle_in("update_phone", phone, socket) do
    phone_db = %{ "id"        => phone["id"],
                  "location"  => phone["location"],
                  "number"    => phone["number"],
                  "of_type"   => phone["ofType"]
                }
    changeset = Repo.one(from p in Saints.Phone, where: p.id == ^phone["id"])
      |> Saints.Phone.changeset(phone_db)
    case Repo.update(changeset) do
      {:ok, phone} ->
        pushDonor phone.donor_id, socket
      {:error, changeset} ->
        {:error, %{reason: "DB failed to update phone/email"}}
    end
  end



  defp pushDonor(id, socket) do
    d = Repo.one(from d in Saints.Donor, where: d.id == ^id, preload: [:addresses, :phones, :notes])
    push socket, "ok_donor", %{donor: d}
    {:noreply, socket}
  end

  def handle_in("request_donor_detail", donor_id, socket) do
    donor = 
      Repo.one( from s in Saints.Donor,
        where: s.id == ^donor_id,
        preload: [:addresses, :phones, :notes]    
      )
    push socket, "ok_donor", %{donor: donor}
    {:noreply, socket}
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
