defmodule Sonyflakex.Time do
  @sonyflake_time_unit 10_000_000

  # computed as timestamp in unit of 10ms of 2014-09-01T00:00:00Z
  @default_epoch 140_952_960_000

  def to_sonyflake_time(datetime) do
    datetime
    |> DateTime.to_unix(:nanosecond)
    |> div(@sonyflake_time_unit)
  end

  def default_epoch(), do: @default_epoch

  def current_elapsed_time(start_time, utc_now \\ &DateTime.utc_now/0) do
    to_sonyflake_time(utc_now.()) - start_time
  end

  def time_until_next_timestamp(elapsed_time, current_time) do
    new_elapsed_time = elapsed_time + 1

    # number of ms to wait to get to new elapsed time
    (new_elapsed_time - current_time) * 10
  end
end
