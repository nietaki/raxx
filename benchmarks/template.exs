defmodule Bench.Template do
  require EEx

  template = String.duplicate("foo<%= bar %>", 10)

  EEx.function_from_string(:defp, :phoenix_html, template, [:bar], engine: Phoenix.HTML.Engine)
  EEx.function_from_string(:defp, :eex, template, [:bar], engine: EEx.HTMLEngine)

  def run() do
    inputs = %{
      "safe" => "abcdefghijklmno",
      "unsafe" => [["", ["<>"]], "abcde<foo>fghij"]
    }

    Benchee.run(
      %{
        "eex" => &eex/1,
        "phoenix_html" => &phoenix_html/1
      },
      inputs: inputs
    )
  end
end

Bench.Template.run()
