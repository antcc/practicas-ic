;;;;;;;;;;;;;;;; RECOMENDACION DE UNA RAMA (REGLAS) ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Reglas y sistema de razonamiento para el problema de recomendar
;;; una rama de Ingenieria Informatica como lo haria un estudiante.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ingenieria del Conocimiento. Curso 2019/20.
;;; Antonio Coin Castro.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;
;;;;;; MODULO PARA LAS PREGUNTAS
;;;;;;

;;;;;; GESTION DE ABREVIATURAS

;;; Diferenciamos las abreviaturas para el resto de variables numericas,
;;; segun tengan que ser en masculino o en femenino.

(defrule r_Abreviado_resto_num_masc
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(Evaluacion ?cosa & mat|prog ?)
=>
(assert
  (Abreviado ?cosa bajo "bajo")
  (Abreviado ?cosa medio "medio")
  (Abreviado ?cosa alto "alto"))
)

(defrule r_Abreviado_resto_num_fem
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(Evaluacion ?cosa & nota ?)
=>
(assert
  (Abreviado ?cosa bajo "baja")
  (Abreviado ?cosa medio "media")
  (Abreviado ?cosa alto "alta"))
)

;;; Las abreviaturas del resto de variables categoricas solo pueden
;;; tomar dos valores, con genero neutral.

(defrule r_Abreviado_resto_cat
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(Evaluacion ?cosa & hw|trabajador|web|bbdd ?)
=>
(assert
  (Abreviado ?cosa S "si")
  (Abreviado ?cosa N "no"))
)

;;;;;; MENSAJES INICIALES

;;; Mensaje de bienvenida

(defrule r_Mensaje_bienvenida
(declare (salience 2))
(modulo PREGUNTAR_RECOMENDAR_RAMA)
=>
(printout t "Bienvenido al sistema de ayuda de eleccion de rama. Te hare una serie " crlf
  "de preguntas y te recomendare una(s) rama(s) como lo haria un estudiante. Si a cualquier " crlf
  "pregunta numerica contestas '-1' o a cualquier pregunta categorica contestas 'X', el " crlf
  "sistema parara de hacer preguntas. Ademas, en las preguntas numericas si contestas " crlf
  "un numero mayor que 10, es equivalente a contestar 'no se'." crlf)
)

;;; Preguntamos el modo en el que quiere trabajar el usuario. Podriamos decir que
;;; le permitimos controlar la "verbosidad" de las recomendaciones.

(defrule r_Modo_verbose
(declare (salience 1))
(modulo PREGUNTAR_RECOMENDAR_RAMA)
=>
(printout t crlf "Quieres que en la exposicion de motivos salgan absolutamente todos los " crlf
  "factores que han influido? (si respondes que no, solo saldran los mas relevantes) (S/N): ")
(assert (Modo_completo (read)))
(printout t crlf)
)


;;;;;; PREGUNTAS

;;; Si contesta '-1' a una pregunta numerica o 'X' a una categorica, paramos
;;; y pasamos al siguiente modulo.

(defrule r_Parar_num
(declare (salience 1))
(modulo PREGUNTAR_RECOMENDAR_RAMA)
?f <- (Respuesta_num ? ?num & :(< ?num 0))
=>
(retract ?f)
(assert (Parar))
)

(defrule r_Parar_cat
(declare (salience 1))
(modulo PREGUNTAR_RECOMENDAR_RAMA)
?f <- (Evaluacion ?cosa X)
=>
(retract ?f)
(assert (Parar) (Evaluacion ?cosa desconocido))
)

;;; Realizamos todas las preguntas. Las respuestas numericas las representamos
;;; como (Respuesta_num ?factor ?valor), y las categoricas directamente
;;; con (Evaluacion ?fator ?valor).

(defrule r_Pregunta_1
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(not (Parar))
=>
(printout t "Cual es tu grado de afinidad con las matematicas? (0-10): ")
(assert (Respuesta_num mat (read)))
)

