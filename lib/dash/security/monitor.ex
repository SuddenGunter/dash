defmodule Dash.Security.Monitor do
  @moduledoc """
  Security monitor module, receives and processes all security events form IoT devices.
  Makes decision if the system is in alarmed state or not and sends this information to the security server.
  Security monitor always enabled, even when the security server is turned off.

  System is in alarmed state if:
  - any door is opened
  - any door sensor is unavailable (zigbee2mqtt availability message)
  - any door sensor failed to send update in last 30 minute
  """
end
