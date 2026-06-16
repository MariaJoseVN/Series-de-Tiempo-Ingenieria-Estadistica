# =============================================================================
# TALLER I - SERIES DE TIEMPO
# USACH / Tetrametric
# Tamar Rojas Castillo | Maria Jose Valderrama N.
# =============================================================================


# Librerias y base de datos----

# install.packages("readxl")
# install.packages("lmtest")
# install.packages("fUnitRoots")
# install.packages("forecast")
# install.packages("here")

library(readxl)
library(lmtest)
library(fUnitRoots)
library(forecast)
library(here)


## Rutas del proyecto----

datos_dir <- here("Bases de Datos", "Denuncias DMCS")
ruta_base <- here("Bases de Datos", "Denuncias DMCS", "DenunciasDMCS.xlsx")
ruta_csv <- here("Bases de Datos", "Denuncias DMCS", "DenunciasDMCS.csv")


## Carga de datos----

base <- read_excel(ruta_base)

if (interactive()) {
  View(base)
}

# Exportacion opcional a CSV.
# write.csv2(base, file = ruta_csv, row.names = FALSE)


## Construccion de objetos de trabajo----

serie <- ts(base$Tasa_Denuncias_DMCC, start = c(2005, 1), frequency = 12)
serie
summary(serie)

train <- serie[1:144]
s.train <- ts(train, start = c(2005, 1), frequency = 12)
mes.train <- base$Mes[1:144]

test <- serie[145:180]
s.test <- ts(test, start = c(2017, 1), frequency = 12)
mes.test <- base$Mes[145:180]


# Serie original y descomposicion----

## Grafico de la serie original----

plot(
  serie,
  main = "Serie de Tiempo original - Tasa de Denuncias DMCC",
  ylab = "Tasa",
  xlab = "Tiempo",
  col = "darkblue",
  lwd = 1.5
)


## Descomposicion de la serie----

# decompose(
#   x = "Base Serie de tiempo",
#   type = "additive o multiplicative",
#   filter = NULL
# )

descomposicion_aditiva <- decompose(x = serie, type = "additive")
plot(descomposicion_aditiva)

descomposicion_multiplicativa <- decompose(x = serie, type = "multiplicative")
plot(descomposicion_multiplicativa)


# Estacionariedad y dependencia temporal----

## Transformacion logaritmica----

serie_log <- log(serie)

var(serie)
var(serie_log)

plot(
  serie_log,
  main = "Serie log-transformada",
  ylab = "Tasa",
  xlab = "Tiempo",
  col = "darkblue",
  lwd = 1.5
)

plot(
  serie,
  main = "Serie de Tiempo original - Tasa de Denuncias DMCC",
  ylab = "Tasa",
  xlab = "Tiempo",
  col = "darkblue",
  lwd = 1.5
)


## Test de Dickey-Fuller aumentado----

# adfTest(
#   x = "serie a evaluar",
#   lags = "rezagos",
#   type = "nc, c o ct",
#   title = NULL,
#   description = NULL
# )

adfTest(s.train, lags = 1, type = "nc")
adfTest(s.train, lags = 12, type = "nc")


## ACF y PACF----

par(mfrow = c(2, 1))

acf(serie, lag.max = 56, lwd = 1, main = "ACF - Serie original")
pacf(serie, lag.max = 56, lwd = 1, main = "PACF - Serie original")

par(mfrow = c(1, 1))


# Metodos de descomposicion clasica----

## Holt-Winters multiplicativo----

# HoltWinters(
#   x = "serie",
#   alpha = NULL,
#   beta = NULL,
#   gamma = NULL,
#   seasonal = "additive o multiplicative",
#   start.periods = NULL,
#   l.start = NULL,
#   b.start = NULL,
#   s.start = NULL,
#   optim.start = NULL,
#   optim.control = list()
# )

hwm <- HoltWinters(x = s.train, seasonal = "multiplicative")
hwm

plot(
  hwm,
  main = "Holt-Winters Multiplicativo - Original Entrenamiento vs Suavizada",
  ylab = "Indice",
  xlab = "Tiempo",
  col = "#394049",
  lty = 1,
  col.predicted = "red",
  lty.predicted = 1,
  lwd = 1
)


## Regresion con tendencia y dummies estacionales----

