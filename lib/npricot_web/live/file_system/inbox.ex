defmodule NpricotWeb.FileSystemLive.Inbox do
  @moduledoc """
  Inbox View in Phoenix Liveview
  """
  
  use NpricotWeb, :live_view
  
  alias Npricot.FileSystem
  alias NpricotWeb.FileSystemLive.Inbox.QueueItem
  
  
  @impl true
  def mount(_params, _session, socket) do
    {:ok, files} = FileSystem.list()
    
    tab = [1, 2, 3]
  
    queue = [
     QueueItem.make("0", "Research quantum computing applications in machine learning. Check recent papers"),
     QueueItem.make("1", "Call dentist for appointment next week. Preferably Tuesday or Wednesday"),
     QueueItem.make("2", "Book recommendation: 'Atomic Habits' - focus on small incremental changes"),
     QueueItem.make("3", "Project idea: Build a task manager with natural language processing"),
     QueueItem.make("4", "Meeting notes: Q3 review showed 15% growth, need to optimise customer acquisition")
    ]
  
    {:ok,
      socket
      |> assign(files: files, queue: queue, tabs: tab, current_tab: 1)}
  end
  
  @impl true
  def handle_event("keep", %{"id" => item_id}, socket) do
    queue = change_status(socket.assigns.queue, item_id, "keep")
    
    {:noreply,
      socket
      |> assign(queue: queue)}
  end
  
  @impl true
  def handle_event("snooze", %{"id" => item_id}, socket) do
    queue = change_status(socket.assigns.queue, item_id, "snooze")
    
    {:noreply,
      socket
      |> assign(queue: queue)}
  end
  
  @impl true
  def handle_event("discard", %{"id" => item_id}, socket) do
    queue = change_status(socket.assigns.queue, item_id, "discard")

    {:noreply,
      socket
      |> assign(queue: queue)}
  end  
  
  @impl true
  def handle_event("previous_state", _, socket) do
    current_tab = socket.assigns.current_tab
    new_tab = if current_tab > 1 do
      current_tab - 1
    else
      current_tab
    end
  
    {:noreply,
      socket
      |> assign(current_tab: new_tab)}
  end  
  
  @impl true
  def handle_event("next_state", _, socket) do
    current_tab = socket.assigns.current_tab
    new_tab = if current_tab < 3 do
       current_tab + 1
    else
      current_tab
    end
  
    {:noreply,
      socket
      |> assign(current_tab: new_tab)}
  end  
  
  # @impl true
  # def handle_event("discard", %{"id" => item_id}, socket) do
  #   queue =
  #     Enum.reject(socket.assigns.queue, fn(x) ->
  #       x.id == item_id
  #     end)
  # 
  #   {:noreply,
  #     socket
  #     |> assign(queue: queue)}
  # end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <ol>
      <%= for tab <- @tabs do %>
        <%= if @current_tab == tab do %>
        <li><strong>{tab}</strong></li>
        <% else %>
        <li>{tab}</li>
        <% end %>
      <% end %>
      </ol>
      <button phx-click="previous_state">Previous</button>
      <button phx-click="next_state">Continue</button>
      <%= if @current_tab == 1 do %>
      <ol>
      <%= for queue_item <- @queue do %>
        <li class={queue_item.status} id={"item-#{queue_item.id}"}>{queue_item.title} |
          <button phx-click="keep" phx-value-id={queue_item.id}>Keep</button>
          <button phx-click="snooze" phx-value-id={queue_item.id}>Snooze</button>
          <button phx-click="discard" phx-value-id={queue_item.id}>Discard</button>
        </li>
      <% end %>
      </ol>
      <% end %>
      
      <%= if @current_tab == 2 do %>
        Original Content
        <textarea></textarea>
      <% end %>
      
      <%= if @current_tab == 3 do %>
        <p>Select Tree</p>
      <% end %>
    </div>
    """
  end
  
  defp change_status(queue, id, status) do
    new_queue =
      Enum.map(queue, fn(x) ->
      if x.id == id do
        %{x | status: status}
      else
       x
      end
    end)
  end
end

defmodule NpricotWeb.FileSystemLive.Inbox.QueueItem do
  defstruct [:id, :title, :status]
  def make(id, title) do
    %__MODULE__{id: id, title: title, status: "neutral"}
  end
end