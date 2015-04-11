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
defmodule RFC3986 do
  alias RFC3986.Normalize, as: Normalize
  @moduledoc """
  A RFC3986 compatible URI parser. Find the grammar in priv/RFC3986.txt.
  """

  @spec init() :: :ok
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
  @spec parse([byte]) :: nil | {[byte], [byte], Map}
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
