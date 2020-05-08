;;; Antonio Coín Castro.
;;; Ejercicio 1: Presentar un menú al usuario para que elija de entre
;;; unas cuantas opciones. Se comprueba que la elección sea válida.

; Definimos las opciones que tendrá el usuario
(deffacts Hechos_iniciales
  (Preguntar)
  (Opciones a b c d)
)

; Hacemos la pregunta
(defrule Preguntar
  ?f <- (Preguntar)
  =>
  (printout t "Elige una de estas opciones:" crlf)
  (printout t "  a] Opcion A" crlf "  b] Opcion B" crlf
    "  c] Opcion C" crlf "  d] Opcion D" crlf)
  (printout t "Opcion elegida: ")
  (retract ?f)
  (assert (OpcionElegida (read)))
)

; Comprobamos que la opción esté entre las permitidas
(defrule Opcion_no_valida
  (declare (salience 1))
  ?f <- (OpcionElegida ?r)
  (not (Opciones $? ?r $?))
  =>
  (printout t "La opcion " ?r " no es valida." crlf)
  (retract ?f)
  (assert (Preguntar))
)

; Si todo va bien, continuamos
(defrule Continuar
  (OpcionElegida ?r)
  =>
  (printout t "La opcion " ?r " es valida." crlf)
)
