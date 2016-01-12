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
    page 
      = ( from s in Saints.Donor, 
          order_by: [asc: s.last_name, asc: s.first_name]
        ) 
      |> Repo.paginate(page: 1)

    donors = # make it look nice for Elm
      %{  totalPages: page.total_pages,
          totalEntries: page.total_entries,
          pageSize: page.page_size,
          pageNumber: page.page_number,
          donors: page.entries
      }

    push socket, "set_donors", %{donors: donors}
    {:noreply, socket}
  end



  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
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
