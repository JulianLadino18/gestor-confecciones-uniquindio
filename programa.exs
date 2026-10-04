Code.require_file("reportes.ex")
Code.require_file("liquidacion.ex")
Code.require_file("datos.exs")

defmodule Programa do
    def main do
    IO.puts("==================================================")
    IO.puts("   GESTION DE PRODUCCION - TALLER DE CONFECCIONES   ")
    IO.puts("==================================================\n")

    # Lotes de prueba simulados
    lotes_validos = [
      %{dia: 1, prendas: 300, confeccionista: "C1", linea: "L1", defectos: 0.01},
      %{dia: 1, prendas: 350, confeccionista: "C2", linea: "L2", defectos: 0.02},
      %{dia: 2, prendas: 500, confeccionista: "C1", linea: "L1", defectos: 0.01},
      %{dia: 3, prendas: 650, confeccionista: "C3", linea: "L3", defectos: 0.03},
      %{dia: 4, prendas: 400, confeccionista: "C2", linea: "L2", defectos: 0.02},
      %{dia: 5, prendas: 700, confeccionista: "C1", linea: "L1", defectos: 0.01},
      %{dia: 6, prendas: 600, confeccionista: "C3", linea: "L3", defectos: 0.02}
    ]

    # 1 prueba de R3
    reporte_r3 = Reportes.r3_produccion_diaria(lotes_validos)

    IO.puts("--- R3: PRODUCCIÓN DIARIA DEL TALLER BASE ---")
    IO.inspect(reporte_r3.mapa_prendas_diarias, label: "Prendas por dia (1 a 6)")
    IO.puts("¿Alcanzo la meta todos los días?: #{reporte_r3.cumpli_todos_los_dias?}")
    IO.puts("¿Alcanzo la meta al menos un día?: #{reporte_r3.cumpli_almenos_un_dia?}\n")

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

    # Prueba de Liquidacion de C1
    lotes = Datos.lotes()
    confeccionista = "C07"
    liquidacion =
      lotes
      |> Liquidacion.calcular_valor_lotes_por_confeccionista(confeccionista)
      |> Liquidacion.liquidar_confeccionista()

  IO.puts("==================================================")
  IO.puts("Liquidacion de #{confeccionista}")
  IO.inspect(liquidacion)

  end
end
Programa.main()
