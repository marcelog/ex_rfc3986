defmodule RFC3986.Result do
  @moduledoc """
  Capture result. All the URI info is stored here.

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

  defstruct scheme: nil,
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

  @type t :: %RFC3986.Result{}
end