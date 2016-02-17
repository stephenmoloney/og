defmodule Og.Mixfile do
  use Mix.Project

  def project do
    [
     app: :og,
     name: "Og",
     version: "0.0.2",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/stephenmoloney/og",
     description: "Og is a small collection of logger helper functions in elixir",
     package: package(),
     deps: [{:earmark, "~> 0.2.1", only: :dev},{:ex_doc,  "~> 0.11", only: :dev},{:plug,  "~> 1.0", only: :dev}]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Stephen Moloney"],
      links: %{ "GitHub" => "https://github.com/stephenmoloney/og"},
      files: ~w(lib mix.exs README* LICENSE* CHANGELOG* changelog*)
     }
  end

end
