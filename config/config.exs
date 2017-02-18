use Mix.Config

config :logger,
  backends: [:console],
  level: :debug,
  format: "\n$date $time [$level] $metadata$message"

if Mix.env == :test do
  config :og, inspect_opts: []
  config :logger,
    backends: [:console],
    compile_time_purge_level: :debug
end

if Mix.env == :prod do
  config :og, inspect_opts: []
end


if Mix.env == :dev do
  config :og, inspect_opts:
  [
    pretty: :true,
    width: 0,
    syntax_colors: [list: :green, atom: :blue]
  ]
end