t <- 1:length(s.train)
t2 <- t^2
t3 <- t^3
t4 <- t^4
meses_dummy <- as.factor(cycle(s.train))

Modelo_reg_1 <- lm(s.train ~ meses_dummy + t)
summary(Modelo_reg_1)$adj.r.squared

Modelo_reg_2 <- lm(s.train ~ meses_dummy + t + t2)
summary(Modelo_reg_2)$adj.r.squared

Modelo_reg_3 <- lm(s.train ~ meses_dummy + t + t2 + t3)
summary(Modelo_reg_3)$adj.r.squared

Modelo_reg_4 <- lm(s.train ~ meses_dummy + t + t2 + t3 + t4)
summary(Modelo_reg_4)$adj.r.squared

Modelo_reg <- Modelo_reg_2
Modelo_reg

Serie_reg <- ts(fitted(Modelo_reg), start = start(s.train), frequency = 12)

plot(
  s.train,
  main = "Regresion Multiple Estacional vs Serie Original - Entrenamiento",
  ylab = "Tasa",
  xlab = "Tiempo",
  col = "black",
  lwd = 1
)
lines(Serie_reg, col = "red", lwd = 1, lty = 1)


# Diagnostico de modelos clasicos----

## Residuos----

resid.hwm <- residuals(hwm)
res_hwm_v <- as.numeric(resid.hwm)
mes_hwm_v <- as.numeric(cycle(resid.hwm))
keep_hwm <- !is.na(res_hwm_v)

resid.reg <- residuals(Modelo_reg)
res_reg_v <- as.numeric(resid.reg)
mes_reg_v <- as.numeric(cycle(s.train))
keep_reg <- !is.na(res_reg_v)


## Test de blancura: Holt-Winters multiplicativo----

# bptest(lm("modelo a evaluar"), varformula = NULL, studentize = TRUE)
# ks.test(x = "datos", y = "tipo de distribucion", ...)
# t.test(x = "datos", alternative = "two.sided", mu = 0)
# bartlett.test(x = "datos", g = "grupos")
# Box.test(x = "datos", lag = "rezagos", type = "Box-Pierce o Ljung-Box")

t_seq <- 1:length(res_hwm_v)
bptest(lm(resid.hwm ~ t_seq))

ks.test(resid.hwm, "pnorm", mean(resid.hwm), sd(resid.hwm))
t.test(resid.hwm, alternative = "two.sided", mu = 0, conf.level = 0.95)
bartlett.test(res_hwm_v[keep_hwm], g = factor(mes_hwm_v[keep_hwm]))

Box.test(resid.hwm, lag = 1, type = "Box-Pierce")
Box.test(resid.hwm, lag = 1, type = "Ljung-Box")
Box.test(resid.hwm, lag = 12, type = "Box-Pierce")
Box.test(resid.hwm, lag = 12, type = "Ljung-Box")


## Test de blancura: regresion multiple----

ks.test(resid.reg, "pnorm", mean(resid.reg), sd(resid.reg))
t.test(resid.reg, alternative = "two.sided", mu = 0, conf.level = 0.95)

t_seq <- 1:length(resid.reg)
bptest(lm(resid.reg ~ t_seq))

Box.test(resid.reg, lag = 1, type = "Box-Pierce")
Box.test(resid.reg, lag = 1, type = "Ljung-Box")
Box.test(resid.reg, lag = 12, type = "Box-Pierce")
Box.test(resid.reg, lag = 12, type = "Ljung-Box")


## Comparacion MAPE y criterios de informacion----

ajuste_reg <- fitted(Modelo_reg)
ajuste_hwm <- fitted(hwm)[, "xhat"]

metricas_reg <- accuracy(ajuste_reg, s.train)
metricas_hwm <- accuracy(ajuste_hwm, s.train)

mape_reg <- metricas_reg[1, "MAPE"]
mape_hwm <- metricas_hwm[1, "MAPE"]

tabla_mape_clasicos <- data.frame(
  Modelo = c("Regresion Dummy", "Holt-Winters Multiplicativo"),
  MAPE = c(mape_reg, mape_hwm)
)

tabla_mape_clasicos

modelo_hwm_moderno <- ets(s.train, model = "MAM")
modelo_hwm_moderno$aic
modelo_hwm_moderno$bic

AIC(Modelo_reg)
BIC(Modelo_reg)

