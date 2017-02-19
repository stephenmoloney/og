use Mix.Config
limiter1 = "===================    [$level]    ========================"
datetime = "|---$date $time"
metadata = "|---$metadata"
node = "|---$node"
msg = "|---message:"
limiter2 = "==================   [end $level]    ======================="


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
#  format: "#{limiter1}\n#{datetime}\n#{metadata}\n#{node}\n#{msg}\n\n$message\n\n#{limiter2}\n",
  metadata: [:module, :function, :line]

config :logger, :og,
  default_inspector: &Kernel.inspect/2,
#  default_inspector: &Apex.Format.format/2,
  kernel: [
    inspect_opts: [width: 70]
  ],
  apex: [
    opts: [numbers: :false, color: :false]
  ]