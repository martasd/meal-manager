defmodule MealManager.Repo do
  use Ecto.Repo,
    otp_app: :meal_manager,
    adapter: Ecto.Adapters.Postgres
end
