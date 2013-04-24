defmodule Process.Managed do
  @moduledoc """
  This module handles a managed process, to allow garbage collection of a
  processs when it's not referenced by anything.
  """

  @opaque t :: record

  defrecordp :process, pid: nil, reference: nil

  @doc """
  Returns the managed pid of a new process started by the application of `fun`.
  It behaves exactly the same as `Kernel.spawn/1`.
  """
  @spec spawn((() -> any)) :: t
  def spawn(fun) do
    pid = Process.spawn(fun)

    process(pid: pid, reference: Finalizer.define(fn ->
      Process.exit(pid, :shutdown)
    end))
  end

  @doc """
  Returns the managed pid of a new process started by the application of `fun`.

  It also accepts extra options, for the list of available options
  check http://www.erlang.org/doc/man/erlang.html#spawn_opt-2
  """
  @spec spawn((() -> any), Process.spawn_opts) :: t
  def spawn(fun, opts) do
    pid = Process.spawn(fun, opts)

    process(pid: pid, reference: Finalizer.define(fn ->
      Process.exit(pid, :shutdown)
    end))
  end

  @doc """
  Returns the managed pid of a new process started by the application of
  `module.function(args)`. The new process created will be placed in the system
  scheduler queue and be run some time later.

  It behaves exactly the same as the `Kernel.spawn/3` function.
  """
  @spec spawn(module, atom, [any]) :: t
  def spawn(mod, fun, args) do
    pid = Process.spawn(mod, fun, args)

    process(pid: pid, reference: Finalizer.define(fn ->
      Process.exit(pid, :shutdown)
    end))
  end

  @doc """
  Returns the managed pid of a new process started by the application of
  `module.function(args)`. The new process created will be placed in the system
  scheduler queue and be run some time later.

  It also accepts extra options, for the list of available options
  check http://www.erlang.org/doc/man/erlang.html#spawn_opt-4

  """
  @spec spawn(module, atom, [any], Process.spawn_opts) :: t
  def spawn(mod, fun, args, opts) do
    pid = Process.spawn(mod, fun, args, opts)

    process(pid: pid, reference: Finalizer.define(fn ->
      Process.exit(pid, :shutdown)
    end))
  end

  @doc """
  Returns the managed pid of a new process started by the application of `fun`.
  A link is created between the calling process and the new process,
  atomically.
  """
  @spec spawn_link((() -> any)) :: t
  def spawn_link(fun) do
    pid = Process.spawn_link(fun)

    process(pid: pid, reference: Finalizer.define(fn ->
      Process.exit(pid, :shutdown)
    end))
  end

  @doc """
  Returns the managed pid of a new process started by the application of
  `module.function(args)`. A link is created between the calling process and
  the new process, atomically. Otherwise works like spawn/3.
  """
  @spec spawn_link(module, atom, [any]) :: t
  def spawn_link(mod, fun, args) do
    pid = Process.spawn_link(mod, fun, args)

    process(pid: pid, reference: Finalizer.define(fn ->
      Process.exit(pid, :shutdown)
    end))
  end

  @doc """
  Returns the managed pid of a new process started by the application of `fun`
  and reference for a monitor created to the new process.
  """
  @spec spawn_monitor((() -> any)) :: t
  def spawn_monitor(fun) do
    pid = Process.spawn_monitor(fun)

    process(pid: pid, reference: Finalizer.define(fn ->
      Process.exit(pid, :shutdown)
    end))
  end

  @doc """
  A new managed process is started by the application of
  `module.function(args)` and the process is monitored at the same time.
  Returns the pid and a reference for the monitor. Otherwise works like
  spawn/3.
  """
  @spec spawn_monitor(module, atom, [any]) :: t
  def spawn_monitor(mod, fun, args) do
    pid = Process.spawn_monitor(mod, fun, args)

    process(pid: pid, reference: Finalizer.define(fn ->
      Process.exit(pid, :shutdown)
    end))
  end

  @doc """
  Returns true if the managed process exists and is alive, that is, is not
  exiting and has not exited. Otherwise, returns false.
  """
  @spec alive?(t) :: boolean
  def alive?(process(pid: pid)) do
    Process.alive?(pid)
  end

  @doc """
  Sends an exit signal with the given reason to the managed process.

  The following behavior apply if reason is any term except `:normal` or `:kill`:

  1) If pid is not trapping exits, pid itself will exist with the given reason;

  2) If pid is trapping exits, the exit signal is transformed into a message
     {'EXIT', from, reason} and delivered to the message queue of pid;

  3) If reason is the atom `:normal`, pid will not exit. If it is trapping exits,
     the exit signal is transformed into a message {'EXIT', from, :normal} and
     delivered to its message queue;

  4) If reason is the atom `:kill`, that is if `exit(pid, :kill)` is called, an
     untrappable exit signal is sent to pid which will unconditionally exit with
     exit reason `:killed`.

  ## Examples

      Process.Managed.exit(pid, :kill)

  """
  @spec exit(t, any) :: true
  def exit(process(pid: pid), reason) do
    Process.exit(pid, reason)
  end

  @typep process_flag :: :trap_exit | :error_handler | :min_heap_size |
                         :min_bin_vheap_size | :priority | :save_calls |
                         :sensitive

  @doc """
  Sets certain flags for the process which calls this function.

  Returns the old value of the flag.

  See http://www.erlang.org/doc/man/erlang.html#process_flag-2 for more info.
  """
  @spec flag(t, process_flag, term) :: term
  def flag(process(pid: pid), flag, value) do
    Process.flag(pid, flag, value)
  end

  @doc """
  Returns information about the managed process identified by pid.

  Use this only for debugging information.

  See http://www.erlang.org/doc/man/erlang.html#process_info-1 for more info.
  """
  @spec info(t) :: Keyword.t
  def info(process(pid: pid)) do
    Process.info(pid)
  end

  @doc """
  Returns information about the process identified by pid or undefined if the
  process is not alive.

  See http://www.erlang.org/doc/man/erlang.html#process_info-2 for more info.
  """
  @spec info(t, atom) :: { atom, term }
  def info(process(pid: pid), spec) do
    Process.info(pid, spec)
  end

  @doc """
  Creates a link between the calling process and another managed process, if
  there is not such a link already.

  See http://www.erlang.org/doc/man/erlang.html#link-1 for more info.
  """
  @spec link(t) :: true
  def link(process(pid: pid)) do
    Process.link(pid)
  end

  @doc """
  Associates the name with a managed process. name, which must be an atom, can
  be used instead of the pid / port identifier in the send operator (name <-
  message).

  See http://www.erlang.org/doc/man/erlang.html#register-2 for more info.
  """
  @spec register(t, atom) :: true
  def register(process(pid: pid), name) do
    Process.register(pid, name)
  end

  @doc """
  Removes the link, if there is one, between the calling process and the
  managed process. Returns true and does not fail, even if there is no link or
  `id` does not exist

  See http://www.erlang.org/doc/man/erlang.html#unlink-1 for more info.
  """
  @spec unlink(t) :: true
  def unlink(process(pid: pid)) do
    Process.unlink(pid)
  end

  @doc """
  Return the pid of the managed process, keep in mind the process won't know if
  you're using the raw pid and garbage collect it anyway, what's important is
  the managed process, not its pid.
  """
  @spec to_pid(t) :: pid
  def to_pid(process(pid: pid)) do
    pid
  end

  def pid <- msg when is_record pid, Process.Managed do
    Kernel.<-(pid.to_pid, msg)
  end

  def pid <- msg do
    Kernel.<-(pid, msg)
  end

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [<-: 2]
      import Process.Managed, only: [<-: 2]
    end
  end
end
