; TODO: eliminar el modulo del deffacts

(deffacts BORRAR
  (modulo MENU_RECOMENDAR_ASIG)
)

;
; MÓDULO MENU_RECOMENDAR_ASIG
;

(defrule Activar_pregunta
  (modulo MENU_RECOMENDAR_ASIG)
  =>
  (assert (Preguntar))
)

; Hacemos la pregunta
(defrule Preguntar
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (Preguntar)
  =>
  (printout t "Elige una de estas opciones:" crlf)
  (printout t "  a] Ver lista de asignaturas disponibles en la BBDD y sus codigos" crlf
  "  b] Comenzar proceso de recomendacion de asignaturas" crlf
  "  c] Volver al menu principal" crlf )
  (printout t "Opcion elegida: ")
  (retract ?f)
  (assert (OpcionElegida (read)))
)

; Comprobamos que la opción esté entre las permitidas
(defrule Opcion_no_valida
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (OpcionElegida ?r)
  (not (Opciones $? ?r $?))
  =>
  (printout t "La opcion " ?r " no es valida." crlf)
  (retract ?f)
  (assert (Preguntar))
)

(defrule Volver_menu
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (OpcionElegida c)
  =>
  (retract ?f)
  (assert (Limpia_temp) (Salir))
)

(defrule Muestra_asig
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (OpcionElegida a)
  =>
  (printout t "Esta es la lista de asignaturas disponibles en la BBDD:" crlf)
  (do-for-all-facts ((?a asignatura)) TRUE
    (printout t ?a:id " " ?a:nombre crlf))
  (retract ?f)
  (assert (Preguntar))
)

(defrule Limpia_previo
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (OpcionElegida b)
  =>
  (retract ?f)
  (assert
    (Limpia_temp)
    (Preguntar_lista))
)

(defrule Pregunta_lista_asig
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (Preguntar_lista)
  =>
  (printout t "Escribe los codigos de las asignaturas posibles (separados por espacios): ")
  (retract ?f)
  (assert
    (T1 ListaAsig (explode$ (readline)))
    (Preguntar_cred))
)

(defrule Pregunta_cred
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (Preguntar_cred)
  =>
  (printout t "Escribe los creditos totales a matricular: ")
  (retract ?f)
  (assert
    (T1 Creditos (read))
    (Preguntar_curso))
)

(defrule Pregunta_curso
  ?f <- (modulo MENU_RECOMENDAR_ASIG)
  ?g <- (Preguntar_curso)
  =>
  (printout t "Cuantos cursos llevas en la carrera? (0+): ")
  (retract ?f ?g)
  (assert
    (T1 Curso (read))
    (modulo PREGUNTAR_RECOMENDAR_ASIG))
)

;;; LIMPIEZA

(defrule Limpia_temp
  (declare (salience 1))
  (modulo MENU_RECOMENDAR_ASIG)
  (Limpia_temp)
  ?f <- (T1 $?)
  =>
  (retract ?f)
)

(defrule Termina_limpia_temp
  (declare (salience 1))
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (Limpia_temp)
  (not (T1 $?))
  =>
  (retract ?f)
)

(defrule Salir
  ?f <- (modulo MENU_RECOMENDAR_ASIG)
  ?g <- (Salir)
  =>
  (retract ?f ?g)
  (assert (modulo MENU_PRINCIPAL))
)


;
; MÓDULO PREGUNTAR_RECOMENDAR_ASIG
;

(defrule Mensaje_bienvenida
  (declare (salience 2))
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Bienvenido al sistema de ayuda de eleccion de asignaturas. Te hare una serie " crlf
    "de preguntas y te recomendare unas asignaturas como lo haria un estudiante. A las " crlf "preguntas categoricas puedes contestar Bajo/a (B), Medio/a (M), Alto/a (A) o No se (NS)." crlf "Si a cualquier pregunta numerica contestas '-1' o a cualquier pregunta categorica" crlf "contestas 'X', el sistema parara de hacer preguntas. Ademas, en las preguntas numericas" crlf "si contestas -2, es equivalente a contestar 'no se'." crlf)
)

