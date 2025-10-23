defmodule Npricot.Anki.Server do
  @moduledoc """
  A GenServer that communicates with the web front-end and Anki.
  
  The GenServer will load the current items present in the tableview. 
  Its initial arguments are the model, flashcards and the desired deck from the webpage.
  
  It will perform a sync operation. It will check which items still exist in the Anki database,
  and which ones have been purged. So the GenServer will maintain the "source of truth" for any operations. 
  
  It will continue to maintain the source of truth by refreshing the database every 5 seconds. 
  
  The user has 3 actions:
  1. create a new row and sync it to a flashcard
  2. update the columns of an existing row that is synced to a flashcard
  3. delete a row. this will delete the corresponding flashcard
  
  Likewise, the server listens to actions performed in the Anki database
  1. updated field values
  2. deleted flashcards
  
  It does not have to monitor for added flashcards because it's only interested in sync'ing items in the table. 
  
  """
  
  use GenServer
  require Logger
  
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  def add_note() do
  end
  
  # Server Implementation
  
  @impl true
  def init(_args) do 
    state = %{
      flashcards: [],
      max_retries: 2
    }
    
    Logger.info("Anki GenServer started")
    
    {:ok, state}
  end
  
  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
  
  @impl true
  def handle_info({:sync}, _from, state) do
  end
end