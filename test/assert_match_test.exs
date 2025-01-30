defmodule AssertMatchTest do
  use ExUnit.Case
  import AssertMatch

  describe "assert_match/2" do
    @atom :atom
    test "should work with static values" do
      assert_match(1, 1)
      assert_match(true, true)
      assert_match(false, false)
      assert_match(nil, nil)
      assert_match(:atom, @atom)
      assert_match("string", "string")
      assert_match(%{}, %{})
      assert_match(%{key: 1}, %{key: 1})
      assert_match([], [])
      assert_match([1, 2], [1, 2])
    end

    test "should work with regex" do
      assert_match("prefix match", ~R/prefix/)
      assert_match("prefix match", ~r/#{"prefix"}/)
    end

    test "should work with patterns" do
      assert_match(1, _)
      assert_match("prefix match", "prefix" <> _)
      assert_match(%{key: 1}, %{})
      assert_match(%{key: 1}, %{key: _})
      assert_match(%{key: 1}, map when is_map_key(map, :key))
      assert_match([1, 2], [_ | _])
    end

    test "should work with incomplete struct patterns" do
      # As a value, %Date{year: 2018} raises since [:month, :day] are also enforced.
      assert_match(~D[2018-01-01], %Date{year: 2018})
    end

    test "should work with bindings" do
      assert_match(1, int)
      assert_match("prefix match", "prefix" <> rest)
      assert_match(%{key: 1}, %{key: value})
      assert_match([1, 2], [head | tail])
      assert int == 1
      assert rest == " match"
      assert value == 1
      assert head == 1
      assert tail == [2]
    end

    test "should work with pinned values" do
      one = 1
      assert_match(1, ^one)
      match = " match"
      assert_match("prefix match", "prefix" <> ^match)
      assert_match(%{key: 1}, %{key: ^one})
      two = 2
      assert_match([1, 2], [^one, ^two])
    end

    test "should work with pinned runtime evaluations" do
      one = 1
      assert_match(1, ^(2 - one))
      assert_match("prefix match", ^Enum.join(["prefix", "match"], " "))
      map = %{key: one}
      assert_match(%{key: 1}, %{key: ^map.key})
      assert_match({1, :atom}, ^{one, @atom})
      assert_match([:atom, 1], ^[@atom, map.key])
    end
  end
end
