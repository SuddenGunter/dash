defmodule Dash.Repo.Migrations.CreateTimers do
  use Ecto.Migration

  def change do
    create table(:timers) do
      add :time_left, :time

      timestamps(type: :utc_datetime)
    end
  end
end
