defmodule DetectinoPanel.Api.PinTest do
  @moduledoc false
  use ExUnit.Case

  alias DetectinoPanel.Api.Pin
  alias Plug.Conn
  alias Plug.Parsers

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "check_pin/2" do
    test "valid pin", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/api/users/check_pin", fn conn ->
        opts = Parsers.init(parsers: [:json], json_decoder: Jason)
        conn = Parsers.call(conn, opts)

        assert "1234" = conn.params |> Map.get("pin")
        assert ["atoken"] == Plug.Conn.get_req_header(conn, "authorization")

        Conn.resp(conn, 200, "")
      end)

      assert :ok = Pin.check_pin("atoken", "1234", server: endpoint_url(bypass.port))
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"
end
