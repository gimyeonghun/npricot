defmodule Npricot.FileSystem.File do
  @moduledoc """
  A file points to a specific location in the given file system.
  
  This module provides a number of high-level functions similar to
  the `File` and `Path` core module. Many functions simply delegate
  the work to the underlying file system.
  """
  defstruct [:file_system_id, :path, :origin_pid]
  
  alias Npricot.FileSystem
  
  @doc """
  Builds a new file struct
  """
  def new(id, path \\ nil) do
    default_path = FileSystem.default_path()
    
    path = if path do
      path
    else
      default_path
    end
    
    %__MODULE__{
      file_system_id: id,
      path: path,
      origin_pid: self()
    }
  end
  
  @doc """
  Checks if two files are equal
  
  Comparing files with `Kernel.==/2` may result in false negatives, because the structs hold additional information
  """
  def equal?(file1, file2) do
    file1.path == file2.path and
      file1.file_system_id == file2.file_system_id
  end
  
  @doc """
  Checks if the given file is a directory.
  
  Note: this check relies solely on the file path
  """
  def dir?(file) do
    File.dir?(file.path)
  end
  
  @doc """
  Checks if the given file is a regular file.
  
  Note: this check relies solely on the file path.
  """
  def regular?(file) do
    File.regular?(file)
  end
  
  @doc """
  Returns file name.
  """
  def name(file) do
    Path.basename(file.path)
  end
  
  @doc """
  Returns binary content of the given file.
  """
  def read(file) do
    File.read(file)
  end
  
  @doc """
  Writes the given binary content to the given file
  """
  def write(file, content) do
    File.write(file, content)
  end
  
  @doc """
  Removes the given file.
  """
  def remove(file) do
    File.rm(file)
  end
  
  @doc """
  Copies the given file or directory contents.
  """
  def copy(source, destination) do
    File.cp(source, destination)
  end
  
  @doc """
  Renames the given file.
  """
  def rename(source, destination) do
    File.rename(source, destination)
  end
end
