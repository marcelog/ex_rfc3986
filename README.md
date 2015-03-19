RFC3986
=======

An URI parser trying to be strictly compatible with [RFC3986](https://tools.ietf.org/html/rfc3986).

## Example

    iex> RFC3986.parse 'http://user:pass@elixir-lang.org/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment'
    %{
        error: nil,
        fragment: 'fragment',
        host: 'elixir-lang.org',
        host_type: :reg_name,
        password: 'pass',
        port: nil,
        query: 'k1%2A=v1&k2=v2',
        query_string: %{'k1%2A' => 'v1', 'k2' => 'v2'},
        scheme: 'http',
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        text: [],
        type: :authority,
        userinfo: 'user:pass',
        username: 'user'
      }

## TODO

 * Implement IPv6 parsing.