;;;;;; HECHOS ESTÁTICOS

;;; Definimos los nombres de las ramas consideradas.

(deffacts Ramas
(Rama CSI)
(Rama IS)
(Rama IC)
(Rama SI)
(Rama TI)
)

(deffacts Nombres
(Nombre_rama CSI "Computacion y Sistemas Inteligentes")
(Nombre_rama IS "Ingenieria del Software")
(Nombre_rama IC "Ingenieria de Computadores")
(Nombre_rama SI "Sistemas de Informacion")
(Nombre_rama TI "Tecnologias de la Informacion")
)

(deffacts Descripciones
(Descripcion CSI (format nil "En esta rama hay una gran exigencia tanto a nivel de matematicas
como de programacion, pero se puede sobrellevar siendo trabajador. Deberias tener una buena nota.
Es una buena forma de acabar como docente."))
(Descripcion IS (format nil "Si te gusta la programacion y no tienes ningun otro interes
particular, esta rama es una buena eleccion, aunque no vas a ver mucho sobre hardware.
No viene mal tener buena nota."))
(Descripcion IC (format nil "La rama del hardware por excelencia. Si quieres huir de las
matematicas y eres trabajador, las empresas lo valoraran bastante."))
(Descripcion SI (format nil "En esta rama se tocan temas tanto de programacion, como de
tecnologias web y de bases de datos. Un buen popurri que te permitira preparar unas oposiciones
para trabajar en la administracion."))
(Descripcion TI (format nil "En esta rama se valora el interes por tecnologias mas alla de la
programacion pura, en la que no es del todo imprescindible ser muy trabajador o tener buena nota.
No veras muchas matematicas y podras trabajar donde quieras."))
)

;;; Inicializamos la puntuacion de todas las ramas a 0.

(deffacts Inicial
(Puntuacion CSI 0)
(Puntuacion IS 0)
(Puntuacion IC 0)
(Puntuacion SI 0)
(Puntuacion TI 0)
)

;;; Inicializamos los valores de las respuestas numericas

(deffacts Por_defecto
(Evaluacion mat desconocido)
(Evaluacion hw desconocido)
(Evaluacion prog desconocido)
(Evaluacion nota desconocido)
(Evaluacion trabajador desconocido)
(Evaluacion web desconocido)
(Evaluacion futuro desconocido)
(Evaluacion bbdd desconocido)
)

(deffacts Abreviado_futuro
(Abreviado futuro D "docencia")
(Abreviado futuro P "administracion publica")
(Abreviado futuro E "empresa privada")
(Abreviado futuro desconocido "desconocido")
)

(defrule Abreviado_resto_num_masc
(declare (salience 10))
(Evaluacion ?cosa & mat|prog ?)
=>
(assert
  (Abreviado ?cosa bajo "bajo")
  (Abreviado ?cosa medio "medio")
  (Abreviado ?cosa alto "alto"))
)

(defrule Abreviado_resto_num_fem
(declare (salience 10))
(Evaluacion ?cosa & nota ?)
=>
(assert
  (Abreviado ?cosa bajo "baja")
  (Abreviado ?cosa medio "media")
  (Abreviado ?cosa alto "alta"))
)

(defrule Abreviado_resto_cat
(declare (salience 10))
(Evaluacion ?cosa & hw|trabajador|web|bbdd ?)
=>
(assert
  (Abreviado ?cosa S "si")
  (Abreviado ?cosa N "no"))
)

;;; Declaramos las cosas que contribuyen a la eleccion de una rama,
;;; y en que factor en [0.5, 1] lo hacen.

(deffacts Contribucion
; CSI
(Contribuye mat CSI 0.75)
(Contribuye prog CSI 0.75)
(Contribuye nota CSI 0.75)
(Contribuye trabajador CSI 0.75)
(Contribuye docencia CSI 0.5)
; IS
(Contribuye mat IS 0.6)
(Contribuye prog IS 1)
(Contribuye nota IS 0.75)
(Contribuye docencia IS 0.5)
(Contribuye empresa IS 0.5)
; IC
(Contribuye hw IC 1)
(Contribuye prog IC 0.5)
(Contribuye trabajador IC 0.75)
(Contribuye empresa IC 1)
; SI
(Contribuye prog SI 0.75)
(Contribuye trabajador SI 0.75)
(Contribuye web SI 0.75)
(Contribuye publica SI 1)
(Contribuye bbdd SI 1)
; TI
(Contribuye prog TI 0.5)
(Contribuye web TI 1)
(Contribuye publica TI 1)
(Contribuye empresa TI 1)
(Contribuye bbdd TI 0.5)
)

; Cuando alguna cosa sea baja, contribuir a una rama concreta en un factor en (0, 2]
(deffacts Contribucion_inversa
; CSI
(Contribuye_inv hw CSI 1)
(Contribuye_inv web CSI 1)
; IS
(Contribuye_inv hw IS 1.5)
(Contribuye_inv bbdd IS 1)
; IC
(Contribuye_inv mat IC 1.5)
(Contribuye_inv web IC 1)
(Contribuye_inv bbdd IC 1)
; SI
(Contribuye_inv mat SI 1.5)
(Contribuye_inv hw SI 1)
; TI
(Contribuye_inv mat TI 2)
(Contribuye_inv hw TI 1)
(Contribuye_inv nota TI 1)
(Contribuye_inv trabajador TI 0.75)
)

;;; Expresion en lenguaje natural de las distintas cosas que contribuyen
;;; a la eleccion de rama.

(deffacts Equivalencia
(Equivalencia_texto mat "Tu grado de interes por las matematicas es ")
(Equivalencia_texto hw "Te gusta el hardware: ")
(Equivalencia_texto prog "Tu grado de interes por la programacion es ")
(Equivalencia_texto nota "Tu nota media es ")
(Equivalencia_texto trabajador "Eres trabajador: ")
(Equivalencia_texto web "Te gustan las tecnologias web: ")
(Equivalencia_texto futuro "En el futuro quieres trabajar en: " )
(Equivalencia_texto bbdd "Te interesan las bases de datos: ")
)

;;; Motivos vacios inicialmente
(deffacts Motivos
(Motivo CSI "")
(Motivo IS "")
(Motivo IC "")
(Motivo SI "")
(Motivo TI "")
)

;;; Mensaje de bienvenida

(defrule Bienvenida
(declare (salience 11))
=>
(printout t "Bienvenido al sistema de ayuda de eleccion de rama. Te hare una serie " crlf
  "de preguntas y te recomendare una(s) rama(s) como lo haria un estudiante. Si a cualquier " crlf
  "pregunta numerica contestas '-1' o a cualquier pregunta categorica contestas 'X', el " crlf
  "sistema parara de hacer preguntas. Ademas, en las preguntas numericas si contestas " crlf
  "un numero mayor que 10, es equivalente a contestar 'no se'." crlf)
)

(defrule Modo
(declare (salience 10))
=>
(printout t crlf "Quieres que en la exposicion de motivos salgan absolutamente todos los " crlf
  "factores que han influido? (si respondes que no, solo saldran los mas relevantes) (S/N): ")
(assert (Modo_completo (read)))
)

;;;;;; PREGUNTAS

(defrule Parar_num
(declare (salience 10))
?f <- (Respuesta_num ? ?num & :(< ?num 0))
=>
(retract ?f)
(assert (Parar))
)

(defrule Parar_cat
(declare (salience 10))
?f <- (Evaluacion ?cosa X)
=>
(retract ?f)
(assert (Parar) (Evaluacion ?cosa desconocido))
)

(defrule Pregunta_1
(declare (salience 9))
(not (Parar))
=>
(printout t crlf "Cual es tu grado de afinidad con las matematicas? (0-10): ")
(assert (Respuesta_num mat (read)))
)

(defrule Pregunta_2
(declare (salience 8))
(not (Parar))
?f <- (Evaluacion hw desconocido)
=>
(printout t "Te gusta el hardware? (S/N/NS): ")
(retract ?f)
(assert (Evaluacion hw (read)))
)

(defrule Pregunta_3
(declare (salience 7))
(not (Parar))
=>
(printout t "Cual es tu grado de afinidad con la programacion? (0-10): ")
(assert (Respuesta_num prog (read)))
)

(defrule Pregunta_4
(declare (salience 6))
(not (Parar))
=>
(printout t "Cual es tu nota media? (5-10): ")
; Reescalamos la nota a [4-10] para que un 5 sea "baja"
(bind ?nota (read))
(bind ?temp (* ?nota 1.2))
(bind ?nota_escalada (- ?temp 2))
(assert (Respuesta_num nota ?nota_escalada))
)

(defrule Pregunta_5
(declare (salience 5))
(not (Parar))
?f <- (Evaluacion trabajador desconocido)
=>
(printout t "Eres trabajador? (S/N/NS): ")
(retract ?f)
(assert (Evaluacion trabajador (read)))
)

(defrule Pregunta_6
(declare (salience 4))
(not (Parar))
?f <- (Evaluacion web desconocido)
=>
(printout t "Te gustan las tecnologias web? (S/N/NS): ")
(retract ?f)
(assert (Evaluacion web (read)))
)

(defrule Pregunta_7
(declare (salience 3))
(not (Parar))
?f <- (Evaluacion futuro desconocido)
=>
(printout t "Te gustaria trabajar en (D)ocencia, en la administracion "
  "(P)ublica o en una (E)mpresa privada? (D/P/E/NS): ")
(retract ?f)
(assert (Evaluacion futuro (read)))
)

(defrule Pregunta_8
(declare (salience 2))
(not (Parar))
?f <- (Evaluacion bbdd desconocido)
=>
(printout t "Te interesa el funcionamiento de las bases de datos? (S/N/NS): ")
(retract ?f)
(assert (Evaluacion bbdd (read)))
)


;;;;;; TRANSFORMAR VARIABLES CATEGÓRICAS A NUMÉRICAS

(defrule Transforma_futuro_docencia
(declare (salience 2))
(Evaluacion futuro D)
=>
(assert
  (Respuesta_num docencia 10)
  (Respuesta_num publica 0)
  (Respuesta_num empresa 0))
)

(defrule Transforma_futuro_publica
(declare (salience 2))
(Evaluacion futuro P)
=>
(assert
  (Respuesta_num docencia 0)
  (Respuesta_num publica 10)
  (Respuesta_num empresa 0))
)

(defrule Transforma_futuro_empresa
(declare (salience 2))
(Evaluacion futuro E)
=>
(assert
  (Respuesta_num docencia 0)
  (Respuesta_num publica 0)
  (Respuesta_num empresa 10))
)

; Si la respuesta es "No se", no sumamos a nada

(defrule Transforma_resto_S
(declare (salience 2))
(Evaluacion ?cosa S)
=>
(assert (Respuesta_num ?cosa 10))
)

(defrule Transforma_resto_N
(declare (salience 2))
(Evaluacion ?cosa N)
=>
(assert (Respuesta_num ?cosa 0))
)


;;;;;; TRANSFORMAR VARIABLES NUMÉRICAS A CATEGÓRICAS

(defrule Evalua_bajo
(declare (salience 2))
(Respuesta_num ?cosa ?n)
?f <- (Evaluacion ?cosa desconocido)
(test (< ?n 5))
=>
(retract ?f)
(assert (Evaluacion ?cosa bajo))
)

(defrule Evalua_medio
(declare (salience 2))
(Respuesta_num ?cosa ?n)
?f <- (Evaluacion ?cosa desconocido)
(test (and (>= ?n 5) (< ?n 8)))
=>
(retract ?f)
(assert (Evaluacion ?cosa medio))
)

(defrule Evalua_alto
(declare (salience 2))
(Respuesta_num ?cosa ?n)
?f <- (Evaluacion ?cosa desconocido)
(test (and (>= ?n 8) (<= ?n 10)))
=>
(retract ?f)
(assert (Evaluacion ?cosa alto))
)


;;;;;; COMPUTAR PUNTUACIÓN DE LAS RAMAS

(defrule Sumar_puntos_futuro_directo
(declare (salience 1))
(Respuesta_num ?cosa & docencia|publica|empresa ?n)
(Contribuye ?cosa ?rama ?factor)
?f <- (Puntuacion ?rama ?m)
(not (Sumado ?cosa ?rama))
(test (and (>= ?n 5) (<= ?n 10)))
=>
(retract ?f)
(bind ?puntos (* ?factor ?n))
(assert (Puntuacion ?rama (+ ?m ?puntos))
  (Sumado ?cosa ?rama) (Agregar_motivo futuro ?rama ?puntos))
)

(defrule Sumar_puntos_futuro_inverso
(declare (salience 1))
(Respuesta_num ?cosa & docencia|publica|empresa ?n & :(< ?n 5))
(Contribuye_neg ?cosa ?rama ?factor)
?f <- (Puntuacion ?rama ?m)
(not (Sumado ?cosa ?rama))
=>
(retract ?f)
(bind ?puntos_inv (- 5 ?n))
(bind ?puntos (* ?factor ?puntos_inv))
(assert (Puntuacion ?rama (+ ?m ?puntos))
  (Sumado ?cosa ?rama) (Agregar_motivo futuro ?rama ?puntos))
)

(defrule Sumar_puntos_resto_directo
(declare (salience 1))
(Respuesta_num ?cosa ?n)
(Contribuye ?cosa ?rama ?factor)
?f <- (Puntuacion ?rama ?m)
(not (Sumado ?cosa ?rama))
(test (and (>= ?n 5) (<= ?n 10)))
=>
(retract ?f)
(bind ?puntos (* ?factor ?n))
(assert (Puntuacion ?rama (+ ?m ?puntos))
  (Sumado ?cosa ?rama) (Agregar_motivo ?cosa ?rama ?puntos))
)

(defrule Sumar_puntos_resto_inverso
(declare (salience 1))
(Respuesta_num ?cosa ?n & :(< ?n 5))
(Contribuye_neg ?cosa ?rama ?factor)
?f <- (Puntuacion ?rama ?m)
(not (Sumado ?cosa ?rama))
=>
(retract ?f)
(bind ?puntos_inv (- 5 ?n))
(bind ?puntos (* ?factor ?puntos_inv))
(assert (Puntuacion ?rama (+ ?m ?puntos))
  (Sumado ?cosa ?rama) (Agregar_motivo ?cosa ?rama ?puntos))
)

; Solo agregamos los motivos poco importantes en el modo completo
(defrule Agregar_motivo_poco_importante
(declare (salience 1))
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

(defrule Agregar_motivo_neutral
(declare (salience 1))
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

(defrule Agregar_motivo_importante
(declare (salience 1))
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


;;;;;; RECOMENDACIONES

(defrule Max_puntuacion
(Puntuacion ?rama ?n & :(> ?n 0))
(not (and (Puntuacion ?otra_rama ?m) (test (> ?m ?n))))
=>
(assert (Consejo_preliminar ?rama))
)

(defrule Aconsejar_CSI_automatico
(Consejo_preliminar CSI)
(Motivo CSI ?motivo)
=>
(assert (Consejo CSI ?motivo "Javier Saez"))
)

(defrule Aconsejar_CSI_manual
(not (Consejo_preliminar CSI))
(Evaluacion mat alto)
(Evaluacion nota alto)
(Evaluacion trabajador S)
(Evaluacion prog medio|alto)
(Motivo CSI ?motivo)
=>
(assert (Consejo CSI ?motivo "Javier Saez"))
)

(defrule Aconsejar_IS_automatico
(Consejo_preliminar IS)
(Motivo IS ?motivo)
=>
(assert (Consejo IS ?motivo "Javier Saez"))
)

(defrule Aconsejar_IC_automatico
(Consejo_preliminar IC)
(Motivo IC ?motivo)
=>
(assert (Consejo IC ?motivo "Javier Saez"))
)

(defrule Aconsejar_IC_manual
(not (Consejo_preliminar IC))
(Evaluacion hw S)
(Motivo IC ?motivo)
=>
(assert (Consejo IC ?motivo "Javier Saez"))
)

(defrule Aconsejar_SI_automatico
(Consejo_preliminar SI)
(Motivo SI ?motivo)
=>
(assert (Consejo SI ?motivo "Javier Saez"))
)

(defrule Aconsejar_TI_automatico
(Consejo_preliminar TI)
(Motivo TI ?motivo)
=>
(assert (Consejo TI ?motivo "Javier Saez"))
)

(defrule Aconsejar_TI_manual
(not (Consejo_preliminar ?))
(Evaluacion web S)
(Motivo TI ?motivo)
=>
(assert (Consejo TI ?motivo "Javier Saez"))
)


;;;;;;; CONSEJOS FINALES

; Si hemos recomendado una rama pero no hay consejos de relevancia media-alta,
; añadimos alguno de relevancia baja.

(defrule Agregar_motivo_poco_importante_2
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

(defrule Aviso_parcial
(Parar)
=>
(printout t crlf "No has contestado a todas las preguntas, asi que la recomendacion puede no"
  " ser la mas refinada." crlf)
)

(defrule Interpretacion
=>
(printout t crlf "Cuantos mas asteriscos haya delante de un motivo, mas importante "
  "ha sido a la hora de hacer la recomendacion." crlf)
)

(defrule Aconsejar_rama
(declare (salience -1))
(Consejo ?rama ?motivo ?experto)
(Nombre_rama ?rama ?nombre)
(Descripcion ?rama ?desc)
=>
(printout t crlf "Recomendacion: " ?nombre crlf "-------------------------------------------------"
  crlf "Descripcion de la rama: " ?desc crlf "Experto: " ?experto crlf "Motivos: " crlf ?motivo)
)

(defrule No_recomendar
(declare (salience -1))
(not (Consejo ? ? ?))
=>
(printout t crlf "No tengo informacion suficiente para hacer ninguna recomendacion" crlf)
)
