defmodule Npricot do
  @external_resource "README.md"
  @moduledoc "README.md"
              |> File.read!()
              
  def call() do
    with true <- File.dir?(directory),
         {:ok, files} <- list_files(directory) do
      Enum.reduce(files, 0, fn file, size -> size + calculate_file_size(file) end)
      |> Kernel.div(length(files))
      |> IO.puts()
    end
  end

  @doc false
  def extract(_module, opts) do
    from = Keyword.fetch!(opts, :from)
    as = Keyword.fetch!(opts, :as)
    paths = from |> Path.wildcard()
    builder = Npricot.Model
    
    entries =
      paths
      |> Task.async_stream(
        fn path ->
          parsed_contents = parse_contents!(path, File.read!(path))
          build_entry(builder, path, parsed_contents, opts)
        end,
        timeout: :infinity
      )
      |> Enum.flat_map(fn
        {:ok, results} -> results
        _ -> []
      end)
      
      # Module.put_attribute(module, as, entries)
      
  end
  
  defp build_entry(builder, path, {_attrs, _body} = parsed_contents, opts) do
    build_entry(builder, path, [parsed_contents], opts)
  end
  
  defp build_entry(builder, path, parsed_contents, opts)
       when is_list(parsed_contents) do
    Enum.map(parsed_contents, fn {attrs, body} ->
      extname = path |> Path.extname() |> String.downcase()
      body = convert_body(path, extname, body, opts)
      builder.build(path, attrs, body)
    end)
  end
  
  defp parse_contents!(path, contents) do
    case parse_contents(path, contents) do
      {:ok, attrs, body} ->
        {attrs, body}
    
      {:error, message} ->
        raise """
        #{message}
    
        Each entry must have a map with attributes, followed by --- and a body. For example:
    
            %{
              title: "Hello World"
            }
            ---
            Hello world!
    
        """
    end
  end
  
  defp parse_contents(path, contents) do
    case :binary.split(contents, ["\n---\n", "\r\n---\r\n"]) do
      [body] -> 
        {:ok, %{}, body}
      [code, body] ->
        case Code.eval_string(code, []) do
          {%{} = attrs, _} ->
            {:ok, attrs, body}
            
          {other, _} ->
            {:error,
              "expected attributes for #{inspect(path)} to return a map; got #{inspect(other)}"}
        end
    end
  end
  
  defp convert_body(_path, extname, body, _opts) when extname in [".md", ".markdown"] do
    MDEx.to_html!(body)
  end
  
  defp convert_body(_path, _extname, body, _opts) do
    body
  end
  
  defp list_files(directory) do
    case File.ls(directory) do
      {:ok, files} ->
      files =
          files
          |> Enum.map(&Path.join(directory, &1))
          |> Enum.reject(&File.dir?/1)
  
    {:ok, files}
  
      error ->
        error
    end
  end
  
  defp calculate_file_size(file) do
    file
    |> File.stat!()
    |> Map.get(:size)
  end
end
