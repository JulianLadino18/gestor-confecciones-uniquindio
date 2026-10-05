Code.require_file("datos.exs")

defmodule Programa do
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

    # 1 prueba de R3
    reporte_r3 = Reportes.r3_produccion_diaria(lotes_validos)

    IO.puts("--- R3: PRODUCCIÓN DIARIA DEL TALLER BASE ---")
    IO.inspect(reporte_r3.mapa_prendas_diarias, label: "Prendas por dia (1 a 6)")
    IO.puts("¿Alcanzo la meta todos los días?: #{reporte_r3.cumpli_todos_los_dias?}")
    IO.puts("¿Alcanzo la meta al menos un día?: #{reporte_r3.cumpli_almenos_un_dia?}\n")

    # Prueba de R4
    IO.puts("--- R4: PRODUCCIÓN DE CADA CONFECCIONISTA ---")
    lista_r4 = Reportes.r4_liquidacion_confeccionistas_ordenada(liquidaciones)
    |> IO.inspect()
    IO.puts("==================================================")

    # Prueba de R7  >>>>>>>>> IMPORTANTE! - DEPENDE DE R4 PARA FUNCIONAR
    IO.puts("--- R7: RESUMEN DEL TALLER ---")
    resumen_r7 = lista_r4
    |> Reportes.r7_total_neto()
    IO.puts("\n==================================================")
    IO.puts("--- R7: TOTALES DEL TALLER Y PROMEDIO ---")
    IO.puts("Total Neto a Pagar:  #{Util.formatear_dinero(resumen_r7.total_a_pagar)}")
    IO.puts("Total de Prendas:    #{resumen_r7.total_de_prenda}")
        promedio =
      case resumen_r7.promedio_por_prenda do
        :no_calculable -> "no puede calcularse (no hay prendas válidas)"
        valor -> Util.formatear_dinero(valor)
      end

    IO.puts("Promedio por Prenda: #{promedio}")
    IO.puts("==================================================")

    # Prueba de C.2 combinar con el mapa de taller aliado
    IO.puts("--- C.2: COMBINACION CON TALLER ALIADO (Map.merge/3) ---")

    taller_aliado = %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}

    produccion_combinada =
      Reportes.c2_combinacion_produccion_aliado(reporte_r3.mapa_prendas_diarias, taller_aliado)

    IO.puts("Mapa Taller Base:   #{inspect(reporte_r3.mapa_prendas_diarias)}")
    IO.puts("Mapa Taller Aliado: #{inspect(taller_aliado)}")
    IO.puts("--------------------------------------------------")
    IO.inspect(produccion_combinada, label: "Produccion combinada final")
    IO.puts("==================================================")

    # Comprobación del ejemplo del enunciado: C01 debe dar neto $598560.00
    liquidacion_c01 = Enum.find(liquidaciones, fn liquidacion -> liquidacion.codigo == "C01" end)
    IO.puts("Neto de C01: #{Util.formatear_dinero(liquidacion_c01.neto)}")

    # Pruebas de los demás reportes (luego se reemplazan por la impresión con formato)
    IO.inspect(Reportes.r1_lotes_rechazados(lotes_rechazados), label: "R1")
    IO.inspect(Reportes.r2_productividad_lineas(lotes_validos, Datos.lineas()), label: "R2")
    IO.inspect(Reportes.r5_ganadores_diarios(lotes_validos, Datos.confeccionistas()), label: "R5")
    IO.inspect(Reportes.r6_mejor_calidad(lotes_validos), label: "R6")
    IO.inspect(Reportes.r8_cobertura_lineas(lotes_validos, Datos.lineas()), label: "R8")

  end
end
Programa.main()
