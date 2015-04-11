defmodule RFC3986 do
  alias RFC3986.Normalize, as: Normalize

  def init() do

    :rfc3986 = :ets.new :rfc3986, [
      {:write_concurrency, false},
      {:read_concurrency, true},
      :public,
      :named_table
    ]
    grammar = ABNF.load_file "priv/RFC3986.abnf"
    true = :ets.insert :rfc3986, {:grammar, grammar}
    :ok
  end

  # https://tools.ietf.org/html/rfc3986
  def parse(text) do
    [{:grammar, grammar}] = :ets.lookup :rfc3986, :grammar
    state = %{
      scheme: nil,
      type: nil,
      userinfo: nil,
      username: nil,
      password: nil,
      host_type: nil,
      host: nil,
      port: nil,
      query: nil,
      query_string: %{},
      fragment: nil,
      segments: []
    }
    case ABNF.apply grammar, "uri", text, state do
      nil -> nil
      {matched, rest, state} -> {matched, rest, Normalize.parse(state)}
    end
  end
end
