defmodule Dragonfly.FlyBackendTest do
  use ExUnit.Case, async: false

  alias Dragonfly.{Runner, FlyBackend}

  setup do
    Application.delete_env(:dragonfly, :backend)
    Application.delete_env(:dragonfly, FlyBackend)
  end

  test "explicit backend" do
    assert_raise ArgumentError, ~r/missing :token/, fn ->
      Runner.new(backend: {FlyBackend, []})
    end

    assert_raise ArgumentError, ~r/missing :image/, fn ->
      Runner.new(backend: {FlyBackend, token: "123"})
    end

    assert_raise ArgumentError, ~r/missing :app/, fn ->
      Runner.new(backend: {FlyBackend, token: "123", image: "img"})
    end

    assert_raise ArgumentError, ~r/missing :app/, fn ->
      Runner.new(backend: {FlyBackend, token: "123", image: "img"})
    end

    assert Runner.new(backend: {FlyBackend, token: "123", image: "img", app: "app"})
  end

  test "extended opts" do
    opts = [
      token: "123",
      image: "img",
      app: "app",
      host: "foo.local",
      env: %{one: 1},
      size: "performance-1x"
    ]

    runner = Runner.new(backend: {FlyBackend, opts})
    assert {:ok, init} = runner.backend_init
    assert init.host == "foo.local"
    assert init.size == "performance-1x"

    assert %{
             one: 1,
             DRAGONFLY_PARENT: _,
             PHX_SERVER: "false"
           } = init.env
  end

  test "global configured backend" do
    assert_raise ArgumentError, ~r/missing :token/, fn ->
      Application.put_env(:dragonfly, :backend, Dragonfly.FlyBackend)
      Application.put_env(:dragonfly, Dragonfly.FlyBackend, [])
      Runner.new()
    end

    assert_raise ArgumentError, ~r/missing :image/, fn ->
      Application.put_env(:dragonfly, :backend, Dragonfly.FlyBackend)
      Application.put_env(:dragonfly, Dragonfly.FlyBackend, token: "123")
      Runner.new()
    end

    assert_raise ArgumentError, ~r/missing :app/, fn ->
      Application.put_env(:dragonfly, :backend, Dragonfly.FlyBackend)
      Application.put_env(:dragonfly, Dragonfly.FlyBackend, token: "123", image: "img")
      Runner.new()
    end

    Application.put_env(:dragonfly, :backend, Dragonfly.FlyBackend)
    Application.put_env(:dragonfly, Dragonfly.FlyBackend, token: "123", image: "img", app: "app")

    assert Runner.new()
  end
end