(defrule r_Pregunta_2
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(not (Parar))
?f <- (Evaluacion hw desconocido)
=>
(printout t "Te gusta el hardware? (S/N/NS): ")
(retract ?f)
(assert (Evaluacion hw (read)))
)

(defrule r_Pregunta_3
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(not (Parar))
=>
(printout t "Cual es tu grado de afinidad con la programacion? (0-10): ")
(assert (Respuesta_num prog (read)))
)

(defrule r_Pregunta_4
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(not (Parar))
=>
(printout t "Cual es tu nota media? (5-10): ")
; Reescalamos la nota a [4-10] para que un 5 sea "baja".
; La formula es (6/5) * x - 2
(bind ?nota (read))
(bind ?temp (* ?nota 1.2))
(bind ?nota_escalada (- ?temp 2))
(assert (Respuesta_num nota ?nota_escalada))
)

(defrule r_Pregunta_5
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(not (Parar))
?f <- (Evaluacion trabajador desconocido)
=>
(printout t "Eres trabajador? (S/N/NS): ")
(retract ?f)
(assert (Evaluacion trabajador (read)))
)

(defrule r_Pregunta_6
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(not (Parar))
?f <- (Evaluacion futuro desconocido)
=>
(printout t "Te gustaria trabajar en (D)ocencia, en la administracion "
  "(P)ublica o en una (E)mpresa privada? (D/P/E/NS): ")
(retract ?f)
(assert (Evaluacion futuro (read)))
)

(defrule r_Pregunta_7
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(not (Parar))
?f <- (Evaluacion web desconocido)
=>
(printout t "Te gustan las tecnologias web? (S/N/NS): ")
(retract ?f)
(assert (Evaluacion web (read)))
)

(defrule r_Pregunta_8
(modulo PREGUNTAR_RECOMENDAR_RAMA)
(not (Parar))
?f <- (Evaluacion bbdd desconocido)
=>
(printout t "Te interesa el funcionamiento de las bases de datos? (S/N/NS): ")
(retract ?f)
(assert (Evaluacion bbdd (read)))
)

(defrule r_Avanzar_modulo_puntuacion
(declare (salience -1))
?f <- (modulo PREGUNTAR_RECOMENDAR_RAMA)
=>
(retract ?f)
(assert (modulo PUNTUAR_RECOMENDAR_RAMA))
)


;;;;;;
;;;;;; MODULO PARA LA PUNTUACION
;;;;;;

;;;;;; TRANSFORMAR VARIABLES CATEGÓRICAS A NUMÉRICAS

;;; Las variables del factor 'futuro' tienen tres posibles
;;; interpretaciones. Le damos 10 puntos a la correspondiente
;;; respuesta y 0 al resto en cada caso.

(defrule r_Transforma_futuro_docencia
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Evaluacion futuro D)
=>
(assert
  (Respuesta_num docencia 10)
  (Respuesta_num publica 0)
  (Respuesta_num empresa 0))
)

(defrule r_Transforma_futuro_publica
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Evaluacion futuro P)
=>
(assert
  (Respuesta_num docencia 0)
  (Respuesta_num publica 10)
  (Respuesta_num empresa 0))
)

(defrule r_Transforma_futuro_empresa
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Evaluacion futuro E)
=>
(assert
  (Respuesta_num docencia 0)
  (Respuesta_num publica 0)
  (Respuesta_num empresa 10))
)

;;; El resto de variables solo pueden ser Si (10 puntos) o No (0 puntos).
;;; Si la respuesta es No se, no la contamos (no suma puntos).

(defrule r_Transforma_S
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Evaluacion ?cosa S)
=>
(assert (Respuesta_num ?cosa 10))
)

(defrule r_Transforma_N
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Evaluacion ?cosa N)
=>
(assert (Respuesta_num ?cosa 0))
)


;;;;;; TRANSFORMAR VARIABLES NUMÉRICAS A CATEGÓRICAS

;;; Las variables numericas se asocian a un nivel de evaluacion
;;; para posteriormente exponerlos como motivos. La conversion es
;;; [0, 5) --> bajo; [5, 8) --> medio; [8, 10] --> alto.

