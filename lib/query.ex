defmodule RFC3986.Query do
  alias RFC3986.Generic, as: Generic

  # query         = *( pchar / "/" / "?" )
  def parse(state = %{error: error}) when error != nil do
    state
  end

  def parse(state = %{text: [??|rest]}) do
    parse %{state | text: rest}, []
  end

  def parse(state) do
    state
  end

  defp parse(state = %{text: []}, []) do
    state
  end

  defp parse(state = %{text: []}, acc) do
    %{state | query: Enum.reverse(acc)}
  end

  defp parse(state = %{text: [char|rest] = text}, acc) do
    if Generic.pchar?(text) or
      char == ?/ or
      char == ?? do
        parse %{state | text: rest}, [char|acc]
    else
      %{state | query: Enum.reverse(acc)}
    end
  end
end
