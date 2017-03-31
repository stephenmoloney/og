use Mix.Config

config :logger,
  backends: [:console],
  level: :debug,
  compile_time_purge_level: :debug,
  compile_time_application: :my_app,
  truncate: (4096 * 8),
  utc_log: :false

config :logger, :console,
  level: :debug,
  format: "$time $metadata [$level] $message\n",
  metadata: [:module, :function, :line]

config :logger, :og,
  kernel_opts: [width: 70],
  apex_opts: [numbers: :false, color: :false]