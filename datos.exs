# Integrantes: Daniel Gil Fino, Julián Andrés Ladino Nosa, Samuel Franco Salazar

defmodule Datos do
  @moduledoc """
  Módulo que contiene los datos de prueba del taller de confección: confeccionistas, líneas y lotes.
  - version: 1.0
  - autor: Daniel Gil Fino
  - fecha: 2026-02-10
  """

  @doc """
  función que retorna la lista de confeccionistas del taller.
  """
  def confeccionistas do
    [
      %{codigo: "C01", nombre: "Daniel Gil Fino", alquiler: true}, #Es quivalente a %{:codigo => "C01", :nombre => "Daniel Gil Fino", :alquiler => true}
      %{codigo: "C02", nombre: "Julián Andrés Ladino Nosa", alquiler: false},
      %{codigo: "C03", nombre: "Samuel Franco Salazar", alquiler: true},
      %{codigo: "C04", nombre: "Melissa Vega Mora", alquiler: false},
      %{codigo: "C05", nombre: "María Claudia Gil Fino", alquiler: true},
      %{codigo: "C06", nombre: "Robinson Arias Muñoz", alquiler: false},
      %{codigo: "C07", nombre: "Jose Manuel Angel", alquiler: true},
      %{codigo: "C08", nombre: "Liliana Andrea Gil Fino", alquiler: false},
      %{codigo: "C09", nombre: "Juan Felipe Rodriguez Campiño", alquiler: true},
      %{codigo: "C10", nombre: "Hernando", alquiler: false}
    ]
  end

  @doc """
  función que devuelve la lista de producción del taller.
  """

  def lineas do
  [
    %{id: "L1", nombre: "LÍNEA NORTE", puestos: 6},
    %{id: "L2", nombre: "LÍNEA CENTRAL", puestos: 4},
    %{id: "L3", nombre: "LÍNEA SUR", puestos: 5},
    %{id: "L4", nombre: "LÍNEA ESTE", puestos: 3}
  ]
