defmodule Sonyflakex.StateTest do
  use ExUnit.Case

  alias Sonyflakex.State

  test "generate id from current state" do
    state = {0, 0b11_0000_0000_0000_0000_0001, 0b1100_1100, 0b101}
    assert State.to_id(state) == 0b00000001100000000000000000001_00000101_0000000011001100
  end

  describe "increment_sequence/1" do
    test "increments sequence if it fits in 8 bits" do
      sequence = 0b1000_1100
      assert State.increment_sequence({0, 0, 0, sequence}) == {:ok, sequence + 1}
    end

    test "overflow error when incrementing sequence over 8 bits" do
      sequence = 0b1111_1111
      assert State.increment_sequence({0, 0, 0, sequence}) == {:error, :overflow}
    end
  end
end
