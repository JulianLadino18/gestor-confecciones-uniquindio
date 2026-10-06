# Integrantes: Daniel Gil Fino, Julián Andrés Ladino Nossa, Samuel Franco Salazar
Code.require_file("datos.exs")

defmodule Programa do
  @moduledoc """
  Módulo principal del programa de gestión de producción del taller de confecciones.

  Concentra los efectos secundarios (lectura por teclado e impresión en pantalla).
  La validación, la liquidación y los cálculos de los reportes viven en los demás
  módulos y son funciones puras.
  - version: 1.0
  - autores: Daniel Gil Fino, Julián Andrés Ladino Nossa, Samuel Franco Salazar
  - fecha: 2026-10-05
  """

  @dias_produccion 1..6
  @separador String.duplicate("=", 60)
  @taller_aliado %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}

  @doc """
  Ejecuta el programa completo: carga los datos, pide un lote adicional, valida y
  liquida, imprime los reportes R1 a R8, el ranking (C.1), la combinación con el
  taller aliado (C.2) y, al final, pide el código para el comprobante individual.
  """
  def main do
    imprimir_titulo("GESTIÓN DE PRODUCCIÓN - TALLER DE CONFECCIONES")

    confeccionistas = for c <- Datos.confeccionistas(), into: %{}, do: {c.codigo, c}
    lineas = for l <- Datos.lineas(), into: %{}, do: {l.id, l}

    lotes = solicitar_lote_adicional(Datos.lotes(), confeccionistas, lineas)

    {lotes_validos, lotes_rechazados} =
      Validacion.validar_lotes(lotes, confeccionistas, lineas)

    lotes_por_confeccionista = Enum.group_by(lotes_validos, fn lote -> lote.confeccionista end)

    liquidaciones =
      for {codigo, confeccionista} <- confeccionistas do
        Liquidacion.liquidar(confeccionista, Map.get(lotes_por_confeccionista, codigo, []))
      end

    imprimir_reportes(lotes_validos, lotes_rechazados, liquidaciones, confeccionistas, lineas)
    imprimir_ranking(liquidaciones)
    imprimir_combinacion_aliado(lotes_validos)
    solicitar_comprobante(confeccionistas, lotes_validos)
  end

  defp leer_linea(mensaje) do
    case IO.gets(mensaje) do
      texto when is_binary(texto) -> String.trim(texto)
      _ -> ""
    end
  end

  defp solicitar_lote_adicional(lotes, confeccionistas, lineas) do
    entrada =
      leer_linea(
        "Ingrese un lote adicional (confeccionista;linea;dia;prendas;defectos)\n" <>
          "o Enter para omitir: "
      )

    if entrada == "" do
      IO.puts("Lote adicional OMITIDO.")
      lotes
    else
      incorporar_lote(entrada, lotes, confeccionistas, lineas)
    end
  end

  defp incorporar_lote(entrada, lotes, confeccionistas, lineas) do
    case parsear_lote(entrada) do
      {:ok, lote} ->
        case Validacion.validar_lote(lote, confeccionistas, lineas) do
          {:ok, _lote} -> IO.puts("Lote adicional AGREGADO: #{inspect(lote)}")
          {:error, motivo} -> IO.puts("Lote adicional RECHAZADO (#{motivo}); aparecerá en R1.")
        end

        lotes ++ [lote]

      {:error, :formato_invalido} ->
        IO.puts("Lote adicional RECHAZADO (formato_invalido); no se incorpora.")
        lotes
    end
  end

  defp parsear_lote(cadena) do
    campos = cadena |> String.split(";") |> Enum.map(&String.trim/1)

    with [confeccionista, linea, dia_texto, prendas_texto, defectos_texto] <- campos,
         {dia, ""} <- Integer.parse(dia_texto),
         {prendas, ""} <- Integer.parse(prendas_texto),
         {defectos, ""} <- Float.parse(defectos_texto) do
      {:ok,
       %{
         confeccionista: confeccionista,
         linea: linea,
         dia: dia,
         prendas: prendas,
         defectos: defectos
       }}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  defp imprimir_reportes(validos, rechazados, liquidaciones, confeccionistas, lineas) do
    r4 = Reportes.r4_liquidacion_confeccionistas_ordenada(liquidaciones)

    imprimir_r1(rechazados)
    imprimir_r2(validos, lineas)
    imprimir_r3(validos)
    imprimir_r4(r4)
    imprimir_r5(validos, confeccionistas)
    imprimir_r6(validos, confeccionistas)
    imprimir_r7(r4)
    imprimir_r8(validos, confeccionistas, lineas)
  end

  defp imprimir_r1(rechazados) do
    imprimir_titulo("R1: LOTES RECHAZADOS")
    r1 = Reportes.r1_lotes_rechazados(rechazados)

    if r1.total_rechazados == 0 do
      IO.puts("No hay lotes rechazados.")
    else
      Enum.each(r1.lotes, fn {lote, motivo} ->
        IO.puts("- #{inspect(lote)} -> #{motivo}")
      end)

      IO.puts("\nRechazos por motivo:")

      Enum.each(r1.conteo_por_motivo, fn {motivo, cantidad} ->
        IO.puts("  #{motivo}: #{cantidad}")
      end)

      IO.puts("Total de lotes rechazados: #{r1.total_rechazados}")
    end
  end

  defp imprimir_r2(validos, lineas) do
    imprimir_titulo("R2: PRODUCTIVIDAD POR LÍNEA (prendas por puesto)")

    validos
    |> Reportes.r2_productividad_lineas(Map.values(lineas))
    |> Enum.each(fn l ->
      IO.puts(
        "- #{l.id} #{l.nombre}: #{l.prendas} prendas | #{l.puestos} puestos | " <>
          "productividad: #{Util.formatear_decimal(l.productividad, 2)}"
      )
    end)
  end

  defp imprimir_r3(validos) do
    imprimir_titulo("R3: PRODUCCIÓN DIARIA Y CUMPLIMIENTO DE META")
    r3 = Reportes.r3_produccion_diaria(validos)

    Enum.each(@dias_produccion, fn dia ->
      info = Map.fetch!(r3.detalle_diario, dia)
      estado = if info.alcanzo_meta?, do: "meta alcanzada", else: "meta NO alcanzada"
      IO.puts("Día #{dia}: #{info.prendas} prendas (#{estado})")
    end)

    IO.puts("\n¿Se alcanzó la meta todos los días? #{si_no(r3.cumpli_todos_los_dias?)}")
    IO.puts("¿Se alcanzó la meta al menos un día? #{si_no(r3.cumpli_almenos_un_dia?)}")
  end

  defp imprimir_r4(r4) do
    imprimir_titulo("R4: LIQUIDACIÓN DE CONFECCIONISTAS (de mayor a menor neto)")

    Enum.each(r4, fn c ->
      IO.puts("#{c.posicion}. #{c.codigo} - #{c.nombre}")

      IO.puts(
        "   Prendas: #{c.prendas} | Valor lotes: #{Util.formatear_dinero(c.bruto)} | " <>
          "Bonificaciones: #{Util.formatear_dinero(c.bonificaciones)} | " <>
          "Alquiler: #{Util.formatear_dinero(c.alquiler)} | " <>
          "NETO: #{Util.formatear_dinero(c.neto)}"
      )
    end)
  end

  defp imprimir_r5(validos, confeccionistas) do
    imprimir_titulo("R5: CONFECCIONISTA CON MÁS PRENDAS POR DÍA")
    r5 = Reportes.r5_ganadores_diarios(validos, Map.values(confeccionistas))

    Enum.each(@dias_produccion, fn dia ->
      case Map.fetch!(r5.detalle_por_dia, dia) do
        :sin_lotes_validos ->
          IO.puts("Día #{dia}: sin lotes válidos")

        %{ganadores: ganadores, max_prendas: maximo} ->
          IO.puts("Día #{dia}: #{etiquetas(confeccionistas, ganadores)} con #{maximo} prendas")
      end
    end)

    case r5.lider_semanal do
      :ninguno ->
        IO.puts("\nNo hay líder semanal (no hay lotes válidos).")

      %{confeccionistas: lideres, dias_ganados: dias} ->
        IO.puts(
          "\nPrimer lugar más días: #{etiquetas(confeccionistas, lideres)} " <>
            "con #{dias} día(s)"
        )
    end
  end

  defp imprimir_r6(validos, confeccionistas) do
    imprimir_titulo("R6: MEJOR CALIDAD (defectos ponderados, mínimo 3 lotes válidos)")

    case Reportes.r6_mejor_calidad(validos) do
      :sin_candidatos_suficientes ->
        IO.puts("Nadie tiene al menos 3 lotes válidos; no se puede determinar.")

      r6 ->
        IO.puts("Mejor calidad: #{etiqueta(confeccionistas, r6.confeccionista)}")

        IO.puts(
          "Defectos ponderados por prendas: #{Util.formatear_decimal(r6.porcentaje_ponderado, 2)} %"
        )

        IO.puts("Calculado con #{r6.total_lotes} lotes y #{r6.total_prendas} prendas.")
    end
  end

  defp imprimir_r7(r4) do
    imprimir_titulo("R7: TOTAL A PAGAR Y COSTO PROMEDIO POR PRENDA")
    r7 = Reportes.r7_total_neto(r4)

    IO.puts("Total a pagar por el taller: #{Util.formatear_dinero(r7.total_a_pagar)}")
    IO.puts("Total de prendas válidas:    #{r7.total_de_prenda}")

    case r7.promedio_por_prenda do
      :no_calculable ->
        IO.puts("Costo promedio por prenda:   no puede calcularse (no hay prendas válidas)")

      promedio ->
        IO.puts("Costo promedio por prenda:   #{Util.formatear_dinero(promedio)}")
    end
  end

  defp imprimir_r8(validos, confeccionistas, lineas) do
    imprimir_titulo("R8: CONFECCIONISTAS QUE TRABAJARON EN TODAS LAS LÍNEAS")

    case Reportes.r8_cobertura_lineas(validos, Map.values(lineas)) do
      :ningun_confeccionista_cobertura_total ->
        IO.puts("Ningún confeccionista trabajó en todas las líneas.")

      codigos ->
        IO.puts(etiquetas(confeccionistas, codigos))
    end
  end

  defp imprimir_ranking(liquidaciones) do
    imprimir_titulo("C.1: RANKING CON KEYWORD LISTS")

    mostrar_ranking(
      "Reportes.ranking(liquidaciones, [])",
      Reportes.ranking(liquidaciones, [])
    )

    mostrar_ranking(
      "Reportes.ranking(liquidaciones, campo: :prendas, limite: 3)",
      Reportes.ranking(liquidaciones, campo: :prendas, limite: 3)
    )

    mostrar_ranking(
      "Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto)",
      Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto)
    )
  end

  defp mostrar_ranking(descripcion, ranking) do
    IO.puts("\n> #{descripcion}")

    Enum.each(ranking, fn c ->
      IO.puts(
        "  #{c.codigo} - #{c.nombre} | prendas: #{c.prendas} | " <>
          "bruto: #{Util.formatear_dinero(c.bruto)} | neto: #{Util.formatear_dinero(c.neto)}"
      )
    end)
  end

  defp imprimir_combinacion_aliado(validos) do
    imprimir_titulo("C.2: COMBINACIÓN CON TALLER ALIADO (Map.merge/3)")
    base = Reportes.r3_produccion_diaria(validos).mapa_prendas_diarias
    combinada = Reportes.c2_combinacion_produccion_aliado(base, @taller_aliado)

    combinada
    |> Enum.sort()
    |> Enum.each(fn {dia, total} ->
      IO.puts(
        "Día #{dia}: base #{Map.get(base, dia, 0)} + aliado #{Map.get(@taller_aliado, dia, 0)} = #{total}"
      )
    end)
  end

  defp solicitar_comprobante(confeccionistas, validos) do
    codigo = leer_linea("\nIngrese el código de un confeccionista para ver su comprobante: ")

    case Map.fetch(confeccionistas, codigo) do
      {:ok, confeccionista} ->
        liquidacion = Liquidacion.liquidar(confeccionista, validos)
        dias = Liquidacion.calcular_valor_lotes_por_confeccionista(validos, codigo)
        imprimir_comprobante(confeccionista, liquidacion, dias)

      :error ->
        IO.puts("El código '#{codigo}' no existe; no se genera comprobante.")
    end
  end

  defp imprimir_comprobante(confeccionista, liquidacion, dias) do
    imprimir_titulo("COMPROBANTE DE PAGO")
    IO.puts("Nombre: #{confeccionista.nombre}")
    IO.puts("Código: #{confeccionista.codigo}")

    if dias == [] do
      IO.puts("\nNo registra días trabajados (sin lotes válidos).")
    else
      IO.puts("\nDetalle por día trabajado:")

      Enum.each(dias, fn dia ->
        valor_lotes = dia.total_dia - dia.bonificacion_dia

        IO.puts(
          "  Día #{dia.dia}: #{dia.total_prendas} prendas | " <>
            "lotes: #{Util.formatear_dinero(valor_lotes)} | " <>
            "bonificación: #{Util.formatear_dinero(dia.bonificacion_dia)}"
        )
      end)
    end

    IO.puts("\nTotal de prendas:         #{liquidacion.prendas}")
    IO.puts("Suma de lotes:            #{Util.formatear_dinero(liquidacion.bruto)}")
    IO.puts("Suma de bonificaciones:   #{Util.formatear_dinero(liquidacion.bonificaciones)}")
    IO.puts("Descuento por alquiler:   #{Util.formatear_dinero(liquidacion.alquiler)}")
    IO.puts("NETO A PAGAR:             #{Util.formatear_dinero(liquidacion.neto)}")
  end

  defp imprimir_titulo(texto) do
    IO.puts("\n" <> @separador)
    IO.puts(texto)
    IO.puts(@separador)
  end

  defp si_no(true), do: "Sí"
  defp si_no(false), do: "No"

  defp etiqueta(confeccionistas, codigo) do
    case Map.fetch(confeccionistas, codigo) do
      {:ok, confeccionista} -> "#{codigo} (#{confeccionista.nombre})"
      :error -> codigo
    end
  end

  defp etiquetas(confeccionistas, codigos) do
    codigos
    |> Enum.map(fn codigo -> etiqueta(confeccionistas, codigo) end)
    |> Enum.join(", ")
  end
end

Programa.main()
