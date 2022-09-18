defmodule AssertMatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :assert_match,
      description:
        "Leverages pattern matching & pipeline in Elixir tests by pipe-friendly `assert_match/2`",
      version: "1.0.0",
      elixir: "~> 1.10",
      package: package(),
      deps: []
    ]
  end

  defp package() do
    [
      licenses: [
        "Apache-2.0"
      ],
      links: %{
        "GitHub" => "https://github.com/siiibo/assert_match"
      }
    ]
  end
end
