defmodule Dragonfly.Pool.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    dynamic_sup = Module.concat(name, "DynamicSup")
    task_sup = Module.concat(name, "TaskSup")
    pool_opts = Keyword.merge(opts, dynamic_sup: dynamic_sup, task_sup: task_sup)

    children =
      [
        {DynamicSupervisor, name: dynamic_sup, strategy: :one_for_one},
        {Task.Supervisor, name: task_sup},
        {Dragonfly.Pool, pool_opts},
      ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end