################################################################################
# Copyright 2015 Marcelo Gornstein <marcelog@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
defmodule RFC3986Test do
  use ExUnit.Case
  doctest RFC3986
  require Logger
  alias RFC3986.Result, as: Res

  setup do
    RFC3986.init
  end

  test "generic full" do
    assert_uri(
      'http://user:pass@elixir-lang.org:8812/docs/stable/elixir/Enum.html?k1?%2A=v1&k2=v2&k3&k4#fragment/other_fragment%2F??',
      %Res{
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
        type: :authority
      }
    )
  end

  test "empty path" do
    assert_uri(
      'http:',
      %Res{
        scheme: 'http',
        type: :path_empty
      }
    )
  end

  test "absolute path" do
    assert_uri(
      'http:/',
      %Res{
        scheme: 'http',
        type: :path_absolute
      }
    )

    assert_uri(
      'http:/a',
      %Res{
        scheme: 'http',
        segments: ['a'],
        type: :path_absolute
      }
    )
  end

  test "path rootless" do
    assert_uri(
      'http:a',
      %Res{
        scheme: 'http',
        segments: ['a'],
        type: :path_rootless
      }
    )
  end

  test "simple ipv6" do
    Enum.map [
      '::',
      '::1',
      '::1:2',
      '::1.2.3.4',
      '::1:2:3',
      '::1:1.2.3.4',
      '::1:2:3:4',
      '::1:2:1.2.3.4',
      '::1:2:3:4:5',
      '::1:2:3:1.2.3.4',
      '::1:2:3:4:5:6:7',
      '::1:2:3:4:5:1.2.3.4',
      '::1:2:3:4:5:6',
      '::1:2:3:4:1.2.3.4',
      '1:2:3:4:5:6:7::',
      '1:2:3:4:5:6::7',
      '1:2:3:4:5::6:7',
      '1:2:3:4:5::6:7',
      '1:2:3:4:5::1.2.3.4',
      '1:2:3:4::5:6:7',
      '1:2:3:4::5:1.2.3.4',
      '1:2:3::4:5:6:7',
      '1:2:3::4:5:1.2.3.4',
      '1:2::3:4:5:6:7',
      '1:2::3:4:5:1.2.3.4',
      '1::2:3:4:5:6:7',
      '1::2:3:4:5:1.2.3.4',
      '1:2:3:4:5:6:7:8',
      '1:2:3:4:5:6:1.2.3.4',
      'FE80:0000:0000:0000:0202:B3FF:FE1E:8329',
      'FE80::0202:B3FF:FE1E:8329',
      '2607:f0d0:1002:51::4'
    ], fn(host) ->
      assert_uri(
        'http://[' ++ host ++ ']:8812/docs',
        %Res{
          scheme: 'http',
          host_type: :ipv6,
          host: host,
          port: 8812,
          segments: ['docs'],
          type: :authority
        }
      )
    end
  end

  test "full with domain name" do
    assert_uri(
      'http://user:pass@elixir-lang.org:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment',
      %Res{
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
        type: :authority
      }
    )
  end

  test "ipv4" do
    assert_uri(
      'http://192.168.0.1',
      %Res{
        scheme: 'http',
        host_type: :ipv4,
        host: '192.168.0.1',
        type: :authority
      }
    )

    assert_uri(
      'http://192.168.0.1/',
      %Res{
        scheme: 'http',
        host_type: :ipv4,
        host: '192.168.0.1',
        type: :authority
      }
    )
  end

  test "full with ipv4" do
    assert_uri(
      'http://user:pass@192.168.0.1:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment',
      %Res{
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
        type: :authority
      }
    )
  end

  test "full with ipv future" do
    assert_uri(
      'http://user:pass@[v1.fe80::a+en1]:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment',
      %Res{
        scheme: 'http',
        host_type: :ipv_future,
        host: 'v1.fe80::a+en1',
        port: 8812,
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        query_string: %{'k1%2A' => 'v1', 'k2' => 'v2'},
        fragment: 'fragment',
        userinfo: 'user:pass',
        username: 'user',
        password: 'pass',
        query: 'k1%2A=v1&k2=v2',
        type: :authority
      }
    )
  end

  test "no user info" do
    assert_uri(
      'http://[v1.fe80::a+en1]:8812/docs/stable/elixir/Enum.html?k1%2A=v1&k2=v2#fragment',
      %Res{
        scheme: 'http',
        host_type: :ipv_future,
        host: 'v1.fe80::a+en1',
        port: 8812,
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        query_string: %{'k1%2A' => 'v1', 'k2' => 'v2'},
        fragment: 'fragment',
        userinfo: nil,
        username: nil,
        password: nil,
        query: 'k1%2A=v1&k2=v2',
        type: :authority
      }
    )
  end

  test "ssh without pass" do
    assert_uri(
      'ssh://user@elixir-lang.org:8812/docs/stable/elixir/Enum.html?k1?%2A=v1&k2=v2&k3&k4#fragment/other_fragment%2F??',
      %Res{
        scheme: 'ssh',
        host_type: :reg_name,
        host: 'elixir-lang.org',
        port: 8812,
        segments: ['docs', 'stable', 'elixir', 'Enum.html'],
        query_string: %{'k1?%2A' => 'v1', 'k2' => 'v2', 'k3' => nil, 'k4' => nil},
        fragment: 'fragment/other_fragment%2F??',
        userinfo: 'user',
        username: 'user',
        password: nil,
        query: 'k1?%2A=v1&k2=v2&k3&k4',
        type: :authority
      }
    )
  end

  test "ssh with pass" do
    assert_uri(
      'ssh://user:pass@elixir-lang.org:8812/docs/stable/elixir/Enum.html?k1?%2A=v1&k2=v2&k3&k4#fragment/other_fragment%2F??',
      %Res{
        scheme: 'ssh',
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
        type: :authority
      }
    )
  end

  defp assert_uri(uri, result) do
    Logger.debug "Testing: #{inspect uri}"
    {_, _, r} = RFC3986.parse uri
    assert result === r
  end
end
