;;;;;;;;;;;;;;;;;;;;; JUGADOR DE 3 EN RAYA ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Version de 3 en raya clásico: tres fichas que se pueden poner
;;; libremente en cualquier posición libre (i,j) con 0 < i, j < 4.
;;; Cuando se han puesto las 3 fichas, las jugadas consisten en
;;; desplazar una ficha propia de la posición en que se encuentra
;;; (i,j) a una contigua.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ingeniería del Conocimiento. Curso 2019/20.
;;; Antonio Coín Castro.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;; HECHOS PARA REPRESENTAR EL ESTADO DEL JUEGO

;;; (Turno X|O) representa a quién corresponde el turno (X máquina, O jugador).

;;; (Posicion ?i ?j " "|X|O) representa que la posición (i,j) del tablero está vacía,
;;; o tiene una ficha de la máquina o tiene una ficha del jugador.


;;;;;; HECHOS PARA REPRESENTAR UNA JUGADA

;;; (Juega X|O ?origen_i ?origen_j ?destino_i ?destino_j) representa que la jugada
;;; consiste en desplazar la ficha de la posicion (?origen_i, ?origen_j) a la posición
;;; (?destino_i, ?destino_j). Las fichas que se ponen inicialmente se supondrá que
;;; están en la posición (0, 0).


;;;;;; INICIALIZAR ESTADO DEL TABLERO

;;; Definimos las conexiones del tablero 3x3.
;;; Las filas son 1,2,3 y las columnas a,b,c.

(deffacts Tablero
(Conectado 1 a horizontal 1 b)
(Conectado 1 b horizontal 1 c)
(Conectado 2 a horizontal 2 b)
(Conectado 2 b horizontal 2 c)
(Conectado 3 a horizontal 3 b)
(Conectado 3 b horizontal 3 c)
(Conectado 1 a vertical 2 a)
(Conectado 2 a vertical 3 a)
(Conectado 1 b vertical 2 b)
(Conectado 2 b vertical 3 b)
(Conectado 1 c vertical 2 c)
(Conectado 2 c vertical 3 c)
(Conectado 1 a diagonal 2 b)
(Conectado 2 b diagonal 3 c)
(Conectado 1 c diagonal_inversa 2 b)
(Conectado 2 b diagonal_inversa 3 a)
)

;;; Todas las casillas están vacías inicialmente
;;; y ambos jugadores tienen 3 fichas para colocar.

(deffacts Estado_inicial
(Posicion 1 a " ")
(Posicion 1 b " ")
(Posicion 1 c " ")
(Posicion 2 a " ")
(Posicion 2 b " ")
(Posicion 2 c " ")
(Posicion 3 a " ")
(Posicion 3 b " ")
(Posicion 3 c " ")
(Fichas_sin_colocar O 3)
(Fichas_sin_colocar X 3)
(Total_descartados_X 0)
)

;;; Establecemos que las conexiones son simétricas, y que
;;; dos casillas conectadas están en línea.

(defrule Conectado_es_simetrica_y_en_linea
(declare (salience 1))
(Conectado ?i1 ?j1 ?forma ?i2 ?j2)
=>
(assert (Conectado ?i2 ?j2 ?forma ?i1 ?j1) (En_linea ?forma ?i1 ?j1 ?i2 ?j2))
)

;;; Establecemos que estar en línea es una propiedad transitiva

(defrule En_linea_es_transitiva
(declare (salience 1))
(En_linea ?forma ?i1 ?j1 ?i2 ?j2)
(En_linea ?forma ?i2 ?j2 ?i3 ?j3)
(or (test (neq ?i1 ?i3)) (test (neq ?j1 ?j3)))
=>
(assert (En_linea ?forma ?i1 ?j1 ?i3 ?j3))
)

;;; Decidimos quién empieza a jugar.

(defrule Elige_quien_comienza
=>
(printout t "Primer jugador ('O' = jugador humano, 'X' = máquina): ")
(assert (Turno (read)))
)

;;; Mostramos el estado actual del tablero.

