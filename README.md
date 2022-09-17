# AssertMatch

Leverages pattern matching & pipeline in Elixir tests!

## Motivation

In short, we wanted this:

```elixir
test "/some/api should work", context do
  conn
  |> post("/some/api")
  |> json_response(200)
  |> assert_match(%{
    "success" => true,
    "id" => ^context.some_fixture.id,
    "bytesize" => ^byte_size(context.some_fixture.contents)
  })
end
```

* **Write assertions in pipeline**
* **Assert by patterns**, not just concrete values (utilizing pattern-matching diffs in Elixir 1.10+)
* Expand **function calls inside pins**, inspired by [Ecto.Query](https://hexdocs.pm/ecto/Ecto.Query.html#module-interpolation-and-casting)

## Installation

```elixir
def deps do
  [
    # If available in Hex
    {:assert_match, "~> 1.0", only: [:test]}
    # If not, or, if you need bleeding edge
    {:assert_match, github: "siiibo/assert_match", ref: "main", only: [:test]}
  ]
end
```
