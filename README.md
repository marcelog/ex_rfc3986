[![Build Status](https://travis-ci.org/marcelog/ex_rfc3986.svg)](https://travis-ci.org/marcelog/ex_rfc3986)
RFC3986
=======

An URI parser trying to be strictly compatible with [RFC3986](https://tools.ietf.org/html/rfc3986).

This project uses [ex_abnf](https://github.com/marcelog/ex_abnf) with the official [uri grammar](https://github.com/marcelog/ex_rfc3986/blob/master/priv/RFC3986.abnf)

## Example

    iex> RFC3986.init # Call this one first to initialize the grammar.
    iex> {_matched_uri, _not_matched_input, result} = RFC3986.parse 'http://user:pass@elixir-lang.org:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment'
    iex> result
    %RFC3986.Result{
        fragment: 'fragment',
        host: 'elixir-lang.org',
        host_type: :reg_name,
        password: 'pass',
        port: 8812,
        query: 'k1%2A=v1&k2=v2',
        query_string: %{'k1%2A' => 'v1', 'k2' => 'v2'},
        scheme: 'http',
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        type: :authority,
        userinfo: 'user:pass',
        username: 'user'
      }


## Using it with Mix

To use it in your Mix projects, first add it as a dependency:

```elixir
def deps do
  [{:ex_rfc3986, "~> 0.2.4"}]
end
```
Then run mix deps.get to install it.

## License
The source code is released under Apache 2 License.

Check [LICENSE](https://github.com/marcelog/ex_abnf/blob/master/LICENSE) file for more information.
