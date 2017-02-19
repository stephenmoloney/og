defmodule Og.TestSupport do
  require Og
  alias ExUnit.CaptureLog
  @data "test"

  def env_test() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() -> Og.log(@data, __ENV__) end
    )
  end

  def env_test(capture_level, log_level) do
    CaptureLog.capture_log(
      [level: capture_level],
      fn() -> Og.log(@data, __ENV__, log_level) end
    )
  end


  def env_test_log_return1() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        map = %{first: "john", last: "doe"}
        Map.to_list(map)
        |> Enum.filter( &(&1 ==={:first, "john"}))
        |> Og.log_return()
        |> List.last()
        |> Tuple.to_list()
        |> List.last()
        |> String.upcase()
      end
    )
    #  [first: "john"]
  end


  def env_test_log_return2() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        map = %{first: "john", last: "doe"}
        Map.to_list(map)
        |> Enum.filter( &(&1 ==={:first, "john"}))
        |> Og.log_return(__ENV__)
        |> List.last()
        |> Tuple.to_list()
        |> List.last()
        |> String.upcase()
      end
    )
    #  module: ..., function: ..., line: ..., [first: "john"]
  end


  def env_test_log_return3() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        map = %{first: "john", last: "doe"}
        Map.to_list(map)
        |> Enum.filter( &(&1 ==={:first, "john"}))
        |> Og.log_return(__ENV__, :info)
        |> List.last()
        |> Tuple.to_list()
        |> List.last()
        |> String.upcase()
      end
    )
  end

end
