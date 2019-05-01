defmodule DetectinoPanel.Api.Session do
  @moduledoc false

  @otp_app :detectino_panel

  @login_path "/api/login"
  @refresh_path "/api/login/refresh"

  def login(opts \\ []) do
    config = Application.get_env(@otp_app, :detectino_api)
    username = opts[:username] || Keyword.get(config, :username)
    password = opts[:password] || Keyword.get(config, :password)

    payload = %{user: %{username: username, password: password}}

    with {:op, {:ok, response}} <- {:op, do_post(@login_path, payload, opts)},
         {:dec, {:ok, token}} <- {:dec, extract_token(response)} do
      {:ok, token}
    else
      {:op, err} -> err
      {:dec, _} -> {:error, :response}
    end
  end

  @spec refresh(String.t()) :: {:ok, String.t()} | {:error, atom}
  def refresh(token, opts \\ []) do
    hdrs = %{"Authorization" => token}

    with {:op, {:ok, response}} <- {:op, do_post(@refresh_path, %{}, opts, hdrs)},
         {:dec, {:ok, token}} <- {:dec, extract_token(response)} do
      {:ok, token}
    else
      {:op, err} -> err
      {:dec, _} -> {:error, :response}
    end
  end

  defp extract_token(%HTTPoison.Response{body: body}) do
    with {:ok, json} <- Jason.decode(body) do
      {:ok, Map.get(json, "token")}
    end
  end

  defp do_post(path, payload, opts, headers \\ %{}) do
    headers = Map.put(headers, "Content-Type", "application/json")

    path
    |> url(opts)
    |> HTTPoison.post(
      Jason.encode!(payload),
      build_headers(headers)
    )
    |> parse_response()
  end

  defp build_headers(hdrs_map) do
    hdrs_map
    |> Enum.map(fn {_k, _v} = hdr ->
      hdr
    end)
  end

  defp parse_response({:ok, %{status_code: 200}} = response), do: response
  defp parse_response({:ok, %{status_code: 401}}), do: {:error, :unauthorized}
  defp parse_response(_), do: {:error, :transport}

  defp url(path, opts) do
    server =
      opts[:server] || @otp_app |> Application.get_env(:detectino_api) |> Keyword.get(:server)

    "#{server}#{path}"
  end
end
