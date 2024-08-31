defmodule DashWeb.HomeControllerTest do
  use DashWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Hello"
  end
end
