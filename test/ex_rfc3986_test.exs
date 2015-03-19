defmodule RFC3986Test do
  use ExUnit.Case
  doctest RFC3986
  require Logger

  test "generic full" do
    assert_uri(
      'http://user:pass@elixir-lang.org:8812/docs/stable/elixir/Enum.html?k1?%2A=v1&k2=v2&k3&k4#fragment/other_fragment%2F??',
      %{
        scheme: 'http',
        host_type: :reg_name,
        host: 'elixir-lang.org',
        port: 8812,
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        query_string: %{'k1?%2A' => 'v1', 'k2' => 'v2', 'k3' => nil, 'k4' => nil},
        fragment: 'fragment/other_fragment%2F??',
        userinfo: 'user:pass',
        username: 'user',
        password: 'pass',
        query: 'k1?%2A=v1&k2=v2&k3&k4',
        type: :authority,
        text: ''
      }
    )
  end

  test "empty path" do
    assert_uri(
      'http:',
      %{
        scheme: 'http',
        type: :path_empty,
        text: ''
      }
    )
  end

  test "absolute path" do
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
  end

  test "path rootless" do
    assert_uri(
      'http:a',
      %{
        scheme: 'http',
        text: '',
        segments: ['a'],
        type: :path_rootless
      }
    )
  end

  test "full with domain name" do
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
  end

  test "ipv4" do
    assert_uri(
      'http://192.168.0.1',
      %{
        scheme: 'http',
        host_type: :ipv4,
        host: '192.168.0.1',
        type: :authority,
        text: ''
      }
    )

    assert_uri(
      'http://192.168.0.1/',
      %{
        scheme: 'http',
        host_type: :ipv4,
        host: '192.168.0.1',
        type: :authority,
        text: ''
      }
    )
  end

  test "full with ipv4" do
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

  test "full with ipv future" do
    assert_uri(
      'http://user:pass@[v1.fe80::a+en1]:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment',
      %{
        scheme: 'http',
        host_type: :ipv_future,
        host: '[v1.fe80::a+en1]',
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

  test "no user info" do
    assert_uri(
      'http://[v1.fe80::a+en1]:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment',
      %{
        scheme: 'http',
        host_type: :ipv_future,
        host: '[v1.fe80::a+en1]',
        port: 8812,
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        query_string: %{'k1%2A' => 'v1', 'k2' => 'v2'},
        fragment: 'fragment',
        userinfo: nil,
        username: nil,
        password: nil,
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
