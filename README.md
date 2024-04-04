# Sonyflakex

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

Add `sonyflakex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sonyflakex, "~> 0.2.0"}
  ]
end
```

Then update your dependencies with the following command:

```
mix deps.get
```

## Usage

Add `Sonyflakex` as one of your application's root supervisor child in `application.ex`.

```elixir
defmodule MyApp do
  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      Sonyflakex,
      # other dependencies 
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

This configuration will register the default `Sonyflakex` GenServer using the module name and you can generate a new ID by using the following call.

```elixir
Sonyflakex.next_id()
```

## Limitations

Like the reference implementation in Go, the default `Sonyflakex` GenServer will pause the process execution for a few milliseconds in case the sequence number in the 10 ms windows overflows. This behaviour prevents the generation of duplicated IDs. However, if you need to generate more than 2^8 IDs in a 10 ms window of time, it can create a performance bottleneck for your system.

If you need to generate a higher volume of IDs in short periods of time, then you might need to run a pool of multiple `Sonyflakex` GenServers (each with a unique machine ID).

## Pending

- [ ] Callback to check machine ID is unique.

## License

The MIT License (MIT)

See [LICENSE](https://github.com/elciok/sonyflakex/blob/main/LICENSE) for details.
