;;; Antonio Coín Castro.
;;; Ejercicio 4: Contar el número de hechos de un determinado tipo.

; Definimos algunos hechos de ejemplo para probar
(deffacts Ejemplos
  (Hecho t1 e11 e12 e13)
  (Hecho t1 e14)
  (Hecho t2 e21)
  (Hecho t2 e22 e23)
  (Hecho t3 e31)
)

; Inicializamos el número de hechos a 0
(defrule Inicializa_hechos
  (declare (salience 10))
  (Hecho ?t $?)
  (not (NumeroHechos ?t ?))
  =>
  (assert (NumeroHechos ?t 0))
)

; Si no hay hechos de ese tipo, devolvemos 0
(defrule Contar_hechos_no
  ?f <- (ContarHechos ?t)
  (not (Hecho ?t $?))
  =>
  (printout t "Numero de hechos de tipo " ?t ": 0" crlf)
  (retract ?f)
)

; Si ya habíamos contado antes, reiniciamos la cuenta
(defrule Reiniciar_cuenta
  (declare (salience 2))
  (ContarHechos ?t)
  ?f <- (NumeroHechos ?t ?n)
  ?g <- (HechosContados ?t)
  =>
  (retract ?f ?g)
  (assert (NumeroHechos ?t 0))
)

; Contamos el número de hechos distintos de ese tipo
(defrule Contar_hechos
  (declare (salience 1))
  (ContarHechos ?t)
  (Hecho ?t $?e)
  ?f <- (NumeroHechos ?t ?n)
  (not (Contado ?t $?e))
  =>
  (retract ?f)
  (assert
    (Contado ?t ?e)
    (NumeroHechos ?t (+ ?n 1)))
)

; Continuamos tras contar los hechos
(defrule Continuar
  ?f <- (ContarHechos ?t)
  (NumeroHechos ?t ?n)
  =>
  (printout t "Numero de hechos de tipo " ?t ": " ?n crlf)
  (retract ?f)
  (assert (HechosContados ?t))
)

; Eliminamos los hechos temporales que hemos usado para contar
(defrule Reiniciar_contados
  (HechosContados ?t)
  ?f <- (Contado ?t $?)
  =>
  (retract ?f)
)
