defmodule Dash.TimersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dash.Timers` context.
  """

  @doc """
  Generate a timer.
  """
  def timer_fixture(attrs \\ %{}) do
    {:ok, timer} =
      attrs
      |> Enum.into(%{
        description: "some description"
      })
      |> Dash.Timers.create_timer()

    timer
  end
end
