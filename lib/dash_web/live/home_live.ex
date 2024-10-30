defmodule DashWeb.HomeLive do
  require Logger
  use DashWeb, :live_view
  alias Dash.Security.Server, as: SecServ

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       timer_form: Phoenix.Component.to_form(%{}),
       security_form:
         Phoenix.Component.to_form(%{
           "enabled" => SecServ.enabled?()
         })
     )}
  end

  @impl true
  def handle_event("submit_timer", %{"duration" => duration}, socket) do
    duration =
      case Integer.parse(duration) do
        {num, _} when duration > 0 ->
          num

        _ ->
          raise ArgumentError, "Invalid duration"
      end

    {:ok, timer} =
      Dash.Timers.Supervisor.start_child(%{
        time_left: Time.from_seconds_after_midnight(duration * 60)
      })

    {:noreply, push_navigate(socket, to: ~p"/timer/#{timer.id}")}
  end

  @impl true
  def handle_event(
        "security_toggle",
        %{"_target" => ["security_enabled"], "security_enabled" => "true"},
        socket
      ) do
    SecServ.enable()

    {:noreply,
     assign(socket,
       security_form:
         Phoenix.Component.to_form(%{
           "enabled" => true
         })
     )}
  end

  @impl true
  def handle_event(
        "security_toggle",
        %{"_target" => ["security_enabled"], "security_enabled" => "false"},
        socket
      ) do
    SecServ.disable()

    {:noreply,
     assign(socket,
       security_form:
         Phoenix.Component.to_form(%{
           "enabled" => false
         })
     )}
  end
end
