defmodule Detectino.Api.Pin do
  @moduledoc false

  @otp_app :detectino_panel

  @api_path "/api/users/check_pin"

  def check_pin(token, pin, opts \\ []) when is_binary(pin) do
    payload = %{pin: pin}

    do_post(@api_path, payload, token, opts)
  end

  defp do_post(path, payload, token, opts) do
    headers = [{"Content-Type", "application/json"}, {"authorization", token}]

    path
    |> url(opts)
    |> HTTPoison.post(
      Jason.encode!(payload),
      headers
    )
    |> parse_response()
  end

  defp parse_response({:ok, %{status_code: 200}}), do: :ok
  defp parse_response({:ok, %{status_code: 400}}), do: {:error, :invalid}
  defp parse_response({:ok, %{status_code: 401}}), do: {:error, :unauthorized}
  defp parse_response({:ok, %{status_code: 404}}), do: {:error, :unauthorized}
  defp parse_response(_), do: {:error, :transport}

  defp url(api_path, opts) do
    server =
      opts[:server] ||
        @otp_app
        |> Application.get_env(:detectino_api)
        |> Keyword.get(:server)

    Path.join(server, api_path)
  end
end
