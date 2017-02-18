defmodule Og.Mixfile do
  use Mix.Project
  @version "0.2.0"

  def project do
    [
     app: :og,
     name: "Óg",
     version: @version,
     elixir: "~> 1.1 or ~> 1.2 or ~> 1.3 or ~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     source_url: "https://github.com/stephenmoloney/og",
     description: "Og is a small collection of logger and debugging helper functions in elixir.",
     package: package(),
     deps: deps(),
     docs: [
       main: "Og",
       extra_section: ""
     ]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  def deps() do
    [
      {:plug,  "~> 1.0", only: [:dev, :test]},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc,  "~> 0.14", only: :dev}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Stephen Moloney"],
      links: %{ "GitHub" => "https://github.com/stephenmoloney/og"},
      files: ~w(lib mix.exs README* LICENSE* CHANGELOG*)
     }
  end


  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

end