(defrule r_Evalua_bajo
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Respuesta_num ?cosa ?n)
?f <- (Evaluacion ?cosa desconocido)
(test (< ?n 5))
=>
(retract ?f)
(assert (Evaluacion ?cosa bajo))
)

(defrule r_Evalua_medio
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Respuesta_num ?cosa ?n)
?f <- (Evaluacion ?cosa desconocido)
(test (and (>= ?n 5) (< ?n 8)))
=>
(retract ?f)
(assert (Evaluacion ?cosa medio))
)

(defrule r_Evalua_alto
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Respuesta_num ?cosa ?n)
?f <- (Evaluacion ?cosa desconocido)
(test (and (>= ?n 8) (<= ?n 10)))
=>
(retract ?f)
(assert (Evaluacion ?cosa alto))
)


;;;;;; COMPUTAR PUNTUACIÓN DE LAS RAMAS

;;; Se suma la puntuacion de cada rama segun la contribucion (directa o inversa)
;;; de cada factor. El caso del factor 'futuro' se trata por separado.
;;; Si el valor numerico de la respuesta es menor que 5, se considera
;;; baja y contribuye de forma inversa. En otro caso contribuye de forma directa.

(defrule r_Sumar_puntos_futuro_directo
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Respuesta_num ?cosa & docencia|publica|empresa ?n)
(Contribuye ?cosa ?rama ?factor)
?f <- (Puntuacion ?rama ?m)
(not (Sumado ?cosa ?rama))
(test
  (and (>= ?n 5) (<= ?n 10)))
=>
(retract ?f)
(bind ?puntos (* ?factor ?n))
(assert
  (Puntuacion ?rama (+ ?m ?puntos))
  (Sumado ?cosa ?rama)
  (Agregar_motivo futuro ?rama ?puntos))
)

(defrule r_Sumar_puntos_futuro_inverso
(declare (salience 1))
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Respuesta_num ?cosa & docencia|publica|empresa ?n & :(< ?n 5))
(Contribuye_inv ?cosa ?rama ?factor)
?f <- (Puntuacion ?rama ?m)
(not (Sumado ?cosa ?rama))
=>
(retract ?f)
(bind ?puntos_inv (- 5 ?n))
(bind ?puntos (* ?factor ?puntos_inv))
(assert
  (Puntuacion ?rama (+ ?m ?puntos))
  (Sumado ?cosa ?rama)
  (Agregar_motivo futuro ?rama ?puntos))
)

(defrule r_Sumar_puntos_resto_directo
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Respuesta_num ?cosa ?n)
(Contribuye ?cosa ?rama ?factor)
?f <- (Puntuacion ?rama ?m)
(not (Sumado ?cosa ?rama))
(test
  (and (>= ?n 5) (<= ?n 10)))
=>
(retract ?f)
(bind ?puntos (* ?factor ?n))
(assert
  (Puntuacion ?rama (+ ?m ?puntos))
  (Sumado ?cosa ?rama)
  (Agregar_motivo ?cosa ?rama ?puntos))
)

(defrule r_Sumar_puntos_resto_inverso
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Respuesta_num ?cosa ?n & :(< ?n 5))
(Contribuye_inv ?cosa ?rama ?factor)
?f <- (Puntuacion ?rama ?m)
(not (Sumado ?cosa ?rama))
=>
(retract ?f)
(bind ?puntos_inv (- 5 ?n))
(bind ?puntos (* ?factor ?puntos_inv))
(assert
  (Puntuacion ?rama (+ ?m ?puntos))
  (Sumado ?cosa ?rama)
  (Agregar_motivo ?cosa ?rama ?puntos))
)

;;;;;; AGREGAR LOS MOTIVOS

;;; Cada vez que sumamos puntos a una rama, guardamos el factor
;;; que ha contribuido para explicar posteriormente los motivos.
;;; Los clasificamos por importancia segun cuanto hayan contribuido.

