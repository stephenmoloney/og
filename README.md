# Óg
Óg is a small collection of logger helper functions in elixir.


## Installation

Add óg to your list of dependencies in `mix.exs`:
    
    def deps, do: [{:og, "~> 0.0.5"}]


## Project Features 
- [log/3](http://hexdocs.pm/og/Og.html#log/3) inspects the data passed and then calls functions in the [Logger module](https://github.com/elixir-lang/elixir/blob/master/lib/logger/lib/logger.ex) 
- [log_return/3](http://hexdocs.pm/og/Og.html#log_return/3) inspects and logs the data, then returns the original data in a pipeline of functions.
- [context/3](http://hexdocs.pm/og/Og.html#context/3) to get the current module, function and line from the caller.
- [context_conn/5](http://hexdocs.pm/og/Og.html#conn_context/5) to get the current module, function and line where it is called along with some conn struct details. 
- All functions should obey the :compile_time_purge_level argument set in the config.exs file for Logger in the application.


## Example Usage

### Og.log/3

    Og.log(String.to_atom("test"))


### Og.log_return/3

    %{first: "john", last: "doe"}
    |> Map.to_list()
    |> Enum.filter( &(&1 === {:first, "john"}))
    |> Og.log_return()
    |> List.last()
    |> Tuple.to_list()
    |> List.last()
    |> Og.log_return(:warn)
    |> String.upcase()


### Og.context/3

    defmodule Test do
      def env_test() do
        Og.context(__ENV__, :info)
      end
    end
    
    Test.env_test()


### Og.context_conn/3

    defmodule Test do
      use Plug.Test
      def test() do
        conn = Plug.Test.conn(:get, "/test", :nil)
        Og.conn_context(conn, __ENV__, :debug)
      end
    end

    Test.test()


## Licence 

MIT
