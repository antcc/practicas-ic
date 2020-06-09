;;;;;;;;;;;;;;;; RECOMENDACION DE UNA ASIGNATURA (REGLAS) ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Reglas y sistema de razonamiento para el problema de recomendar
;;; una asignatura de Ingenieria Informatica como lo haria un estudiante.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ingenieria del Conocimiento. Curso 2019/20.
;;; Antonio Coin Castro.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;
;;;;;; MODULO PARA EL SUBMENU
;;;;;;

(defrule a_Activar_pregunta
  (modulo MENU_RECOMENDAR_ASIG)
  =>
  (assert (Preguntar))
)

; Mostramos las opciones del menu
(defrule a_Preguntar
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

; Comprobamos que la opción este entre las permitidas
(defrule a_Opcion_no_valida
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (OpcionElegida ?r)
  (not (Opciones $? ?r $?))
  =>
  (printout t "La opcion " ?r " no es valida." crlf)
  (retract ?f)
  (assert (Preguntar))
)

; Opcion c: volver al menu principal
(defrule a_Volver_menu_principal
  ?f <- (modulo MENU_RECOMENDAR_ASIG)
  ?g <- (OpcionElegida c)
  =>
  (retract ?f ?g)
  (assert (Resetear))
)

; Opcion a: mostrar lista de asignaturas
(defrule a_Muestra_asig
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (OpcionElegida a)
  =>
  (printout t "Esta es la lista de asignaturas disponibles en la BBDD:" crlf)
  (do-for-all-facts ((?a asignatura)) TRUE
    (printout t ?a:id " " ?a:nombre crlf))
  (retract ?f)
  (assert (Preguntar))
)

; Opcion b: limpiar calculos previos y comenzar sistema recomendador
(defrule a_Limpia_previo
  (modulo MENU_RECOMENDAR_ASIG)
  ?f <- (OpcionElegida b)
  =>
  (retract ?f)
  (assert
    (Limpia_temp))
)

;;; LIMPIEZA

; Limpia todos los hechos que comienzan con RA
(defrule a_Limpia_temp
  (modulo MENU_RECOMENDAR_ASIG)
  (Limpia_temp)
  ?f <- (RA $?)
  =>
  (retract ?f)
)

(defrule a_Avanza_preguntas
  ?f <- (modulo MENU_RECOMENDAR_ASIG)
  ?g <- (Limpia_temp)
  (not (RA $?))
  =>
  (retract ?f ?g)
  (assert (modulo PREGUNTAR_RECOMENDAR_ASIG))
)

;;;;;;
;;;;;; MODULO PARA LAS PREGUNTAS DE CARACTERISTICAS
;;;;;;

; Primera pregunta obligatoria: lista de asignaturas a matricular
(defrule a_Pregunta_lista_asig
  (declare (salience 2))
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Escribe los codigos de las asignaturas posibles (separados por espacios): ")
  (assert
    (RA ListaAsig (explode$ (readline))))
)

; Segunda pregunta obligatoria: numero de creditos a matricular
(defrule a_Pregunta_cred
  (declare (salience 2))
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Escribe los creditos totales a matricular: ")
  (assert
    (RA Creditos (read)))
)

; Tercera pregunta obligatoria: curso actual del estudiante
(defrule a_Pregunta_curso
  (declare (salience 2))
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "En que curso estas?: ")
  (assert
    (RA Curso (read)))
)

(defrule a_Mensaje_bienvenida
  (declare (salience 1))
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (printout t "Bienvenido al sistema de ayuda de eleccion de asignaturas. Te hare una serie " crlf
    "de preguntas y te recomendare unas asignaturas como lo haria un estudiante. A las " crlf "preguntas categoricas puedes contestar Bajo/a (B), Medio/a (M), Alto/a (A) o No se (NS)." crlf "Si a cualquier pregunta numerica contestas '-1' o a cualquier pregunta categorica" crlf "contestas 'X', el sistema parara de hacer preguntas. Ademas, en las preguntas numericas" crlf "si contestas -2, es equivalente a contestar 'no se'." crlf)
)

; Razonamiento por defecto: valores de las variables por defecto
(defrule a_Respuestas_por_defecto
  (declare (salience 1))
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  (variable ?cosa $?defecto)
  (not (RA dato ?cosa $?))
  =>
  (assert (RA dato ?cosa por_defecto $?defecto))
)

;;; Si contesta '-1' a una pregunta numerica o 'X' a una categorica, paramos

