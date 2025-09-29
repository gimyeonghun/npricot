defmodule NpricotWeb.FileEditorLive do
  use NpricotWeb, :live_view
  alias Npricot.FileSystem.Watcher

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Watcher.subscribe(self())
    end

    content = Watcher.get_content()
    
    socket = 
      socket
      |> assign(:content, content)
      |> assign(:last_update_source, nil)
      |> assign(:unsaved_changes, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("content_changed", %{"content" => new_content}, socket) do
    socket = 
      socket
      |> assign(:content, new_content)
      |> assign(:unsaved_changes, new_content != Watcher.get_content())

    {:noreply, socket}
  end

  @impl true
  def handle_event("save_content", %{"content" => content}, socket) do
    case Watcher.update_content(content) do
      :ok ->
        socket = 
          socket
          |> assign(:content, content)
          |> assign(:unsaved_changes, false)
          |> assign(:last_update_source, :web)
          |> put_flash(:info, "Content saved successfully!")

        {:noreply, socket}
      
      {:error, reason} ->
        socket = put_flash(socket, :error, "Failed to save: #{reason}")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:content_updated, new_content, source}, socket) do
    socket = case source do
      :file ->
        # File changed externally, update the interface
        socket
        |> assign(:content, new_content)
        |> assign(:unsaved_changes, false)
        |> assign(:last_update_source, :file)
        |> put_flash(:info, "File updated from external change")
      
      :web ->
        # Change originated from web interface, just update tracking
        assign(socket, :last_update_source, :web)
    end

    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, _socket) do
    Watcher.unsubscribe(self())
    :ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <div class="bg-white shadow-lg rounded-lg p-6">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-2xl font-bold text-gray-800">File Editor</h1>
          <div class="flex items-center space-x-2">
            <%= if @unsaved_changes do %>
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                Unsaved Changes
              </span>
            <% end %>
            <%= if @last_update_source == :file do %>
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                Updated from File
              </span>
            <% end %>
          </div>
        </div>

        <.form for={%{}} phx-submit="save_content" phx-change="content_changed">
          <div class="mb-4">
            <textarea 
              name="content"
              rows="20"
              class="w-full px-3 py-2 text-gray-700 border rounded-lg focus:outline-none focus:border-blue-500 font-mono"
              placeholder="Start typing your content here..."
            ><%= @content %></textarea>
          </div>
          
          <div class="flex justify-between items-center">
            <button 
              type="submit"
              class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
            >
              Save to File
            </button>
            
            <div class="text-sm text-gray-600">
              Content length: <%= String.length(@content) %> characters
            </div>
          </div>
        </.form>
      </div>

      <!-- Status Panel -->
      <div class="mt-6 bg-gray-50 rounded-lg p-4">
        <h3 class="text-lg font-semibold mb-2">File Sync Status</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
          <div>
            <strong>Last Update Source:</strong>
            <%= case @last_update_source do %>
              <% :file -> %>
                <span class="text-blue-600">External File Change</span>
              <% :web -> %>
                <span class="text-green-600">Web Interface</span>
              <% _ -> %>
                <span class="text-gray-500">Initial Load</span>
            <% end %>
          </div>
          
          <div>
            <strong>Sync Status:</strong>
            <%= if @unsaved_changes do %>
              <span class="text-yellow-600">Pending Changes</span>
            <% else %>
              <span class="text-green-600">Synchronized</span>
            <% end %>
          </div>
          
          <div>
            <strong>File Watching:</strong>
            <span class="text-green-600">Active</span>
          </div>
        </div>
      </div>
    </div>
    """
  end
end