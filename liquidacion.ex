defmodule Liquidacion do
  @moduledoc """
  Módulo que calcula el valor de los lotes válidos, y aplica bonificación o descuento al valor final de cada lote según el porcentaje de defectos.
  - version: 1.0
  - autor: Julian Andres Ladino Nossa
  - fecha: 2026-04-10
  """

  # Valor consatante de cada prenda
  @precio_prenda 3200

  # Bonificación adicional por mas de 120 prendas en el día)
  @bonus_produccion 18000

  # Valor del alquiler
  @valor_alquiler 15000

  @doc """
  Filtra los lotes válidos por confeccionista, agrupa por día y calcula el valor
  de cada lote individual. La bonificación por producción se aplica una sola vez
  por día si el total de prendas del día supera 120.

  Retorna una lista de mapas por día con sus lotes calculados y el bonus diario.
  """

  def calcular_valor_lotes_por_confeccionista(lotes_validos, confeccionista) do
    lotes_validos
    |> Enum.filter(fn lote -> lote.confeccionista == confeccionista end)
    |> Enum.group_by(fn lote -> lote.dia end)
    |> Enum.map(fn {dia, lotes_del_dia} ->

      # Total de prendas producidas ese día
      total_prendas_dia = Enum.reduce(lotes_del_dia, 0, fn lote, acc -> acc + lote.prendas end)

      # Bonificación diaria se aplica una sola vez si supera las 120 prendas
      bonificacion_dia = if total_prendas_dia > 120, do: @bonus_produccion, else: 0

      # Calcula el valor individual de cada lote
      lotes_calculados =
        Enum.map(lotes_del_dia, fn lote ->
          valor_base = lote.prendas * @precio_prenda
          factor =
            cond do
              lote.defectos < 0.02 -> 1.07 # Hasta 2%  -> Bonificacion del 7%
              lote.defectos < 0.05 -> 1.00 # Hasta 5%  -> Sin ajuste
              lote.defectos < 0.10 -> 0.88 # Hasta 10% -> Descuento del 12%
              lote.defectos > 0.10 -> 0.75 # Mas de 10% -> Descuento del 25%
              true -> 1.00
            end
          valor_final = valor_base * factor
          %{linea: lote.linea, prendas: lote.prendas, defectos: lote.defectos, valor_base: valor_base, factor: factor, valor_final: valor_final}
        end)
      subtotal_lotes = Enum.reduce(lotes_calculados, 0, fn l, acc -> acc + l.valor_final end)
      %{dia: dia, total_prendas: total_prendas_dia, lotes: lotes_calculados, bonificacion_dia: bonificacion_dia,total_dia: subtotal_lotes + bonificacion_dia}
    end)
    |> Enum.sort_by(fn dia_info -> dia_info.dia end)
  end

  @doc """
  Suma el valor total de todos los lotes de un confeccionista.
  """
  def total_lotes(dias_calculados) do
    Enum.reduce(dias_calculados, 0, fn dia_info, acc -> acc + dia_info.total_dia end)
  end

  @doc """
  Calcula el pago final al confeccionista:
    total_bruto = suma de todos los lotes + bonificaciones por día
    descuento_alquiler = 15 000 × días trabajados
    total_neto  = total_bruto - descuento_alquiler
  """

  def liquidar_confeccionista(dias_calculados) do
    total_bruto = total_lotes(dias_calculados)
    dias_trabajados = length(dias_calculados)
    descuento_alquiler = dias_trabajados * @valor_alquiler
    total_neto = total_bruto - descuento_alquiler
    %{total_bruto: total_bruto, dias_trabajados: dias_trabajados, descuento_alquiler: descuento_alquiler, total_neto: total_neto}
  end
end