(defrule a_Parar_num
  (declare (salience 1))
  ?f <- (RA dato_num ? ?num & :(= ?num -1))
  =>
  (retract ?f)
  (assert (RA Parar_preguntas))
)

(defrule a_Parar_cat
  (declare (salience 1))
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?f <- (Parar)
  =>
  (retract ?f)
  (assert (RA Parar_preguntas))
)

;;; Realizamos todas las preguntas. Las respuestas numericas las representamos
;;; como (RA dato_num ?factor ?valor), y las categoricas directamente con
;;; (RA dato ?factor ?valor). Si se da una respuesta, se retractan los valores por defecto

(defrule a_Pregunta_1
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  (not (RA Parar_preguntas))
  =>
  (printout t "Cual es tu nota media? (5-10): ")
  (bind ?x (read))
  (if (>= ?x -1) then
    (assert (RA dato_num nota ?x)))
)

(defrule a_Pregunta_2
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  (not (RA Parar_preguntas))
  =>
  (printout t "Cuantas horas al dia aparte de las clases le sueles dedicar a la carrera? (0-24): ")
  (bind ?x (read))
  (if (>= ?x -1) then
    (assert (RA dato_num horas ?x)))
)

; Dejar en blanco es equivalente a responder NS
(defrule a_Pregunta_3
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  (not (RA Parar_preguntas))
  ?f <- (RA dato areas por_defecto $?)
  =>
  (printout t "Cual(es) de estas areas de la informatica te gusta(n) mas? " crlf)
  ; Buscamos los hechos 'equivalencia_area', usando el campo 'implied'
  ; porque son ordered facts
  (do-for-all-facts ((?f equivalencia_area)) TRUE
    (printout t "  - " (nth$ 2 ?f:implied) " (" (nth$ 1 ?f:implied) ")" crlf))
  (printout t "Respuesta (separadas por espacios): ")
  ; Leemos la respuesta como multifield
  (bind ?resp (explode$ (readline)))
  (if (eq (nth$ 1 ?resp) X) then
    (assert (Parar))
  else
    ; Si no es vacio ni 'NS', guardamos la respuesta
    (if (and (neq (nth$ 1 ?resp) NS) (neq (nth$ 1 ?resp) nil)) then
      (retract ?f)
      (assert (RA dato areas segura ?resp))))
)

(defrule a_Pregunta_4
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  (not (RA Parar_preguntas))
  ?f <- (RA dato capacidad por_defecto ?)
  =>
  (printout t "Como calificarias tu capacidad de trabajo? (B/M/A/NS): ")
  (bind ?x (read))
  (if (eq ?x X) then
    (assert (Parar))
  else
    (if (neq ?x NS) then
      (retract ?f)
      (assert (RA dato capacidad segura ?x))))
)

(defrule a_Pregunta_5
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  (not (RA Parar_preguntas))
  ?f <- (RA dato programacion por_defecto ?)
  =>
  (printout t "Como calificarias tu gusto por la programacion? (B/M/A/NS): ")
  (bind ?x (read))
  (if (eq ?x X) then
    (assert (Parar))
  else
    (if (neq ?x NS) then
      (retract ?f)
      (assert (RA dato programacion segura ?x))))
)

(defrule a_Pregunta_6
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  (not (RA Parar_preguntas))
  ?f <- (RA dato practicas por_defecto ?)
  =>
  (printout t "Como calificarias tu preferencia por las aplicaciones practicas frente a las teoricas? (B/M/A/NS): ")
  (bind ?x (read))
  (if (eq ?x X) then
    (assert (Parar))
  else
    (if (neq ?x NS) then
      (retract ?f)
      (assert (RA dato practicas segura ?x))))
)

;;; Transformamos variables numericas a categoricas para los datos seguros
;;; Seguimos los umbrales establecidos en los hechos 'equivalencia_cat'

(defrule a_Evalua_bajo
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?f <- (RA dato_num ?cosa ?n)
  ?g <- (RA dato ?cosa por_defecto ?)
  (equivalencia_cat ?cosa u1 ?x)
  (test (< ?n ?x))
  =>
  (retract ?f ?g)
  (assert (RA dato ?cosa segura B))
)

(defrule a_Evalua_medio
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?f <- (RA dato_num ?cosa ?n)
  ?g <- (RA dato ?cosa por_defecto ?)
  (equivalencia_cat ?cosa u1 ?x1)
  (equivalencia_cat ?cosa u2 ?x2)
  (test (and (>= ?n ?x1) (< ?n ?x2)))
  =>
  (retract ?f ?g)
  (assert (RA dato ?cosa segura M))
)

