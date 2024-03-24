defmodule Sonyflakex.State do
  import Bitwise
  import Sonyflakex.Time
  import Sonyflakex.IpAddress

  @bits_time 39
  @bits_sequence 8
  @bits_machine_id 16

  @mask_sequence (1 <<< @bits_sequence) - 1

  def new() do
    # TODO: allow user to customize start_time, machine_id and checking machine_id uniqueness
    start_time = default_epoch()
    machine_id = lower_16_bit_ip_address(first_private_ipv4())
    sequence = (1 <<< @bits_sequence) - 1
    create_state(start_time, 0, machine_id, sequence)
  end

  def create_state(start_time, elapsed_time, machine_id, sequence), do: {start_time, elapsed_time, machine_id, sequence}

  def to_id({_start_time, elapsed_time, machine_id, sequence} = _state) do
    concatenated = <<elapsed_time::size(@bits_time), sequence::size(@bits_sequence), machine_id::size(@bits_machine_id)>>
    <<result::integer-size(63)>> = concatenated
    result
  end

  def increment_sequence({_start_time, _elapsed_time, _machine_id, sequence} = _state) do
    new_sequence = sequence + 1 &&& @mask_sequence
    if new_sequence == 0 do
      {:error, :overflow}
    else
      {:ok, new_sequence}
    end
  end
end
