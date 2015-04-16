defmodule RFC3986.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_rfc3986,
     name: "ex_rfc3986",
     version: "0.1.3",
     source_url: "https://github.com/marcelog/ex_rfc3986",
     elixir: ">= 1.0.0",
     description: description,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp description do
    """
    An URI parser trying to be strictly compatible with RFC3986. Uses official ABNF grammar and ex_abnf as interpreter.
    """
  end

  defp deps do
    [
      {:ex_abnf, "~> 0.1.3"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*", "priv"],
      contributors: ["Marcelo Gornstein"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/marcelog/ex_rfc3986"
      }
    ]
  end
end