(defrule a_Evalua_alto
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  ?f <- (RA dato_num ?cosa ?n)
  ?g <- (RA dato ?cosa por_defecto ?)
  (equivalencia_cat ?cosa u2 ?x)
  (test (>= ?n ?x))
  =>
  (retract ?f ?g)
  (assert (RA dato ?cosa segura A))
)

; Mostramos los valores que estamos finalmente asumiendo por defecto (si hay alguno)
(defrule a_Mensaje_por_defecto
  (declare (salience -1))
  (modulo PREGUNTAR_RECOMENDAR_ASIG)
  (RA dato ?cosa por_defecto $?valores)
  (not (RA Mensaje_mostrado ?cosa))
  =>
  (assert (RA Mensaje_mostrado ?cosa))
  (printout t "!! Estoy asumiendo por defecto que el valor de '" ?cosa "' es: ")
  (foreach ?v $?valores
    (printout t ?v " "))
  (printout t crlf)
)

; Avanzamos al siguiente modulo
(defrule a_Avanzar_razonador
  (declare (salience -2))
  ?f <- (modulo PREGUNTAR_RECOMENDAR_ASIG)
  =>
  (retract ?f)
  (assert (modulo RAZONAR_RECOMENDAR_ASIG))
)


;;;;;;
;;;;;; MODULO PARA EL RAZONADOR
;;;;;;

; Inicializamos informacion necesaria para el razonador
(defrule a_Inicializar
  (declare (salience 2))
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (RA ListaAsig $?lasig)
  (RA Curso ?curso)
  =>
  (assert
    (RA CreditosRecomendados 0)
    (RA AsigRecomendadas)
    (RA RecomendarCurso menor_igual)) ; por defecto
  ; Buscamos las asignaturas que estan en la lista
  (do-for-all-facts ((?f asignatura))
    (neq (member$ ?f:id $?lasig) FALSE)
      ; Le damos prioridad a la de cursos menores o iguales
      (if (> ?f:curso ?curso) then
        (assert
          (RA Puntos ?f:id -1000)
          (RA motivos-pos ?f:id "Javier Saez" "")
          (RA motivos-neg ?f:id "Javier Saez" (format nil "  + Esta asignatura es de un curso superior, y por defecto no te la recomiendo primero%n")))
      else
        (assert
          (RA Puntos ?f:id 0)
          (RA motivos-pos ?f:id "Javier Saez" (format nil "  + Por defecto te recomiendo primero asignaturas de tu curso o menor%n"))
          (RA motivos-neg ?f:id "Javier Saez" ""))))
)

; Si finalmente se elimina la restriccion de los cursos, retractamos la informacion
(defrule a_Retractar_curso_por_defecto
  (declare (salience 1))
  (modulo RAZONAR_RECOMENDAR_ASIG)
  ?f <- (RA RecomendarCurso menor_igual)
  (or
    (RA dato nota segura A)
    (RA dato capacidad segura A))
  =>
  (retract ?f)
  (assert (RA RecomendarCurso cualquiera))
  (printout t crlf "!! Como tienes una nota alta o una gran capacidad de trabajo, voy a" crlf
              "eliminar la restriccion por defecto de no recomendar asignaturas de" crlf
              "cursos superiores" crlf)
)

; Retractamos los motivos por defecto sobre los cursos
(defrule a_Retractar_curso_por_defecto_motivos
  (declare (salience 1))
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (RA RecomendarCurso cualquiera)
  ?f <- (RA ?mot & motivos-pos|motivos-neg ?id  ?experto ?expl & :(neq ?expl ""))
  =>
  (retract ?f)
  (assert (RA ?mot ?id ?experto ""))
)

; Retractamos los puntos penalizando a los cursos superiores
(defrule a_Retractar_curso_por_defecto_puntos
  (declare (salience 1))
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (RA RecomendarCurso cualquiera)
  ?f <- (RA Puntos ?id -1000)
  (not (RA Retractado_puntos ?id))
  =>
  (retract ?f)
  (assert
    (RA Retractado_puntos ?id)
    (RA Puntos ?id 0))
)

; Funcion auxiliar que añade un hecho con una explicacion
(deffunction add-explicacion (?sentido ?id ?expl ?defecto)
  (if (= (str-compare ?sentido "positiva") 0) then
    (assert (RA explicacion-positiva ?id ?expl ?defecto))
  else
    (assert (RA explicacion-negativa ?id ?expl ?defecto)))
)

