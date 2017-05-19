defmodule Og.Mixfile do
  use Mix.Project
  @version "1.1"

  def project do
    [
     app: :og,
     name: "Óg",
     version: @version,
     elixir: ">= 1.2.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     source_url: "https://github.com/stephenmoloney/og",
     description: "Og is a small collection of debugging functions for use during development.",
     package: package(),
     deps: deps(),
     docs: [
       main: "Og",
       extra_section: ""
     ]
    ]
  end

  def application do
    [applications: [:logger, :apex]]
  end

  def deps() do
    [
      {:apex,  "~> 1.0"},
      {:secure_log_formatter, "~> 1.0"},
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
