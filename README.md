# Npricot

A Zettelkasten companion. Write your Markdown files in any text editor, while Npricot will provide the visual flair and additional interactivity. 

The Npricot architecture is based off Dr. Drang's posts on a "No-Server Personal Wiki". As this is an Elixir project, it extensively uses `Mix.Task`.

However, while Npricot can generate static pages, any interactivity will require starting a webserver. The webserver will sync any changes to the textfiles and vice versa.

## Installation

Add the code to your `mix.exs`

```elixir
def deps do
  [
    {:npricot, "~> 0.1.0"}
  ]
end
```

