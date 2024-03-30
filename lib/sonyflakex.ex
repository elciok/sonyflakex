defmodule Sonyflakex do
  @external_resource "README.md"
  @moduledoc File.read!("README.md")

  use GenServer

  alias Sonyflakex.{State, Generator, Time}

  def start_link(args) do
    GenServer.start_link(
      __MODULE__,
      args,
      name: __MODULE__
    )
  end

  @impl GenServer
  def init(_args) do
    {:ok, State.new()}
  end

  @impl GenServer
  def handle_call(:next_id, _from, state) do
    generate_next_id(state)
  end

  defp generate_next_id({start_time, elapsed_time, machine_id, _sequence} = state) do
    case Generator.next_id(state) do
      {:ok, new_id, new_state} ->
        {:reply, new_id, new_state}

      {:error, :overflow} ->
        # wait until next timestamp that will reset sequence
        current_time = DateTime.to_unix(DateTime.utc_now(), :millisecond)
        wait_ms = Time.time_until_next_timestamp(start_time, elapsed_time, current_time)
        if wait_ms > 0, do: Process.sleep(wait_ms)

        # try again after waking up
        State.create_state(start_time, elapsed_time + 1, machine_id, 0)
        |> generate_next_id()
    end
  end

  # public interface

  @doc ~S"""
  Get new ID from running Sonyflake process.

  Returns: New integer ID.
  """
  @spec next_id() :: State.sonyflake_id()
  def next_id() do
    GenServer.call(__MODULE__, :next_id)
  end
end
