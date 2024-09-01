defmodule Dash.Repo.Migrations.AddLock do
  use Ecto.Migration

  def change do
    alter table(:timers) do
      add :lock_version, :integer, default: 1
    end
  end
end