# Los objetos HoltWinters base no tienen metodo logLik; para comparar AIC/BIC
# se usa el equivalente moderno ajustado con ets().
# AIC(hwm)
# BIC(hwm)


# Procesos no estacionarios----

## Diferenciacion correlativa y estacional----

diff_corr_1 <- diff(s.train, lag = 1, differences = 1)
adfTest(diff_corr_1, lags = 1, type = "nc")

acf(diff_corr_1, lag.max = 56, main = "ACF - Primera Diferenciacion Correlativa")
pacf(diff_corr_1, lag.max = 56, main = "PACF - Primera Diferenciacion Correlativa")

diff_est_1 <- diff(diff_corr_1, lag = 12, differences = 1)
adfTest(diff_est_1, lags = 12, type = "nc")

acf(diff_est_1, lag.max = 56, main = "ACF - Primera Diferenciacion Estacional")
pacf(diff_est_1, lag.max = 56, main = "PACF - Primera Diferenciacion Estacional")

auto.arima(serie)
ndiffs(serie)
nsdiffs(serie)


## Tabla resumen de diferenciaciones----

X_t <- s.train
diff_1 <- diff(s.train, differences = 1)
diff_12 <- diff(s.train, lag = 12)
diff_1_12 <- diff(diff_1, lag = 12)
diff_2 <- diff(s.train, differences = 2)
diff_12_2 <- diff(s.train, lag = 12, differences = 2)

calcular_metricas <- function(ts_data) {
  ts_clean <- na.omit(ts_data)

  p_val_lag1 <- adfTest(ts_clean, lags = 1, type = "nc")@test$p.value
  p_val_lag12 <- adfTest(ts_clean, lags = 12, type = "nc")@test$p.value
  stdev <- sd(ts_clean)

  round(c(p_val_lag1, p_val_lag12, stdev), 4)
}

tabla_resumen <- data.frame(
  "X_t" = calcular_metricas(X_t),
  "diff_X_t" = calcular_metricas(diff_1),
  "diff12_X_t" = calcular_metricas(diff_12),
  "diff12_diff_X_t" = calcular_metricas(diff_1_12),
  "diff2_X_t" = calcular_metricas(diff_2),
  "diff12_2_X_t" = calcular_metricas(diff_12_2)
)

rownames(tabla_resumen) <- c(
  "adfTest(., lags = 1)",
  "adfTest(., lags = 12)",
  "Stdev"
)

print(tabla_resumen)


# Modelos SARIMA----

## Ajuste automatico y manual----

modelo_automatico <- auto.arima(
  s.train,
  stepwise = FALSE,
  approximation = FALSE
)

modelo_automatico_ml <- auto.arima(
  s.train,
  stepwise = FALSE,
  approximation = FALSE,
  method = "ML"
)

# auto.arima(
#   s.train,
#   stepwise = FALSE,
#   approximation = FALSE,
#   method = "CSS, ML o CSS-ML"
# )

modelo_manual_css <- Arima(
  s.train,
  order = c(0, 1, 0),
  seasonal = c(1, 1, 1),
  method = "CSS"
)

modelo_manual <- Arima(
  s.train,
  order = c(0, 1, 0),
  seasonal = c(1, 1, 1),
  method = "ML"
)


## Comparacion de modelos SARIMA----

errores_automatico <- accuracy(modelo_automatico)
errores_manual <- accuracy(modelo_manual)

mape_automatico <- errores_automatico[1, "MAPE"]
mape_manual <- errores_manual[1, "MAPE"]

tabla_mape_sarima <- data.frame(
  Modelo = c("ARIMA Manual (0,1,0)(1,1,1)", "ARIMA Automatico"),
  MAPE_Porcentaje = c(mape_manual, mape_automatico)
)

tabla_mape_sarima$MAPE_Porcentaje <- round(tabla_mape_sarima$MAPE_Porcentaje, 2)
print(tabla_mape_sarima)

parametros_hwm <- 17
parametros_reg <- length(coef(Modelo_reg))
parametros_aut <- length(coef(modelo_automatico))
parametros_man <- length(coef(modelo_manual))

tabla_parsimonia <- data.frame(
  Modelo = c("Holt-Winters Mult", "Regresion Dummies", "Auto ARIMA", "ARIMA Manual"),
  Cantidad_Parametros = c(parametros_hwm, parametros_reg, parametros_aut, parametros_man)
)

