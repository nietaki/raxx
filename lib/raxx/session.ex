defmodule Raxx.Session do
  # Assume session is under raxx.session otherwise will always need it configured

  defmodule Agent do
    def init(options) do
      {:ok, name} = Keyword.fetch(options, :name)
      {:ok, pid} = Agent.start_link(fn -> %{} end, name: name)
      pid
    end

    # This is decode
    def get(pid, session_id) do
      Agent.get(pid, fn state -> Map.get(session_id) end)
    end

    # session id is a pain to run between various calls
    # Have session id field in struct
    # put
    def encode() do
    end
  end

  defmodule MyApp.Session do
    def unpack do
    end

    def upgrade() do
    end

    def pack(term) do
      term
    end
  end

  defmacro __using__(options) do
    store_module = Keyword.get(options, :store_module, Raxx.Session.SignedCookie)
    # get cookie key

    quote do
      def init() do
        # pop all cookie options
      end

      def fetch(request, session) do
        case unquote(__MODULE__).fetch_cookie(request) do
          {:ok, cookie} ->
            case unquote(store_module).decode(cookie, session.store_config) do
              {:ok, saved_session} ->
                case unpack(saved_session) do
                  {:ok, session} ->
                    # Can wrap in single function
                    if safe?(request) do
                      {:ok, session}
                    else
                      protect_from_forgery(request, csrf_token(session))
                    end
                end
            end
        end
      end

      def replace(response, session, store, config) do
      end

      def expire() do
      end
    end
  end

  # Example update adds flash default is to add []
  # Example add username needs dropping
  # needs a third argument for cookie options like domain and lifetime.
  def fetch_session(request, config = %store{}) do
    case fetch_cookie(request, "raxx.session") do
      {:ok, cookie} ->
        case store.decode(cookie, config) do
        end
    end
  end

  defp fetch_cookie(request, key) do
    case Raxx.get_header(request, "cookie") do
      header when is_binary(header) ->
        cookies = Cookie.parse(header)

        case Map.fetch(cookies, key) do
          {:ok, cookie} ->
            {:ok, cookie}

          :error ->
            {:error, {:no_cookie, key}}
        end

      nil ->
        {:error, :no_cookies_sent}
    end
  end

  # TODO move to Raxx
  def safe?(%{method: method}) do
    Enum.member?([:GET, :HEAD], method)
  end
end
