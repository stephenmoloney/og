use Mix.Config

config :logger,
  backends: [:console],
  level: :debug,
  format: "\n$date $time [$level] $metadata$message"

if Mix.env == :test do
  config :logger,
    backends: [:console],
    compile_time_purge_level: :debug
end
