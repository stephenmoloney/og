use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :info

config :logger, :og,
  kernel_opts: [width: 70],
  apex_opts: [numbers: :false, color: :false]