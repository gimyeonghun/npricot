defmodule Npricot.Repo do
  use Ecto.Repo,
    otp_app: :npricot,
    adapter: Ecto.Adapters.Postgres
end
