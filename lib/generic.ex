defmodule RFC3986.Generic do

  def alpha?(char) do
    (char >= ?a and char <= ?z) or (char >= ?A and char <= ?Z)
  end

  def digit?(char) do
    char >= ?0 and char <= ?9
  end

  # pchar         = unreserved / pct-encoded / sub-delims / ":" / "@"
  def pchar?([char|_rest] = text) do
    unreserved?(char) or
    sub_delims?(char) or
    char == ?: or
    char == ?@ or
    pct_encoded?(text)
  end

  def unreserved?(char) do
    alpha?(char) or
    digit?(char) or
    char == ?- or
    char == ?. or
    char == ?_ or
    char == ?~
  end

  def hex_digit?(char) do
    digit?(char) or
    (char >= ?a and char <= ?f) or
    (char >= ?A and char <= ?F)
  end

  def pct_encoded?([?%, a, b|_]) do
    hex_digit?(a) and hex_digit?(b)
  end

  def pct_encoded?(_) do
    false
  end

  # sub-delims    = "!" / "$" / "&" / "'" / "(" / ")"
  #               / "*" / "+" / "," / ";" / "="
  def sub_delims?(?!) do
    true
  end

  def sub_delims?(?$) do
    true
  end

  def sub_delims?(?&) do
    true
  end

  def sub_delims?(?') do
    true
  end

  def sub_delims?(?() do
    true
  end

  def sub_delims?(?)) do
    true
  end

  def sub_delims?(?@) do
    true
  end

  def sub_delims?(?*) do
    true
  end

  def sub_delims?(?+) do
    true
  end

  def sub_delims?(?,) do
    true
  end

  def sub_delims?(?;) do
    true
  end

  def sub_delims?(?=) do
    true
  end

  def sub_delims?(_) do
    false
  end
end
