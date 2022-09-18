# AssertMatch

[![Elixir CI](https://github.com/siiibo/assert_match/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/siiibo/assert_match/actions/workflows/build.yml)

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

### Introductory slide

<a href="https://docs.google.com/presentation/d/e/2PACX-1vRuIA2ocDafLRJUn6nWScZmOq6YwpqXba7x5RG72yzT3X7FB-JcET33QMGsBidHsAdbnVF9KYCOa00R/pub?start=false&loop=false&delayms=3000&slide=id.p"><img src="slide.png" alt="Further leveraging pattern matches in Elixir unit tests!" width="320"/></a>

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
