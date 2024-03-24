defmodule Sonyflakex.State do
  @moduledoc """
  Handles internal state data.
  """

  import Bitwise
  import Sonyflakex.Time
  import Sonyflakex.IpAddress

  @bits_time 39
  @bits_sequence 8
  @bits_machine_id 16

  @mask_sequence (1 <<< @bits_sequence) - 1

  @doc ~S"""
  Initializes ID generator state.

  This method should be used by clients to create the initial state for
  the ID generator with the following default configuration:

    - *Start time*: '2014-09-01T00:00:00Z' is used when calculating
    elapsed time for timestamps in state.
    - *Machine ID*: Lower 16 bits of one of the machine's private
    IP addresses. If you run multiple generators in the same
    machine this field will be set to the same value and duplicated
    IDs might be generated.
  """
  def new() do
    # TODO: allow user to customize start_time, machine_id and checking machine_id uniqueness
    start_time = default_epoch()
    machine_id = lower_16_bit_ip_address(first_private_ipv4())
    sequence = (1 <<< @bits_sequence) - 1
    create_state(start_time, 0, machine_id, sequence)
  end

  @doc ~S"""
  Creates state tuple used internally by Sonyflakex.

  ## Examples

      iex> Sonyflakex.State.create_state(1, 2, 3, 4)
      {1, 2, 3, 4}

  """
  def create_state(start_time, elapsed_time, machine_id, sequence),
    do: {start_time, elapsed_time, machine_id, sequence}

  @doc ~S"""
  Converts internal state to integer ID.

  ## Examples

      iex> Sonyflakex.State.to_id({1, 2, 3, 4})
      33816579

  """
  def to_id({_start_time, elapsed_time, machine_id, sequence} = _state) do
    concatenated =
      <<elapsed_time::size(@bits_time), sequence::size(@bits_sequence),
        machine_id::size(@bits_machine_id)>>

    <<result::integer-size(63)>> = concatenated
    result
  end

  @doc ~S"""
  Increments current sequence number and checks for overflow.

  Returns:
    - `{:ok, new_sequence}`: if the sequence can be incremented
    its new value is returned as the second element of the response.

    - `{:error, :overflow}`: if incrementing the sequence would overflow
    the 8 bit field then it returns an error response.

  ## Examples

      iex> Sonyflakex.State.increment_sequence({1, 1, 1, 41})
      {:ok, 42}

      iex> Sonyflakex.State.increment_sequence({1, 1, 1, 255})
      {:error, :overflow}
  """
  def increment_sequence({_start_time, _elapsed_time, _machine_id, sequence} = _state) do
    new_sequence = sequence + 1 &&& @mask_sequence

    if new_sequence == 0 do
      {:error, :overflow}
    else
      {:ok, new_sequence}
    end
  end
end
