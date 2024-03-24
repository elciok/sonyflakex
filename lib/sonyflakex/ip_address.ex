defmodule Sonyflakex.IpAddress do
  def is_private_ipv4({10, _, _, _} = _ip), do: true
  def is_private_ipv4({192, 168, _, _} = _ip), do: true
  def is_private_ipv4({172, x, _, _} = _ip) when x >= 16 and x < 32, do: true
  def is_private_ipv4(_ip), do: false

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

  def lower_16_bit_ip_address({_, _, b3, b4} = _ip) do
    <<result::integer-size(2)-unit(8)>> = <<b3::8, b4::8>>
    result
  end
end
