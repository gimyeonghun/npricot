defmodule NpricotWeb.TableLive.Index do
  use NpricotWeb, :live_view

  def mount(_params, _session, socket) do
    initial_table = %{
      rows: [
        ["Header 1", "Header 2", "Header 3"],
        ["Row 1 Col 1", "Row 1 Col 2", "Row 1 Col 3"],
        ["Row 2 Col 1", "Row 2 Col 2", "Row 2 Col 3"]
      ],
      has_header: true
    }

    {:ok,
     socket
     |> assign(:table, initial_table)
     |> assign(:markdown, generate_markdown(initial_table))}
  end

  def handle_event("add_row", _params, socket) do
    table = socket.assigns.table
    new_row = List.duplicate("", length(hd(table.rows)))
    updated_table = %{table | rows: table.rows ++ [new_row]}
    
    {:noreply,
     socket
     |> assign(:table, updated_table)
     |> assign(:markdown, generate_markdown(updated_table))}
  end

  def handle_event("add_column", _params, socket) do
    table = socket.assigns.table
    updated_rows = Enum.map(table.rows, fn row -> row ++ [""] end)
    updated_table = %{table | rows: updated_rows}
    
    {:noreply,
     socket
     |> assign(:table, updated_table)
     |> assign(:markdown, generate_markdown(updated_table))}
  end

  def handle_event("remove_row", %{"index" => index}, socket) do
    table = socket.assigns.table
    row_index = String.to_integer(index)
    
    if length(table.rows) > 1 do
      updated_rows = List.delete_at(table.rows, row_index)
      updated_table = %{table | rows: updated_rows}
      
      {:noreply,
       socket
       |> assign(:table, updated_table)
       |> assign(:markdown, generate_markdown(updated_table))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("remove_column", %{"index" => index}, socket) do
    table = socket.assigns.table
    col_index = String.to_integer(index)
    
    if length(hd(table.rows)) > 1 do
      updated_rows = Enum.map(table.rows, fn row -> List.delete_at(row, col_index) end)
      updated_table = %{table | rows: updated_rows}
      
      {:noreply,
       socket
       |> assign(:table, updated_table)
       |> assign(:markdown, generate_markdown(updated_table))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_cell", %{"row" => row, "col" => col, "value" => value}, socket) do
    table = socket.assigns.table
    row_index = String.to_integer(row)
    col_index = String.to_integer(col)
    
    updated_rows = List.update_at(table.rows, row_index, fn current_row ->
      List.update_at(current_row, col_index, fn _ -> value end)
    end)
    
    updated_table = %{table | rows: updated_rows}
    
    {:noreply,
     socket
     |> assign(:table, updated_table)
     |> assign(:markdown, generate_markdown(updated_table))}
  end

  def handle_event("toggle_header", _params, socket) do
    table = socket.assigns.table
    updated_table = %{table | has_header: !table.has_header}
    
    {:noreply,
     socket
     |> assign(:table, updated_table)
     |> assign(:markdown, generate_markdown(updated_table))}
  end

  defp generate_markdown(%{rows: [], has_header: _}), do: ""
  
  defp generate_markdown(%{rows: rows, has_header: has_header}) do
    case {rows, has_header} do
      {[], _} -> ""
      {[single_row], false} ->
        "| " <> Enum.join(single_row, " | ") <> " |"
      {[header | data_rows], true} ->
        header_line = "| " <> Enum.join(header, " | ") <> " |"
        separator_line = "|" <> String.duplicate(" --- |", length(header))
        data_lines = Enum.map(data_rows, fn row ->
          "| " <> Enum.join(row, " | ") <> " |"
        end)
        
        [header_line, separator_line | data_lines]
        |> Enum.join("\n")
      {all_rows, false} ->
        all_rows
        |> Enum.map(fn row -> "| " <> Enum.join(row, " | ") <> " |" end)
        |> Enum.join("\n")
    end
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold text-gray-900">Dynamic Table Creator</h1>
        <div class="flex gap-2">
          <button
            phx-click="toggle_header"
            class={[
              "px-4 py-2 rounded-md text-sm font-medium transition-colors",
              @table.has_header && "bg-blue-600 text-white" || "bg-gray-200 text-gray-700 hover:bg-gray-300"
            ]}
          >
            <%= if @table.has_header, do: "Header: ON", else: "Header: OFF" %>
          </button>
        </div>
      </div>

      <div class="bg-white shadow-lg rounded-lg p-6">
        <div class="flex gap-4 mb-4">
          <button
            phx-click="add_row"
            class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
          >
            Add Row
          </button>
          <button
            phx-click="add_column"
            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
          >
            Add Column
          </button>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full border-collapse border border-gray-300">
            <tbody>
              <%= for {row, row_index} <- Enum.with_index(@table.rows) do %>
                <tr class={if @table.has_header and row_index == 0, do: "bg-gray-50 font-medium", else: ""}>
                  <%= for {cell, col_index} <- Enum.with_index(row) do %>
                    <td class="border border-gray-300 p-2 relative group">
                      <input
                        type="text"
                        value={cell}
                        phx-blur="update_cell"
                        phx-value-row={row_index}
                        phx-value-col={col_index}
                        class="w-full p-1 border-0 focus:ring-2 focus:ring-blue-500 rounded"
                        placeholder="Enter text..."
                      />
                      
                      <!-- Column controls (show on first row) -->
                      <%= if row_index == 0 do %>
                        <div class="absolute -top-6 left-1/2 transform -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity">
                          <button
                            phx-click="remove_column"
                            phx-value-index={col_index}
                            class="bg-red-500 hover:bg-red-600 text-white px-2 py-1 rounded text-xs"
                            title="Remove Column"
                          >
                            ×
                          </button>
                        </div>
                      <% end %>
                    </td>
                  <% end %>
                  
                  <!-- Row controls -->
                  <td class="p-2 w-10">
                    <button
                      phx-click="remove_row"
                      phx-value-index={row_index}
                      class="bg-red-500 hover:bg-red-600 text-white px-2 py-1 rounded text-xs opacity-0 group-hover:opacity-100 transition-opacity"
                      title="Remove Row"
                    >
                      ×
                    </button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>

      <div class="bg-gray-50 shadow-lg rounded-lg p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">Generated Markdown</h2>
        <div class="bg-white border rounded-lg p-4">
          <pre class="text-sm text-gray-800 whitespace-pre-wrap font-mono"><%= @markdown %></pre>
        </div>
        <button
          onclick={"navigator.clipboard.writeText(`#{String.replace(@markdown, "`", "\\`")}`).then(() => alert('Copied to clipboard!'))"}
          class="mt-4 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
        >
          Copy Markdown
        </button>
      </div>
    </div>
    """
  end
end