defmodule DetectinoPanel.Api.SessionTest do
  @moduledoc false
  use ExUnit.Case

  alias DetectinoPanel.Api.Session
  alias Plug.Conn
  alias Plug.Parsers

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "sends correct login parameters", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/api/login", fn conn ->
      opts = Parsers.init(parsers: [:json], json_decoder: Jason)
      conn = Parsers.call(conn, opts)

      assert %{"username" => "admin@local", "password" => "canemorto"} =
               conn.params |> Map.get("user")

      body = Jason.encode!(%{token: "footoken"})
      Conn.resp(conn, 200, body)
    end)

    assert {:ok, "footoken"} = Session.login(server: endpoint_url(bypass.port))
  end

  test "http error 500", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/api/login", fn conn ->
      Conn.resp(conn, 500, "")
    end)

    assert {:error, :transport} = Session.login(server: endpoint_url(bypass.port))
  end

  test "http error 401", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/api/login", fn conn ->
      Conn.resp(conn, 401, "")
    end)

    assert {:error, :unauthorized} = Session.login(server: endpoint_url(bypass.port))
  end

  test "no server response", %{bypass: _bypass} do
    assert {:error, :transport} = Session.login(server: endpoint_url(42))
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"
end