; Solo agregamos los motivos poco importantes en el modo completo
(defrule r_Agregar_motivo_poco_importante
(modulo PUNTUAR_RECOMENDAR_RAMA)
(Modo_completo S)
?f <- (Agregar_motivo ?cosa ?rama ?puntos)
(Evaluacion ?cosa ?eval_abreviado)
(Equivalencia_texto ?cosa ?texto)
(test (< ?puntos 5))
?g <- (Motivo ?rama ?motivo_antiguo)
(Abreviado ?cosa ?eval_abreviado ?eval)
(not (Agregado ?cosa ?rama)) ; Para que 'futuro' solo se agregue una vez
=>
(retract ?f ?g)
(assert
  (Agregado ?cosa ?rama)
  (Motivo ?rama (format nil (str-cat ?motivo_antiguo "  * " ?texto ?eval "%n"))))
)

(defrule r_Agregar_motivo_neutral
(modulo PUNTUAR_RECOMENDAR_RAMA)
?f <- (Agregar_motivo ?cosa ?rama ?puntos)
(Evaluacion ?cosa ?eval_abreviado)
(Equivalencia_texto ?cosa ?texto)
(test (and (>= ?puntos 5) (< ?puntos 8)))
?g <- (Motivo ?rama ?motivo_antiguo)
(Abreviado ?cosa ?eval_abreviado ?eval)
(not (Agregado ?cosa ?rama)) ; Para que 'futuro' solo se agregue una vez
=>
(retract ?f ?g)
(assert
  (Agregado ?cosa ?rama)
  (Motivo ?rama (format nil (str-cat ?motivo_antiguo "  ** " ?texto ?eval "%n"))))
)

(defrule r_Agregar_motivo_importante
(modulo PUNTUAR_RECOMENDAR_RAMA)
?f <- (Agregar_motivo ?cosa ?rama ?puntos)
(Evaluacion ?cosa ?eval_abreviado)
(Equivalencia_texto ?cosa ?texto)
(test (>= ?puntos 8))
?g <- (Motivo ?rama ?motivo_antiguo)
(Abreviado ?cosa ?eval_abreviado ?eval)
(not (Agregado ?cosa ?rama)) ; Para que 'futuro' solo se agregue una vez
=>
(retract ?f ?g)
(assert
  (Agregado ?cosa ?rama)
  (Motivo ?rama (format nil (str-cat ?motivo_antiguo "  *** " ?texto ?eval "%n"))))
)

(defrule r_Avanzar_modulo_aconsejar
(declare (salience -1))
?f <- (modulo PUNTUAR_RECOMENDAR_RAMA)
=>
(retract ?f)
(assert (modulo ACONSEJAR_RECOMENDAR_RAMA))
)


;;;;;;
;;;;;; MODULO PARA ACONSEJAR
;;;;;;

;;;;;; CALCULAR RAMA ELEGIDA

;;; Elegimos para recomendar la rama (o ramas) con la mayor puntuacion.

(defrule r_Max_puntuacion
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(Puntuacion ?rama ?n & :(> ?n 0))
(not
  (and
    (Puntuacion ?otra_rama ?m)
    (test (> ?m ?n))))
=>
(assert (Consejo_preliminar ?rama))
)


;;;;;; ACONSEJAR RAMAS

;;; Si el sistems ha aconsejado una rama, ponemos los motivos.
;;; Tambien recomendamos en ocasiones ramas de forma "manual" siguiendo el
;;; conocimiento extraido del experto.

(defrule r_Aconsejar_CSI_automatico
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(Consejo_preliminar CSI)
(Motivo CSI ?motivo)
=>
(assert (Consejo CSI ?motivo "Javier Saez"))
)

(defrule r_Aconsejar_CSI_manual
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(not (Consejo_preliminar CSI))
(Evaluacion mat alto)
(Evaluacion nota alto)
(Evaluacion trabajador S)
(Evaluacion prog ?eval_prog & medio|alto)
=>
(bind ?motivo (format nil (str-cat "  *** Tu grado de interes por las matematicas es alto%n"
  "  *** Tu nota media es alta%n"
  "  *** Eres trabajador: si%n"
  "  ** Tu grado de interes por la programacion es " ?eval_prog "%n")))
(assert (Consejo CSI ?motivo "Javier Saez"))
)