(defrule Muestra_tablero
(declare (salience 1))
?f <- (Muestra_tablero)
(Posicion 1 a ?p11)
(Posicion 1 b ?p12)
(Posicion 1 c ?p13)
(Posicion 2 a ?p21)
(Posicion 2 b ?p22)
(Posicion 2 c ?p23)
(Posicion 3 a ?p31)
(Posicion 3 b ?p32)
(Posicion 3 c ?p33)
=>
(printout t crlf)
(printout t "   a      b      c" crlf)
(printout t "   -      -      -" crlf)
(printout t "1 |" ?p11 "| -- |" ?p12 "| -- |" ?p13 "|" crlf)
(printout t "   -      -      -" crlf)
(printout t "   |  \\   |   /  |" crlf)
(printout t "   -      -      -" crlf)
(printout t "2 |" ?p21 "| -- |" ?p22 "| -- |" ?p23 "|" crlf)
(printout t "   -      -      -" crlf)
(printout t "   |   /  |  \\   |" crlf)
(printout t "   -      -      -" crlf)
(printout t "3 |" ?p31 "| -- |" ?p32 "| -- |" ?p33 "|"crlf)
(printout t "   -      -      -" crlf)
(retract ?f)
)


;;;;;; TURNO DEL JUGADOR HUMANO

;;; Si le toca al jugador humano, muestra estado del tablero
;;; antes de preguntar por su movimiento.

(defrule Muestra_tablero_O
(declare (salience 10))
(Turno O)
=>
(assert (Muestra_tablero))
)

;;; Si le toca al jugador humano y le quedan fichas sin colocar,
;;; preguntar dónde quiere poner la siguiente.

(defrule Juega_O_fichas_sin_colocar
?f <- (Turno O)
(Fichas_sin_colocar O ?n)
=>
(printout t crlf "--- Colocar siguiente ficha (quedan " ?n ")" crlf)
(printout t "Fila (1, 2 ó 3): ")
(bind ?fila (read))
(printout t "Columna (a, b ó c): ")
(bind ?columna (read))
(printout t crlf "O: Juegas poner la ficha en " ?fila ?columna crlf)
(retract ?f)
(assert (Juega O 0 0 ?fila ?columna))
)

;;; Comprueba si la jugada es válida.

(defrule Juega_O_fichas_sin_colocar_check
(declare (salience 1))
?f <- (Juega O 0 0 ?i ?j)
(not (Posicion ?i ?j " "))
=>
(printout t "No puedes jugar en " ?i ?j " porque no está vacío" crlf)
(retract ?f)
(assert (Turno O))
)

;;; Si la jugada es válida, actualizamos el estado del tablero.

(defrule Juega_O_fichas_sin_colocar_actualiza_estado
?f <- (Juega O 0 0 ?i ?j)
?g <- (Posicion ?i ?j " ")
=>
(retract ?f ?g)
(assert (Turno X) (Posicion ?i ?j O) (Reducir_fichas O))
)

;;; Si le toca al jugador humano y ha colocado todas sus fichas,
;;; se le pide que mueva una de ellas.

(defrule Juega_O_mover
?f <- (Turno O)
(Todas_en_tablero O)
=>
(printout t crlf "--- Mover ficha" crlf)
(printout t "Fila origen (1, 2 ó 3): ")
(bind ?origen_i (read))
(printout t "Columna origen (a, b ó c): ")
(bind ?origen_j (read))
(printout t "Fila destino (1, 2 ó 3): ")
(bind ?destino_i (read))
(printout t "Columna destino (a, b ó c): ")
(bind ?destino_j (read))
(printout t crlf "O: Juegas mover la ficha de " ?origen_i ?origen_j
  " a " ?destino_i ?destino_j crlf)
(retract ?f)
(assert (Juega O ?origen_i ?origen_j ?destino_i ?destino_j))
)

;;; Comprueba que la jugada al mover ficha sea válida:
;;;     1. En la casilla de origen debe haber una ficha nuestra.
;;;     2. La casilla de destino debe estar libre.
;;;     3. La casilla de origen y la de destino deben estar conectadas.

(defrule Juega_O_mover_check_propia
(declare (salience 1))
?f <- (Juega O ?origen_i ?origen_j ?destino_i ?destino_j)
(Posicion ?origen_i ?origen_j ?X)
(test (neq O ?X))
=>
(printout t "Jugada no válida porque en " ?origen_i ?origen_j " no hay una ficha tuya" crlf)
(retract ?f)
(assert (Turno O))
)

(defrule Juega_O_mover_check_libre
(declare (salience 1))
?f <- (Juega O ?origen_i ?origen_j ?destino_i ?destino_j)
(Posicion ?destino_i ?destino_j ?X)
(test (neq " " ?X))
=>
(printout t "Jugada no válida porque " ?destino_i ?destino_j " no está libre" crlf)
(retract ?f)
(assert (Turno O))
)

