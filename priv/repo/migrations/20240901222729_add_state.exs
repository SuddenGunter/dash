defmodule Dash.Repo.Migrations.AddState do
  use Ecto.Migration

  def change do
    alter table(:timers) do
      add :state, :string
    end
  end
end
