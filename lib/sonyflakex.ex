defmodule Sonyflakex do
  @moduledoc """
  Documentation for `Sonyflakex`.
  """

  use GenServer

  alias Sonyflakex.{State, Generator, Time}

  # @doc """
  # Hello world.

  # ## Examples

  #     iex> Sonyflakex.hello()
  #     :world

  # """
  # def hello do
  #   :world
  # end

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
        current_time = Time.current_elapsed_time(start_time)
        wait_ms = Time.time_until_next_timestamp(elapsed_time, current_time)
        if wait_ms > 0, do: Process.sleep(wait_ms)

        # try again after waking up
        State.create_state(start_time, elapsed_time + 1, machine_id, 0)
        |> generate_next_id()
    end
  end

  def next_id() do
    GenServer.call(__MODULE__, :next_id)
  end
end
