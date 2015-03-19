defmodule RFC3986.Authority do
  alias RFC3986.Generic, as: Generic
  alias RFC3986.Host, as: Host

  # authority     = [ userinfo "@" ] host [ ":" port ]
  def parse(state = %{error: error}) when error != nil do
    state
  end

  def parse(state) do
    state |> userinfo |> Host.parse |> Host.parse_port
  end

  # userinfo      = *( unreserved / pct-encoded / sub-delims / ":" )
  # reg-name      = *( unreserved / pct-encoded / sub-delims )
  # host          = IP-literal / IPv4address / reg-name
  # IP-literal    = "[" ( IPv6address / IPvFuture  ) "]"
  # IPvFuture     = "v" 1*HEXDIG "." 1*( unreserved / sub-delims / ":" )
  defp userinfo(state) do
    userinfo state, []
  end

  defp userinfo(state = %{text: []}, acc) do
    %{state | text: Enum.reverse(acc)}
  end

  defp userinfo(state = %{text: [?@]}, _acc) do
    %{state | error: {:invalid_authority}, text: []}
  end

  defp userinfo(state = %{text: [?@|rest]}, acc) do
    %{state | userinfo: Enum.reverse(acc), text: rest}
  end

  defp userinfo(state = %{text: [char|rest] = text}, acc) do
    if Generic.unreserved?(char) or
      Generic.pct_encoded?(text) or
      Generic.sub_delims?(char) or
      char == ?: do userinfo %{state | text: rest}, [char|acc]
    else
      %{state | text: Enum.reverse(acc) ++ text}
    end
  end
end