(defrule Juega_O_mover_check_conectado
(declare (salience 1))
(Todas_en_tablero O)
?f <- (Juega O ?origen_i ?origen_j ?destino_i ?destino_j)
(not (Conectado ?origen_i ?origen_j ? ?destino_i ?destino_j))
=>
(printout t "Jugada no válida porque " ?origen_i ?origen_j
  " no está conectado con " ?destino_i ?destino_j crlf)
(retract ?f)
(assert (Turno O))
)

;;; Si la jugada es válida, actualizamos el estado.

(defrule Juega_O_mover_actualiza_estado
?f <- (Juega O ?origen_i ?origen_j ?destino_i ?destino_j)
?g <- (Posicion ?origen_i ?origen_j O)
?h <- (Posicion ?destino_i ?destino_j " ")
=>
(retract ?f ?g ?h)
(assert (Turno X) (Posicion ?destino_i ?destino_j O) (Posicion ?origen_i ?origen_j " "))
)


;;;;;; REGLAS PARA AMBOS JUGADORES

;;; Comprobamos si tenemos dos fichas en línea (no queremos información simétrica).
;;; Si movemos alguna de las fichas, dejamos de tener 2 en línea automáticamente.

(defrule Dos_en_linea
(declare (salience 2))
(logical (Posicion ?i1 ?j1 ?jugador) (Posicion ?i2 ?j2 ?jugador))
(En_linea ?forma ?i1 ?j1 ?i2 ?j2)
(not (Dos_en_linea ?forma ?i2 ?j2 ?i1 ?j1 ?jugador))
(test (neq " " ?jugador))
=>
(assert (Dos_en_linea ?forma ?i1 ?j1 ?i2 ?j2 ?jugador))
)

;;; Comprueba si un jugador puede realizar un movimiento ganador.
;;; Si cambia el estado del tablero, los jugadores dejan automáticamente
;;; de poder ganar.

(defrule Puede_ganar_fichas_sin_colocar
(declare (salience 2))
(logical (not (Todas_en_tablero ?jugador)) (Posicion ?i2 ?j2 " "))
(Dos_en_linea ?forma ?i1 ?j1 ? ? ?jugador)
(En_linea ?forma ?i1 ?j1 ?i2 ?j2)
=>
(assert (Puede_ganar 0 0 ?i2 ?j2 ?jugador))
)

(defrule Puede_ganar_mover
(declare (salience 2))
(logical
  ; Debemos tener 2 en línea y un hueco en la línea
  (Dos_en_linea ?forma ?i1 ?j1 ? ? ?jugador)
  (Posicion ?i2 ?j2 " ")
  ; Debemos poder mover una ficha nuestra (i3, j3) al hueco libre
  (Posicion ?i3 ?j3 ?jugador))
; Comprobaciones adicionales (hechos que no cambian en ejecución)
(En_linea ?forma ?i1 ?j1 ?i2 ?j2)
(Conectado ?i2 ?j2 ? ?i3 ?j3)
(not (En_linea ?forma ?i3 ?j3 ?i2 ?j2))
=>
(assert (Puede_ganar ?i3 ?j3 ?i2 ?j2 ?jugador))
)

;;; Reducimos el número de fichas disponibles para colocar en 1.

(defrule Reducir_fichas_sin_colocar
(declare (salience 1))
?f <- (Reducir_fichas ?jugador)
?g <- (Fichas_sin_colocar ?jugador ?n)
=>
(retract ?f ?g)
(assert (Fichas_sin_colocar ?jugador (- ?n 1)))
)

;;; Comprobamos si un jugador ha colocado todas sus fichas.

(defrule Todas_las_fichas_en_tablero
(declare (salience 1))
?f <- (Fichas_sin_colocar ?jugador 0)
=>
(retract ?f)
(assert (Todas_en_tablero ?jugador))
)


;;;;;; TURNO DEL JUGADOR AUTOMÁTICO

;;; Si al mover una ficha de X dejamos un hueco para que el jugador
;;; humano gane, marcamos el movimiento como descartado y lo revertimos.
;;; Esta regla se activa tras haber actualizado el estado.

