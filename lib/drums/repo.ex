defmodule Drums.Repo do
  use Ecto.Repo,
    otp_app: :drums,
    adapter: Ecto.Adapters.Postgres
end
