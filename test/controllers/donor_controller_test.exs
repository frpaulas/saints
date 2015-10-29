defmodule Saints.DonorControllerTest do
  use Saints.ConnCase

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

    }
    Saints.Repo.insert(donor)
    query = from donor in Saints.Donor,
            order_by: [desc: donor.id],
            select: donor
    assert length(Saints.Repo.all(query)) == 1
  end
end
