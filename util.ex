# Integrantes: Daniel Gil Fino, Julián Andrés Ladino Nossa, Samuel Franco Salazar

defmodule Util do
  @moduledoc """
  Funciones de apoyo del programa. Por ahora concentra el formato de los números
  que se imprimen en los reportes, para que todos usen el mismo criterio.
  """

  @doc """
  Convierte un número (entero o decimal) en texto con la cantidad de decimales
  indicada, sin notación científica. Acepta enteros porque los multiplica por 1.0.
  """
  def formatear_decimal(numero, decimales) do
    :erlang.float_to_binary(numero * 1.0, decimals: decimales)
  end

  @doc """
  Convierte un valor en pesos a texto con el signo $ y dos decimales.
  """
  def formatear_dinero(valor) do
    "$" <> formatear_decimal(valor, 2)
  end
end
