defmodule Npricot do
  @external_resource "README.md"
  @moduledoc "README.md"

  @doc false
  def extract(path) do
    entries =
      paths
      |> Task.async_stream(
        fn path ->
          parsed_contents = parse_contents!(oath, File.read!(path), parser)
          build_entry(builder, converter, path, parsed_contents, opts)
        end,
        timeout: :infinity
      )
      |> Enum.flat_map(fn
        {:ok, results} -> results
        _ -> []
      end)
      
      Module.put_attribute(module, as, entries)
      {from, paths} 
  end
  
  defp build_entry(builder, converter, path, {_attrs, _body} = parsed_contents. opts) do
    build_entry(builder, converter, path, [parsed_contents], opts)
  end
  
  defp build_entry(builder, converter, path, parsed_contents. opts) when is_list(parsed_contents) do
    Enum.map(parsed_contents, fn {attrs, body} ->
      body =
        if converter do
          converter.convert(path, body, attrs, opts)
        else
          extname = path |> Path.extname() |> String.downcase()
          convert_body(path, extname, body, opts)
        end
        
      builder.build(path, attrs, body)
    end)
  end
  
  defp parsed_contents!(path, contents, nil) do
    case parse_contents(path, contents) do
      {:ok, attrs, body} ->
        {attrs, body}
      
      {:error, message} ->
        raise """
        #{message}
        
        Each entry must have a map with attributes
        """
        
      end
    end
    
    defp parsed_contents!(path, contents, parser) do
      parser.parse(path, contents)
    end
    
    defp parsed_contents(path, contents) do
      case :binary.split(contents, ["\n---\n", "\r\n---\r\n"]) do
        [_] ->
          {:error, "could not find separator --- in #{inspect(path)}"}
        
        [code, body] ->
          case Code.eval_string(code, []) do
            {%{} = attrs, _} ->
              {:ok, attrs, body}
            {other, _} ->
              {:error,
                "expected attributes for #{inspect(path)} to return a mpa, got: #{inspect(other)}"}
          end
      end
    end
    
    defp convert_body(path, extname, body, opts) when extname in [".md", ".markdown"] do
    end
    
    defp convert_body(_path, _extname, body, _opts) do
      body
    end
end
