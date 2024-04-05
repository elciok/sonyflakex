defmodule Sonyflakex do
  @external_resource "README.md"
  @moduledoc File.read!("README.md")

  use GenServer

  alias Sonyflakex.{State, Generator, Time}

  @doc """
  Starts GenServer process that generates
  Sonyflake IDs.

  Options:
    - start_time: UNIX timestamp used as starting point
        for other timestamps used to compose IDs
    - machine_id: Integer that identifies the machine
        generating IDs. It is also part of the ID
        so it should fit in 16 bits.
    - check_machine_id: Callback function to validate
        the uniqueness of the machine ID. If check_machine_id
        returns false, Sonyflakex process is not started. If
        check_machine_id is nil, no validation is done.

  Returns:
    - `{:ok, pid}`: In case process is started successfully, it returns a tuple containing an ID.
    - `{:error, error_detail}`: If the process can't be started due to invalid configuration options
      it will return an error tuple containing details about the validation error.

  An example of setting configuration options in an application:application:

  ```elixir
  defmodule MyApp do
    use Application

    @impl Application
    def start(_type, _args) do
      children = [
        {Sonyflakex, machine_id: 33, start_time: 1712269128},
        # other dependencies
      ]
      Supervisor.start_link(children, strategy: :one_for_one)
    end
  end
  ```

  """
  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(args \\ []) do
    GenServer.start_link(
      __MODULE__,
      args,
      name: __MODULE__
    )
  end

  @impl GenServer
  def init(opts) do
    State.new(opts)
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