; FASE 1 del razonador: procesar antecedentes de todas las reglas
(defrule a_Procesar_antecedentes
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (regla ?num antecedentes $?ant)
  =>
  (assert
    ; La regla es segura salvo que se demuestre lo contrario
    (RA seguridad ?num segura)
    (RA Procesar_consecuentes ?num))
  (bind ?i 1)

  ; Vamos cogiendo las parejas caracteristica-valor y asertando un hecho para procesarlas
  (while TRUE do
    (if (> ?i (length $?ant)) then
      (break))
    (assert (RA check-antecedente ?num (nth$ ?i $?ant) (nth$ (+ ?i 1) $?ant)))
    (bind ?i (+ ?i 2)))
)

; Comprobamos si se cumplen o no los antecedentes
(defrule a_Check-antecedentes
  (modulo RAZONAR_RECOMENDAR_ASIG)
  ?f <- (RA check-antecedente ?num ?caract ?valor)
  ?g <- (RA seguridad ?num ?seg)
  (RA dato ?caract ?defecto ?v)
  =>
  (if (eq ?v ?valor) then
    ; Retractar el hecho (RA check-antecedente) equivale a especificar que se cumple el antecedente
    (retract ?f)
    ; Si habia informacion por defecto, la regla completa es por_defecto
    (if (and (eq ?defecto por_defecto) (neq ?seg ?defecto)) then
      (retract ?g)
      (assert (RA seguridad ?num por_defecto))))
)

; Procesamos los consecuentes de aquellas reglas cuyos antecedentes se cumplan
(defrule a_Procesar_consecuentes
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (RA ListaAsig $?lasig)
  (regla ?num consecuentes ?signo ?caract $?valores)
  (regla ?num explicacion ?expl)
  (RA seguridad ?num ?defecto)
  ?f <- (RA Procesar_consecuentes ?num)
  (not (RA check-antecedente ?num $?))
  =>
  (retract ?f)
  ; Para cada posible valor del consecuente
  (foreach ?valor $?valores
    ; Buscamos las asignaturas de la lista con el valor especificado
    (bind ?facts
      (find-all-facts ((?f asignatura))
        (and (neq (member$ ?f:id $?lasig) FALSE) (eq ?f:?caract ?valor))))

    ; Para cada caracteristica encontrada
    (loop-for-count (?i 1 (length$ ?facts))
      (bind ?id (fact-slot-value (nth$ ?i ?facts) id))
      ; Contabilizamos la regla como aplicada
      (assert (contar ?id ?signo por_regla ?num))
      (if (= ?signo 1) then
        (add-explicacion positiva ?id ?expl ?defecto)
      else
        (add-explicacion negativa ?id ?expl ?defecto))))
)

; Contabilizamos las reglas relacionadas con las areas de conocimiento
(defrule a_Contar_puntos_area
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (RA dato areas ?defecto $?la)
  (RA ListaAsig $?lasig)
  =>
  ; Para cada elemento de la lista de areas proporcionada
  (loop-for-count (?i 1 (length$ $?la))
    (bind ?a (nth$ ?i $?la))
    ; Para cada asignatura de la lista con ese elemento en sus areas relacionadas
    (do-for-all-facts ((?f asignatura))
      (and (neq (member$ ?f:id $?lasig) FALSE) (neq (member$ ?a ?f:areas) FALSE))
        ; Buscamos el nombre completo del area en cuestion
        (do-for-all-facts ((?g equivalencia_area)) (eq ?a (nth$ 1 ?g:implied))
            (bind ?a_equiv (nth$ 2 ?g:implied))
            ; Añadimos la explicacion pertinente y contabilizamos con 2 puntos
            (add-explicacion positiva ?f:id (str-cat "Es afin al area de conocimiento " ?a_equiv ", asi que creo que te gustaran los contenidos" ) ?defecto)
            (assert (contar ?f:id 2 por_area (nth ?i $?la))))))
)

; Contabilizamos los puntos por satisfacer las reglas para cada asignatura
(defrule a_Contar_puntos
  (modulo RAZONAR_RECOMENDAR_ASIG)
  ?f <- (contar ?id ?s $?)
  ?g <- (RA Puntos ?id ?n)
  =>
  (retract ?f ?g)
  (assert (RA Puntos ?id (+ ?n ?s)))
)

