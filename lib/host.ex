defmodule RFC3986.Host do
  require Logger
  alias RFC3986.Generic, as: Generic

  # host          = IP-literal / IPv4address / reg-name
  def parse(state = %{error: error}) when error != nil do
    state
  end

  # IP-literal    = "[" ( IPv6address / IPvFuture  ) "]"
  def parse(state = %{text: [?[,?v|_rest]}) do
    ipv_future %{state | host_type: :ipv_future}
  end

  def parse(state = %{text: [?[,_char|_rest]}) do
    ipv6_address state
  end

  def parse(state) do
    ipv4_address_or_host state
  end

  # port          = *DIGIT
  def parse_port(state = %{error: error}) when error != nil do
    state
  end

  def parse_port(state = %{text: [?:|rest]}) do
    parse_port %{state | text: rest}, []
  end

  def parse_port(state) do
    state
  end

  defp parse_port(state = %{text: []}, []) do
    %{state | error: {:missing_port_number, []}}
  end

  defp parse_port(state = %{text: []}, acc) do
    %{state | port: Enum.reverse(acc)}
  end

  defp parse_port(state = %{text: [char|rest]}, acc) do
    if Generic.digit?(char) do
      parse_port %{state | text: rest}, [char|acc]
    else
      %{state | port: Enum.reverse(acc)}
    end
  end
  # IPv6address   =                            6( h16 ":" ) ls32
  #               /                       "::" 5( h16 ":" ) ls32
  #               / [               h16 ] "::" 4( h16 ":" ) ls32
  #               / [ *1( h16 ":" ) h16 ] "::" 3( h16 ":" ) ls32
  #               / [ *2( h16 ":" ) h16 ] "::" 2( h16 ":" ) ls32
  #               / [ *3( h16 ":" ) h16 ] "::"    h16 ":"   ls32
  #               / [ *4( h16 ":" ) h16 ] "::"              ls32
  #               / [ *5( h16 ":" ) h16 ] "::"              h16
  #               / [ *6( h16 ":" ) h16 ] "::"
  defp ipv6_address(state = %{error: error}) when error != nil do
    state
  end

  defp ipv6_address(_state) do
    raise "ipv6 not supported yet"
  end

  # IPvFuture     = "v" 1*HEXDIG "." 1*( unreserved / sub-delims / ":" )
  # https://tools.ietf.org/html/draft-sweet-uri-zoneid-01
  # [v1.fe80::a+en1]
  defp ipv_future(state = %{error: error}) when error != nil do
    state
  end

  defp ipv_future(state = %{text: [?[, ?v, char, ?.|rest]}) do
    if Generic.hex_digit?(char) do
      ipv_future %{state | text: rest}, [?., char, ?v, ?[]
    else
      %{state | error: {:invalid_ipv_future}}
    end
  end

  defp ipv_future(state) do
    %{state | error: {:invalid_ipv_future, state.text}}
  end

  defp ipv_future(state = %{text: [?]|rest]}, acc) do
    %{state | host: Enum.reverse([?]|acc]), host_type: :ipv_future, text: rest}
  end

  defp ipv_future(state = %{text: []}, _acc) do
    %{state | error: {:invalid_ipv_future, []}}
  end

  defp ipv_future(state = %{text: [char|rest] = text}, acc) do
    if Generic.unreserved?(char) or
      Generic.sub_delims?(char) or
      char == ?: do
        ipv_future %{state | text: rest}, [char|acc]
    else
      %{state | error: {:invalid_ipv_future, text}}
    end
  end

  defp ipv4_address_or_host(state = %{error: error}) when error != nil do
    state
  end

  defp ipv4_address_or_host(state) do
    case ipv4_address state do
      nil -> reg_name state
      state -> state
    end
  end

  # IPv4address   = dec-octet "." dec-octet "." dec-octet "." dec-octet
  defp ipv4_address(state) do
    case octets state.text do
      {ip, []} when ip !== nil -> %{state | host_type: :ipv4, host: ip, text: []}
      {ip, [?:|_] = rest} when ip !== nil -> %{state | host_type: :ipv4, host: ip, text: rest}
      {ip, [?/|_] = rest} when ip !== nil -> %{state | host_type: :ipv4, host: ip, text: rest}
      _ -> nil
    end
  end

  defp octets(text) do
    octets text, []
  end

  defp octets(text, acc) when length(acc) < 4 do
    case dec_octet text do
      {octet, [?.|rest]} when octet !== nil -> octets rest, [octet|acc]
      {octet, rest} when octet !== nil -> octets rest, [octet|acc]
      _ -> nil
    end
  end

  defp octets(rest, acc) when length(acc) == 4 do
    {to_char_list(Enum.join Enum.reverse(acc), "."), rest}
  end

  # dec-octet     = DIGIT                 ; 0-9
  #               / %x31-39 DIGIT         ; 10-99
  #               / "1" 2DIGIT            ; 100-199
  #               / "2" %x30-34 DIGIT     ; 200-249
  #               / "25" %x30-35          ; 250-255
  defp dec_octet([?2, ?5, char|rest]) when char >= ?0 and char <= ?5 do
    {[?2, ?5, char], rest}
  end

  defp dec_octet([?2, char1, char2|rest]) when
    char1 >= ?0 and char1 <= ?4 and char2 >= ?0 and char2 <= ?9 do
    {[?2, char1, char2], rest}
  end

  defp dec_octet([?1, char1, char2|rest]) when
    char1 >= ?0 and char1 <= ?9 and char2 >= ?0 and char2 <= ?9 do
    {[?1, char1, char2], rest}
  end

  defp dec_octet([?1, char1|rest]) when char1 >= ?0 and char1 <= ?9 do
    {[?1, char1], rest}
  end

  defp dec_octet([char|rest]) when char >= ?0 and char <= ?9 do
    {[char], rest}
  end

  defp dec_octet(text) do
    {nil, text}
  end

  # reg-name      = *( unreserved / pct-encoded / sub-delims )
  defp reg_name(state = %{error: error}) when error != nil do
    state
  end

  defp reg_name(state) do
    reg_name state, []
  end

  defp reg_name(state = %{text: []}, acc) do
    %{state | host_type: :reg_name, host: Enum.reverse(acc), text: []}
  end

  defp reg_name(state = %{text: [char|rest] = text}, acc) do
    if Generic.unreserved?(char) or
      Generic.pct_encoded?(text) or
      Generic.sub_delims?(char) do
        reg_name %{state | text: rest}, [char|acc]
    else
      %{state | host_type: :reg_name, host: Enum.reverse(acc), text: text}
    end
  end
end
