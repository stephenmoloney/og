# Og
Og is a small collection of util logging functions in elixir.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add og to your list of dependencies in `mix.exs`:

        def deps do
          [{:og, "~> 0.0.1"}]
        end

  2. Ensure og is started before your application:

        def application do
          [applications: [:og]]
        end


## Project Features 
- [log/3]() inspects the data passed and then calls functions in the [Logger module](https://github.com/elixir-lang/elixir/blob/master/lib/logger/lib/logger.ex) 
- [log_return/3]() returns the original data in a pipeline of functions.
- [context/3]() to get the current module, function and line from the caller.
- [context_conn/5]() to get the current module, function and line where it is called along with some conn struct details. 



## Example Usage



## Licence 

MIT