; Priorizamos las asignaturas favoritas (si hay alguna en la lista)
(defrule a_Puntos_asignatura_favorita
  (modulo RAZONAR_RECOMENDAR_ASIG)
  (Asignatura_fav ?id)
  (Explicacion_fav ?id ?expl)
  ?f <- (RA Puntos ?id ?n)
  (not (RA Contada_fav ?id))
  =>
  (retract ?f)
  (assert
    (RA Puntos ?id (+ ?n 1000))
    (RA Contada_fav ?id))
  (add-explicacion positiva ?id ?expl seguro)
)

; Finalmente, elegimos las asignaturas que mas arriba en el ranking han quedado,
; hasta completar el numero de creditos pedido o quedarse lo mas cerca posible
(defrule a_Max_puntos
  (declare (salience -1))
  (modulo RAZONAR_RECOMENDAR_ASIG)
  ?f <- (RA Puntos ?id ?n)
  ?g <- (RA CreditosRecomendados ?c)
  ?h <- (RA AsigRecomendadas $?actual)
  (RA Creditos ?c_tot)
  (not
    (and
      (RA Puntos ?otro_id ?m)
      (test (> ?m ?n))))
  =>
  (retract ?f)
  ; Buscamos la asignatura con el id especificado como el maximo
  (bind ?asig (fact-index (nth$ 1 (find-fact ((?a asignatura)) (eq ?a:id ?id)))))
  (bind ?asig_id (fact-slot-value ?asig id))
  (bind ?asig_cred (fact-slot-value ?asig creditos))
  (bind ?new_c (+ ?c ?asig_cred))
  (if (<= ?new_c ?c_tot) then
    (retract ?g ?h)
    (assert
      (RA CreditosRecomendados ?new_c)
      (RA AsigRecomendadas $?actual ?asig_id)))
)

; Avanzamos al modulo recomendador
(defrule a_Avanzar_recomendador
  (declare (salience -2))
  ?f <- (modulo RAZONAR_RECOMENDAR_ASIG)
  =>
  (retract ?f)
  (assert (modulo ACONSEJAR_RECOMENDAR_ASIG))
)


;;;;;;
;;;;;; MODULO PARA LAS RECOMENDACIONES
;;;;;;

; Concatenamos todos los motivos positivos de las asignaturas
(defrule a_Juntar_motivos_positivos
  (declare (salience 1))
  (modulo ACONSEJAR_RECOMENDAR_ASIG)
  ?f <- (RA explicacion-positiva ?id ?expl ?defecto)
  ?g <- (RA motivos-pos ?id ?experto ?mot)
  =>
  (retract ?f ?g)
  (bind ?s *)
  (if (eq ?defecto por_defecto) then
    (bind ?s +))
  (assert (RA motivos-pos ?id ?experto (format nil (str-cat ?mot "  " ?s " " ?expl "%n"))))
)

; Concatenamos todos los motivos negativos de las asignaturas
(defrule a_Juntar_motivos_negativos
  (declare (salience 1))
  (modulo ACONSEJAR_RECOMENDAR_ASIG)
  ?f <- (RA explicacion-negativa ?id ?expl ?defecto)
  ?g <- (RA motivos-neg ?id ?experto ?mot)
  =>
  (retract ?f ?g)
  (bind ?s *)
  (if (eq ?defecto por_defecto) then
    (bind ?s +))
  (assert (RA motivos-neg ?id ?experto (format nil (str-cat ?mot "  " ?s " " ?expl "%n"))))
)

