require IEx
require Logger
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
    update_rec Saints.Donor, db_donor(donor), socket, "FAILED TO UPDATE DONOR NAME", [:addresses, :phones, :notes, :donations]
  end

  def handle_in("create_donor", donor, socket) do
    create_donor donor, socket, "FAILED TO CREATE DONOR"
  end

  def handle_in("delete_donor", donor, socket) do
    delete_this Saints.Donor, donor, socket, "FAILED TO DELETE DONOR"
  end

  def handle_in("update_donation", donation, socket) do
    update_rec Saints.Donation, db_donation(donation), socket, "FAILED TO UPDATE DONATION"
  end

  def handle_in("create_donation", donation, socket) do
    create_assoc :donations, db_donation(donation), socket, "FAILED TO CREATE DONATION"
  end

  def handle_in("delete_donation", donation, socket) do
    delete_this Saints.Donation, donation, socket, "DB FAILED TO DELETE DONATION"
  end

  def handle_in("update_note", note, socket) do
    update_rec Saints.Note, db_note(note), socket, "FAILED TO UPDATE NOTE"
  end

  def handle_in("create_note", note, socket) do
    create_assoc :notes, db_note(note), socket, "FAILED TO CREATE NOTE"
  end

  def handle_in("delete_note", note, socket) do
    delete_this Saints.Note, note, socket, "DB FAILED TO DELETE NOTE"
  end

  def handle_in("update_address", address, socket) do
    update_rec Saints.Address, db_address(address), socket, "FAILED TO UPDATE ADDRESS"
  end

  def handle_in("create_address", address, socket) do
    create_assoc :addresses, db_address(address), socket, "FAILED TO CREATE ADDRESS"
  end

  def handle_in("delete_address", address, socket) do
    delete_this Saints.Address, address, socket, "DB FAILED TO DELETE ADDRESS"
  end

  def handle_in("update_phone", phone, socket) do
    update_rec Saints.Phone, db_phone(phone), socket, "FAILED TO UPDATE PHONE"
  end

  def handle_in("create_phone", phone, socket) do
    create_assoc :phones, db_phone(phone), socket, "FAILED TO CREATE PHONE"
  end
  def handle_in("delete_phone", phone, socket) do
    delete_this Saints.Phone, phone, socket, "DB FAILED TO DELETE PHONE"
  end


  def handle_in("request_donor_detail", donor_id, socket) when donor_id < 0 do
    {:noreply, socket}
  end
  def handle_in("request_donor_detail", donor_id, socket) do
    pushDonor donor_id, socket
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


  defp db_donor(donor) do
    %{  
      title:        donor["title"],
      first_name:   donor["firstName"], 
      middle_name:  donor["middleName"], 
      last_name:    donor["lastName"], 
      name_ext:     donor["nameExt"],
      id:           donor["id"]
    }
  end

  defp db_donation(donation) do
    import Decimal, only: [new: 1]
    %{  amount: donation["amount"] |> Decimal.new,
        of_type: donation["ofType"],
        of_type_id: donation["ofTypeID"],
        donor_id: donation["donor_id"],
        id: donation["id"]
    }
  end

  defp db_note(note) do
    %{  author:   author(note), 
        memo:     note["memo"], 
        donor_id: note["donor_id"],
        id:       note["id"]
      }
    
  end

  defp db_address(address) do
    %{ location:  location(address),
        address1: address["address1"],
        address2: address["address2"],
        city:     address["city"],
        state:    address["state"],
        zip:      address["zip"],
        country:  address["country"],
        donor_id: address["donor_id"],
        id:       address["id"]
      }
  end

  defp db_phone(phone) do
    %{  location: location(phone), 
        of_type:  phone["ofType"], 
        number:   phone["number"],
        donor_id: phone["donor_id"],
        id:       phone["id"]
      }
  end
    
  defp update_rec(model, map, socket, fail_msg \\ "DB_FAILED", preloads \\[]) do
    changeset = Repo.get(model, map.id)
      |> Repo.preload(preloads)
      |> model.changeset(map)
    case Repo.update(changeset) do
      {:ok, resp} ->
        id = if resp |> Map.has_key?(:donor_id), do: resp.donor_id, else: resp.id
        pushDonor id, socket
      {:error, changeset} ->
        {:error, %{reason: fail_msg}}
    end
  end

  def create_donor(map, socket, fail_msg \\ "DB FAIL") do
    mx = %Saints.Donor{
      title:        map["title"],
      first_name:   map["firstName"],
      middle_name:  map["middleName"],
      last_name:    map["lastName"],
      name_ext:     map["nameExt"],
      aka:          map["aka"]
    }
    case Repo.insert(mx) do
      {:ok, donor} ->
        Logger.debug "INSERT DONOR OK: #{inspect donor}"
        pushDonor donor.id, socket
      {:error, resp} ->
        Logger.debug "INSERT DONOR FAIL: #{resp}"
        {:error, %{reason: fail_msg}}
    end
  end

  defp create_assoc(assoc, map, socket, fail_msg \\ "DB FAIL") do
    map = map |> Map.delete(:id)
    new_assoc = Repo.get(Saints.Donor, map.donor_id)
      |> Ecto.build_assoc(assoc, map)
    case Repo.insert(new_assoc) do
      {:ok, resp} ->
        pushDonor resp.donor_id, socket
      {:error, msg} -> 
        {:error, %{reason: fail_msg}}
    end
  end


  defp delete_this(model, map, socket, fail_msg \\ "DB FAIL") do
    IO.puts "DELETE THIS: #{inspect map}"
    cond do
      map["id"] < 0 && map["donor_id"] |> is_nil ->
        {:noreply, socket}
      map["id"] < 0 -> 
        pushDonor map["donor_id"], socket
      true ->
        Repo.one(from m in model, where: m.id == ^map["id"])
        |> repo_delete(model, socket, fail_msg)
    end
  end

defp repo_delete(record, model, socket, msg) do
  Repo.delete(record) |> _repo_delete(model, socket, msg)
end

defp _repo_delete({:ok, resp}, Saints.Donor, socket, _msg), do: {:noreply, socket}
defp _repo_delete({:ok, resp}, model, socket, _msg), do: pushDonor resp.donor_id, socket
defp _repo_delete({:ok, _error_msg}, _model, socket, msg), do: {:error, %{reason: msg}}


defp location(map) do
  if map["location"]|>String.strip|>String.length == 0, do: "unknown", else: map["location"]
end

defp author(map) do
    if map["author"]|>String.strip|>String.length == 0, do: "unknown", else: map["author"]
end

  defp pushDonor(id, socket) do
    unless id |> is_nil do
      d = Repo.one(from d in Saints.Donor, where: d.id == ^id, preload: [:addresses, :phones, :notes, :donations])
      push socket, "ok_donor", %{donor: d}
    end
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
