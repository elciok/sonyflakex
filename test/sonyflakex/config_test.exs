defmodule Sonyflakex.ConfigTest do
  use ExUnit.Case, async: true
  doctest Sonyflakex.Config

  alias Sonyflakex.Config

  describe "set_default/3" do
    test "sets integer value from callback function return if option is not set" do
      {:ok, opts} = Config.set_default([age: 42], :size, fn -> 200 end)
      assert {:ok, 200} = Keyword.fetch(opts, :size)
    end

    test "doesn't change option value if option is set" do
      {:ok, opts} = Config.set_default([age: 42], :age, fn -> 200 end)
      assert {:ok, 42} = Keyword.fetch(opts, :age)
    end
  end

  describe "validate_is_integer/2" do
    test "returns ok if value is not set" do
      assert {:ok, []} = Config.validate_is_integer([], :size)
    end

    test "returns ok if value set is integer" do
      assert {:ok, [size: 170]} = Config.validate_is_integer([size: 170], :size)
    end

    test "returns error if value set is not integer" do
      assert {:error, {:non_integer, :size, :not_an_integer}} =
               Config.validate_is_integer([size: :not_an_integer], :size)
    end
  end

  describe "value_fits_in_bits/2" do
    test "checks input value fits input number of bits" do
      assert Config.value_fits_in_bits(1, 1) == true
      assert Config.value_fits_in_bits(2, 1) == false
      assert Config.value_fits_in_bits(2, 2) == true
      assert Config.value_fits_in_bits(0, 1) == true
      assert Config.value_fits_in_bits(0b10000000, 7) == false
      assert Config.value_fits_in_bits(0b10000000, 8) == true
    end
  end

  describe "validate_bit_option_length/3" do
    test "keeps option with input value if is valid" do
      {:ok, opts} = Config.validate_bit_option_length([age: 42], :age, 8)
      assert {:ok, 42} = Keyword.fetch(opts, :age)
    end

    test "indicates validation error if input integer value can't fit in the max number of bits" do
      {:error, which} = Config.validate_bit_option_length([age: 42], :age, 3)
      assert which == {:value_too_big, :age, 42}
    end
  end

  describe "validate_is_function/3" do
    test "returns ok if no option set" do
      {:ok, _opts} = Config.validate_is_function([age: 42], :check_function, 2)
    end

    test "returns ok if option is set with function reference with correct arity" do
      check_function = fn _, _ -> true end

      {:ok, opts} =
        Config.validate_is_function([check_function: check_function], :check_function, 2)

      assert {:ok, ^check_function} = Keyword.fetch(opts, :check_function)
    end

    test "returns error if option is set with function reference with wrong arity" do
      check_function = fn _, _ -> true end

      {:error, which} =
        Config.validate_is_function([check_function: check_function], :check_function, 100)

      assert which == {:wrong_function_arity, :check_function, check_function}
    end

    test "returns error if option set is not a function reference" do
      {:error, which} =
        Config.validate_is_function([check_function: 1234], :check_function, 1)

      assert which == {:non_function, :check_function, 1234}
    end
  end

  describe "validate_machine_id/3" do
    test "returns ok if check_machine_id option is not set" do
      {:ok, _opts} = Config.validate_machine_id([age: 42], :check_machine_id, :machine_id)
    end

    test "returns ok if check_machine_id(machine_id) returns true" do
      check_function = fn machine_id ->
        if machine_id == 1, do: true, else: false
      end

      {:ok, _opts} =
        Config.validate_machine_id(
          [check_machine_id: check_function, machine_id: 1],
          :check_machine_id,
          :machine_id
        )
    end

    test "returns error if check_machine_id(machine_id) returns true" do
      check_function = fn machine_id ->
        if machine_id == 1, do: true, else: false
      end

      {:error, which} =
        Config.validate_machine_id(
          [check_machine_id: check_function, machine_id: 2],
          :check_machine_id,
          :machine_id
        )

      assert which == {:machine_id_not_unique, 2}
    end
  end
end
