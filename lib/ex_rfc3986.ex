defmodule RFC3986 do
  alias RFC3986.Scheme, as: Scheme
  alias RFC3986.Hier, as: Hier
  alias RFC3986.Query, as: Query
  alias RFC3986.Fragment, as: Fragment
  alias RFC3986.Normalize, as: Normalize

  # https://tools.ietf.org/html/rfc3986
  #URI           = scheme ":" hier-part [ "?" query ] [ "#" fragment ]
  def parse(text) do
    state = %{
      text: text,
      scheme: nil,
      error: nil,
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
    state |> Scheme.parse
    |> Scheme.parse_separator
    |> Hier.parse
    |> Query.parse
    |> Fragment.parse
    |> Normalize.parse
  end
end
