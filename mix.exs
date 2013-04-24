defmodule ManagedProcess.Mixfile do
  use Mix.Project

  def project do
    [ app: :managed_process,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:finalizer] ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [ { :finalizer, %r(.*), github: "meh/elixir-finalizer" } ]
  end
end