;;; Si contesta '-1' a una pregunta numerica o 'X' a una categorica, paramos
;;; y pasamos al siguiente modulo.

(defrule Parar_num
  (declare (salience 1))
  ?f <- (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?g <- (T1 dato_num ? ?num & :(= ?num -1))
  =>
  (retract ?f ?g)
  (assert (modulo RAZONAR_RECOMENDAR_ASIG))
)

(defrule Parar_cat
  (declare (salience 1))
  ?f <- (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?g <- (T1 dato ? X)
  =>
  (retract ?f ?g)
  (assert (modulo RAZONAR_RECOMENDAR_ASIG))
)

;;; Realizamos todas las preguntas. Las respuestas numericas las representamos
;;; como (T1 dato_num ?factor ?valor), y las categoricas directamente con
;;; (T1 dato ?factor ?valor).

(defrule Pregunta_1
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Cual es tu nota media? (5-10): ")
  (bind ?x (read))
  (if (>= ?x -1) then
    (assert (T1 dato_num nota ?x)))
)

(defrule Pregunta_2
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Cuantos creditos has superado ya? (>=0): ")
  (bind ?x (read))
  (if (>= ?x -1) then
    (assert (T1 dato_num superados ?x)))
)

; Dejar en blanco es equivalente a responder NS
(defrule Pregunta_3
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Cual(es) de estas areas de la informatica te gusta(n) mas? " crlf)
  (do-for-all-facts ((?f equivalencia_area)) TRUE
    (printout t "  - " (nth$ 2 ?f:implied) " (" (nth$ 1 ?f:implied) ")" crlf))
  (printout t "Respuesta (separadas por espacios): ")
  (assert (T1 dato areas (explode$ (readline))))
)

(defrule Pregunta_4
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Como calificarias tu capacidad de trabajo? (B/M/A/NS): ")
  (bind ?x (read))
  (if (<> (str-compare ?x "NS") 0) then
    (assert (T1 dato capacidad ?x)))
)

(defrule Pregunta_5
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Como calificarias tu gusto por la programacion? (B/M/A/NS): ")
  (bind ?x (read))
  (if (<> (str-compare ?x "NS") 0) then
    (assert (T1 dato programacion ?x)))
)

(defrule Pregunta_6
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Como calificarias tu afinidad con las aplicaciones practicas? (B/M/A/NS): ")
  (bind ?x (read))
  (if (<> (str-compare ?x "NS") 0) then
    (assert (T1 dato practicas ?x)))
)

;;; Transformamos variables numericas a categoricas

(defrule Evalua_bajo
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?f <- (T1 dato_num ?cosa ?n)
  (equivalencia_cat ?cosa u1 ?x)
  (test (< ?n ?x))
  =>
  (retract ?f)
  (assert (T1 dato ?cosa B))
)

(defrule Evalua_medio
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?f <- (T1 dato_num ?cosa ?n)
  (equivalencia_cat ?cosa u1 ?x1)
  (equivalencia_cat ?cosa u2 ?x2)
  (test (and (>= ?n ?x1) (< ?n ?x2)))
  =>
  (retract ?f)
  (assert (T1 dato ?cosa M))
)

(defrule Evalua_alto
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?f <- (T1 dato_num ?cosa ?n)
  (equivalencia_cat ?cosa u2 ?x)
  (test (>= ?n ?x))
  =>
  (retract ?f)
  (assert (T1 dato ?cosa A))
)

(defrule Avanzar_razonador
  (declare (salience -1))
  ?f <- (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (retract ?f)
  (assert (modulo RAZONAR_RECOMENDAR_ASIG))
)


;
; MÓDULO RAZONAR_RECOMENDAR_ASIG
;

(defrule Iniciar_puntuacion
  (declare (salience 2))
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (T1 ListaAsig $?lasig)
  =>
  (do-for-all-facts ((?f asignatura))
    (neq (member$ ?f:id $?lasig) FALSE)
      (assert (T1 Puntos ?f:id 0)))
)

(deffunction add-explicacion (?sentido ?id ?expl)
  (if (= (str-compare ?sentido "positiva") 0) then
    (assert (T1 explicacion-positiva ?id ?expl))
  else
    (assert (T1 explicacion-negativa ?id ?expl)))
)

(defrule Procesar_antecedentes
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (regla ?num antecedentes $?ant)
  =>
  (bind ?i 1)
  (while TRUE do
    (if (> ?i (length $?ant)) then
      (break))
    (assert (T1 check-antecedente ?num (nth$ ?i $?ant) (nth$ (+ ?i 1) $?ant)))
    (bind ?i (+ ?i 2)))
  (assert (T1 Procesar_consecuente ?num))
)

(defrule Check-antecedentes
  (modulo RAZONAR_RECOMENDAR_ASIG)
  ?f <- (T1 check-antecedente ? ?caract ?valor)
  (T1 dato ?caract ?v)
  =>
  (if (eq ?v ?valor) then
    (retract ?f))
)

(defrule Procesar_consecuente
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (T1 ListaAsig $?lasig)
  (regla ?num consecuente ?signo ?caract ?valor)
  (regla ?num explicacion ?expl)
  ?f <- (T1 Procesar_consecuente ?num)
  (not (T1 check-antecedente ?num $?))
  =>
  (retract ?f)
  (bind ?facts
    (find-all-facts ((?f asignatura))
      (and (neq (member$ ?f:id $?lasig) FALSE) (eq ?f:?caract ?valor))))

  (loop-for-count (?i 1 (length$ ?facts))
    (bind ?id (fact-slot-value (nth$ ?i ?facts) id))
    (assert (contar ?id ?signo por_regla ?num))
    (if (= ?signo 1) then
      (add-explicacion positiva ?id ?expl)
    else
      (add-explicacion negativa ?id ?expl))
  )
)

(defrule Contar_puntos_area
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (T1 dato areas $?la)
  (T1 ListaAsig $?lasig)
  =>
  (loop-for-count (?i 1 (length$ $?la))
    (bind ?a (nth$ ?i $?la))
    (do-for-all-facts ((?f asignatura))
      (and (neq (member$ ?f:id $?lasig) FALSE) (neq (member$ ?a ?f:areas) FALSE))
        (do-for-all-facts ((?g equivalencia_area)) (eq ?a (nth$ 1 ?g:implied))
            (bind ?a_equiv (nth$ 2 ?g:implied))
            (add-explicacion positiva ?f:id (str-cat "Es afin al area de conocimiento " ?a_equiv " que has indicado que te gusta"))
            (assert
              (contar ?f:id 1 por_area (nth ?i $?la))))))
)

(defrule Contar_puntos
  (modulo RAZONAR_RECOMENDAR_ASIG)
  ?f <- (contar ?id ?s $?)
  ?g <- (T1 Puntos ?id ?n)
  =>
  (retract ?f ?g)
  (assert (T1 Puntos ?id (+ ?n ?s)))
)

; Dar opción de ver algunas razones negativas relevantes DE LAS ASIG NO ELEGIDAS.
; mostrar solo las que no sean vacias. TODO: añadir reglas negativas

; TODO assert Preguntar cuando acabe
; TODO acumular explicaciones positivas y negativas
; TODO: borrar todos los facts generados cuando acabe (Limpiar_temp)
(defrule Recomendar
  (declare (salience -1))
  ?f <- (modulo RAZONAR_RECOMENDAR_ASIG)
  =>
  (printout t "Aqui iria la recomendacion" crlf)
  (retract ?f)
  (assert
    (modulo MENU_RECOMENDAR_ASIG)
    (Preguntar))
)
