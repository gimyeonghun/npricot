defmodule Npricot.FileSystem.Utils do
  @doc """
  The working directory
  """
  def default_dir() do
    default = "./sample_repo"
    Path.expand(default)
  end
end