defmodule NpricotWeb.FileSystemLive.Index do
  use NpricotWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, result} = Npricot.FileSystem.list()
    {:ok,
     socket
     |> assign(:files, result)
   }
  end

  def render(assigns) do
    ~H"""
    <div>
      <ol>
      <%= for row <- @files do %>
        <li>{row}</li>
      <% end %>
      </ol>
    </div>
    """
  end
end