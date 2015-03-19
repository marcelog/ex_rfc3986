defmodule RFC3986.PathSegment do
  alias RFC3986.Generic, as: Generic

  # segment-nz    = 1*pchar
  def segment_nz(state = %{text: []}) do
    %{state | error: {:empty_rootless_path}}
  end

  def segment_nz(state) do
    segment_nz state, []
  end

  defp segment_nz(state = %{text: [?/|rest]}, acc) do
    %{state | text: rest, segments: [Enum.reverse(acc)]}
  end

  defp segment_nz(state = %{text: []}, acc) do
    %{state | text: [], segments: [Enum.reverse(acc)]}
  end

  defp segment_nz(state = %{text: [char|rest] = text}, acc) do
    if Generic.pchar?(text) do
      segment_nz %{state | text: rest}, [char|acc]
    else
      %{state | error: {:invalid_rootless_path, text}}
    end
  end

  # segment       = *pchar
  def segments(state = %{error: error}) when error != nil do
    state
  end

  def segments(state = %{text: [?/|rest]}) do
    segments %{state | text: rest}, [], []
  end

  def segments(state) do
    segments state, [], []
  end

  defp segments(state = %{text: [], segments: old_segments}, [], segments_acc) do
    %{state | segments: old_segments ++ Enum.reverse(segments_acc)}
  end

  defp segments(state = %{text: [], segments: old_segments}, segment_acc, segments_acc) do
    segment = Enum.reverse segment_acc
    all_segments = [segment|segments_acc]
    %{state | segments: old_segments ++ Enum.reverse(all_segments)}
  end

  defp segments(state = %{text: [?/|rest]}, segment_acc, segments_acc) do
    segment = Enum.reverse segment_acc
    all_segments = [segment|segments_acc]
    segments %{state | text: rest}, [], all_segments
  end

  defp segments(state = %{text: [char|rest] = text, segments: old_segments}, segment_acc, segments_acc) do
    if Generic.pchar?(text) do
      segments %{state | text: rest}, [char|segment_acc], segments_acc
    else
      case segment_acc do
        [] -> %{state | text: text, segments: old_segments ++ Enum.reverse(segments_acc)}
        _ ->
          segment = Enum.reverse segment_acc
          all_segments = [segment|segments_acc]
          %{state | text: text, segments: old_segments ++ Enum.reverse(all_segments)}
      end
    end
  end
end