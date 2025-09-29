defmodule Npricot.FileSystem.FileTest do
  use ExUnit.Case, async: true
  
  alias Npricot.FileSystem.File
  
  describe "new/2" do
    test "creates a new file struct" do
      file = File.new()
      assert path == File.path
    end
  end
end