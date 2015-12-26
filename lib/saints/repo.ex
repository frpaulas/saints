defmodule Saints.Repo do
  use Ecto.Repo, otp_app: :saints
  use Scrivener, page_size: 12
end
