defmodule Sonyflakex.Generator do
  import Sonyflakex.Time
  import Sonyflakex.State

  def next_id(
        {start_time, elapsed_time, machine_id, _sequence} = state,
        utc_now \\ &DateTime.utc_now/0
      ) do
    current_time = current_elapsed_time(start_time, utc_now)

    if elapsed_time < current_time do
      # moved to new timestamp => reset sequence
      new_state = create_state(start_time, current_time, machine_id, 0)
      {:ok, to_id(new_state), new_state}
    else
      case increment_sequence(state) do
        {:ok, new_sequence} ->
          # still in the same timestamp => increment sequence
          new_state = create_state(start_time, elapsed_time, machine_id, new_sequence)
          {:ok, to_id(new_state), new_state}

        {:error, :overflow} = error ->
          # sequence overflow
          error
      end
    end
  end
end
