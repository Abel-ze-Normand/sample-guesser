defmodule Processor do

  @doc """
  Function tries to find such value, that can split all given values on two almost
  equal batches. In other words, we try to find such value from such domain
  that will effectively split our given sample data

  Return: { devisor_domain, devisor_value, devisor_frequency, devisor_index }
  """
  def find_devisor all_vals, uniq_vals do
    do_find_devisor(all_vals, uniq_vals, 0, 1.0, "", "", {"", "", 1.0, 0})
  end

  defp do_find_devisor(
    all_vals,
    uniq_vals,
    trgt_index,
    min_devisor,
    domain_name,
    val_name,
    { devisor_domain, devisor_val, devisor_freq, curr_index }
  ) when devisor_freq < min_devisor do
    do_find_devisor(
      all_vals,
      uniq_vals,
      curr_index - 1,
      devisor_freq,
      devisor_domain,
      devisor_val,
      {"", "", 1.0, curr_index }
    )
  end

  defp do_find_devisor([h_all_vals|t_all_vals], [h_uniq_vals|t_uniq_vals], trgt_index, min_devisor, domain_name, val_name,
    { _, _, _, curr_index }) do

    { domain, all_vals_row } = h_all_vals
    { domain, uniq_vals_row } = h_uniq_vals

    # find relative frequences
    denominator = Enum.count(all_vals_row)
    frequences = for v <- uniq_vals_row do
      numerator = all_vals_row
      |> Enum.filter(&(&1 == v))
      |> Enum.count
      { v, abs(numerator / denominator - 0.5) }
    end

  { min_val_name, min_freq } = Enum.min_by(frequences, fn({_attr_val, freq}) -> freq end)

  do_find_devisor(
    t_all_vals,
    t_uniq_vals,
    trgt_index,
    min_devisor,
    domain_name,
    val_name,
    { domain, min_val_name, min_freq, curr_index + 1 }
  )
  end

  defp do_find_devisor([], [], trgt_index, min_devisor, domain_name, val_name, _tuple) do
    { domain_name, val_name, min_devisor, trgt_index }
  end
end
