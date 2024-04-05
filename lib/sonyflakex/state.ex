defmodule Sonyflakex.State do
  @moduledoc """
  Handles internal state data.
  """

  import Bitwise
  import Sonyflakex.Time
  import Sonyflakex.IpAddress

  alias Sonyflakex.Config

  @bits_time 39
  @bits_sequence 8
  @bits_machine_id 16

  @mask_sequence (1 <<< @bits_sequence) - 1

  @option_start_time :start_time
  @option_machine_id :machine_id
  @option_check_machine_id :check_machine_id

  @typedoc """
  Represents internal ID generator state used to compute the next ID.

  Tuple composed by (in order):
    1. *start_time*: Timestamp used as relative starting point relative to
      elapsed time used in generated IDs.
    2. *elapsed_time*: Timestamp in 10 ms unit of how much time has passed
      since start_time.
    3. *machine_id*: Value used to uniquely identify each machine generating IDs.
    4. *sequence*: Number incremented for IDs generated in the same 10 ms time window.
  """
  @type t :: {non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()}

  @typedoc """
  ID generated by Sonyflake
  """
  @type sonyflake_id() :: non_neg_integer()

  @doc ~S"""
  Initializes ID generator state.

  This method should be used by clients to create the initial state for
  the ID generator with the following configuration.

    Options (all optional):
    - start_time: UNIX timestamp used as starting point
        for other timestamps used to compose IDs
    - machine_id: Integer that identifies the machine
        generating IDs. It is also part of the ID
        so it should fit in 16 bits.
    - check_machine_id: Callback function to validate
        the uniqueness of the machine ID. If check_machine_id
        returns false, Sonyflakex process is not started. If
        check_machine_id is nil, no validation is done.

  When not set, these will be the ddefault values for options
  used by the Sonyflake generator:
    - start_time: '2014-09-01T00:00:00Z'.
    - machine_id: Lower 16 bits of one of the machine's private
    IP addresses. If you run multiple generators in the same
    machine this field will be set to the same value and duplicated
    IDs might be generated.
    - check_machine_id: `nil`
  """
  @spec new(keyword()) :: {:ok, t()} | {:error, any()}
  def new(opts) do
    case validate_opts(opts) do
      {:ok, opts} ->
        start_time = Keyword.fetch!(opts, @option_start_time)
        machine_id = Keyword.fetch!(opts, @option_machine_id)
        sequence = (1 <<< @bits_sequence) - 1
        {:ok, create_state(start_time, 0, machine_id, sequence)}

      error ->
        error
    end
  end

  defp validate_opts(opts) do
    with {:ok, opts} <- Config.set_default(opts, @option_start_time, &default_epoch/0),
         {:ok, opts} <- Config.validate_is_integer(opts, @option_start_time),
         {:ok, opts} <-
           Config.set_default(opts, @option_machine_id, fn ->
             lower_16_bit_ip_address(first_private_ipv4())
           end),
         {:ok, opts} <- Config.validate_is_integer(opts, @option_machine_id),
         {:ok, opts} <-
           Config.validate_bit_option_length(opts, @option_machine_id, @bits_machine_id),
         {:ok, opts} <- Config.validate_is_function(opts, @option_check_machine_id, 1),
         {:ok, opts} <-
           Config.validate_machine_id(opts, @option_check_machine_id, @option_machine_id) do
      {:ok, opts}
    end
  end

  @doc ~S"""
  Creates state tuple used internally by Sonyflakex.

  ## Examples

      iex> Sonyflakex.State.create_state(1, 2, 3, 4)
      {1, 2, 3, 4}

  """
  @spec create_state(non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()) ::
          t()
  def create_state(start_time, elapsed_time, machine_id, sequence),
    do: {start_time, elapsed_time, machine_id, sequence}

  @doc ~S"""
  Converts internal state to integer ID.

  ## Examples

      iex> Sonyflakex.State.to_id({1, 2, 3, 4})
      33816579

  """
  @spec to_id(t()) :: sonyflake_id()
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
  @spec increment_sequence(t()) ::
          {:error, :overflow} | {:ok, non_neg_integer()}
  def increment_sequence({_start_time, _elapsed_time, _machine_id, sequence} = _state) do
    new_sequence = sequence + 1 &&& @mask_sequence

    if new_sequence == 0 do
      {:error, :overflow}
    else
      {:ok, new_sequence}
    end
  end
end
