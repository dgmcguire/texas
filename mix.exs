defmodule Texas.Mixfile do
  use Mix.Project

  def project do
    [app: :texas,
     version: "0.1.3",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {Texas.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:floki, "~>0.17.0"},
      {:phoenix, "~>1.3"},
      {:phoenix_html, "~>2.10"},
      {:uuid, "~>1.1"},
    ]
  end

  defp description do
    """
    This is the core library for texas.  A backend driven, realtime, view layer for webdev.
    """
  end

  defp package do
    [
      name: :texas,
      files: ~W(lib mix.exs README.md),
      maintainers: ["Dan McGuire"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dgmcguire/texas"},
    ]
  end
end
