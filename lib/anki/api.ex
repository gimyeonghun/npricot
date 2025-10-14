defmodule Npricot.Anki.API do
  @moduledoc """
  An AnkiConnect API
  """
  
  require Logger
  
  @default_url "http://localhost:8765"
  @default_version 6
  
  @doc """
  Get Anki version
  """
  def version, do: call("version")
  
  @doc """
  Sync the Anki collection
  """
  def sync, do: call("sync")
  
  @doc "Get deck statistics"
  def deck_stats(deck_name) do
    GenServer.call(__MODULE__, {:request, "getDeckStats", %{decks: [deck_name]}})
  end
  
  @doc """
  Get list of all deck names
  """
  def deck_names, do: call("deckNames")
  
  @doc """
  Get list of all model (note type) namess
  """
  def model_names, do: call("modelNames")
  
  @doc """
  Add a note to Anki
  """
  def add_note(deck, model, fields, tags \\ []) do
    params = %{
      note: %{
        deckName: deck,
        modelName: model,
        fields: fields,
        tags: tags
      }
    }
    call("addNote", params)
  end
  
  @doc "Find notes by query"
  def find_notes(query) do
    GenServer.call(__MODULE__, {:request, "findNotes", %{query: query}})
  end
  
  @doc "Get note info by note IDs"
  def notes_info(note_ids) when is_list(note_ids) do
    GenServer.call(__MODULE__, {:request, "notesInfo", %{notes: note_ids}})
  end
  
  @doc "Update note fields"
  def update_note_fields(note_id, fields) do
    params = %{
      note: %{
        id: note_id,
        fields: fields
      }
    }
    GenServer.call(__MODULE__, {:request, "updateNoteFields", params})
  end
  
  @doc "Delete notes by IDs"
  def delete_notes(note_ids) when is_list(note_ids) do
    GenServer.call(__MODULE__, {:request, "deleteNotes", %{notes: note_ids}})
  end
  
  defp call(action, params \\ %{}) do
    payload = %{
      action: action,
      version: @default_version,
      params: params
    }
    
    case Req.post(@default_url, json: payload) do
      {:ok, %{status: 200, body: body}} ->
        case body do
        %{"error" => nil, "result" => result} ->
          {:ok, result}
          
        %{"error" => error} ->
          Logger.error("AnkiConnect error: #{error}")
          {:error, error}
        end
        
      {:ok, %{status: status}} ->
        Logger.error("HTTP error: status #{status}")
        {:error, "Unexpected response format"}
        
      {:error, reason} ->
        Logger.error("Request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end
end