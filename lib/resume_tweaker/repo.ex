defmodule ResumeTweaker.Repo do
  use Ecto.Repo,
    otp_app: :resume_tweaker,
    adapter: Ecto.Adapters.Postgres
end
