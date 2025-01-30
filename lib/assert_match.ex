defmodule AssertMatch do
  @moduledoc """
  Provides pipe-friendly `assert_match/2`
  """

  @doc """
  Pipe-friendly equality/matching assertion.

  Performs `assert/1` with:

  - `=~` for Regex patterns
  - `match?/2` for patterns with guards
  - `=` for other patterns

  For the third variant, it can utilize bindings inside the pattern from outside!

      %{key: 1}
      |> assert_match(%{key: value})

      assert value == 1

  ## Extraction of pinned function calls

  Elixir's `^/1` (pin operator) usually does not allow runtime function calls,
  and only accepts previously bound user variables.

  However, this macro "extracts" runtime function calls on pins in the pattern
  and bind their results to temporary variables named `pinned__<n>`
  (where `<n>` is unique integer) so that you can actually write
  function calls with pins! (Just like you do with [`Ecto.Query`](https://hexdocs.pm/ecto/Ecto.Query.html#module-interpolation-and-casting))

  With this you are now able to write test expressions like so:

      conn
      |> post("/some/api")
      |> json_response(200)
      |> assert_match(%{
        "success" => true,
        "id" => ^context.some_fixture.id,
        "bytesize" => ^byte_size(context.some_fixture.contents)
      })

  You cannot nest pinned expressions. See test/assert_match_test.exs for more usages.

  ## Guards

  Guards are supported, but with limitations: if guards are used, bindings inside patterns cannot be used from outside.

      %{key: 1}
      |> assert_match(map when is_map(map))
      # => Passes

      assert map == %{key: 1}
      # => error: undefined variable "map"

  Related: bindings inside patterns that are NOT used in the guards are warned as unused.

      %{key: 1}
      |> assert_match(%{key: value} = map when not is_map_key(map, :nonkey))
      # => warning: variable "value" is unused (if the variable is not meant to be used, prefix it with an underscore)

  This is a relatively new limitation introduced in Elixir 1.18, as a side-effect of [this change](https://github.com/elixir-lang/elixir/pull/13817).
  """
  @spec assert_match(any, Macro.t()) :: any
  defmacro assert_match(subject, pattern) do
    case pattern do
      falsy when falsy == nil or falsy == false ->
        quote do
          left = unquote(subject)
          ExUnit.Assertions.assert(left == unquote(falsy))
          left
        end

      {type, _, _} when type in [:sigil_r, :sigil_R] ->
        quote do
          left = unquote(subject)
          right = unquote(pattern)
          ExUnit.Assertions.assert(left =~ right)
          left
        end

      _other_matchables ->
        {matchable_ast, extracted_tmpvars} = extract_pinned_function_calls_to_variables(pattern)
        # Notice pattern is at left-hand side
        # In Elixir 1.10+, match assertions can display rich diffs for various subject-pattern combinations
        case matchable_ast do
          {:when, _location, _branches} = ast_with_guard ->
            # After Elixir 1.18, patterns with guards require special treatment. cf. https://github.com/elixir-lang/elixir/pull/13817
            quote do
              right = unquote(subject)
              unquote(tmpvar_definitions(extracted_tmpvars))
              ExUnit.Assertions.assert(match?(unquote(ast_with_guard), right))
              right
            end

          _otherwise ->
            quote do
              right = unquote(subject)
              unquote(tmpvar_definitions(extracted_tmpvars))
              ExUnit.Assertions.assert(unquote(matchable_ast) = right)
              right
            end
        end
    end
  end

  defp extract_pinned_function_calls_to_variables(ast) do
    Macro.prewalk(ast, [], fn ast_node, acc ->
      case do_extract(ast_node) do
        {:extracted, extracted_pin_node, extracted_tmpvar} ->
          {extracted_pin_node, [extracted_tmpvar | acc]}

        otherwise ->
          {otherwise, acc}
      end
    end)
  end

  defp do_extract({:^, _lines, [{varname, _varlines, nil}]} = pin_with_user_var)
       when is_atom(varname) do
    pin_with_user_var
  end

  defp do_extract({:^, lines, [child]}) do
    varnum = System.unique_integer([:positive, :monotonic])
    tmpvar = :"pinned__#{varnum}"
    {:extracted, {:^, lines, [{tmpvar, lines, nil}]}, {tmpvar, lines, child}}
  end

  defp do_extract(other_node) do
    other_node
  end

  defp tmpvar_definitions(extracted_tmpvars) do
    Enum.map(extracted_tmpvars, fn {varname, lines, expression} ->
      {:=, lines, [{varname, lines, nil}, expression]}
    end)
  end
end
