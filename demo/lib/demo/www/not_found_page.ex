defmodule Demo.WWW.NotFoundPage do
  use Raxx.Server
  use Demo.WWW.Layout, arguments: [:value]

  @impl Raxx.Server
  def handle_request(_request, _state) do
    response(:not_found)
    |> render(0)
  end

  def foo(value) do
    5 / value
  end
end
