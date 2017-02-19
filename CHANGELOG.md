# Changelog


## v0.2.2

[bug fix]

- Issue with the default options breaking some the `alog` functions.


## v0.2.1

[changes]

- Add some docs

## v0.2.0

[changes]
- fix compiler warnings on newer elixir verson.
- Add pull request for `travis.yml`
- remove docs about `log/3`, `log/4` and so on. Add a lot of bulk to the api.
Users can read source code if those functions are needed.

[breaking changes]
- deprecate `context` and `conn_context` functions. Perhaps will create a separate
package for those.
- `log_return` is now renamed to `log_r` for brevity but api will continue to work for
`log_return` for now at least.

[enhancements]
- able to add `inspect_opts` to the config file so that they will be applied by default on
all logs. Example `config :og, inspect_opts: [syntax_colors: [atom: :blue]]`
- add an option to use [Apex](https://github.com/BjRo/apex) for the formatting. See `https://github.com/BjRo/apex`.
- add `klog` function for `Kernel.inspect/2` on data and `alog` function for `Apex.Format.format/2` on data.
- add `klog_r` function for `Kernel.inspect/2` on data and `alog_r` function for `Apex.Format.format/2` on data.
- new dependency on `Apex`.


## v0.1.0

- [Bug] `inspect_opts` was previously unused, rectify by passing into `Kernel.inspect/2`
- [Tests] - added tests which capture logs and ensure output as expected.
- [Docs] - add more complete documentation and specs.


## v0.0.6

- Add an option `__ENV__` argument to the `log` and `log_return` function so that
  the context (line, function, module) can optionally be logged when the function is called.
- Rewrite functions`log/1`, `log/2`, `log/3`, `log_return/1`, `log_return/2` and `log_return/3`


## v0.0.5

- Docs: Add examples to readme.md file
- Docs: Add links to functions in hex docs.
- Bug Fix: add arguments log_level, inspect_opts to the log function on line 79.
