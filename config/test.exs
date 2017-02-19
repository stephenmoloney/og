use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :debug

config :logger, :og,
  default_inspector: &Kernel.inspect/2