tabla_parsimonia <- tabla_parsimonia[order(tabla_parsimonia$Cantidad_Parametros), ]
print(tabla_parsimonia)


## Test de blancura: modelos ARIMA----

resid_aut <- residuals(modelo_automatico)
res_aut_v <- as.numeric(resid_aut)
mes_aut_v <- as.numeric(cycle(resid_aut))
keep_aut <- !is.na(res_aut_v)

resid_man <- residuals(modelo_manual)
res_man_v <- as.numeric(resid_man)
mes_man_v <- as.numeric(cycle(resid_man))
keep_man <- !is.na(res_man_v)

ks.test(resid_aut, "pnorm", mean(resid_aut), sd(resid_aut), alternative = "two.sided")
t.test(resid_aut, alternative = "two.sided", mu = 0, conf.level = 0.95)

t_seq <- 1:length(resid_aut)
bptest(lm(resid_aut ~ t_seq))

Box.test(resid_aut, lag = 1, type = "Ljung-Box")
Box.test(resid_aut, lag = 12, type = "Ljung-Box")

ks.test(resid_man, "pnorm", mean(resid_man), sd(resid_man), alternative = "two.sided")
t.test(resid_man, alternative = "two.sided", mu = 0, conf.level = 0.95)

t_seq <- 1:length(resid_man)
bptest(lm(resid_man ~ t_seq))

Box.test(resid_man, lag = 1, type = "Ljung-Box")
Box.test(resid_man, lag = 12, type = "Ljung-Box")


# Predicciones----

# forecast(
#   object = "modelo ajustado",
#   h = "pasos hacia adelante",
#   level = "intervalo de confianza",
#   fan = FALSE,
#   bootstrap = FALSE
# )

pred_aut <- forecast(modelo_automatico, h = 36, level = 95)

plot(
  pred_aut,
  main = "Pronostico Auto.ARIMA vs Serie Original (2017 - 2019)",
  ylab = "Tasa de Denuncias",
  xlab = "Tiempo",
  xlim = c(2014, 2020),
  lwd = 1.5
)

lines(s.test, col = "red", lwd = 2)

tiempo_final_historia <- time(s.train)[length(s.train)]
valor_final_historia <- s.train[length(s.train)]

tiempo_inicio_futuro <- time(pred_aut$mean)[1]
valor_inicio_futuro <- pred_aut$mean[1]

segments(
  x0 = tiempo_final_historia,
  y0 = valor_final_historia,
  x1 = tiempo_inicio_futuro,
  y1 = valor_inicio_futuro,
  col = "blue",
  lwd = 2
)

legend(
  "bottomleft",
  legend = c("Historia (2005-2016)", "Pronostico ARIMA", "Intervalo 95%", "Realidad (2017-2019)"),
  col = c("black", "blue", "gray80", "red"),
  lty = c(1, 1, 1, 1),
  lwd = c(1.5, 2, 8, 2),
  bty = "n",
  cex = 0.8
)

comparacion_pred <- accuracy(pred_aut, s.test)
mape_comparacion <- comparacion_pred[2, "MAPE"]
mape_comparacion


# Analisis espectral----

## Periodograma----

periodograma <- spec.pgram(
  s.train,
  log = "no",
  main = "Periodograma - Serie de entrenamiento",
  xlab = "Frecuencia",
  ylab = "Espectro"
)

f_dom <- periodograma$freq[which.max(periodograma$spec)]
f_dom
1 / f_dom


## Periodograma alternativo----

# spectrum(
#   x = "datos",
#   log = "yes, no o dB",
#   spans = NULL,
#   method = "pgram o ar"
# )

periodograma_alt <- spectrum(
  s.train,
  log = "no",
  main = "Periodograma - Serie Original - Entrenamiento",
  xlab = "Frecuencia (Ciclos por mes)",
  ylab = "Densidad Espectral",
  col = "darkblue",
  lwd = 1.5
)

amplitud_max <- which.max(periodograma_alt$spec)
frecuencia_dominante <- periodograma_alt$freq[amplitud_max]
periodo_meses <- 1 / frecuencia_dominante

abline(v = frecuencia_dominante, col = "red", lwd = 2, lty = 2)
