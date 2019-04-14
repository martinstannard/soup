defmodule Soup.Repo do
  use Ecto.Repo,
    otp_app: :soup,
    adapter: Ecto.Adapters.Postgres
end
