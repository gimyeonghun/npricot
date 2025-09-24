defmodule Npricot.Model do
  # @enforce_keys [:id, :author, :title, :body, :description, :tags, :date]
  defstruct [:id, :author, :title, :body, :description, :tags, :date]
  
  def build(filename, attrs, body) do
    struct!(__MODULE__, [id: nil, date: nil, body: body] ++ Map.to_list(attrs))
  end
end