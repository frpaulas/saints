defmodule Saints.DonorView do
  use Saints.Web, :view
  alias Saints.Donor

  def full_name(donor) do
    Regex.replace ~r/\s\s/, 
      "#{donor.title} #{donor.first_name} #{donor.middle_name} #{donor.last_name} #{donor.name_ext}",
      " "
  end

  def pagination_links(page) do
    link("2", [to: "?page=2"])
  end

  def pagination_number(label, page) do
    link label, [to: "?page=#{_valid_page(page)}"]
  end

  def _valid_page(n) do
    if n > 0, do: n, else: 1
  end

  def alphabet_filter do
    links = ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    |> Enum.map( fn(letter)->
        content_tag(:li, link("#{letter}", [to: "/donors/alpha/#{letter}"]))
      end)

    content_tag(:ul, links, [class: "alphabetDonors"])
  end

end
