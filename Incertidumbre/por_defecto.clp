;;; Antonio Coín Castro.
;;; Ejercicio sobre razonamiento por defecto en CLIPS.

; Hechos iniciales
(deffacts Iniciales
  (ave gorrion)
  (ave paloma)
  (ave aguila)
  (ave pinguino)
  (mamifero vaca)
  (mamifero perro)
  (mamifero caballo)
  (vuela pinguino no seguro)
  (preguntar)
)

; Las aves son animales
(defrule aves_son_animales
  (ave ?x)
  =>
  (assert (animal ?x))
  (bind ?expl (str-cat "sabemos que un " ?x " es un animal porque "
    "las aves son un tipo de animal"))
  (assert (explicacion ave ?x ?expl))
)

; Los mamíferos son animales
(defrule mamiferos_son_animales
  (mamifero ?x)
  =>
  (assert (animal ?x))
  (bind ?expl (str-cat "sabemos que un " ?x " es un animal porque "
    "los mamiferos son un tipo de animal"))
  (assert (explicacion animal ?x ?expl))
)

; Asumimos por defecto que las aves vuelan
(defrule ave_vuela_por_defecto
  (declare (salience -1)) ; disminuir la probabilidad de añadir erroneamente
  (ave ?x)
  =>
  (assert (vuela ?x si por_defecto))
  (bind ?expl (str-cat "asumo que un " ?x " vuela, porque casi todas las aves vuelan"))
  (assert (explicacion vuela ?x ?expl))
)

; Retractamos cuando hay algo en contra
(defrule retracta_vuela_por_defecto
  (declare (salience 1)) ; retractar antes de inferir cosas erroneamente
  ?f <- (vuela ?x ?r por_defecto)
  (vuela ?x ?s seguro)
  =>
  (retract ?f)
  (bind ?expl (str-cat "retractamos que un " ?x " " ?r " vuela por defecto, porque "
    "sabemos seguro que " ?x " " ?s " vuela"))
  (assert (explicacion retracta_vuela ?x ?expl))
)

; Asumimos por defecto que un animal no vuela
(defrule mayor_parte_animales_no_vuelan
  (declare (salience -2)) ; mejor después de otros razonamientos
  (animal ?x)
  (not (vuela ?x ? ?))
  =>
  (assert (vuela ?x no por_defecto))
  (bind ?expl (str-cat "asumo que un " ?x " no vuela, porque la mayor parte de los "
    "animales no vuelan"))
  (assert (explicacion no_vuela ?x ?expl))
)

; Preguntamos por un animal para saber si vuelta
(defrule preguntar_animal
  ?f <- (preguntar)
  =>
  (printout t "Introduce un animal para saber si vuela: ")
  (retract ?f)
  (assert (preguntado (read)))
)

; Vemos si queremos hacer otra pregunta
(defrule repetir_pregunta
  ?f <- (repetir)
  =>
  (printout t "Quieres hacer otra pregunta? (s/n): ")
  (retract ?f)
  (bind ?resp (read))
  (if (eq ?resp s)
    then
      (assert(preguntar)))
)

; Si tenemos conocimiento sobre si vuela, lo decimos
(defrule animal_conocido_vuela
  (declare (salience -3))
  ?f <- (preguntado ?x)
  (vuela ?x ?r ?)
  =>
  (printout t "Un " ?x " " ?r " vuela" crlf)
  (retract ?f)
  (assert (repetir))
)

; Si no tenemos conocimiento sobre ese animal, preguntamos si es ave o mamífero
(defrule preguntar_ave_mamifero
  (declare (salience -4))
  (preguntado ?x)
  (not (vuela ?x ? ?))
  =>
  (printout t "Dime si un " ?x " es un ave (a) o un mamifero (m). Si no lo sabes, "
    "responde cualquier otra letra: ")
  (assert (tipo_animal ?x (read)))
)

; Evaluamos la respuesta
(defrule evalua_ave_mamifero
  ?f <- (tipo_animal ?x ?r)
  =>
  (retract ?f)
  (if (eq ?r a)
    then
      (assert (ave ?x))
    else
      (if (eq ?r m)
        then
          (assert (mamifero ?x))
        else
          (assert (animal ?x))))
)