(defrule Juega_X_mover_revertir
(declare (salience 1))
?f <- (Juega X ?origen_i ?origen_j ?destino_i ?destino_j)
?g <- (Puede_ganar ? ? ?origen_i ?origen_j O)
; Los siguientes hechos son ciertos porque ya hemos movido la ficha
?h <- (Posicion ?origen_i ?origen_j " ")
?k <- (Posicion ?destino_i ?destino_j X)
?l <- (Total_descartados_X ?n)
=>
(retract ?f ?g ?h ?k ?l)
(assert (Turno X) (Posicion ?origen_i ?origen_j X)
  (Posicion ?destino_i ?destino_j " ") (Descartado_X ?origen_i ?origen_j)
  (Total_descartados_X (+ ?n 1)))
)

;;; Si al mover una ficha no hay peligro de que el jugador humano gane,
;;; seguimos adelante con el movimiento y limpiamos la lista de
;;; movimientos descartados. También cambiamos de turno. Esta regla se
;;; activa tras haber actualizado el estado.

; Si continuamos, es seguro que no perdemos en el siguiente turno.
(defrule Juega_X_mover_continuar
(declare (salience 1))
?f <- (Juega X ?origen_i ?origen_j ?destino_i ?destino_j)
(Todas_en_tablero X)
(Posicion ?origen_i ?origen_j " ") ; Para que se active la regla tras haber movido la ficha
(not (Puede_ganar ? ? ?origen_i ?origen_j O))
=>
(printout t "X: Juego mover la ficha de " ?origen_i ?origen_j " a "
  ?destino_i ?destino_j " (aleatoriamente, pero no pierdo)" crlf)
(retract ?f)
(assert (Turno O) (Limpia_descartados_X))
)

;;; Limpia la lista de movimientos descartados.

(defrule Reinicia_descartados
(declare (salience 2))
?f <- (Limpia_descartados_X)
(Total_descartados_X 0)
=>
(retract ?f)
)

(defrule Limpia_descartados
(declare (salience 2))
(Limpia_descartados_X)
?f <- (Total_descartados_X ?n)
?g <- (Descartado_X ? ?)
=>
(retract ?f ?g)
(assert (Total_descartados_X (- ?n 1)))
)

;;; Actualizamos el estado de forma definitiva cuando la máquina
;;; pone una nueva ficha en el tablero, o bien cuando mueve una ficha
;;; para realizar un movimiento no aleatorio. Estas reglas se definen
;;; por comodidad, para no repetir mucho código.

(defrule Juega_X_fichas_sin_colocar_actualiza_estado
?f <- (Juega X 0 0 ?i ?j)
?g <- (Posicion ?i ?j " ")
=>
(retract ?f ?g)
(assert (Turno O) (Posicion ?i ?j X) (Reducir_fichas X))
)

(defrule Juega_X_mover_actualiza_estado
(not (Jugada_X_mover_temporal))
?f <- (Juega X ?origen_i ?origen_j ?destino_i ?destino_j)
?g <- (Posicion ?origen_i ?origen_j X)
?h <- (Posicion ?destino_i ?destino_j " ")
=>
(retract ?f ?g ?h)
(assert (Turno O) (Posicion ?destino_i ?destino_j X) (Posicion ?origen_i ?origen_j " "))
)

;;; Actualizamos el estado de forma temporal cuando la máquina
;;; mueve una ficha del tablero aleatoriamente, ya que es posible
;;; que haya que revertirlo si ocasiona que el jugador humano pueda ganar.
;;; No cambiamos aún de turno.

(defrule Juega_X_mover_actualiza_estado_temporal
?f <- (Jugada_X_mover_temporal)
(Juega X ?origen_i ?origen_j ?destino_i ?destino_j)
?g <- (Posicion ?origen_i ?origen_j X)
?h <- (Posicion ?destino_i ?destino_j " ")
=>
(retract ?f ?g ?h)
(assert (Posicion ?destino_i ?destino_j X) (Posicion ?origen_i ?origen_j " "))
)

;;; Si podemos ganar la partida, lo hacemos. Jugada con la prioridad más alta.

(defrule Juega_X_ganar_fichas_sin_colocar
(declare (salience -1))
?f <- (Turno X)
(Puede_ganar 0 0 ?i ?j X)
=>
(printout t "X: Juego poner ficha en " ?i ?j  " (para ganar)" crlf)
(retract ?f)
(assert (Juega X 0 0 ?i ?j))
)

(defrule Juega_X_ganar_mover
(declare (salience -1))
?f <- (Turno X)
(Todas_en_tablero X)
(Puede_ganar ?origen_i ?origen_j ?destino_i ?destino_j X)
=>
(printout t "X: Juego mover la ficha de " ?origen_i ?origen_j
  " a " ?destino_i ?destino_j " (para ganar)" crlf)
(retract ?f)
(assert (Juega X ?origen_i ?origen_j ?destino_i ?destino_j))
)

