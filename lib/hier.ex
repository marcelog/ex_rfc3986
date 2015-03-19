defmodule RFC3986.Hier do
  alias RFC3986.PathSegment, as: PathSegment
  alias RFC3986.Authority, as: Authority

  #hier-part     = "//" authority path-abempty
  #               / path-absolute
  #               / path-rootless
  #               / path-empty
  def parse(state = %{error: error}) when error != nil do
    state
  end

  # path-empty    = 0<pchar>
  def parse(state = %{text: []}) do
    %{state | type: :path_empty}
  end

  # "//" authority path-abempty
  # path-abempty  = *( "/" segment )
  def parse(state = %{text: [?/,?/|rest]}) do
    %{state | type: :authority, text: rest} |>
      Authority.parse |>
      PathSegment.segments
  end

  # path-absolute = "/" [ segment-nz *( "/" segment ) ]
  def parse(state = %{text: [?/, char|rest]}) do
    %{state | type: :path_absolute, text: [char|rest]} |>
      PathSegment.segment_nz |>
      PathSegment.segments
  end

  def parse(state = %{text: [?/]}) do
    %{state | type: :path_absolute, text: []}
  end

  # path-rootless = segment-nz *( "/" segment )
  def parse(state) do
    %{state | type: :path_rootless} |>
      PathSegment.segment_nz |>
      PathSegment.segments
  end
end
