use Mix.Config

config :logger,
  backends: [:console]

config :logger, :og,
  default_inspector: &Kernel.inspect/2