;;; Si el jugador humano puede ganar en su siguiente movimiento, la máquina lo evita.
;;; Jugada con prioridad intermedia.

(defrule Juega_X_evita_perder_fichas_sin_colocar
(declare (salience -2))
?f <- (Turno X)
(Fichas_sin_colocar X ?n)
(Puede_ganar ? ? ?i ?j O)
=>
(printout t "X: Juego poner ficha en " ?i ?j " (para evitar perder)" crlf)
(retract ?f)
(assert (Juega X 0 0 ?i ?j))
)

(defrule Juega_X_evita_perder_mover
(declare (salience -2))
?f <- (Turno X)
(Todas_en_tablero X)
(Puede_ganar ? ? ?destino_i ?destino_j O)
(Conectado ?origen_i ?origen_j ? ?destino_i ?destino_j)
(Posicion ?origen_i ?origen_j X)
=>
(printout t "X: Juego mover la ficha de " ?origen_i ?origen_j
  " a " ?destino_i ?destino_j " (para evitar perder)" crlf)
(retract ?f)
(assert (Juega X ?origen_i ?origen_j ?destino_i ?destino_j))
)

;;; Coloca una ficha en una posición cualquiera, o mueve una ficha cualquiera.
;;; En el caso de mover, puede que el movimiento no sea definitivo.
;;; Jugada con la menor prioridad.

; Si podemos, colocamos la primera ficha en el centro
(defrule Juega_X_aleatorio_fichas_sin_colocar_inicio
(declare (salience -2))
?f <- (Turno X)
(Fichas_sin_colocar X 3)
(Posicion 2 b " ")
=>
(printout t "X: Juego poner ficha en " 2 b " (por ser la primera)" crlf)
(retract ?f)
(assert (Juega X 0 0 2 b))
)

(defrule Juega_X_aleatorio_fichas_sin_colocar
(declare (salience -3))
?f <- (Turno X)
(Fichas_sin_colocar X ?n)
(Posicion ?i ?j " ")
=>
(printout t "X: Juego poner ficha en " ?i ?j " (aleatoriamente, pero no pierdo)" crlf)
(retract ?f)
(assert (Juega X 0 0 ?i ?j))
)

(defrule Juega_X_aleatorio_mover_temporal
(declare (salience -3))
?f <- (Turno X)
(Todas_en_tablero X)
(Posicion ?origen_i ?origen_j X)
(Posicion ?destino_i ?destino_j " ")
(Conectado ?origen_i ?origen_j ? ?destino_i ?destino_j)
(not (Descartado_X ?origen_i ?origen_j))
=>
(retract ?f)
(assert (Jugada_X_mover_temporal) (Juega X ?origen_i ?origen_j ?destino_i ?destino_j))
)

; Si no hay más remedio, movemos aleatoriamente (podríamos perder en el siguiente turno).
(defrule Juega_X_aleatorio_mover
(declare (salience -4))
?f <- (Turno X)
(Todas_en_tablero X)
(Posicion ?origen_i ?origen_j X)
(Posicion ?destino_i ?destino_j " ")
(Conectado ?origen_i ?origen_j ? ?destino_i ?destino_j)
=>
(printout t "X: Juego mover la ficha de " ?origen_i ?origen_j " a "
  ?destino_i ?destino_j " (aleatoriamente)" crlf)
(retract ?f)
(assert (Juega X ?origen_i ?origen_j ?destino_i ?destino_j))
)


;;;;;; FIN DEL JUEGO

;;; Comprueba si algún jugador ha ganado.

(defrule Tres_en_raya
(declare (salience 9999))
?f <- (Turno ?X)
(Posicion ?i1 ?j1 ?jugador)
(Posicion ?i2 ?j2 ?jugador)
(Posicion ?i3 ?j3 ?jugador)
(Conectado ?i1 ?j1 ?forma ?i2 ?j2)
(Conectado ?i2 ?j2 ?forma ?i3 ?j3)
(test (neq ?jugador " "))
(test (or (neq ?i1 ?i3) (neq ?j1 ?j3)))
=>
(printout t crlf)
(printout t "El jugador " ?jugador " ha ganado, pues tiene tres en raya: "
  ?i1 ?j1 ", " ?i2 ?j2 ", " ?i3 ?j3 crlf)
(retract ?f)
(assert (Muestra_tablero))
)