end

  @doc """
  función que retorna la lista de lotes entregados por los confeccionistas durantes la semana.
  Algunos de los lotes contienen errores de digitación a propósito para probar la validación.
  """

  def lotes do
    [
      # Día 1

      %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5},
      %{confeccionista: "C01", linea: "L2", dia: 1, prendas: 55, defectos: 7},
      %{confeccionista: "C02", linea: "L1", dia: 1, prendas: 80, defectos: 1.8},
      %{confeccionista: "C02", linea: "L2", dia: 1, prendas: 60, defectos: 3},
      %{confeccionista: "C03", linea: "L1", dia: 1, prendas: 45, defectos: 2},
      %{confeccionista: "C03", linea: "L3", dia: 1, prendas: 100, defectos: 4.5},
      %{confeccionista: "C04", linea: "L2", dia: 1, prendas: 100, defectos: 5},
      %{confeccionista: "C04", linea: "L4", dia: 1, prendas: 30, defectos: 8},
      %{confeccionista: "C05", linea: "L3", dia: 1, prendas: 50, defectos: 10},
      %{confeccionista: "C05", linea: "L1", dia: 1, prendas: 60, defectos: 12},
      %{confeccionista: "C06", linea: "L4", dia: 1, prendas: 40, defectos: 0},
      %{confeccionista: "C06", linea: "L2", dia: 1, prendas: 70, defectos: 6},
      %{confeccionista: "C07", linea: "L3", dia: 1, prendas: 35, defectos: 15},
      %{confeccionista: "C08", linea: "L1", dia: 1, prendas: 25, defectos: 3.5},
      %{confeccionista: "C09", linea: "L3", dia: 1, prendas: 10, defectos: 20},

      # Día 2

      %{confeccionista: "C01", linea: "L1", dia: 2, prendas: 90, defectos: 12},
      %{confeccionista: "C02", linea: "L3", dia: 2, prendas: 60, defectos: 2.5},
      %{confeccionista: "C02", linea: "L4", dia: 2, prendas: 60, defectos: 6},
      %{confeccionista: "C03", linea: "L2", dia: 2, prendas: 40, defectos: 1},
      %{confeccionista: "C03", linea: "L4", dia: 2, prendas: 30, defectos: 9},
      %{confeccionista: "C04", linea: "L1", dia: 2, prendas: 119, defectos: 3},
      %{confeccionista: "C05", linea: "L2", dia: 2, prendas: 30, defectos: 4.2},
      %{confeccionista: "C05", linea: "L3", dia: 2, prendas: 25, defectos: 11},
      %{confeccionista: "C06", linea: "L1", dia: 2, prendas: 20, defectos: 0.5},
      %{confeccionista: "C06", linea: "L4", dia: 2, prendas: 30, defectos: 2},
      %{confeccionista: "C07", linea: "L2", dia: 2, prendas: 35, defectos: 5.5},
      %{confeccionista: "C07", linea: "L1", dia: 2, prendas: 25, defectos: 7.5},
      %{confeccionista: "C08", linea: "L3", dia: 2, prendas: 20, defectos: 1.2},

      # Día 3

      %{confeccionista: "C03", linea: "L2", dia: 3, prendas: 100, defectos: 2.2},
      %{confeccionista: "C03", linea: "L3", dia: 3, prendas: 90, defectos: 3.8},
      %{confeccionista: "C02", linea: "L1", dia: 3, prendas: 80, defectos: 1.1},
      %{confeccionista: "C02", linea: "L4", dia: 3, prendas: 50, defectos: 5.5},
      %{confeccionista: "C04", linea: "L2", dia: 3, prendas: 60, defectos: 8},
      %{confeccionista: "C04", linea: "L1", dia: 3, prendas: 30, defectos: 4},
      %{confeccionista: "C05", linea: "L2", dia: 3, prendas: 85, defectos: 4.9},
      %{confeccionista: "C05", linea: "L1", dia: 3, prendas: 8, defectos: 9},
      %{confeccionista: "C06", linea: "L4", dia: 3, prendas: 45, defectos: 0},
      %{confeccionista: "C06", linea: "L2", dia: 3, prendas: 12, defectos: 3},
      %{confeccionista: "C07", linea: "L1", dia: 3, prendas: 20, defectos: 13},
      %{confeccionista: "C07", linea: "L3", dia: 3, prendas: 15, defectos: 2},
      %{confeccionista: "C09", linea: "L3", dia: 3, prendas: 5, defectos: 18},

      # Día 4

      %{confeccionista: "C09", linea: "L2", dia: 4, prendas: 150, defectos: 0.5},
      %{confeccionista: "C03", linea: "L1", dia: 4, prendas: 80, defectos: 3},
      %{confeccionista: "C03", linea: "L3", dia: 4, prendas: 70, defectos: 6.5},
      %{confeccionista: "C02", linea: "L2", dia: 4, prendas: 90, defectos: 1.5},
      %{confeccionista: "C02", linea: "L1", dia: 4, prendas: 40, defectos: 4},
      %{confeccionista: "C04", linea: "L2", dia: 4, prendas: 60, defectos: 2},
      %{confeccionista: "C04", linea: "L1", dia: 4, prendas: 50, defectos: 7},
      %{confeccionista: "C05", linea: "L3", dia: 4, prendas: 70, defectos: 11},
      %{confeccionista: "C05", linea: "L2", dia: 4, prendas: 45, defectos: 3.5},
      %{confeccionista: "C06", linea: "L1", dia: 4, prendas: 55, defectos: 1},
      %{confeccionista: "C06", linea: "L2", dia: 4, prendas: 30, defectos: 4},
      %{confeccionista: "C07", linea: "L1", dia: 4, prendas: 40, defectos: 5.2},
      %{confeccionista: "C07", linea: "L3", dia: 4, prendas: 25, defectos: 9.5},
      %{confeccionista: "C07", linea: "L2", dia: 4, prendas: 20, defectos: 8},

      # Día 5

       %{confeccionista: "C02", linea: "L1", dia: 5, prendas: 180, defectos: 1.9},
      %{confeccionista: "C02", linea: "L3", dia: 5, prendas: 20, defectos: 4},
      %{confeccionista: "C03", linea: "L2", dia: 5, prendas: 75, defectos: 2.4},
      %{confeccionista: "C03", linea: "L4", dia: 5, prendas: 40, defectos: 7.5},
      %{confeccionista: "C03", linea: "L3", dia: 5, prendas: 30, defectos: 3},
      %{confeccionista: "C04", linea: "L4", dia: 5, prendas: 70, defectos: 3.3},
      %{confeccionista: "C04", linea: "L2", dia: 5, prendas: 55, defectos: 5.8},
      %{confeccionista: "C05", linea: "L1", dia: 5, prendas: 60, defectos: 4.5},
      %{confeccionista: "C05", linea: "L3", dia: 5, prendas: 50, defectos: 9.5},
      %{confeccionista: "C06", linea: "L2", dia: 5, prendas: 120, defectos: 1.9},
      %{confeccionista: "C07", linea: "L1", dia: 5, prendas: 30, defectos: 5},
      %{confeccionista: "C07", linea: "L2", dia: 5, prendas: 45, defectos: 8.5},
      %{confeccionista: "C07", linea: "L3", dia: 5, prendas: 15, defectos: 11},

      # Día 6

       %{confeccionista: "C02", linea: "L2", dia: 6, prendas: 100, defectos: 2},
      %{confeccionista: "C02", linea: "L4", dia: 6, prendas: 80, defectos: 3},
      %{confeccionista: "C03", linea: "L1", dia: 6, prendas: 90, defectos: 5},
      %{confeccionista: "C03", linea: "L2", dia: 6, prendas: 40, defectos: 4.2},
      %{confeccionista: "C03", linea: "L3", dia: 6, prendas: 25, defectos: 6},
      %{confeccionista: "C04", linea: "L1", dia: 6, prendas: 60, defectos: 10},
      %{confeccionista: "C04", linea: "L2", dia: 6, prendas: 20, defectos: 3},
      %{confeccionista: "C05", linea: "L2", dia: 6, prendas: 50, defectos: 3},
      %{confeccionista: "C05", linea: "L1", dia: 6, prendas: 1, defectos: 100},
      %{confeccionista: "C06", linea: "L1", dia: 6, prendas: 40, defectos: 0},
      %{confeccionista: "C06", linea: "L4", dia: 6, prendas: 15, defectos: 12},
      %{confeccionista: "C07", linea: "L3", dia: 6, prendas: 35, defectos: 4},
      %{confeccionista: "C07", linea: "L1", dia: 6, prendas: 25, defectos: 12},

      # Lotes con errores de digitación (La idea es que el programa los detecte y los rechace)

      # Motivo esperado: :confeccionista_desconocido
      %{confeccionista: "C99", linea: "L1", dia: 2, prendas: 50, defectos: 3},
      %{confeccionista: "c01", linea: "L9", dia: 8, prendas: 0, defectos: 120},
      # Motivo esperado: :linea_desconocida
      %{confeccionista: "C02", linea: "L5", dia: 3, prendas: 60, defectos: 2.5},
      %{confeccionista: "C04", linea: "l2", dia: 0, prendas: 200, defectos: 3},
      # Motivo esperado: :dia_invalido
      %{confeccionista: "C03", linea: "L1", dia: 7, prendas: 40, defectos: 3},
      %{confeccionista: "C05", linea: "L2", dia: 2.5, prendas: 0, defectos: 105},
      # Motivo esperado: :prendas_fuera_de_rango
      %{confeccionista: "C06", linea: "L3", dia: 4, prendas: 181, defectos: 4},
      %{confeccionista: "C07", linea: "L4", dia: 5, prendas: 85.5, defectos: 130},
      # Motivo esperado: :porcentaje_invalido
      %{confeccionista: "C08", linea: "L2", dia: 3, prendas: 30, defectos: 101},
      %{confeccionista: "C09", linea: "L1", dia: 6, prendas: 25, defectos: "7%"}
    ]
  end
end
