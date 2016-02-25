require IEx
defmodule Loader do
  alias Saints.Repo
  alias Saints.Donor

  @fields [ "title", "first_name", "middle_name", "last_name", "name_ext", "aka", 
            "email", "phone", "location", 
            "address1", "address2", "city", "state", "zip", "country"
          ]

  def start_link do
    Agent.start_link fn-> build end, name: __MODULE__
  end
  defp build do
    import String
    [h|t] = File.open!("./data/fake_data.csv", [:read, :utf8])
      |> IO.stream(:line)
      |> Enum.reduce([], fn(ln, list)-> 
        [ 
          ln |> String.strip |> String.replace("\"", "") |> String.split("|")
          | list
        ]
      end)
      |> Enum.reverse
    %{fields: @fields, 
      data: t 
        |> Enum.map(&Enum.zip(@fields, &1))
        |> Enum.map(&Enum.into(&1, %{}))
    }
  end
  def identity(), do: Agent.get(__MODULE__, &(&1))
  def fields(), do: identity.fields
  def data(), do: identity.data

  def load(), do: _load(Loader.data)
  def _load([]), do: {:ok}
  def _load([vals|data]) do
    donor = %Saints.Donor{  
      title: vals["title"],
      first_name: vals["first_name"],
      middle_name: vals["middle_name"],
      last_name: vals["last_name"],
      name_ext: vals["name_ext"],
      aka: vals["aka"]
      }
    address = %{
      location: vals["location"],
      address1: vals["address1"],
      address2: vals["address2"],
      city: vals["city"],
      state: vals["state"],
      zip: vals["zip"],
      country: vals["country"]
      }
    email = %{  
      location: vals["location"],
      of_type: "email",
      number: vals["email"]
      }
    phone = %{  
      location: vals["location"],
      of_type: "phone",
      number: vals["phone"]
      }
    db_donor = Repo.insert! donor
    new_assoc = db_donor |> Ecto.build_assoc(:addresses, address)
    Repo.insert! new_assoc
    new_assoc = db_donor |> Ecto.build_assoc(:phones, email)
    Repo.insert! new_assoc
    new_assoc = db_donor |> Ecto.build_assoc(:phones, phone)
    Repo.insert! new_assoc

    _load(data)
  end
end



