# Changelog

## v0.1.1

[changes]
- fix compiler warnings on newer elixir verson.
- Add pull request for `travis.yml`

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
