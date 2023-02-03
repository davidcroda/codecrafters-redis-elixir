defmodule Server do
  @moduledoc """
  Your implementation of a Redis server
  """

  use Application

  def start(_type, _args) do
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  @doc """
  Listen for incoming connections
  """
  def listen() do
    # You can use print statements as follows for debugging, they'll be visible when running tests.
    IO.puts("Logs from your program will appear here!")

    # Uncomment this block to pass the first stage
    #
    {:ok, socket} = :gen_tcp.listen(6379, [:binary, active: false, reuseaddr: true])

    serve(socket)
  end

  def serve(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn(fn -> answer(client) end)
    serve(socket)
  end

  def answer(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        get_resp(data) |> write_resp(client)
        answer(client)

      {:error, _} ->
        true
    end
  end

  defp write_resp(data, client) do
    :gen_tcp.send(client, data)
    IO.puts("Sent #{data}")
  end

  defp get_resp(_data) do
    simple_string("PONG")
  end

  defp simple_string(data) do
    "+#{data}\r\n"
  end
end
