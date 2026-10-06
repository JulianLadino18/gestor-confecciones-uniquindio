# Integrantes: Daniel Gil Fino, Julián Andrés Ladino Nossa, Samuel Franco Salazar

defmodule Reportes do
    @moduledoc """
    Módulo que sirva para generar los reportes que se requieren del programa.
    - version: 1.0.1
    - autores: Daniel Gil Fino, Julián Andrés Ladino Nossa, Samuel Franco Salazar
    - fecha: 2026-04-10
    """

    # Meta diaria de producción del taller, en prendas
    @meta_diaria 600

   @doc """
  Desarrollo del reporte 1: Analiza los lotes rechazados y los agrupa según su motivo.

  Retorna un mapa con la lista original de lotes, el conteo agrupado por motivo y el total de rechazados.
  """

    def r1_lotes_rechazados(lotes_rechazados) do
        conteo_por_motivo =
            lotes_rechazados
            |> Enum.frequencies_by(fn {_lote, motivo} -> motivo end)
        #se utiliza el Enum.frequencies_by/2 para agrupar y contar
        #en una sola pasada para contar cuantas veces aparece cada :motivo de rechazo en la lista
            %{
                lotes: lotes_rechazados,
                conteo_por_motivo: conteo_por_motivo,
                total_rechazados: length(lotes_rechazados)
            }
    end

    @doc """
  Desarrollo del reporte 2: Calcula la productividad de cada línea de confección.
  Agrupa los lotes válidos por línea y divide el total de prendas entre los puestos de trabajo.

  Retorna una lista de mapas con la información de cada línea, ordenada de mayor a menor productividad.
  """

    def r2_productividad_lineas(lotes_validos, lista_lineas) do
        lotes_por_linea = Enum.group_by(lotes_validos, fn lote -> lote.linea end)

        lista_lineas
        |> Enum.map(fn linea ->
            lotes = Map.get(lotes_por_linea, linea.id, [])
            total_prendas = Enum.reduce(lotes, 0, fn lote, acc -> acc + lote.prendas end)
            productividad = if linea.puestos > 0, do: total_prendas / linea.puestos, else: 0.0

            %{
                id: linea.id,
                nombre: linea.nombre,
                puestos: linea.puestos,
                prendas: total_prendas,
                productividad: productividad
            }
        end)
        |> Enum.sort_by(fn linea -> linea.productividad end, :desc)

    end

   @doc """
  Desarrollo del reporte 3: Consolida la producción diaria de todo el taller.
  Agrupa los lotes por día y verifica si se alcanzó la meta mínima de 600 prendas.

  Retorna un mapa con el detalle por día, el consolidado de prendas y los indicadores de cumplimiento.
  """

    def r3_produccion_diaria(lotes_validos) do
        lotes_por_dia = Enum.group_by(lotes_validos, fn lote -> lote.dia end)

    mapa_diario =
        1..6
        |>Enum.map(fn dia ->
            lotes = Map.get(lotes_por_dia, dia, [])
            total_prendas = Enum.reduce(lotes, 0, fn lote, acc -> acc + lote.prendas end)
            {dia, %{prendas: total_prendas, alcanzo_meta?: total_prendas >= @meta_diaria}}
        end)
        |> Map.new()

        #extrayendo solo el numero de prendas por dia para c.2
        prendas_por_dia = mapa_diario |> Enum.map(fn {dia, info} -> {dia, info.prendas} end) |> Map.new()

        meta_todos = Enum.all?(mapa_diario, fn {_dia, info} -> info.alcanzo_meta? end)
        meta_almenos_uno = Enum.any?(mapa_diario, fn {_dia, info} -> info.alcanzo_meta? end)

        %{
            detalle_diario: mapa_diario,
            mapa_prendas_diarias: prenas_por_dia,
            cumpli_todos_los_dias?: meta_todos,
            cumpli_almenos_un_dia?: meta_almenos_uno
        }
    end

    # Desarrollo del reporte 4: Generar el pago de todo los confeccionistas y ordenarlos de manera descendente.

    def r4_liquidacion_confeccionistas_ordenada(liquidaciones) do
        # Ordenar de mayor a menor según el neto a pagar.
        liquidaciones
            |> Enum.sort_by(&(&1.neto), :desc)
            |> Enum.with_index(1)
            |> Enum.map(fn {liq, idx} -> Map.put(liq, :posicion, idx) end)
    end

    @doc """
  Desarrollo del reporte 5: Identifica a los confeccionistas con mayor producción cada día
  y determina al líder semanal (el que ganó más días).

  Retorna un mapa con los ganadores diarios detallados y el ganador definitivo de la semana.
  """

    def r5_ganadores_diarios(lotes_validos, _lista_confeccionistas) do
        lotes_por_dia = Enum.group_by(lotes_validos, fn lote -> lote.dia end)

    resultados_por_dia =
        1..6
        |>Enum.map(fn dia ->
            lotes_dia = Map.get(lotes_por_dia, dia, [])

            if lotes_dia == [] do
                {dia, :sin_lotes_validos}
            else

                prendas_por_confeccionista =
                    lotes_dia
                    |> Enum.group_by(fn lote -> lote.confeccionista end)
                    |> Enum.map(fn {confeccionista_cod, lotes} ->
                        total = Enum.reduce(lotes, 0, fn lote, acc -> acc + lote.prendas end)
                        {confeccionista_cod, total}
                    end)

                    max_prendas = prendas_por_confeccionista |> Enum.map(fn {_cod, prendas} -> prendas end) |> Enum.max()

                    ganadores_dia =
                        prendas_por_confeccionista
                        |> Enum.filter(fn {_confeccionista, prendas} -> prendas == max_prendas end)
                        |> Enum.map(fn {confeccionista_cod, _prendas} -> confeccionista_cod    end)

                    {dia, %{ganadores: ganadores_dia, max_prendas: max_prendas}}
            end
        end)
        |> Map.new()

        #Aqui se debe hacer cuantos dias gano cada confeccionista

        dias_ganados_por_confeccionista =
            resultados_por_dia
            |> Enum.flat_map(fn {_dia, res} ->
                case res do
                    :sin_lotes_validos -> []
                    %{ganadores: ganadores} -> ganadores
                end
            end)
            |> Enum.frequencies()

        lider_semanal =
            if dias_ganados_por_confeccionista == %{} do
                :ninguno
            else
                max_dias = dias_ganados_por_confeccionista |> Map.values() |> Enum.max()

                ganadores_semanales =
                    dias_ganados_por_confeccionista
                    |> Enum.filter(fn {_confeccionista, dias} -> dias == max_dias end)
                    |> Enum.map(fn {confeccionista_cod, _dias} -> confeccionista_cod end)

                %{confeccionistas: ganadores_semanales, dias_ganados: max_dias}
            end
        %{
            detalle_por_dia: resultados_por_dia,
            lider_semanal: lider_semanal
        }
    end

  @doc """
  Desarrollo del reporte 6: Evalúa la calidad de los confeccionistas.
  Filtra aquellos con al menos 3 lotes válidos y calcula el porcentaje de defectos ponderado.

  Retorna el mapa del confeccionista con el menor porcentaje de defectos ponderado, o :sin_candidatos_suficientes.
  """

    def r6_mejor_calidad(lotes_validos) do
        candidatos =
            lotes_validos
            |> Enum.group_by(fn lote -> lote.confeccionista end)
            |> Enum.filter(fn {_confeccionista, lotes} -> length(lotes) >= 3 end)

        if candidatos == [] do
            :sin_candidatos_suficientes
        else
            candidatos
                |> Enum.map(fn {confeccionista_cod, lotes} ->
                    suma_prendas= Enum.reduce(lotes, 0, fn lote, acc -> acc + lote.prendas end)

                    suma_defectos_ponderados = Enum.reduce(lotes, 0, fn lote, acc -> acc + (lote.defectos * lote.prendas) end)

                    porcentaje_ponderado = suma_defectos_ponderados / suma_prendas

                    %{
                        confeccionista: confeccionista_cod,
                        porcentaje_ponderado: porcentaje_ponderado,
                        total_lotes: length(lotes),
                        total_prendas: suma_prendas
                    }
                end)
                |> Enum.min_by(fn confeccionista-> confeccionista.porcentaje_ponderado end)
        end
    end

    #Desarrollo del reporte 7: Total que debe pagar el taller y el promedio por prenda

    def r7_total_neto(liquidaciones) do
        total_taller =
            Enum.reduce(liquidaciones, 0, fn liquidacion, acc -> acc + liquidacion.neto end)
        total_prendas =
            Enum.reduce(liquidaciones, 0, fn liquidacion, acc -> acc + liquidacion.prendas end)
        promedio_por_prenda = if total_prendas > 0, do: total_taller / total_prendas, else: :no_calculable
        %{total_a_pagar: total_taller, total_de_prenda: total_prendas, promedio_por_prenda: promedio_por_prenda}
    end

    @doc """
  Desarrollo del reporte 8: Verifica la versatilidad de los confeccionistas.
  Comprueba cuáles confeccionistas han trabajado en todas las líneas disponibles en el taller.

  Retorna una lista con los códigos de los confeccionistas que cumplen, o :ningun_confeccionista_cobertura_total.
  """
    def r8_cobertura_lineas(lotes_validos, lista_lineas) do
        codigos_lineas_totales = lista_lineas |> Enum.map(fn linea -> linea.id end) |> MapSet.new()

    confeccionistas_cumplen =
        lotes_validos
        |> Enum.group_by(fn lote -> lote.confeccionista end)
        |> Enum.filter(fn {_confeccionista, lotes} ->
            lineas_trabajadas = lotes |> Enum.map(fn lote -> lote.linea end) |> MapSet.new()
                MapSet.equal?(lineas_trabajadas, codigos_lineas_totales)
        end)
        |> Enum.map(fn {confeccionista_cod, _lotes} -> confeccionista_cod end)

        if confeccionistas_cumplen == [] do
            :ningun_confeccionista_cobertura_total
        else
            confeccionistas_cumplen
        end
    end

    # C.2 combinar la produccion diaria R3 con el mapa de taller_aliado

        def c2_combinacion_produccion_aliado(mapa_prendas_r3, taller_aliado) do
            Map.merge(mapa_prendas_r3, taller_aliado, fn _dia, prendas_r3, prendas_aliado -> prendas_r3 + prendas_aliado end)
        end
end