(defrule r_Aconsejar_IS_automatico
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(Consejo_preliminar IS)
(Motivo IS ?motivo)
=>
(assert (Consejo IS ?motivo "Javier Saez"))
)

(defrule r_Aconsejar_IC_automatico
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(Consejo_preliminar IC)
(Motivo IC ?motivo)
=>
(assert (Consejo IC ?motivo "Javier Saez"))
)

(defrule r_Aconsejar_IC_manual
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(not (Consejo_preliminar IC))
(Evaluacion hw S)
=>
(bind ?motivo (format nil "  *** Te gusta el hardware: si%n"))
(assert (Consejo IC ?motivo "Javier Saez"))
)

(defrule r_Aconsejar_SI_automatico
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(Consejo_preliminar SI)
(Motivo SI ?motivo)
=>
(assert (Consejo SI ?motivo "Javier Saez"))
)

(defrule r_Aconsejar_TI_automatico
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(Consejo_preliminar TI)
(Motivo TI ?motivo)
=>
(assert (Consejo TI ?motivo "Javier Saez"))
)


;;;;;;; CONSEJOS FINALES

;;; Si hemos recomendado una rama pero no hay motivos de relevancia media-alta,
;;; ponemos todos los de relevancia baja.

(defrule r_Agregar_motivo_poco_importante_2
(modulo ACONSEJAR_RECOMENDAR_RAMA)
?f <- (Consejo ?rama ?motivo ?experto)
?g <- (Agregar_motivo ?cosa ?rama ?puntos)
(Evaluacion ?cosa ?eval_abreviado)
(Equivalencia_texto ?cosa ?texto)
(test (< ?puntos 5))
(Abreviado ?cosa ?eval_abreviado ?eval)
(not (Agregado ?cosa ?rama)) ; Para que 'futuro' solo se agregue una vez
(or
  (test (eq ?motivo ""))
  (Agregar_poco_importantes ?rama))
=>
(retract ?f ?g)
(bind ?motivo_nuevo (format nil (str-cat ?motivo "  * " ?texto ?eval "%n")))
(assert
  (Agregar_poco_importantes ?rama)
  (Consejo ?rama ?motivo_nuevo ?experto)
  (Agregado ?cosa ?rama))
)

;;; Mensajes de informacion para ayudar al usuario a interpretar las recomendaciones

(defrule r_Aviso_parcial
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(Parar)
=>
(printout t crlf "No has contestado a todas las preguntas, asi que la recomendacion puede no"
  " ser la mas refinada." crlf)
)

(defrule r_Interpretacion
(modulo ACONSEJAR_RECOMENDAR_RAMA)
=>
(printout t crlf "Cuantos mas asteriscos haya delante de un motivo, mas importante "
  "ha sido a la hora de hacer la recomendacion." crlf)
)

;;; Mensajes de recomendacion de rama

(defrule r_Aconsejar_rama
(declare (salience -1))
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(Consejo ?rama ?motivo ?experto)
(Nombre_rama ?rama ?nombre)
(Descripcion ?rama ?desc)
=>
(printout t crlf "Recomendacion: " ?nombre crlf "---------------------------------------------"
  crlf "Descripcion de la rama: " ?desc crlf "Experto: " ?experto crlf "Motivos: " crlf ?motivo)
)

(defrule r_No_recomendar
(declare (salience -1))
(modulo ACONSEJAR_RECOMENDAR_RAMA)
(not (Consejo ? ? ?))
=>
(printout t crlf "No tengo informacion suficiente para hacer ninguna recomendacion" crlf)
)

;;; Mensaje de pausa para volver al menu principal

(defrule r_Volver_menu_
  (declare (salience -2))
  ?f <- (modulo ACONSEJAR_RECOMENDAR_RAMA)
  =>
  (printout t crlf "Escribe cualquier cosa para volver al menu principal... ")
  (read)
  (printout t crlf)
  (retract ?f)
  (assert (Resetear))
)
