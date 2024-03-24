defmodule Sonyflakex.GeneratorTest do
  use ExUnit.Case

  alias Sonyflakex.Generator
  alias Sonyflakex.State

  describe "next_id/2" do
    test "generate next ID when current timestamp is different from current timestamp" do
      state = State.create_state(0, 5, 2, 34)

      utc_now = fn ->
        {:ok, utc_now_datetime} = DateTime.from_unix(62, :millisecond)
        utc_now_datetime
      end

      assert {:ok, new_id, new_state} = Generator.next_id(state, utc_now)
      assert new_id == 100_663_298
      assert new_state == State.create_state(0, 6, 2, 0)
    end

    test "generate next ID when current timestamp is equal to current timestamp and sequence doesn't overflow" do
      state = State.create_state(0, 5, 2, 34)

      utc_now = fn ->
        {:ok, utc_now_datetime} = DateTime.from_unix(51, :millisecond)
        utc_now_datetime
      end

      assert {:ok, new_id, new_state} = Generator.next_id(state, utc_now)
      assert new_id == 86_179_842
      assert new_state == State.create_state(0, 5, 2, 35)
    end

    test "retturns error when current timestamp is equal to current timestamp and sequence overflows" do
      state = State.create_state(0, 5, 2, 255)

      utc_now = fn ->
        {:ok, utc_now_datetime} = DateTime.from_unix(55, :millisecond)
        utc_now_datetime
      end

      assert {:error, :overflow} = Generator.next_id(state, utc_now)
    end
  end
end
