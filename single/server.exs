defmodule Server do
  use Ace.HTTP.Service, port: 8080, cleartext: true

  def handle_request(_request, _state) do
    response(:ok)
    |> set_body("Hello, World!")
  end
end

Server.start_link([])
