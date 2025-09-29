defmodule Npricot.FileSystem do
  @moduledoc """
  This module defines an interface for a virtual file system that can be plugged into Npricot.
  """
  
  alias Npricot.FileSystem
  
  # @spec new(keyword()) :: t()
  # def new(opts \\ []) do
  #   default_path =
  #     Keyword.get_lazy(opts, :default_path, fn ->
  #       File.cwd!() |> FileSystem.Utils.ensure_dir_path()
  #     end)
  # 
  #   FileSystem.Utils.assert_dir_path!(default_path)
  # 
  #   %__MODULE__{default_path: default_path}
  # end
  
  @doc """
  Returns the default directory path.
  
  This is similar to the current working directory in a regular file system.
  """
  def default_path() do
    FileSystem.Utils.default_dir()
  end
  
  @doc """
  Returns a list of files located in the given directory
  """
  def list(path \\ nil, recursive \\ false) do
    dir = if path do
      path
    else
      default_path()
    end
    
    case File.ls(dir) do
      {:ok, files} ->
        paths = Enum.map(files, fn name ->
          path = Path.join(dir, name)
          if File.dir?(path), do: path <> "/", else: path
        end)
        
        to_traverse = 
          if recursive do
            Enum.filter(paths, &File.dir?/1)
          else
            []
          end
          
        Enum.reduce(to_traverse, {:ok, paths}, fn path, result ->
          with {:ok, current_paths} <- result,
            {:ok, new_paths} <- list(path, recursive) do
              {:ok, current_paths ++ new_paths}
            end
        end)
      {:error, error} ->
        {:error, error}
    end
  end
  
  @doc """
  Creates the given directory unless it already exists.
  
  All necessary parent directories are created as well.
  """
  def create_dir(path) do
    File.mkdir(path)
  end
end