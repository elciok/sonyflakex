defmodule Sonyflakex.IpAddress do
  @moduledoc """
  Helpers to handle IP address calculations.
  """

  @doc ~S"""
  Checks if tuple containing a IPv4 address
  is a private network address.

  Args:
    - `ip`: 4 item tuple containing the address octets.

  Returns: `true` if the address is used in private networks.

  ## Examples

      iex> Sonyflakex.IpAddress.is_private_ipv4({192, 168, 0, 90})
      true

  """
  def is_private_ipv4({10, _, _, _} = _ip), do: true
  def is_private_ipv4({192, 168, _, _} = _ip), do: true
  def is_private_ipv4({172, x, _, _} = _ip) when x >= 16 and x < 32, do: true
  def is_private_ipv4(_ip), do: false

  @doc ~S"""
  Returns one of the machine's private IPv4 addresses.

  Args:
    - `list_ips_func`: Function that returns IP addresses. Should follow the
    same contract as `:inet.getif/0`. Used in tests to mock getting addresses.

  ## Examples

      iex> Sonyflakex.IpAddress.lower_16_bit_ip_address({192, 168, 1, 90})
      346

  """

  def first_private_ipv4(list_ips_func \\ &:inet.getif/0) do
    {:ok, addresses} = list_ips_func.()

    addresses
    |> Enum.find(fn address ->
      address
      |> elem(0)
      |> is_private_ipv4()
    end)
    |> elem(0)
  end

  @doc ~S"""
  Extracts two lower octets as a 16 bit integer.

  Args:
    - `ip`: 4 item tuple containing the address octets.

  Returns: Two lower octets as an integer.

  ## Examples

      iex> Sonyflakex.IpAddress.lower_16_bit_ip_address({192, 168, 1, 90})
      346

  """
  def lower_16_bit_ip_address({_, _, b3, b4} = _ip) do
    <<result::integer-size(2)-unit(8)>> = <<b3::8, b4::8>>
    result
  end
end
