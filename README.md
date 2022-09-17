# AssertMatch

Leverages pattern matching & pipeline in Elixir tests!

## Motivation

In short, we wanted this:

```elixir
conn
|> post("/some/api")
|> json_response(200)
|> assert_match(%{
  "success" => true,
  "id" => ^context.some_fixture.id,
  "bytesize" => ^byte_size(context.some_fixture.contents)
})
```

* **Write assertions in pipeline**
* **Assert by patterns**, not just concrete values (utilizing pattern-matching diffs in Elixir 1.10+)
* Expand **function calls inside pins**, inspired by [Ecto.Query](https://hexdocs.pm/ecto/Ecto.Query.html#module-interpolation-and-casting)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `assert_match` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:assert_match, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/assert_match>.
