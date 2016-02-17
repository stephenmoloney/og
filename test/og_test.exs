defmodule OgTest do
  use ExUnit.Case
  doctest Og

  test "log_return returns the original data" do
    res =
      %{first: "john", last: "doe"}
      |> Map.to_list()
      |> Enum.filter( &(&1 === {:first, "john"}))
      |> Og.log_return()
      |> List.last()
      |> Tuple.to_list()
      |> List.last()
      |> Og.log_return()
      |> String.upcase()
    assert res == "JOHN"
  end

end


