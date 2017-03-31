defmodule OgTest do
  use ExUnit.Case, async: :false
  alias ExUnit.CaptureLog
  alias Og.TestSupport

  test "log/1 when capture level = :debug" do
    actual = CaptureLog.capture_log(
      [level: :debug],
      fn() -> Og.log("test", level: :info) end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    assert(as_expected? ==  :true)
  end

  test "log/1 when capture level = :warn" do
    actual = CaptureLog.capture_log(
      [level: :warn],
      fn() -> Og.log("test") end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    refute(as_expected? ==  :true)
  end

  test "log/2 when capture level = :debug and log_level = :warn" do
    actual = CaptureLog.capture_log(
      [level: :debug],
      fn() -> Og.log("test", [level: :warn]) end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    assert(as_expected? ==  :true)
  end

  test "log/2 when capture level = :warn and log_level = :warn" do
    actual = CaptureLog.capture_log(
      [level: :warn],
      fn() -> Og.log("test", [level: :warn]) end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    assert(as_expected? ==  :true)
  end

  test "log/2 when capture level = :error and log_level = :warn" do
    actual = CaptureLog.capture_log(
      [level: :error],
      fn() -> Og.log("test", [level: :warn]) end
    )
    as_expected? = Regex.match?(~r/test/, actual)
    refute(as_expected? ==  :true)
  end

  test "log/2 when passing the __ENV__ variable" do
    actual =  TestSupport.log_test(:debug, :info)
    as_expected? = Regex.match?(~r/test/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: log_test\/2/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? ==  :true)
  end

  test "log/3 when passing the __ENV__ variable and
          when capture level = :debug and log_level = :warn" do
    actual =  TestSupport.log_test(:debug, :warn)
    as_expected? = Regex.match?(~r/test/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: log_test\/2/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? ==  :true)
  end

  test "log/3 when passing the __ENV__ variable and
          when capture level = :warn and log_level = :warn" do
    actual =  TestSupport.log_test(:warn, :warn)
    as_expected? = Regex.match?(~r/test/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: log_test\/2/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? ==  :true)
  end

  test "log/3 when passing the __ENV__ variable and
          when capture level = :error and log_level = :warn" do
    actual =  TestSupport.log_test(:error, :warn)
    as_expected? = Regex.match?(~r/test/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: log_test\/2/, actual) &&
                              Regex.match?(~r/line: /, actual)
    refute(as_expected? ==  :true)
  end

  test "log_r/1 logs intermediate data in a pipeline of trasformations" do
    actual = TestSupport.log_test_log_r1()
    as_expected? = Regex.match?(~r/[first: "john"]/, actual)
    assert(as_expected? == :true)
  end

  test "log_r/2 logs intermediate data in a pipeline of trasformations" do
    actual = TestSupport.log_test_log_r2()
    as_expected? = Regex.match?(~r/[first: "john"]/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: log_test_log_r2\/0/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? == :true)
  end

  test "log_r/3 logs intermediate data in a pipeline of trasformations" do
    actual = TestSupport.log_test_log_r3()
    as_expected? = Regex.match?(~r/[first: "john"]/, actual) &&
                              Regex.match?(~r/module: Elixir.Og.TestSupport/, actual) &&
                              Regex.match?(~r/function: log_test_log_r3\/0/, actual) &&
                              Regex.match?(~r/line: /, actual)
    assert(as_expected? == :true)
  end

  test "log_r returns intermediate data unchanged in a pipeline of trasformations" do
    Logger.configure([level: :error]) # ignore logs for this test below log_level :error
    actual =
      %{first: "john", last: "doe"}
      |> Map.to_list()
      |> Enum.filter( &(&1 === {:first, "john"}))
      |> Og.log_r()
      |> List.last()
      |> Tuple.to_list()
      |> List.last()
      |> String.upcase()
    Logger.configure([level: :debug]) # change back the log_level
    expected = "JOHN"
    assert(actual ==expected)
  end

  # The expected output should not be printed since the `:compile_time_purge_level` is set to `:info`
  test "compile_time_purge_level works as expected - :debug" do
    actual = TestSupport.compile_purge_test(:debug)
    as_expected? = Regex.match?(~r/test/, actual)
    refute(as_expected? == :true)
  end

  # The expected output should be printed since the `:compile_time_purge_level` is set to `:info`
  test "compile_time_purge_level works as expected - :info" do
    actual = TestSupport.compile_purge_test(:info)
    as_expected? = Regex.match?(~r/test/, actual)
    assert(as_expected? == :true)
  end



end
