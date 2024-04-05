defmodule Sonyflakex.MixProject do
  use Mix.Project

  @source_url "https://github.com/elciok/sonyflakex"
  @version "0.3.0"

  def project do
    [
      app: :sonyflakex,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Sonyflakex",
      source_url: @source_url
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31.2", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description() do
    "Distributed unique ID generator inspired by Twitter's Snowflake, based on Sonyflake's original implementation in Go."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
