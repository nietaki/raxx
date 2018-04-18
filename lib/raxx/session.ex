defmodule Raxx.Session do
  defmacro __using__(options) do
    {options, []} = Module.eval_quoted(__CALLER__, options)
    session_store = Keyword.get(options, :store, Raxx.Session.SignedCookie)

    # TODO no headers of the form `raxx.*` should be admissable from Ace
    defp extract_session(request, state) do
      case Raxx.Session.SignedCookie.extract(request, session_config(state)) do
        {:ok, session} ->
        # Need an update session step
          Raxx.set_header(request, "raxx.session", session)
        # New session
      end
    end

    defp session_config(state) do
      Map.get(state, :session_config)
    end
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(__env) do
    quote do
      defoverridable Raxx.Server

      @impl Raxx.Server
      def handle_head(head, config) do
        {id, head} = unquote(__MODULE__).ensure_request_id(head)

        Logger.metadata(request_id: id)
        super(head, config)
      end
    end
  end

end
