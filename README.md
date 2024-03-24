# Sonyflakex

**TODO: Add installation instructions**

**TODO: Configurattion options to set start_time and machine_id**

**TODO: Generate documentation**

**TODO: Submit to hex.pm**

Sonyflake is a distributed unique ID generator inspired by [Twitter's Snowflake](https://blog.twitter.com/2010/announcing-snowflake).  

This is an Elixir implementation of the original [sony/sonyflake](https://github.com/sony/sonyflake), which is written in Go.

Sonyflake focuses on lifetime and performance on many host/core environment.
So it has a different bit assignment from Snowflake.
A Sonyflake ID is composed of

    39 bits for time in units of 10 msec
     8 bits for a sequence number
    16 bits for a machine id

As a result, Sonyflake has the following advantages and disadvantages:

- The lifetime (174 years) is longer than that of Snowflake (69 years)
- It can work in more distributed machines (2^16) than Snowflake (2^10)
- It can generate 2^8 IDs per 10 msec at most in a single machine/thread (slower than Snowflake)

However, if you want more generation rate in a single host,
you can run multiple Sonyflake ID generators concurrently.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sonyflakex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sonyflakex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/sonyflakex>.

License
-------

The MIT License (MIT)

See [LICENSE](https://github.com/elciok/sonyflakex/blob/main/LICENSE) for details.
