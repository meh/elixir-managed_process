Process.Managed - garbage collected processes for Elixir
========================================================
This small library implements garbage collected processes using the awesome NIF
hack.

Example
-------

```elixir
pid = fn ->
  use Process.Managed

  p = Process.Managed.spawn fn ->
    receive do
      _ -> IO.puts "received"
    end

    receive do
      _ -> IO.puts "received again"
    end
  end

  p <- 42

  IO.inspect Process.alive?(p.to_pid) # => true

  p.to_pid
end.()

IO.inspect Process.alive?(pid) # => false
```
