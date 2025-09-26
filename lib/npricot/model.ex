defmodule Npricot.Model do
  @enforce_keys [:id, :title, :body]
  defstruct [:id, :file_path, :note_type, :title, :body, :links, :back_links, :ctime, :mtime]
  
  def build(filename, attrs, body) do
    date_modified = File.Stat.mtime
    date_created = File.Stat.ctime
    
    struct!(__MODULE__,
      [id: nil,
        file_path: filename,
        body: body,
        ctime: date_created, 
        mtime: date_modified,
      ] ++ Map.to_list(attrs))
  end
end