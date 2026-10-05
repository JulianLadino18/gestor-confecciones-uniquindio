# Integrantes: Daniel Gil Fino, Julián Andrés Ladino Nosa, Samuel Franco Salazar

defmodule Liquidacion do
  @moduledoc """
  Módulo que calcula el valor de los lotes válidos, y aplica bonificación o descuento al valor final de cada lote según el porcentaje de defectos.
  - version: 1.0
  - autor: Julian Andres Ladino Nossa
  - fecha: 2026-04-10
  """

  # Valor consatante de cada prenda
  @precio_prenda 3200

  # Bonificación adicional por 120 ó más prendas en el día
  @bonus_produccion 18000
  @prendas_para_bonificacion 120

  # Valor del alquiler
  @valor_alquiler 15000

  @doc """
  Filtra los lotes válidos por confeccionista, agrupa por día y calcula el valor
  de cada lote individual. La bonificación por producción se aplica una sola vez
  por día si el total de prendas del día llega a 120 o más.

  Retorna una lista de mapas por día con sus lotes calculados y el bonus diario.
  """

  def calcular_valor_lotes_por_confeccionista(lotes_validos, confeccionista) do
    lotes_validos
    |> Enum.filter(fn lote -> lote.confeccionista == confeccionista end)
    |> Enum.group_by(fn lote -> lote.dia end)
    |> Enum.map(fn {dia, lotes_del_dia} ->

      # Total de prendas producidas ese día
      total_prendas_dia = Enum.reduce(lotes_del_dia, 0, fn lote, acc -> acc + lote.prendas end)

      # Bonificación diaria: se aplica una sola vez si el día llega a 120 prendas o más
      bonificacion_dia = bonificacion_diaria(total_prendas_dia)

      # Calcula el valor individual de cada lote
      lotes_calculados =
        Enum.map(lotes_del_dia, fn lote ->
          valor_base = lote.prendas * @precio_prenda
          factor = factor_por_defectos(lote.defectos)
          valor_final = valor_lote(lote)
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
    descuento_alquiler = 15 000 × días trabajados (solo si usa máquina del taller)
    total_neto  = total_bruto - descuento_alquiler
  """

  def liquidar_confeccionista(dias_calculados, alquila?) do
    total_bruto = total_lotes(dias_calculados)
    dias_trabajados = length(dias_calculados)
        descuento_alquiler = calcular_alquiler(alquila?, dias_trabajados)
    total_neto = total_bruto - descuento_alquiler
    %{total_bruto: total_bruto, dias_trabajados: dias_trabajados, descuento_alquiler: descuento_alquiler, total_neto: total_neto}
  end

    @doc """
  Liquida a un confeccionista a partir de su mapa (`codigo`, `nombre`, `alquiler`)
  y de sus lotes válidos. Devuelve un mapa con `codigo`, `nombre`, `prendas`,
  `bruto` (suma de los lotes, sin bonificaciones ni alquiler), `bonificaciones`,
  `alquiler` y `neto`. Si no tiene lotes, todos los valores son cero.
  """
  def liquidar(confeccionista, lotes_validos) do
    dias_calculados =
      calcular_valor_lotes_por_confeccionista(lotes_validos, confeccionista.codigo)

    resumen = liquidar_confeccionista(dias_calculados, confeccionista.alquiler)
    bonificaciones = Enum.reduce(dias_calculados, 0, fn dia, acc -> acc + dia.bonificacion_dia end)
    prendas = Enum.reduce(dias_calculados, 0, fn dia, acc -> acc + dia.total_prendas end)

    %{
      codigo: confeccionista.codigo,
      nombre: confeccionista.nombre,
      prendas: prendas,
      bruto: resumen.total_bruto - bonificaciones,
      bonificaciones: bonificaciones,
      alquiler: resumen.descuento_alquiler,
      neto: resumen.total_neto
    }
  end

  @doc """
  Calcula el valor de un lote: prendas por tarifa base, ajustado según el
  porcentaje de defectos. El porcentaje se recibe en puntos porcentuales (1.5 es 1,5 %).
  """
  def valor_lote(lote) do
    lote.prendas * @precio_prenda * factor_por_defectos(lote.defectos)
  end

  @doc """
  Devuelve la bonificación de un día: 18.000 si se acumulan 120 prendas o más, y 0 si no.
  """
  def bonificacion_diaria(prendas_del_dia) when prendas_del_dia >= @prendas_para_bonificacion,
    do: @bonus_produccion

  def bonificacion_diaria(_prendas_del_dia), do: 0

  @doc """
  Devuelve el alquiler: 15.000 por día trabajado si el confeccionista usa
  máquina del taller (`true`), y 0 si usa la propia (`false`).
  """
  def calcular_alquiler(true, dias_trabajados), do: dias_trabajados * @valor_alquiler
  def calcular_alquiler(false, _dias_trabajados), do: 0

  # Hasta 2 %: +7 %. Hasta 5 %: sin ajuste. Hasta 10 %: -12 %. Más de 10 %: -25 %.
  defp factor_por_defectos(defectos) do
    cond do
      defectos <= 2 -> 1.07
      defectos <= 5 -> 1.00
      defectos <= 10 -> 0.88
      true -> 0.75
    end
  end
end
