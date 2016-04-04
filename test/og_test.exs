defmodule OgTest do
  use ExUnit.Case, async: :false
  require Og
  alias ExUnit.CaptureLog
  alias Og.TestSupport


  test "log/1 when capture level = :debug" do
    actual = CaptureLog.capture_log(
      [ level: :debug ],
      fn() -> Og.log("test") end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    assert(as_expected? ==  :true)
  end


  test "log/1 when capture level = :warn" do
    actual = CaptureLog.capture_log(
      [ level: :warn ],
      fn() -> Og.log("test") end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    refute(as_expected? ==  :true)
  end


  test "log/2 when capture level = :debug and log_level = :warn" do
    actual = CaptureLog.capture_log(
      [ level: :debug ],
      fn() -> Og.log("test", :warn) end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    assert(as_expected? ==  :true)
  end


  test "log/2 when capture level = :warn and log_level = :warn" do
    actual = CaptureLog.capture_log(
      [ level: :warn ],
      fn() -> Og.log("test", :warn) end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    assert(as_expected? ==  :true)
  end


  test "log/2 when capture level = :error and log_level = :warn" do
    actual = CaptureLog.capture_log(
      [ level: :error ],
      fn() -> Og.log("test", :warn) end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    refute(as_expected? ==  :true)
  end


  test "log/2 when passing the __ENV__ variable" do
    actual =  TestSupport.env_test()
    as_expected? = Regex.match?(~r/test/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: env_test\/0/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? ==  :true)
  end


  test "log/3 when passing the __ENV__ variable and
          when capture level = :debug and log_level = :warn" do
    actual =  TestSupport.env_test(:debug, :warn)
    as_expected? = Regex.match?(~r/test/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: env_test\/2/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? ==  :true)
  end


  test "log/3 when passing the __ENV__ variable and
          when capture level = :warn and log_level = :warn" do
    actual =  TestSupport.env_test(:warn, :warn)
    as_expected? = Regex.match?(~r/test/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: env_test\/2/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? ==  :true)
  end


  test "log/3 when passing the __ENV__ variable and
          when capture level = :error and log_level = :warn" do
    actual =  TestSupport.env_test(:error, :warn)
    as_expected? = Regex.match?(~r/test/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: env_test\/2/, actual) &&
                              Regex.match?(~r/line: /, actual)
    refute(as_expected? ==  :true)
  end


  test "log_return/1 logs intermediate data in a pipeline of trasformations" do
    actual = TestSupport.env_test_log_return1()
    as_expected? = Regex.match?(~r/[first: "john"]/, actual)
    assert(as_expected? == :true)
  end


  test "log_return/2 logs intermediate data in a pipeline of trasformations" do
    actual = TestSupport.env_test_log_return2()
    as_expected? = Regex.match?(~r/[first: "john"]/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: env_test_log_return2\/0/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? == :true)
  end


  test "log_return/3 logs intermediate data in a pipeline of trasformations" do
    actual = TestSupport.env_test_log_return3()
    as_expected? = Regex.match?(~r/[first: "john"]/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: env_test_log_return3\/0/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? == :true)
  end


  test "log_return returns intermediate data unchanged in a pipeline of trasformations" do
    Logger.configure([level: :error]) # ignore logs for this test below log_level :error
    actual =
      %{first: "john", last: "doe"}
      |> Map.to_list()
      |> Enum.filter( &(&1 === {:first, "john"}))
      |> Og.log_return()
      |> List.last()
      |> Tuple.to_list()
      |> List.last()
      |> String.upcase()
    Logger.configure([level: :debug]) # change back the log_level
    expected = "JOHN"
    assert(actual ==expected)
  end


  test "context/1 logs the module, function and line of the caller" do
    actual = TestSupport.context_test1()
    as_expected? = Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: context_test1\/0/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? == :true)
  end


  test "context/2 logs the module, function and line of the caller" do
    actual = TestSupport.context_test2()
    as_expected? = Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: context_test2\/0/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? == :true)
  end


  test "conn_context/2 logs the module, function and line of the caller and
          the conn struct key-value pairs for the keys :method and :request_path" do
    actual = TestSupport.conn_context_test1()
    as_expected? = Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: conn_context_test1\/0/, actual) &&
                              Regex.match?(~r/line: /, actual) &&
                              Regex.match?(~r/conn details: { method: GET, request_path: \/test }/, actual)
    assert(as_expected? == :true)
  end


  test "conn_context/3 logs the module, function and line of the caller and
          the conn struct key-value pairs for the keys :method and :request_path" do
    actual = TestSupport.conn_context_test2()
    as_expected? = Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: conn_context_test2\/0/, actual) &&
                              Regex.match?(~r/line: /, actual) &&
                              Regex.match?(~r/conn details: { method: GET, request_path: \/test }/, actual)
    assert(as_expected? == :true)
  end


  test "conn_context/4 logs the module, function and line of the caller and
          the conn struct key-value pairs for the keys :method and :request_path" do
    actual = TestSupport.conn_context_test3()
    as_expected? = Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: conn_context_test3\/0/, actual) &&
                              Regex.match?(~r/line: /, actual) &&
                              Regex.match?(~r/conn details: { method: GET, req_headers: \[\], peer: {{127, 0, 0, 1}, 111317} }/, actual)
    assert(as_expected? == :true)
  end


end
