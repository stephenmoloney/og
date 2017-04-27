# Changelog

## v1.0.2

[changes]
- Add `:apex` to applications. Giving warnings as unstarted application otherwise.

## v1.0.1

[changes]
- Add support for the old form of writing the log functions. Eg `Og.log_r(%{"test" => "test"}, __ENV__, :error)`
as it was faster and quite convenient. These functions will be docless... to avoid cluttering the docs.


## v1.0.0

[security fix]
  - Remove dependency on `Code.eval_string/3`. A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107).
Hence only versions of `Og` >= 1.0.0 should be used.

[Breaking changes]
  - Major change to the api. As the number of arguments grew, the api became complex.
  The api is changing in favour of `log(data, opts)` or `log_r(data, opts)` to simplify the api.



## v0.2.4

***Security Warning: Versions of `Og` less than 1.0.0 are deprecated and should not be used***

- A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)
This was noticed upon reading a relatively new warning in the
[docs]((https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)).
- `Og` versions lower than `v1.0.0` are now deprecated and retired in favour of versions >= `1.0`.

[bug fix]

- Some of the `log_r`, `alog_r` and `klog_r` functions were pointing to the
 incorrect `log`, `alog` and `klog` functions causing the tuple `:ok` to be returned rather than
 the expected data.


## v0.2.3

***Security Warning: Versions of `Og` less than 1.0.0 are deprecated and should not be used***

- A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)
This was noticed upon reading a relatively new warning in the
[docs]((https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)).
- `Og` versions lower than `v1.0.0` are now deprecated and retired in favour of versions >= `1.0`.

[bug fix]

- Misnamed function during refactoring, `logr` -> `log_r`


## v0.2.2

***Security Warning: Versions of `Og` less than 1.0.0 are deprecated and should not be used***

- A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)
This was noticed upon reading a relatively new warning in the
[docs]((https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)).
- `Og` versions lower than `v1.0.0` are now deprecated and retired in favour of versions >= `1.0`.

[bug fix]

- Issue with the default options breaking some the `alog` functions.


## v0.2.1

***Security Warning: Versions of `Og` less than 1.0.0 are deprecated and should not be used***

- A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)
This was noticed upon reading a relatively new warning in the
[docs]((https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)).
- `Og` versions lower than `v1.0.0` are now deprecated and retired in favour of versions >= `1.0`.

[changes]

- Add some docs

## v0.2.0

***Security Warning: Versions of `Og` less than 1.0.0 are deprecated and should not be used***

- A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)
This was noticed upon reading a relatively new warning in the
[docs]((https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)).
- `Og` versions lower than `v1.0.0` are now deprecated and retired in favour of versions >= `1.0`.

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

***Security Warning: Versions of `Og` less than 1.0.0 are deprecated and should not be used***

- A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)
This was noticed upon reading a relatively new warning in the
[docs]((https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)).
- `Og` versions lower than `v1.0.0` are now deprecated and retired in favour of versions >= `1.0`.

- [Bug] `inspect_opts` was previously unused, rectify by passing into `Kernel.inspect/2`
- [Tests] - added tests which capture logs and ensure output as expected.
- [Docs] - add more complete documentation and specs.


## v0.0.6

***Security Warning: Versions of `Og` less than 1.0.0 are deprecated and should not be used***

- A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)
This was noticed upon reading a relatively new warning in the
[docs]((https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)).
- `Og` versions lower than `v1.0.0` are now deprecated and retired in favour of versions >= `1.0`.

- Add an option `__ENV__` argument to the `log` and `log_return` function so that
  the context (line, function, module) can optionally be logged when the function is called.
- Rewrite functions`log/1`, `log/2`, `log/3`, `log_return/1`, `log_return/2` and `log_return/3`


## v0.0.5

***Security Warning: Versions of `Og` less than 1.0.0 are deprecated and should not be used***

- A potential security issue exists with the use of
[Code.eval_string/3](https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)
This was noticed upon reading a relatively new warning in the
[docs]((https://github.com/elixir-lang/elixir/commit/f1daca5be78e6a466745ba2cdc66d9787c3cf47f#diff-da151e1c1d9b535259a2385407272c9eR107)).
- `Og` versions lower than `v1.0.0` are now deprecated and retired in favour of versions >= `1.0`.

- Docs: Add examples to readme.md file
- Docs: Add links to functions in hex docs.
- Bug Fix: add arguments log_level, inspect_opts to the log function on line 79.
