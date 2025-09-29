defmodule Npricot.FileSystem.Watcher do
  use GenServer
  require Logger
  
  @file_check_interval 1000
  
  defstruct [:file_path, :last_modified, :content, :subscribers]  
  @impl true
  def init(file_path) do
    unless File.exists?(file_path) do
      File.write!(file_path, "")
    end
    
    state = %__MODULE__{
      file_path: file_path,
      last_modified: get_file_mtime(file_path),
      content: File.read!(file_path),
      subscribers: MapSet.new()
    }
    
    schedule_file_check()
    
    Logger.info("Watcher started for #{file_path}")
    {:ok, state}
  end
  
  @impl true
  def handle_call(:get_content, _from, state) do
    {:reply, state.content, state}
  end
  
  @impl true
  def handle_call({:update_content, new_content}, _from, state) do
    case write_file_safely(state.file_path, new_content) do
      :ok ->
        new_state = %{state |
          content: new_content,
          last_modified: get_file_mtime(state.file_path)
        }
        
        notify_subscribers(new_state.subscribers, {:content_updated, new_content, :web})
        
        Logger.info("Content updated from web interface")
        {:reply, :ok, new_state}
        
      {:error, reason} ->
        Logger.error("Failed to write file: #{reason}")
        {:reply, {:error, reason}, state}
    end
  end
  
  @impl true
  def handle_call({:subscribe, pid}, _from, state) do
    Process.monitor(pid)
    new_subscribers = MapSet.put(state.subscribers, pid)
    {:reply, :ok, %{state | subscribers: new_subscribers}}
  end
  
  @impl true
  def handle_call({:unsubscribe, pid}, _from, state) do
    new_subscribers = MapSet.delete(state.subscribers, pid)
    {:reply, :ok, %{state | subscribers: new_subscribers}}
  end
  
  @impl true
  def handle_info(:check_file, state) do
    current_mtime = get_file_mtime(state.file_path)
    
    new_state = if current_mtime != state.last_modified do
      case File.read(state.file_path) do
        {:ok, new_content} ->
          Logger.info("File changed detected, updating content")
          
          # Notify subscribers about file change
          notify_subscribers(state.subscribers, {:content_updated, new_content, :file})
          
          %{state | 
            content: new_content,
            last_modified: current_mtime
          }
        
        {:error, reason} ->
          Logger.error("Failed to read file: #{reason}")
          state
      end
    else
      state
    end
  
    schedule_file_check()
    {:noreply, new_state}
  end
  
  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # Remove dead subscriber
    new_subscribers = MapSet.delete(state.subscribers, pid)
    {:noreply, %{state | subscribers: new_subscribers}}
  end
  
  @impl true
  def start_link(file_path) do
    GenServer.start_link(__MODULE__, file_path, name: __MODULE__)
  end
  
  def get_content do
    GenServer.call(__MODULE__, :get_content)
  end
  
  def update_content(new_content) do
    GenServer.call(__MODULE__, {:update_content, new_content})
  end
  
  def subscribe(pid) do
    GenServer.call(__MODULE__, {:subscribe, pid})
  end
  
  def unsubscribe(pid) do
    GenServer.call(__MODULE__, {:unsubscribe, pid})
  end
  
  defp get_file_mtime(file_path) do
    case File.stat(file_path) do
      {:ok, %{mtime: mtime}} -> mtime
      {:error, _} -> nil
    end
  end
  
  defp write_file_safely(file_path, content) do
    temp_path = file_path <> ".tmp"
    
    with :ok <- File.write(temp_path, content),
         :ok <- File.rename(temp_path, file_path) do
      :ok
    else
      error -> 
        File.rm(temp_path) # Clean up temp file if it exists
        error
    end
  end
  
  defp schedule_file_check do
    Process.send_after(self(), :check_file, @file_check_interval)
  end
  
  defp notify_subscribers(subscribers, message) do
    Enum.each(subscribers, fn pid ->
      send(pid, message)
    end)
  end
end