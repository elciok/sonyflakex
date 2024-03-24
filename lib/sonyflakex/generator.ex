defmodule Sonyflakex.Generator do
  @moduledoc """
  Logic to generate new IDs.
  """

  import Sonyflakex.Time
  import Sonyflakex.State

  @doc ~S"""
  Returns new ID based on current state.

  Args:
    - `state`: Generator state.
    - `utc_now`: (Optional) Function that returns current datetime
    using the same contract as DateTime.utc_now/0. It is used to
    mock datetime generation in tests.

  Returns:
    - `{:ok, new_id, new_state}`: new ID value and state after generating the ID.

    - `{:error, :overflow}`: if incrementing the sequence would overflow
    the 8 bit field then it returns an error response.

  """
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
