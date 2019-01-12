defmodule Doraemon.MixProject do
  use Mix.Project

  def project do
    [
      app: :doraemon,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Doraemon.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git"},
      {:giphy, "~> 0.1.1"},
      {:poison, "~> 3.1"}
    ]
  end
end
