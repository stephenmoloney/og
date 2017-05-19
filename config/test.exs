use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :info

config :logger, :og,
  kernel_opts: [width: 70],
  apex_opts: [numbers: :false, color: :false],
  sanitize_by_default: :false,
  default_inspector: :kernel

config :logger,
  secure_log_formatter:
    [
      fields: [~r/\w*_token/, "credit_card", "password"],
      patterns: [
        ~r/#?(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})/,
        ~r/\d{3}-?\d{2}-?\d{4}/
      ],
      replacement: "[HIDDEN]"
    ]