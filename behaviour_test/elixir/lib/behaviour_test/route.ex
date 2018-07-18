defmodule BehaviourTest.Route do
  use Plug.Router
  require Logger
  @api_key Application.fetch_env!(:behaviour_test, :api_key)

  plug(:match)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  post "/" do
    Logger.debug(inspect(Node.list()))

    conn
    |> read_body()
    |> notify()
    |> send_response(conn)
  end

  defp notify({:ok, _, conn}) do
    params = conn.body_params

    BatchElixir.send_notication(
      :web,
      params["group_id"],
      params["custom_ids"],
      params["title"],
      params["message"]
    )
  end

  defp send_response(:ok, conn) do
    send_resp(conn, 204, "")
  end

  defp send_response({:error, reason}, conn) do
    send_resp(conn, 500, reason)
  end
end
