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
    {:ok, client} = :gen_tcp.accept(socket)

    serve(client)
  end

  defp serve(client) do
    client
    |> read_line()
    |> get_resp()
    |> write_resp(client)

    serve(client)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_resp(data, socket) do
    :gen_tcp.send(socket, data)
    IO.puts("Sent #{data}")
  end

  defp get_resp(_data) do
    simple_string("PONG")
  end

  defp simple_string(data) do
    "+#{data}\r\n"
  end
end
