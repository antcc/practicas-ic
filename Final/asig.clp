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

(defrule Inicializar
  (declare (salience 2))
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (T1 ListaAsig $?lasig)
  =>
  (assert
    (T1 CreditosRecomendados 0)
    (T1 AsigRecomendadas))
  (do-for-all-facts ((?f asignatura))
    (neq (member$ ?f:id $?lasig) FALSE)
      (assert
        (T1 Puntos ?f:id 0)
        (T1 motivos-pos ?f:id "")
        (T1 motivos-neg ?f:id "")))
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
            (add-explicacion positiva ?f:id (str-cat "Es afin al area de conocimiento " ?a_equiv ", que has indicado que te gusta"))
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

(defrule Puntos_asignatura_favorita
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (Asigantura_fav ?id)
  (Explicacion_fav ?id ?expl)
  ?f <- (T1 Puntos ?id ?n)
  (not (T1 Contada_fav ?id))
  =>
  (retract ?f)
  (assert
    (T1 Puntos ?id (+ ?n 100))
    (T1 Contada_fav ?id))
  (add-explicacion positiva ?id ?expl)
)

(defrule Max_puntos
  (declare (salience -1))
  (modulo RAZONAR_RECOMENDAR_ASIG)
  ?f <- (T1 Puntos ?id ?n)
  ?g <- (T1 CreditosRecomendados ?c)
  ?h <- (T1 AsigRecomendadas $?actual)
  (T1 Creditos ?c_tot)
  (not
    (and
      (T1 Puntos ?otro_id ?m)
      (test (> ?m ?n))))
  =>
  (retract ?f)
  (bind ?asig (fact-index (nth$ 1 (find-fact ((?a asignatura)) (eq ?a:id ?id)))))
  (bind ?asig_id (fact-slot-value ?asig id))
  (bind ?asig_cred (fact-slot-value ?asig creditos))
  (bind ?new_c (+ ?c ?asig_cred))
  (if (<= ?new_c ?c_tot) then
    (retract ?g ?h)
    (assert
      (T1 CreditosRecomendados ?new_c)
      (T1 AsigRecomendadas $?actual ?asig_id)))
)

(defrule Avanzar_recomendador
  (declare (salience -2))
  ?f <- (modulo RAZONAR_RECOMENDAR_ASIG)
  =>
  (retract ?f)
  (assert (modulo RECOMENDAR_RECOMENDAR_ASIG))
)


;
; MODULO DE RECOMENDACIONES
;

(defrule Juntar_motivos_positivos
  (declare (salience 1))
  (modulo RECOMENDAR_RECOMENDAR_ASIG)
  ?f <- (T1 explicacion-positiva ?id ?expl)
  ?g <- (T1 motivos-pos ?id ?mot)
  =>
  (retract ?f ?g)
  (assert (T1 motivos-pos ?id (format nil (str-cat ?mot "  * " ?expl "%n"))))
)

(defrule Juntar_motivos_negativos
  (declare (salience 1))
  (modulo RECOMENDAR_RECOMENDAR_ASIG)
  ?f <- (T1 explicacion-negativa ?id ?expl)
  ?g <- (T1 motivos-neg ?id ?mot)
  =>
  (retract ?f ?g)
  (assert (T1 motivos-neg ?id (format nil (str-cat ?mot "  * " ?expl "%n"))))
)

(defrule Recomendar
  (modulo RECOMENDAR_RECOMENDAR_ASIG)
  (T1 Creditos ?c_orig)
  (T1 CreditosRecomendados ?c)
  (T1 AsigRecomendadas $?lasig)
  =>
  (printout t "Numero de creditos que te recomiendo matricular: " ?c crlf)
  (if (> ?c_orig ?c) then
    (printout t "(No te puedo recomendar los " ?c_orig " creditos que querias con la lista " crlf
                "de asignaturas que me has dado)" crlf))
  (printout t "Aqui esta la lista de asignaturas que te recomiendo, ordenada de forma que " crlf
              "conforme mas arriba este, mas fuerte es la recomendacion:" crlf)
  (loop-for-count (?i 1 (length$ $?lasig))
    (bind ?asig
      (fact-index (nth$ 1 (find-fact ((?a asignatura)) (eq ?a:id (nth$ ?i $?lasig))))))
    (bind ?motivo (fact-index (nth$ 1
      (find-fact ((?g T1)) (and (eq (nth$ 1 ?g:implied) motivos-pos) (eq (nth$ 2 ?g:implied) (fact-slot-value ?asig id)))))))
    (printout t crlf "Recomendacion: " (fact-slot-value ?asig nombre) crlf "---------------------------------------"
     crlf "Experto: Javier Saez" crlf "Motivos: " crlf (nth$ 3 (fact-slot-value ?motivo implied))))
)

(defrule Pregunta_mostrar_motivos_neg
  (declare (salience -1))
  (modulo RECOMENDAR_RECOMENDAR_ASIG)
  =>
  (printout t crlf "Quieres ver los principales motivos por los que el resto de asignaturas" crlf
              "no han sido recomendadas? (S/N): ")
  (printout t "")
  (if (eq (read) S) then
    (assert (Mostrar_neg)))
)

;TODO: mostrar solo las que no sean vacias
(defrule Mostrar_motivos_neg
  (modulo RECOMENDAR_RECOMENDAR_ASIG)
  ?f <- (Mostrar_neg)
  (T1 AsigRecomendadas $?lrec)
  (T1 ListaAsig $?lasig)
  =>
  (bind ?vacio S)
  (loop-for-count (?i 1 (length$ $?lasig))
    (bind ?asig
      (fact-index (nth$ 1 (find-fact ((?a asignatura)) (eq ?a:id (nth$ ?i $?lasig))))))
    (if (eq (member$ (fact-slot-value ?asig id) $?lrec) FALSE) then
      (bind ?motivo (fact-index (nth$ 1
        (find-fact ((?g T1)) (and (eq (nth$ 1 ?g:implied) motivos-neg) (eq (nth$ 2 ?g:implied) (fact-slot-value ?asig id)))))))

      (bind ?texto_mot (nth$ 3 (fact-slot-value ?motivo implied)))
      (if (<> (str-compare ?texto_mot "") 0) then
        (bind ?vacio N)
        (printout t (fact-slot-value ?asig nombre) crlf "---------------------------------------"
      crlf "Motivos de rechazo: " ?texto_mot crlf crlf))))

  (if (eq ?vacio N) then
    (retract ?f))
)

(defrule No_neg
  (declare (salience -1))
  ?f <- (Mostrar_neg)
  =>
  (retract ?f)
  (printout t "No hay motivos negativos. Simplemente las que te he recomendado tienen "
              "mas motivos positivos." crlf crlf)
)

(defrule Volver_menu_recomendar
  (declare (salience -2))
  ?f <- (modulo RECOMENDAR_RECOMENDAR_ASIG)
  =>
  (retract ?f)
  (assert
    (modulo MENU_RECOMENDAR_ASIG)
    (Preguntar))
)
