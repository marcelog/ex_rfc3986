defmodule RFC3986.Normalize do
  @moduledoc """
  Normalices a captured URI. Don't use this directly, it will be called after
  matching an input.

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

  # fragment      = *( pchar / "/" / "?" )
  @spec parse(RFC3986.Result.t) :: RFC3986.Result.t
  def parse(state = %{error: error}) when error != nil do
    state
  end

  def parse(state) do
    state |> port |> userinfo |> query_string
  end

  defp port(state = %{port: nil}) do
    state
  end

  defp port(state) do
    {p, _} = Integer.parse to_string(state.port)
    %{state | port: p}
  end

  defp userinfo(state = %{userinfo: nil}) do
    state
  end

  defp userinfo(state) do
    userinfo state, state.userinfo, []
  end

  defp userinfo(state, [char|rest], acc) do
    if char == ?: || Enum.empty?(rest) do
      if char !== ?:, do: acc = [char|acc]
      if Enum.empty?(rest), do: rest = nil

      %{state | username: Enum.reverse(acc), password: rest}
    else
      userinfo(state, rest, [char|acc])
    end
  end

  defp query_string(state = %{query: nil}) do
    state
  end

  defp query_string(state) do
    query_string state, state.query, []
  end

  defp query_string(state, [], []) do
    state
  end

  defp query_string(state = %{query_string: map}, [], acc) do
    k = Enum.reverse acc
    %{state | query_string: Map.put(map, k, nil)}
  end

  defp query_string(state = %{query_string: map}, [?&|rest], acc) do
    k = Enum.reverse acc
    query_string %{state | query_string: Map.put(map, k, nil)}, rest, []
  end

  defp query_string(state = %{query_string: map}, [?=|rest], acc) do
    k = Enum.reverse acc
    {v, rest} = query_string_value rest
    query_string %{state | query_string: Map.put(map, k, v)}, rest, []
  end

  defp query_string(state, [char|rest], acc) do
    query_string state, rest, [char|acc]
  end

  defp query_string_value([]) do
    {nil, []}
  end

  defp query_string_value(text) do
    query_string_value text, []
  end

  defp query_string_value([], []) do
    {nil, []}
  end

  defp query_string_value([], acc) do
    {Enum.reverse(acc), []}
  end

  defp query_string_value([?&|rest], acc) do
    {Enum.reverse(acc), rest}
  end

  defp query_string_value([char|rest], acc) do
    query_string_value rest, [char|acc]
  end
end
