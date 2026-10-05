# Integrantes: Daniel Gil Fino, Julián Andrés Ladino Nosa, Samuel Franco Salazar

defmodule Validacion do
  @moduledoc """
  Módulo que valida los lotes entregados por los confeccionistas antes de efectuar cualquier cálculo.
  Cada lote se revisa con cinco reglas en un orden fijo y solo se informa el primer motivo de rechazo.
  Todas las funciones son puras: no imprimen ni leen datos, solo reciben colecciones y devuelven resultados.
  - version: 1.0
  - autores: Daniel Gil Fino
  - fecha: 2026-05-10
  """

  @dias_produccion 1..6
  @maximo_prendas_por_lote 180
  @porcentaje_minimo 0
  @porcentaje_maximo 100

  @doc """
  Valida un lote aplicando las cinco reglas del taller en este orden:
  confeccionista existente, línea existente, día entero entre 1 y 6,
  prendas enteras entre 1 y 180 y porcentaje de defectos numérico entre 0 y 100.

  Recibe el lote, el mapa de confeccionistas indexado por código y el mapa de
  líneas indexado por id.

  Devuelve `{:ok, lote}` si cumple todas las reglas, o `{:error, motivo}` con el
  primer motivo incumplido: `:confeccionista_desconocido`, `:linea_desconocida`,
  `:dia_invalido`, `:prendas_fuera_de_rango` o `:porcentaje_invalido`.
  """
  def validar_lote(lote, confeccionistas, lineas) do
    with :ok <- validar_confeccionista(lote, confeccionistas),
         :ok <- validar_linea(lote, lineas),
         :ok <- validar_dia(lote),
         :ok <- validar_prendas(lote),
         :ok <- validar_porcentaje(lote) do
      {:ok, lote}
    end
  end

  @doc """
  Valida una lista de lotes con los mismos mapas que recibe `validar_lote/3`.

  Devuelve `{validos, rechazados}`: `validos` es la lista de lotes que cumplen las
  cinco reglas y `rechazados` es una lista de tuplas `{lote, motivo}`, que es el
  formato que espera el reporte R1. Ambas listas conservan el orden original.
  """
  def validar_lotes(lotes, confeccionistas, lineas) do
    evaluados =
      Enum.map(lotes, fn lote -> {lote, validar_lote(lote, confeccionistas, lineas)} end)

    validos = for {_lote, {:ok, valido}} <- evaluados, do: valido
    rechazados = for {lote, {:error, motivo}} <- evaluados, do: {lote, motivo}

    {validos, rechazados}
  end

  defp validar_confeccionista(%{confeccionista: codigo}, confeccionistas) do
    if Map.has_key?(confeccionistas, codigo) do
      :ok
    else
      {:error, :confeccionista_desconocido}
    end
  end

  defp validar_confeccionista(_lote, _confeccionistas), do: {:error, :confeccionista_desconocido}

  defp validar_linea(%{linea: id}, lineas) do
    if Map.has_key?(lineas, id) do
      :ok
    else
      {:error, :linea_desconocida}
    end
  end

  defp validar_linea(_lote, _lineas), do: {:error, :linea_desconocida}

  defp validar_dia(%{dia: dia}) when is_integer(dia) and dia in @dias_produccion, do: :ok

  defp validar_dia(_lote), do: {:error, :dia_invalido}

  defp validar_prendas(%{prendas: prendas})
       when is_integer(prendas) and prendas >= 1 and prendas <= @maximo_prendas_por_lote,
       do: :ok

  defp validar_prendas(_lote), do: {:error, :prendas_fuera_de_rango}

  defp validar_porcentaje(%{defectos: defectos})
       when is_number(defectos) and defectos >= @porcentaje_minimo and
              defectos <= @porcentaje_maximo,
       do: :ok

  defp validar_porcentaje(_lote), do: {:error, :porcentaje_invalido}
end
