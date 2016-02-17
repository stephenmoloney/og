defmodule Og.Mixfile do
  use Mix.Project

  def project do
    [
     app: :og,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: [{:earmark, "~> 0.2.1", only: :dev},{:ex_doc,  "~> 0.11", only: :dev},{:plug,  "~> 1.0", only: :dev}]
    ]
  end

  def application do
    [applications: [:logger]]
  end

end
