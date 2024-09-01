defmodule Dash.Timers.Timer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timers" do
    field :time_left, :time
    field :state, Ecto.Enum, values: [:stopped, :running]

    field :lock_version, :integer, default: 1
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:time_left, :state])
    |> validate_required([:time_left, :state])
    |> validate_change(:time_left, fn :time_left, time_left ->
      # max interval size is 8 hours for now
      if Time.compare(time_left, Time.new!(8, 0, 0)) == :gt do
        [time_left: "interval can not be longer than 8 hours"]
      else
        []
      end
    end)
    |> Ecto.Changeset.optimistic_lock(:lock_version)
  end
end
