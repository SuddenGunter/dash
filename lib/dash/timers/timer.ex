defmodule Dash.Timers.Timer do
  # TODO reuse validation from Timer schema
  @doc false
  # def changeset(timer, attrs) do
  #   timer
  #   |> cast(attrs, [:time_left, :state])
  #   # time_left is not required cause zero value will fail this validation, and zero value is valid when timer is finished.
  #   |> validate_required([:time_left, :state])
  #   |> validate_change(:time_left, fn :time_left, time_left ->
  #     # max interval size is 8 hours for now
  #     if Time.compare(time_left, Time.new!(8, 0, 0)) == :gt do
  #       [time_left: "interval can not be longer than 8 hours"]
  #     else
  #       []
  #     end
  #   end)
  #   |> Ecto.Changeset.optimistic_lock(:lock_version)
  # end
end
