defmodule Mix.Tasks.Npricot.Build do
  @moduledoc "Builds the html pages from a markdown directory"
  @shortdoc "Generates HTML pages"
  
  @default_dir "./sample_repo"
  
  use Mix.Task
  
  @impl Mix.Task
  def run(args) when args == [] do
    list_files(@default_dir)
  end
  
  @impl Mix.Task
  def run(args) do
    [arg_dir | _] = args
    list_files(arg_dir)
  end
  
  defp list_files(dir) do
    dir
    |> Path.expand
    |> list_md
    |> IO.puts
  end
  
  defp list_md(path) do
    md_files = "#{path}/*.md"
    Path.wildcard(md_files)
  end
end