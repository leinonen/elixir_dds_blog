defmodule DdsBlog do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(__MODULE__, [], function: :run)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DdsBlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def run do
    routes = [
      {"/", DdsBlog.Handler, []},
      {"/:filename", DdsBlog.Handler, []},
      {"/static/[...]", :cowboy_static, {:priv_dir, :dds_blog, "static_files"}}
    ]

    dispatch = :cowboy_router.compile([{:_, routes}])

    opts = [port: 8000]
    env = [dispatch: dispatch]

    {:ok, _pid} = :cowboy.start_http(:http, 100, opts, [env: env])
  end
end
