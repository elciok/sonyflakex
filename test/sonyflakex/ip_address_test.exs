defmodule Sonyflakex.IpAddressTest do
  use ExUnit.Case

  alias Sonyflakex.IpAddress

  test "checks IP address is a private network IP v4 address" do
    assert IpAddress.is_private_ipv4({192, 168, 0, 19})
    assert IpAddress.is_private_ipv4({10, 1, 10, 1})
    assert IpAddress.is_private_ipv4({172, 17, 20, 101})
    refute IpAddress.is_private_ipv4({85, 31, 230, 83})
    refute IpAddress.is_private_ipv4(:anything)
  end

  test "returns first private IP address" do
    mock_list_ips = fn ->
      {:ok, [
          {{127,0, 0, 1}, {}, {}},
          {{225,16, 10, 17}, {}, {}},
          {{192,168, 0, 19}, {}, {}},
          {{10,3, 6, 2}, {}, {}},
        ]
      }
    end

    assert IpAddress.first_private_ipv4(mock_list_ips) == {192, 168, 0, 19}
  end

  test "returns lower 16 bits from IP address" do
    assert IpAddress.lower_16_bit_ip_address({192, 168, 0b10100, 0b1011}) == 0b1010000001011
  end
end
