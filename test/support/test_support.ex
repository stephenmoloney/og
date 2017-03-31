defmodule Og.TestSupport do
  alias ExUnit.CaptureLog
  @data "test"


  def log_test(capture_level, log_level) do
    CaptureLog.capture_log(
      [level: capture_level],
      fn() -> Og.log(@data, env: __ENV__, level: log_level) end
    )
  end

  def log_test_log_r1() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        map = %{first: "john", last: "doe"}
        Map.to_list(map)
        |> Enum.filter( &(&1 ==={:first, "john"}))
        |> Og.log_r(level: :info)
        |> List.last()
        |> Tuple.to_list()
        |> List.last()
        |> String.upcase()
      end
    )
    #  [first: "john"]
  end


  def log_test_log_r2() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        map = %{first: "john", last: "doe"}
        Map.to_list(map)
        |> Enum.filter( &(&1 ==={:first, "john"}))
        |> Og.log_r(env: __ENV__, level: :info)
        |> List.last()
        |> Tuple.to_list()
        |> List.last()
        |> String.upcase()
      end
    )
    #  module: ..., function: ..., line: ..., [first: "john"]
  end


  def log_test_log_r3() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        map = %{first: "john", last: "doe"}
        Map.to_list(map)
        |> Enum.filter( &(&1 ==={:first, "john"}))
        |> Og.log_r(env: __ENV__, level: :info)
        |> List.last()
        |> Tuple.to_list()
        |> List.last()
        |> String.upcase()
      end
    )
  end

  def compile_purge_test(:debug) do
    CaptureLog.capture_log(
      [level: :debug],
      fn() -> Og.log(@data, level: :debug) end
    )
  end

  def compile_purge_test(:info) do
    CaptureLog.capture_log(
      [level: :debug],
      fn() -> Og.log(@data, level: :info) end
    )
  end

end