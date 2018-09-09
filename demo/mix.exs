defmodule Demo.Mixfile do
  use Mix.Project

  def project do
    [
      app: :demo,
      version: "0.1.0",
      elixir: "~> 1.7.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {Demo.Application, []}]
  end

  defp deps do
    [
      {:ace, "~> 0.16.8"},
      {:raxx, path: "../", override: true},
      {:raxx_static, "~> 0.6.1"},
      {:jason, "~> 1.0.0"},
      {:exsync, "~> 0.2.3", only: :dev}
    ]
  end
end
