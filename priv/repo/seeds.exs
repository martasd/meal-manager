alias MealManager.Diners
alias MealManager.Diners.Diner

defmodule Seeds.CreateDiner do
  def get_or_create_user(id, %{} = attrs) do
    case Diners.get_diner(id) do
      %Diner{} = diner ->
        diner

      nil ->
        {:ok, diner} = Diners.create_diner(attrs)
        diner
    end
  end
end

Seeds.CreateDiner.get_or_create_user(1, %{})
