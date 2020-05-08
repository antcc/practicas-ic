;;; Antonio Coín Castro.
;;; Ejercicio 2: Presentar un menú al usuario para que elija de entre
;;; unas cuantas opciones. Se comprueba que la elección sea válida.
;;; Se permite elección múltiple.

; Definimos las opciones que tendrá el usuario
(deffacts Hechos_iniciales
  (Preguntar)
  (Opciones a b c d)
)

; Hacemos la pregunta. Si alguna de las opciones no es válida, se vuelve
; a realizar la pregunta (no se guardan respuestas parcialmente válidas).
(defrule Preguntar
  ?f <- (Preguntar)
  =>
  (printout t "Elige una o varias de estas opciones (separadas por espacios):" crlf)
  (printout t "  a] Opcion A" crlf "  b] Opcion B" crlf
    "  c] Opcion C" crlf "  d] Opcion D" crlf)
  (printout t "Opcion elegida: ")
  (retract ?f)
  (assert (OpcionesElegidas (explode$ (readline))))
)

; Si la opción es válida, la guardamos
(defrule Opcion_valida
  ?f <- (OpcionesElegidas ?r $?resto)
  =>
  (retract ?f)
  (assert (OpcionElegida ?r))
  (if (neq (length ?resto) 0) then
    (assert (OpcionesElegidas ?resto)))
)

; Comprobamos que la opción esté entre las permitidas
(defrule Opcion_no_valida
  (declare (salience 1))
  ?f <- (OpcionesElegidas ?r $?resto)
  (not (Opciones $? ?r $?))
  =>
  (printout t "La opcion " ?r " no es valida." crlf)
  (retract ?f)
  (assert (Limpiar))
)

; Limpiamos las opciones elegidas
(defrule Limpiar
  (Limpiar)
  ?f <- (OpcionElegida ?r)
  =>
  (retract ?f)
)

; Volvemos a preguntar
(defrule Limpio
  ?f <- (Limpiar)
  (not (exists (OpcionElegida)))
  =>
  (retract ?f)
  (assert (Preguntar))
)

; Si todo va bien, continuamos
(defrule Continuar
  (declare (salience -1))
  (OpcionElegida ?r)
  =>
  (printout t "La opcion " ?r " es valida." crlf)
)
