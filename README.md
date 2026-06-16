# Implementación de Series de Tiempo en R

Este repositorio contiene material teórico y práctico desarrollado para la asignatura Taller 1 de la carrera de Ingeniería Estadística de la Universidad de Santiago de Chile (USACH), correspondiente al primer semestre del año 2026.

Taller 1 corresponde a la primera práctica profesional de la carrera. Esta actividad se realiza de manera interna dentro de la universidad y es supervisada por profesores de la Carrera.

La primera parte del curso consiste en preparar y exponer contenidos asociados a seis asignaturas de la carrera. Este proyecto aborda la asignatura **Series de Tiempo**, y tiene como objetivo reunir una implementación práctica en R de sus principales contenidos, considerando:

- Una parte teórica, orientada a explicar los fundamentos, componentes y propiedades de una serie temporal.
- Una parte práctica, implementada en RStudio, donde se analiza una serie mensual de denuncias DMCS mediante herramientas clásicas y modelos SARIMA.

## Estructura del repositorio

``` text
.
|-- Bases de Datos/
|   `-- Denuncias DMCS/
|-- Bibliografía/
|-- Imágenes/
|-- Scripts/
|-- .here
|-- Diagrama Resumen Box-Jenkins.png
|-- Series de Tiempo PPT.pdf
`-- README.md
```

## Contenido principal

- `Bases de Datos/`: contiene la base utilizada en el ejercicio práctico.
- `Bases de Datos/Denuncias DMCS/`: contiene el archivo `DenunciasDMCS.xlsx`, utilizado como insumo principal del script.
- `Bibliografía/`: documentos, apuntes y material bibliográfico de apoyo para el desarrollo teórico del proyecto.
- `Imágenes/`: imágenes de apoyo asociadas al desarrollo del taller y a la presentación del contenido.
- `Scripts/`: implementaciones en R de los ejercicios prácticos de la asignatura.
- `Diagrama Resumen Box-Jenkins.png`: diagrama resumen del flujo de trabajo de la metodología Box-Jenkins.
- `Series de Tiempo PPT.pdf`: presentación utilizada para exponer la parte teórica y práctica del proyecto.

## Metodología Box-Jenkins

El siguiente diagrama resume el flujo de trabajo utilizado para la identificación, estimación, diagnóstico y predicción de modelos de series de tiempo bajo la metodología Box-Jenkins:

![Diagrama resumen de la metodología Box-Jenkins](./Diagrama%20Resumen%20Box-Jenkins.png)

## Script principal

El archivo principal del proyecto es:

[Taller_I_SeriesDeTiempo_TMR.R](./Scripts/Taller_I_SeriesDeTiempo_TMR.R)

Este script desarrolla un flujo secuencial de análisis de series de tiempo, incluyendo:

- Carga de librerías y base de datos.
- Construcción del objeto de serie temporal.
- Gráfico de la serie original.
- Descomposición aditiva y multiplicativa.
- Análisis de estacionariedad, transformación logarítmica, ACF y PACF.
- División de la serie en entrenamiento y prueba.
- Ajuste de modelos Holt-Winters y regresión con dummies estacionales.
- Diagnóstico de residuos mediante pruebas de blancura.
- Diferenciación regular y estacional.
- Ajuste y comparación de modelos SARIMA.
- Pronósticos y comparación con el conjunto de prueba.
- Análisis espectral mediante periodograma.

## Base de datos

La base utilizada corresponde a una serie mensual de tasas de denuncias DMCS. El archivo principal se encuentra en:

``` text
Bases de Datos/Denuncias DMCS/DenunciasDMCS.xlsx
```

El script permite generar opcionalmente una copia en formato CSV mediante `write.csv2()`, pero esta exportación se mantiene comentada para evitar crear archivos derivados innecesarios.

## Presentación final

La presentación utilizada para exponer la parte teórica y práctica del proyecto puede revisarse en el siguiente enlace:

[Ver presentación en PDF](./Series%20de%20Tiempo%20PPT.pdf)

## Reproducibilidad

El proyecto está organizado para ejecutarse desde RStudio usando rutas relativas mediante el paquete `here`. Para ello se incluye un archivo `.here` en la raíz del proyecto, lo que permite que las rutas se resuelvan correctamente sin depender de rutas locales específicas del equipo.

Antes de ejecutar el script, se recomienda instalar las librerías requeridas:

``` r
install.packages("readxl")
install.packages("lmtest")
install.packages("fUnitRoots")
install.packages("forecast")
install.packages("here")
```

Luego, el script puede ejecutarse desde:

``` text
Scripts/Taller_I_SeriesDeTiempo_TMR.R
```
