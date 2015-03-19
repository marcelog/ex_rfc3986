defmodule RFC3986Test do
  use ExUnit.Case
  doctest RFC3986
  require Logger

  test "common uris" do
    assert_uri(
      'http:',
      %{
        scheme: 'http',
        type: :path_empty,
        text: ''
      }
    )

    assert_uri(
      'http:/',
      %{
        scheme: 'http',
        text: '',
        type: :path_absolute
      }
    )

    assert_uri(
      'http:/a',
      %{
        scheme: 'http',
        text: '',
        segments: ['a'],
        type: :path_absolute
      }
    )

    assert_uri(
      'http:a',
      %{
        scheme: 'http',
        text: '',
        segments: ['a'],
        type: :path_rootless
      }
    )

    assert_uri(
      'http://user:pass@elixir-lang.org:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment',
      %{
        scheme: 'http',
        host_type: :reg_name,
        host: 'elixir-lang.org',
        port: 8812,
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        query_string: %{'k1%2A' => 'v1', 'k2' => 'v2'},
        fragment: 'fragment',
        userinfo: 'user:pass',
        username: 'user',
        password: 'pass',
        query: 'k1%2A=v1&k2=v2',
        type: :authority,
        text: ''
      }
    )

    assert_uri(
      'http://user:pass@192.168.0.1:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment',
      %{
        scheme: 'http',
        host_type: :ipv4,
        host: '192.168.0.1',
        port: 8812,
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        query_string: %{'k1%2A' => 'v1', 'k2' => 'v2'},
        fragment: 'fragment',
        userinfo: 'user:pass',
        username: 'user',
        password: 'pass',
        query: 'k1%2A=v1&k2=v2',
        type: :authority,
        text: ''
      }
    )
  end

  defp assert_uri(uri, props) do
    Logger.debug "Testing: #{inspect uri}"
    result = RFC3986.parse uri
    Logger.debug "Result: #{inspect result}"
    nil = result.error
    Enum.each props, fn({k, v}) ->
      Logger.debug "Asserting: #{k} = #{inspect v}"
      ^v = result[k]
    end
  end
end
