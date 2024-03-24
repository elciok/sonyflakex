defmodule SonyflakexTest do
  use ExUnit.Case
  doctest Sonyflakex

  describe "next_id/0" do
    test "generates a new id" do
      {:ok, _pid} = Sonyflakex.start_link([])
      id = Sonyflakex.next_id()
      assert is_integer(id)
    end

    test "generates unique ids in strict ascending order" do
      num_ids = 5_000
      {:ok, _pid} = Sonyflakex.start_link([])

      ids = Enum.map(1..num_ids, fn _item -> Sonyflakex.next_id() end)

      assert num_ids == length(Enum.uniq(ids))

      assert is_ascending(ids)
    end
  end

  # helper function to check list order
  def is_ascending([]), do: true
  def is_ascending([_]), do: true
  def is_ascending([head1, head2 | tail]) do
    if head1 >= head2 do
      false
    else
      is_ascending([head2 | tail])
    end
  end
end
