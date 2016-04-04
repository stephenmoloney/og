defmodule Og.TestSupport do
  use Plug.Test
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


  def context_test1() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        Og.context(__ENV__)
      end
    )
  end


  def context_test2() do
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        Og.context(__ENV__, :info)
      end
    )
  end


  def conn_context_test1() do
    conn = Plug.Test.conn(:get, "/test", :nil)
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        Og.conn_context(conn, __ENV__)
      end
    )
  end


  def conn_context_test2() do
    conn = Plug.Test.conn(:get, "/test", :nil)
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        Og.conn_context(conn, __ENV__, :info)
      end
    )
  end



  def conn_context_test3() do
    conn = Plug.Test.conn(:get, "/test", :nil)
    CaptureLog.capture_log(
      [level: :debug],
      fn() ->
        Og.conn_context(conn, __ENV__, :warn, [:method, :req_headers, :peer])
      end
    )
  end


end
