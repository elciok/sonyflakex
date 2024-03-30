defmodule Sonyflakex.Time do
  @moduledoc """
  Helpers to handle timestamp calculations.
  """

  @sonyflake_time_unit 10_000_000

  # timestamp in unit of 10ms of 2014-09-01T00:00:00Z
  @default_epoch 140_952_960_000

  @typedoc """
  Timestamp in 10ms unit used in Sonyflake IDs.
  """
  @type sonyflake_timestamp() :: non_neg_integer()

  @typedoc """
  UNIX timestamp in ms.
  """
  @type unix_timestamp_ms() :: non_neg_integer()

  @doc ~S"""
  Converts DateTime to timestamp in unit of 10ms.

  ## Examples

      iex> Sonyflakex.Time.to_sonyflake_time(~U[2020-10-01 00:00:01.020777Z])
      160151040102

  """
  @spec to_sonyflake_time(DateTime.t()) :: sonyflake_timestamp()
  def to_sonyflake_time(datetime) do
    datetime
    |> DateTime.to_unix(:nanosecond)
    |> div(@sonyflake_time_unit)
  end

  @doc ~S"""
  Default timestamp used as start reference when computing elapsed time.

  ## Examples

      iex> Sonyflakex.Time.default_epoch()
      140952960000

  """
  @spec default_epoch() :: sonyflake_timestamp()
  def default_epoch(), do: @default_epoch

  @doc ~S"""
  Computes timestamp in unit of 10ms elapsed from start time.

  Args:
    - `start_time`: Timestamp in unit of 10 ms used as reference.
    - `utc_now`: (Optional) Function that returns current DateTime
    using the same contract as DateTime.utc_now/0. It is used to
    mock datetime generation in tests.
  """
  @spec current_elapsed_time(sonyflake_timestamp(), (-> DateTime.t())) ::
          sonyflake_timestamp()
  def current_elapsed_time(start_time, utc_now \\ &DateTime.utc_now/0) do
    to_sonyflake_time(utc_now.()) - start_time
  end

  @doc ~S"""
  Computed how many milliseconds to wait from current time until
  the next timestamp window from `elapsed_time`.

  It is used to pause the process and wait until the next timestamp
  windows to generate new IDs and avoid a sequence overflow.

  Args:
    - `start_time`: Timestamp in unit of 10ms used as base reference
    for timestamps.
    - `elapsed_time`: Timestamp in unit of 10ms to generate the
    next ID.
    - `current_time`: Current clock timestamp in ms.

  Returns: time in milliseconds until next elapsed time or zero
  if next elapsed time is in the past.

  ## Examples

      iex> Sonyflakex.Time.time_until_next_timestamp(0, 1, 15)
      5

  """
  @spec time_until_next_timestamp(
          sonyflake_timestamp(),
          sonyflake_timestamp(),
          unix_timestamp_ms()
        ) :: non_neg_integer()
  def time_until_next_timestamp(start_time, elapsed_time, current_time) do
    new_elapsed_time = elapsed_time + 1

    # number of ms to wait to get to new elapsed time
    result = (new_elapsed_time + start_time) * 10 - current_time

    if result > 0 do
      result
    else
      0
    end
  end
end
