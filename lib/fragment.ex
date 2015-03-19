defmodule RFC3986.Fragment do
  alias RFC3986.Generic, as: Generic

  # fragment      = *( pchar / "/" / "?" )
  def parse(state = %{error: error}) when error != nil do
    state
  end

  def parse(state = %{text: [?#|rest]}) do
    parse %{state | text: rest}, []
  end

  def parse(state) do
    state
  end

  defp parse(state = %{text: []}, []) do
    state
  end

  defp parse(state = %{text: []}, acc) do
    %{state | fragment: Enum.reverse(acc)}
  end

  defp parse(state = %{text: [char|rest] = text}, acc) do
    if Generic.pchar?(text) or
      char == ?/ or
      char == ?? do
        parse %{state | text: rest}, [char|acc]
    else
      %{state | fragment: Enum.reverse(acc)}
    end
  end
end
