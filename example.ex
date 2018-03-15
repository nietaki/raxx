defmodule CORS do
  behaviour Raxx.CompactedMiddleware
  use Raxx.Logger, level: :info

  # Once body buffered
  def handle_request(request, next) do
    :timer.start
    request2 = request
    response = next.handle_request(request2)
    request2 = response
    :timer.stop
    Print timer
    response
  end

  request_id = Raxx.get_header(request, "x-request-id", UUID.uuid)
  Logger.metadata(request_id: request_id)
  super

  use Raxx.Server, middlewares: [
    CORS
    {Logger, level: :info}
  ]
  def really_init(opts) do

  end

  def init(config_state, runtime_opts) do
    {:ok, combined}
  end

  def intercept_request_headers(request = %{}, _) do
    {:cont, request, nil}
  end

  def intercept_response_headers(response, %{start: start}) do
    stop = :timer.now
    print(stop - start)
    response
  end
end

defmodule MyApp do
  use Raxx.SimpleMiddleware [
    &MyApp.middleware/1
  ]
end


defmodule MyApp.Auth do
  def authenticate(request) do

    BasicAuth.authenticate(request, username: "user", password: "password"),
  end
end
defmodule MyApp.Web do
  use Raxx.Server
  alias Raxx.BasicAuth

  def handle_request(%{path: ["public"]}, _) do
    {:ok, response(:ok)}
  end

  def handle_request(%{path: ["admin"]}, _) do
    with
      {:ok, user} <- MyApp.authenticate
      {:ok params} <- decode(request)
    do
      MyApp.Biz.do_the_stuff
      {:ok, response(:ok)}
    end
  end

  def handle_error(:basic_auth_denied) do
    BasicAuth.unauthorized(realm: "admin")
  end
end

defmodule MyApp do
  # use Raxx.BasicAuth, username: "user", password: "password"

  def handle_request(request, ) do
    user = BasicAuth.authenticate(request)

    do_1(user)
    do_2(user)
  end

end

defmodule MyApp do
  use Raxx.BasicAuth

  def handle_request(request, ) do
    user = BasicAuth.user(request)
  end

  @impl Raxx.BasicAuth
  def verify_credentials(username, password) do
    {:ok, :user}
  end
end
