defmodule AssertMatch do
  @moduledoc """
  Provides pipe-friendly `assert_match/2`
  """

  @doc """
  Pipe-friendly equality/matching assertion.

  Performs:

  - `=~` for Regex patterns
  - `=` for other patterns

  ## Extraction of pinned function calls

  Elixir's `^/1` (pin operator) usually does not allow runtime function calls,
  and only accepts previously bound user variables.

  However, this macro "extracts" runtime function calls on pins in the pattern
  and bind their results to temporary variables named `pinned__<n>`
  (where `<n>` is unique integer) so that you can actually write
  function calls with pins! (Just like you do with `Ecto.Query`)

  With this you are now able to write test expressions like so:

      conn
      |> post("/some/api")
      |> json_response(200)
      |> assert_match(%{
        "success" => true,
        "id" => ^context.some_fixture.id,
        "bytesize" => ^byte_size(context.some_fixture.contents)
      })

  You cannot nest pinned expressions. See test/support/assertion_test.exs for more usages.
  """
  defmacro assert_match(subject, pattern) do
    case pattern do
      nil ->
        quote do
          left = unquote(subject)
          assert left == nil
          left
        end

      {type, _, _} when type in [:sigil_r, :sigil_R] ->
        quote do
          left = unquote(subject)
          right = unquote(pattern)
          assert left =~ right
          left
        end

      _other_matchables ->
        {matchable_ast, extracted_tmpvars} = extract_pinned_function_calls_to_variables(pattern)
        # Notice pattern is at left-hand side
        # In Elixir 1.10+, match assertions can display rich diffs for various subject-pattern combinations
        quote do
          right = unquote(subject)
          unquote(tmpvar_definitions(extracted_tmpvars))
          assert unquote(matchable_ast) = right
          right
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
