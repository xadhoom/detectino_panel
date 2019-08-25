defmodule Detectino.Api.Scenario do
  @moduledoc false

  @otp_app :detectino_panel

  @api_path "/api/scenarios"

  def get_available({_token, _pin} = auth, opts \\ []) do
    do_get(@api_path, auth, opts)
  end

  defp do_get(path, {token, pin}, opts) do
    headers = [{"Content-Type", "application/json"}, {"authorization", token}, {"p-dt-pin", pin}]

    path
    |> url(opts)
    |> HTTPoison.get(headers)
    |> parse_response()
  end

  defp parse_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

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
