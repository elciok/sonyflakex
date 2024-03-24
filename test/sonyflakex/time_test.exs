defmodule Sonyflakex.TimeTest do
  use ExUnit.Case, async: true
  doctest Sonyflakex.Time

  alias Sonyflakex.Time

  test "convert date time to timestamp with 10ms as base unit" do
    {:ok, time, _} = DateTime.from_iso8601("2020-10-01T00:00:01.020777Z")
    assert Time.to_sonyflake_time(time) == 160_151_040_102
  end

  test "compute difference of current time to start time in 10 ms units" do
    start_time = 200

    utc_now = fn ->
      {:ok, utc_now_datetime} = DateTime.from_unix(8_000, :millisecond)
      utc_now_datetime
    end

    assert Time.current_elapsed_time(start_time, utc_now) == 600
  end

  describe "time_until_next_timestamp/3" do
    test "compute milliseconds to sleep from current time until next unit of 10 ms after current elapsed time" do
      assert Time.time_until_next_timestamp(0, 120, 1000) == 210
    end

    test "returns zero if next elapsed time happens before current time" do
      assert Time.time_until_next_timestamp(1, 10, 1000) == 0
    end
  end
end
