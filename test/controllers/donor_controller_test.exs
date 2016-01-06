defmodule Saints.DonorControllerTest do
  use Saints.ConnCase

  test "shows chosen resource" do
    donor = Repo.insert! %Saints.Donor{
      title: "The Rev.",
      first_name: "Elmer",
      middle_name: "P",
      last_name: "Fudd",
      name_ext: "IV",
      address: [],
      phone: [],
      note: []
    }

    # conn = get conn, donor_path(conn, :show, donor)
    # assert json_response(conn, 200)["data"] == %{"id" => donor.id}
    resp = conn(:get, donor_path(conn, :show, donor)) |> send_request
    assert resp.status == 200
  end

  test "GET /donors" do
    conn = get conn(), "/donors"
    assert html_response(conn, 200) =~ "Donor Listing"
  end

  test "create donor" do
    donor = %Saints.Donor{
      title: "The Rev.",
      first_name: "Elmer",
      middle_name: "P",
      last_name: "Fudd",
      name_ext: "IV",
      address: [],
      phone: [],
      note: []
    }
    Saints.Repo.insert(donor)
    query = from donor in Saints.Donor,
            order_by: [desc: donor.id],
            select: donor
    assert length(Saints.Repo.all(query)) == 1
  end

  defp send_request(conn) do
    me = %Saints.User{email: "frpaulas@gmail.com", 
                      id: 1, 
                      name: "Paul Sutcliffe", 
                      password: nil, 
                      password_hash: "$2b$12$gKajL14kXz3fou.oIoTpnekSmzEAGo/1Xnz.CnVBCUorPROjbXhrK", 
                      phone: "412-517-8031"}
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> assign(:current_user, me)
    |> Saints.Endpoint.call([])
  end

end
