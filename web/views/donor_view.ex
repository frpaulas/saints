defmodule Saints.DonorView do
  use Saints.Web, :view
  alias Saints.Donor

  def full_name(donor) do
    Regex.replace ~r/\s\s/, 
      "#{donor.title} #{donor.first_name} #{donor.middle_name} #{donor.last_name} #{donor.name_ext}",
      " "
  end
end
