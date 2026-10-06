defmodule Programa do
  @moduledoc """
  Módulo principal que ejecuta la coordinación y presentación visual del sistema de Gestión de Producción del Taller de Confecciones.
  - version: 1.0
  - autor: Samuel Franco Salazar, Julián Andrés Ladino Nossa
  - fecha: 2026-05-10
  """
    def main do
    IO.puts("==================================================")
    IO.puts("   GESTION DE PRODUCCION - TALLER DE CONFECCIONES   ")
    IO.puts("==================================================\n")

    # Mapas indexados por código e id, construidos una sola vez
    confeccionistas = for c <- Datos.confeccionistas(), into: %{}, do: {c.codigo, c}
    lineas = for l <- Datos.lineas(), into: %{}, do: {l.id, l}

    # Se validan todos los lotes antes de efectuar cualquier cálculo
    {lotes_validos, lotes_rechazados} =
      Validacion.validar_lotes(Datos.lotes(), confeccionistas, lineas)

    # Liquidación de TODOS los confeccionistas, incluso de quienes no tienen lotes
    lotes_por_confeccionista = Enum.group_by(lotes_validos, fn lote -> lote.confeccionista end)

    liquidaciones =
      for {codigo, confeccionista} <- confeccionistas do
        Liquidacion.liquidar(confeccionista, Map.get(lotes_por_confeccionista, codigo, []))
      end

      # Reporte 1: Lotes rechazados

      IO.puts("--- R1: LOTES RECHAZADOS ---")
      r1 = Reportes.r1_lotes_rechazados(lotes_rechazados)
      if r1.total_rechazados == 0 do
        IO.puts("No hay lotes rechazados.")
      else
       enum.each(r1.conteo_por_motivo, fn {motivo, cantidad} ->
          IO.puts("- #{motivo}: #{cantidad} lote(s)")
        end)
        IO.puts("Total de lotes rechazados: #{r1.total_rechazados}")
      end
      IO.puts("==================================================\n")

      # Reporte 2: Productividad por línea
      IO.puts("--- R2: PRODUCTIVIDAD POR LÍNEA ---")
      r2 = Reportes.r2_productividad_lineas(lotes_validos, Datos.lineas())
      Enum.each(r2, fn l ->
        IO.puts("- Linea #{l.codigo} (#{l.nombre}): #{l.prendas} prendas. Productividad: #{l.productividad}")
      end)
      IO.puts("==================================================\n")

    # Reporte 3: Producción diaria

    IO.puts("--- R3: PRODUCCIÓN DIARIA DEL TALLER BASE ---")
    r3 = Reportes.r3_produccion_diaria(lotes_validos)
    Enum.each(1..6 , fn dia ->
      info = r3.detalle_diario[dia]
      estado = if info.alcanzo_meta?, do: "Cumplió", else: "No cumplió"
      IO.puts("Día #{dia}: #{info.prendas} prendas(#{estado})")
    end)
    IO.puts("Alcanzó la meta todos los días? #{if r3.cumpli_todos_los_dias?, do: "Sí", else: "No"}")
    IO.puts("Alcanzó la meta al menos un día? #{if r3.cumpli_al_menos_un_dia?, do: "Sí", else: "No"}")
    IO.puts("==================================================\n")

# Reporte 4: Liquidación Ordenada

    IO.puts("--- R4: LIQUIDACIÓN DE CONFECCIONISTAS ---")
    r4 = Reportes.r4_liquidacion_confeccionistas_ordenada(liquidaciones)
    Enum.each(r4, fn c ->
      IO.puts("#{c.posicion}. #{c.codigo} - #{c.nombre}: Neto a pagar: #{Util.formatear_dinero(c.neto)}")
      IO.puts("   Prendas: #{c.prendas} | Bruto: #{Util.formatear_dinero(c.bruto)} | Bonos: #{Util.formatear_dinero(c.bonificaciones)} | Alquiler: #{Util.formatear_dinero(c.alquiler)}")
    end)
    IO.puts("==================================================\n")

    # Reporte 5: Ganadores diarios y líder semanal

    IO.puts("--- R5: GANADORES DIARIOS Y LÍDER SEMANAL ---")
    r5 = Reportes.r5_ganadores_diarios(lotes_validos, Datos.confeccionistas())
    Enum.each(1..6, fn dia ->
      case r5.detalle_por_dia[dia] do
        :sin_lotes_validos -> IO.puts("Día #{dia}: Sin producción")
        %{ganadores: g, max_prendas: max} -> IO.puts("Día #{dia}: #{Enum.join(g, ", ")} con #{max} prendas")
      end
    end)
    IO.puts("-> LÍDER(ES) SEMANAL(ES): #{Enum.join(r5.lider_semanal.confeccionistas, ", ")} con #{r5.lider_semanal.dias_ganados} día(s) ganado(s)")
    IO.puts("==================================================\n")

    # Reporte 6: Mejor Calidad

    IO.puts("--- R6: MEJOR CALIDAD (Mínimo 3 lotes) ---")
    r6 = Reportes.r6_mejor_calidad(lotes_validos)
    if r6 == :sin_candidatos_suficientes do
      IO.puts("Ningún confeccionista cumplió el requisito de tener 3 o más lotes.")
    else
      IO.puts("Ganador: #{r6.confeccionista}")
      IO.puts("Porcentaje de defectos ponderado: #{r6.porcentaje_ponderado}%")
      IO.puts("Total prendas: #{r6.total_prendas} en #{r6.total_lotes} lotes.")
    end
    IO.puts("==================================================\n")

    # Reporte 7: Resumen del taller

    IO.puts("--- R7: TOTALES DEL TALLER ---")
    r7 = Reportes.r7_total_neto(r4)
    IO.puts("Total Neto a Pagar:  #{Util.formatear_dinero(r7.total_a_pagar)}")
    IO.puts("Total de Prendas:    #{r7.total_de_prenda}")
    promedio =
      case r7.promedio_por_prenda do
        :no_calculable -> "No calculable"
        valor -> Util.formatear_dinero(valor)
      end
    IO.puts("Promedio por Prenda: #{promedio}")
    IO.puts("==================================================\n")

    # Reporte 8: Cobertura de Líneas

    IO.puts("--- R8: COBERTURA TOTAL DE LÍNEAS ---")
    r8 = Reportes.r8_cobertura_lineas(lotes_validos, Datos.lineas())
    if r8 == :ningun_confeccionista_cobertura_total do
      IO.puts("Ningún confeccionista trabajó en todas las líneas.")
    else
      IO.puts("Confeccionistas que trabajaron en todas las líneas: #{Enum.join(r8, ", ")}")
    end
    IO.puts("==================================================\n")

    # --- PARTE C.2: Taller Aliado ---

    IO.puts("--- C.2: COMBINACIÓN CON TALLER ALIADO ---")
    taller_aliado = %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}
    produccion_combinada = Reportes.c2_combinacion_produccion_aliado(r3.mapa_prendas_diarias, taller_aliado)

    IO.puts("Taller Base (R3): #{inspect(r3.mapa_prendas_diarias)}")
    IO.puts("Taller Aliado:    #{inspect(taller_aliado)}")
    IO.puts("Producción Final: #{inspect(produccion_combinada)}")
    IO.puts("==================================================\n")
  end
end
Programa.main()

defmodule ConsolaInteractiva 