; Imprimimos las recomendaciones del sistema
(defrule a_Recomendar
  (modulo ACONSEJAR_RECOMENDAR_ASIG)
  (RA Creditos ?c_orig)
  (RA CreditosRecomendados ?c)
  (RA AsigRecomendadas $?lasig)
  =>
  (printout t crlf "Numero de creditos que te recomiendo matricular: " ?c crlf)
  (if (> ?c_orig ?c) then
    (printout t "(No te puedo recomendar los " ?c_orig " creditos que querias con la lista " crlf
                "de asignaturas que me has dado, bien porque no tengo informacion sobre suficientes asignaturas" crlf "o bien porque no hay suficientes para cubrir los creditos)" crlf))
  ; Si hay alguna recomendacion
  (if (> (length$ $?lasig) 0) then
    (printout t "Aqui esta la lista de asignaturas que te recomiendo, ordenada de forma que " crlf
                "conforme mas arriba este, mas fuerte es la recomendacion. Se indica con el simbolo '+' cuando el motivo" crlf "contenga informacion asumida por defecto." crlf)
    ; Para cada recomendacion
    (loop-for-count (?i 1 (length$ $?lasig))
      ; Buscamos la asignatura con el id correspondiente
      (bind ?asig
        (fact-index (nth$ 1 (find-fact ((?a asignatura)) (eq ?a:id (nth$ ?i $?lasig))))))
      ; Buscamos el motivo correspondiente
      (bind ?motivo (fact-index (nth$ 1
        (find-fact ((?g RA)) (and (eq (nth$ 1 ?g:implied) motivos-pos) (eq (nth$ 2 ?g:implied) (fact-slot-value ?asig id)))))))
      ; Imprimimos la informacion
      (bind ?experto (nth$ 3 (fact-slot-value ?motivo implied)))
      (bind ?texto_mot (nth$ 4 (fact-slot-value ?motivo implied)))
      (printout t crlf "Recomendacion: " (fact-slot-value ?asig nombre) crlf "---------------------------------------"
       crlf "Experto: " ?experto crlf "Curso: " (fact-slot-value ?asig curso) crlf "Motivos: " crlf)
      ; Si el motivo es vacio es que se ha elegido para completar los creditos
      (if (<> (str-compare ?texto_mot "") 0) then
        (printout t ?texto_mot)
      else
        (printout t "  * No hay motivos mas alla de que faltaban creditos por rellenar" crlf))))
)

; Preguntamos al usuario si quiere ver los motivos negativos
(defrule a_Pregunta_mostrar_motivos_neg
  (declare (salience -1))
  (modulo ACONSEJAR_RECOMENDAR_ASIG)
  =>
  (printout t crlf "Quieres ver los principales motivos por los que el resto de asignaturas" crlf
              "no han sido recomendadas? (S/N): ")
  (if (eq (read) S) then
    (assert (Mostrar_neg)))
  (printout t crlf)
)

; Imprimimos las asignaturas descartadas y los motivos negativos
(defrule a_Mostrar_motivos_neg
  (modulo ACONSEJAR_RECOMENDAR_ASIG)
  ?f <- (Mostrar_neg)
  (RA AsigRecomendadas $?lrec)
  (RA ListaAsig $?lasig)
  (test (> (length$ $lrec) 0))
  =>
  (bind ?vacio S)
  ; Para cada id de asignatura de la lista inicial
  (loop-for-count (?i 1 (length$ $?lasig))
    ; Obtenemos la direccion de la asignatura correspondiente
    (bind ?asig_addr (nth$ 1 (find-fact ((?a asignatura)) (eq ?a:id (nth$ ?i $?lasig)))))
    (if (neq ?asig_addr nil) then
      (bind ?asig (fact-index ?asig_addr))
      ; Si no se encuentra en la lista de recomendadas, obtenemos los motivos negativos
      (if (eq (member$ (fact-slot-value ?asig id) $?lrec) FALSE) then
        (bind ?motivo (fact-index (nth$ 1
          (find-fact ((?g RA)) (and (eq (nth$ 1 ?g:implied) motivos-neg) (eq (nth$ 2 ?g:implied) (fact-slot-value ?asig id)))))))

        ; Mostramos la informacion
        (bind ?experto (nth$ 3 (fact-slot-value ?motivo implied)))
        (bind ?texto_mot (nth$ 4 (fact-slot-value ?motivo implied)))
        (if (<> (str-compare ?texto_mot "") 0) then
          (bind ?vacio N)
          (printout t (fact-slot-value ?asig nombre) crlf "---------------------------------------"
          crlf "Experto: " ?experto crlf "Curso: " (fact-slot-value ?asig curso) crlf "Motivos de rechazo: " crlf ?texto_mot crlf)))))

  (if (eq ?vacio N) then
    (retract ?f))
)

; Si no habia motivos negativos, lo decimos
(defrule a_No_neg
  (declare (salience -1))
  ?f <- (Mostrar_neg)
  =>
  (retract ?f)
  (printout t "No hay motivos negativos. Simplemente las que te he recomendado tienen "
              "mas motivos positivos." crlf crlf)
)

; Finalizamos el recomendador y volvemos al submenu del subsistema
(defrule a_Volver_menu_recomendar
  (declare (salience -2))
  ?f <- (modulo ACONSEJAR_RECOMENDAR_ASIG)
  =>
  (retract ?f)
  (assert
    (modulo MENU_RECOMENDAR_ASIG)
    (Preguntar))
)
