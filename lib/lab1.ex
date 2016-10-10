defmodule Lab1 do
  @attributes [
    "Жизненная форма",
    "Окраска листа",
    "Форма листа",
    "Поверхность",
    "Размер листа",
    "Размер цветка",
    "Название"
  ]

  def start(_, _) do
    { :ok, self }
  end

  def start_play do
    play(3)
  end

  def play(tries_count) do
    attr_values = open_file_db
    # samples_mapped_to_attrs = attr_values |> map_samples_to_attrs
    db = [@attributes|attr_values]
    do_play(tries_count, db)
  end

  defp do_play(tries_count, db) when tries_count > 0 do
    all_values = build_all_values(db)
    available_values = build_available_values(db)
    devisor = Processor.find_devisor(all_values, available_values)
    # IO.puts "debug"
    # IO.inspect db
    # IO.inspect all_values
    # IO.inspect available_values
    # IO.puts "end of debug"
    player_decision = devisor |> play_decision
    do_play(tries_count - 1, Enum.filter(db, player_decision))
  end

  defp do_play(_tries_count, db) do
    db |> collect_rest_vals |> conclude
  end

  defp play_decision({ devisor_domain, devisor_value, devisor_freq, devisor_domain_index }) do
    decide = fn(ans) ->
      case ans do
        "y\n" ->
          fn(x) -> Enum.at(x, devisor_domain_index) == devisor_value || Enum.at(x, devisor_domain_index) == devisor_domain end
        "n\n" ->
          fn(x) -> Enum.at(x, devisor_domain_index) != devisor_value || Enum.at(x, devisor_domain_index) == devisor_domain end
        _ ->
          IO.puts "Нужно выбрать y или n!";
          play_decision({ devisor_domain, devisor_value, devisor_freq, devisor_domain_index })
      end
    end
    "У вашего цветка #{devisor_domain} #{devisor_value} (FREQ OF ERROR: #{devisor_freq}) ? [y/n]"
    |> IO.gets
    |> decide.()
  end

  defp collect_rest_vals(db) do
    Enum.map(db, fn(row) -> row |> Enum.at(-1) end) |> tl |> Enum.join(",")
  end

  defp conclude(vals) do
    "Ваше предполагаемое растение(-я): [#{vals}]"
  end

  @doc """
  From given array of arrays where last element - name of sample,
  build list of tuples, where:
  { sample name, [attr1, attr2, ..]}
  """
  def map_samples_to_attrs(l) do
    for line <- l do
      { Enum.at(line, -1), Enum.slice(line, 0..-2) }
    end
  end

  @doc """
  Separates given db from list of lists to list of tuples,
  in following format without duplicates.

  ## Examples:
  [
  {"attribute_name", ["val1", "val2", ...]},
  ...
  ]
  """
  def build_available_values(db) do
    db
    |> transpose
    |> Enum.map(&assign_attrib_to_vals(&1))
    |> dup
  end

  @doc """
  Separates given db from list of lists to list of tuples,
  in following format.

  ## Examples:
  [
  {"attribute_name", ["val1", "val2", ...]},
  ...
  ]
  """
  def build_all_values(db) do
    db
    |> transpose
    |> Enum.map(&assign_attrib_to_vals(&1))
  end

  defp open_file_db do
    File.stream!('data.csv') |> CSV.decode |> Enum.to_list
  end

  defp transpose(l) do
    l |> List.zip |> Stream.map(&Tuple.to_list(&1))
  end

  defp dup(l) do
    l |> Enum.map(fn { type, vals } ->
      { type, Enum.uniq(vals) }
    end)
  end

  defp assign_attrib_to_vals(x), do: { hd(x), tl(x) }
end
