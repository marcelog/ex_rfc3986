defmodule RFC3986 do
  alias RFC3986.Normalize, as: Normalize
  @moduledoc """
  Main module. [A RFC3986](https://tools.ietf.org/html/rfc3986) compatible URI
  parser. Find the grammar in priv/RFC3986.txt.

      Copyright 2015 Marcelo Gornstein <marcelog@gmail.com>

      Licensed under the Apache License, Version 2.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      See the License for the specific language governing permissions and
      limitations under the License.
  """

  @doc """
  Call this one once, and before calling parse/1 so the grammar is parsed and
  stored for later use.
  """
  @spec init() :: :ok
  def init() do
    :rfc3986 = :ets.new :rfc3986, [
      {:write_concurrency, false},
      {:read_concurrency, true},
      :public,
      :named_table
    ]
    my_priv = :code.priv_dir :ex_rfc3986
    grammar = ABNF.load_file "#{my_priv}/RFC3986.abnf"
    true = :ets.insert :rfc3986, {:grammar, grammar}
    :ok
  end

  @doc """
  Parses a char_list and tries to find an URI.
  """
  @spec parse([byte]) :: nil | {[byte], [byte], RFC3986.Result.t}
  def parse(text) do
    [{:grammar, grammar}] = :ets.lookup :rfc3986, :grammar
    case ABNF.apply grammar, "uri", text, %RFC3986.Result{} do
      nil -> nil
      %ABNF.CaptureResult{
        string_text: matched,
        rest: rest,
        state: state
      } -> {matched, rest, Normalize.parse(state)}
    end
  end
end
