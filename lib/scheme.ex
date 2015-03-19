defmodule RFC3986.Scheme do

  alias RFC3986.Generic, as: Generic

  #    scheme        = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
  def parse(state = %{text: []}) do
    %{state | error: {:empty_scheme, []}}
  end

  def parse(state = %{text: [char|_rest] = text}) do
    if Generic.alpha?(char) do
      parse state, []
    else
      %{state | error: {:invalid_scheme, text}}
    end
  end

  def parse_separator(state = %{error: error}) when error != nil do
    state
  end

  def parse_separator(state = %{text: [?:|rest]}) do
    %{state | text: rest}
  end

  def parse_separator(state = %{text: text}) do
    %{state | error: {:invalid_scheme_separator, text}}
  end

  # Private
  defp parse(state = %{text: []}, acc) do
    %{state | scheme: Enum.reverse(acc), text: []}
  end

  defp parse(state = %{text: [char|rest] = text}, acc) do
    if Generic.alpha?(char) or
      Generic.digit?(char) or
      char == ?+ or
      char == ?. do parse %{state | text: rest}, [char|acc]
    else
      %{state | scheme: Enum.reverse(acc), text: text}
    end
  end
end
