# gestor-confecciones-uniquindio
# Liquidación de la producción de un taller de confección

**Universidad del Quindío**
Programa de Ingeniería de Sistemas y Computación
Programación III — Parcial 1
Docente: Robinson Arias Muñoz

## Integrantes

- Daniel Gil Fino
- Julián Andrés Ladino Nosa
- Samuel Franco Salazar

## Descripción

Programa en Elixir que liquida la producción semanal de un taller de confección que produce uniformes escolares en el Quindío. A partir de los lotes entregados por los confeccionistas independientes, el programa:

1. Valida los lotes (los datos pueden traer errores de digitación) y excluye los inválidos de los cálculos.
2. Calcula el valor de cada lote según el porcentaje de defectos.
3. Aplica la bonificación diaria por productividad y el descuento por alquiler de máquina.
4. Liquida a todos los confeccionistas y genera ocho reportes de producción, calidad y rendimiento.
5. Permite agregar un lote adicional por consola y consultar el comprobante individual de un confeccionista.

### Parámetros del taller

| Parámetro | Valor |
|---|---|
| Tarifa base por prenda | $3.200 |
| Meta diaria del taller | 600 prendas |
| Días de producción | 6 (numerados del 1 al 6) |
| Máximo de prendas por lote | 180 |
| Prendas diarias para bonificación | 120 |
| Bonificación diaria | $18.000 |
| Alquiler de máquina | $15.000 por día trabajado |

## Requisitos

- Elixir 1.17 o superior, con su Erlang/OTP correspondiente.

El programa se desarrolló y probó con estas dos combinaciones:

| Elixir | Erlang/OTP |
|---|---|
| 1.20.3 | 29 |
| 1.17.2 | 27 |

Para verificar la versión instalada:

```bash
elixir --version
```

No se usan proyectos `mix` ni librerías externas.

## Estructura del proyecto

```
.
├── datos.exs          # Módulo Datos: confeccionistas, líneas y lotes
├── util.ex            # Módulo Util: funciones de apoyo (formato, conversiones)
├── validacion.ex      # Módulo Validacion: reglas de validación de lotes
├── liquidacion.ex     # Módulo Liquidacion: valor de lote, bonificación, alquiler y neto
├── reportes.ex        # Módulo Reportes: reportes R1 a R8 y ranking/2
├── programa.exs       # Módulo Programa y función main
└── README.md
```

| Módulo | Responsabilidad |
|---|---|
| `Datos` | Entrega los datos en listas (`confeccionistas/0`, `lineas/0`, `lotes/0`). |
| `Util` | Funciones auxiliares reutilizables. |
| `Validacion` | Valida cada lote con `with` y devuelve `{:ok, lote}` o `{:error, motivo}`. |
| `Liquidacion` | Cálculos puros de liquidación. |
| `Reportes` | Cálculos puros de los reportes y su impresión. |
| `Programa` | Punto de entrada (`main`), lectura de datos del usuario e impresión. |

## Compilación y ejecución

Todos los comandos se ejecutan desde la carpeta raíz del repositorio.

**1. Compilar los módulos de apoyo:**

```bash
elixirc util.ex validacion.ex liquidacion.ex reportes.ex
```

Esto genera los archivos `.beam` en la carpeta actual.

**2. Ejecutar el programa:**

```bash
elixir programa.exs
```

`programa.exs` carga `datos.exs` al iniciar, por lo que basta con reemplazar ese archivo para usar otro conjunto de datos, sin modificar el resto del programa.

> Si se modifica algún módulo de apoyo, hay que volver a ejecutar el paso 1 antes de ejecutar el programa.

## Uso

Al ejecutar el programa:

1. **Lote adicional.** Después de cargar los datos y antes de los reportes, el programa pide un lote en una sola línea, con campos separados por punto y coma:

   ```
   Ingrese un lote adicional (confeccionista;linea;dia;prendas;defectos)
   o Enter para omitir: C03;L2;4;85;3.5
   ```

   El programa informa si el lote se agregó, se rechazó o se omitió. Si el formato no es válido responde `{:error, :formato_invalido}` y continúa sin fallar.

2. **Reportes.** Se imprimen los ocho reportes en orden:

   | # | Reporte |
   |---|---|
   | R1 | Lotes rechazados con su motivo y cantidad por motivo |
   | R2 | Prendas y productividad (prendas por puesto) por línea |
   | R3 | Producción diaria del taller y cumplimiento de la meta |
   | R4 | Liquidación de todos los confeccionistas ordenada por pago neto |
   | R5 | Confeccionista con más prendas cada día |
   | R6 | Confeccionista con mejor calidad (defectos ponderados por prendas) |
   | R7 | Total pagado y costo promedio por prenda válida |
   | R8 | Confeccionistas que trabajaron en todas las líneas |

   También se muestran las tres llamadas a `Reportes.ranking/2` de la Parte C.1.

3. **Comprobante individual.** Al terminar los reportes, el programa solicita el código de un confeccionista y muestra su comprobante. Si el código no existe, lo informa sin fallar.

## Reglas de validación

Cada lote se valida en este orden y solo se informa el primer motivo de rechazo:

| Orden | Regla | Motivo de rechazo |
|---|---|---|
| 1 | El confeccionista existe | `:confeccionista_desconocido` |
| 2 | La línea existe | `:linea_desconocida` |
| 3 | El día es un entero entre 1 y 6 | `:dia_invalido` |
| 4 | Las prendas son un entero entre 1 y 180 | `:prendas_fuera_de_rango` |
| 5 | El porcentaje de defectos es un número entre 0 y 100 | `:porcentaje_invalido` |

## Verificación con el ejemplo del enunciado

María Elena (usa máquina del taller) con estos lotes válidos:

| Día | Línea | Prendas | Defectos | Valor del lote |
|---|---|---|---|---|
| 1 | L1 | 70 | 1,5 % | $239.680 |
| 1 | L2 | 55 | 7 % | $154.880 |
| 2 | L1 | 90 | 12 % | $216.000 |

- Suma de los lotes: **$610.560**
- Bonificación (día 1 con 125 prendas): **$18.000**
- Alquiler (2 días trabajados): **$30.000**
- **Neto: $598.560**

El programa debe producir este resultado para esos datos.

## Alcance permitido

El código se resuelve únicamente con los temas vistos hasta la guía de colecciones. No se usa: recursividad, `defstruct`, lectura o escritura de archivos con `File`, procesos (`spawn`, `Task`, `Agent`, `GenServer`), proyectos `mix`, librerías externas ni `try`/`rescue` para validar datos. Los errores se manejan con tuplas `{:ok, valor}` y `{:error, motivo}`, y los recorridos se hacen con `Enum` o comprehensions (`for`).

## Documentación entregada por separado

El documento PDF con el diseño (Parte A), la explicación de R6, la investigación (Parte C), la salida completa del programa y el uso de IA (Parte D) se entrega aparte y no forma parte de este repositorio.
