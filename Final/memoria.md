---
title: Ingeniería del Conocimiento
subtitle: "Práctica Final: Sistema experto recomendador de asignaturas y ramas"
author: Antonio Coín Castro
date: $77191012$E
geometry: margin = 1.2in
documentclass: scrartcl
fontsize: 11pt
numbersections: true
colorlinks: true
urlcolor: Magenta
toc: true
output: pdf_document
header-includes:
  - \usepackage{amsmath}
  - \usepackage{graphicx}
  - \usepackage{hyperref}
  - \usepackage{subcaption}
  - \usepackage[spanish, es-tabla]{babel}
---

\decimalpoint


\newpage

# Resumen del funcionamiento del sistema

En esta práctica se desarrolla un sistema experto que actúa como recomendador de ramas y/o asignaturas del Grado en Ingeniería Informática de la UGR, según cómo lo haría un estudiante del mismo. El nombre del experto del cual se ha extraído el conocimiento es **Javier Sáez** (estudiante matriculado actualmente en la asignatura de IC). Al ejecutar el sistema, se muestra un menú que permite elgir cuál de los dos tipos de recomendaciones quieres recibir, dando la posibilidad de volver más tarde a ese mismo menú y escoger otra opción. Se ha implementado además una estructura modular de alto nivel para diferenciar y tratar adecuadamente los distintos estados por los que pasa el sistema.

En líneas generales, el sistema parte de un conocimiento adquirido sobre hechos y relaciones entre una serie de características de los estudiantes (capacidad de trabajo, nota, ...) y una serie de características de las ramas y asignaturas (dificultad, carga de trabajo, ...). Cuando se inicia alguno de los dos sistemas de recomendación, se comienza a hacer preguntas al usuario, hasta que se termine la lista de preguntas o hasta que este decida que no quiere contestar más. A continuación, el sistema incorpora el conocimiento obtenido a través de las preguntas a la base de conocimientos, y comienza un proceso de deducción a partir de las reglas que posee, lo que le lleva finalmente a mostrar las recomendaciones pertinentes.

Todas las recomendaciones se acompañan de motivos que explican por qué se ha recomendado esa asignatura o rama en concreto, en función de las preguntas respondidas por el usuario y del conocimiento global del sistema. Estas recomendaciones permiten seguir la pista a los razonamientos realizados para obtener los resultados, de forma que el sistema no se asemeja a una caja negra sino que se presta a la interpretabilidad.

El sistema se ha desarrollado en 5 archivos `.clp`, atendiendo a la siguiente estructura:

- `ramas.datos.clp` contiene el conocimiento global relativo al subsistema de recomendación de ramas (RR),
- `ramas.clp` contiene las reglas del subsistema RR,
- `asig.datos.clp` contiene el conocimiento global relativo al subsistema de recomendación de asignaturas (RA),
- `asig.clp` contiene las reglas del subsistema RA, y
- `recomendador.clp` actúa como elemento integrador de los dos subsistemas, permitiendo elegir uno u otro o finalizar el programa.

# Descripción del proceso seguido

## Procedimiento para el desarrollo de la base de conocimiento

Comentaremos ahora el procedimiento seguido para obtener y representar el conocimiento. Cuando sea necesario, diferenciaremos si estamos hablando del subsistema RR ó RA.

Para la **obtención del conocimiento**, se ha empleado una combinación de los siguientes elementos:

1. *Estudio inicial del problema*. Se llevó a cabo un pequeño estudio sobre la viabilidad del problema a resolver y las necesidades de los futuros usuarios del sistema, realizando un esquema general del proceso (que posteriormente daría lugar a los módulos implementados).

1. *Entrevistas con el experto*. Se han realizado un total de dos entrevistas abiertas con el experto. La primera tuvo lugar en las horas de clase, con el objetivo de obtener el conocimiento para el subsistema RR. En la segunda, realizada ya de manera telemática, se perseguía adquirir el conocimiento para el subsistema RA, así como revisar las conclusiones de la primera reunión y enfocar ambos subsistemas como un 'todo'.

3. *Rejilla de repertorio*. Con el fin de extraer características relevantes sobre las asignaturas, las ramas y los estudiantes se realizó con el experto un emparrillado a partir de las ramas y otro a partir de las asignaturas (basado en una de las tareas de clase).

4. *Árboles de decisión*. Finalmente, para obtener las reglas por las cuales recomendar una u otra asignatura o rama, se realizó un proceso de aprendizaje de árboles de decisión utilizando las características extraídas en el punto anterior.


Para la **representación del conocimiento**, se aprovechó en parte (para extraer algunas estructuras) un ejercicio sobre *ontologías* realizado como tarea de la asignatura, en el que se pedía obtener una representación de los elementos más relevantes de las asignaturas del Grado, enfocada a decidir si matricularse o no en algunas de ellas. En general, como los hechos a representar son bastante simples se ha optado por mantenerlos como *ordered facts*, con la excepción de las asignaturas para el subsistema RA, para las cuales se implementa una estructura `deftemplate` que permite un tratamiento más avanzado mediante funciones genéricas de manejo de hechos. Se reproduce a continuación un esquema simplificado de la misma:

```clips
(deftemplate asignatura
  (slot id)
  (slot nombre)
  (slot curso)
  (slot creditos (default 6))
  (slot dificultad)
  (slot carga)
  (slot tipo)
  (slot programar)
  (slot hardware)
  (multislot areas))
```

Se han ido incorporando a la base de conocimiento los hechos que se consieraron necesarios tras la adquisición de conocimiento realizada. Una descripción detallada de los hechos utilizados para representar el conocimiento global puede consultarse en la sección [Conocimiento global], y un recuento pormenorizado del conocimiento utilizado puede econtrarse en la sección [Hechos y reglas].

## Procedimiento de validación y verificación

Hemos seguido un proceso de **verificación** que nos ha permitido asegurar que hemos construido el sistema correctamente y el conocimiento es coherente. En particular, se han tenido en cuenta los siguientes factores:

- Tenemos un sistema **consistente** que no presenta conclusiones incoherentes. En particular, se han evitado las inconsistencias
    * *estructurales*, comprobando que todas las reglas se alcanzan para algún posible camino, que no hay callejones sin salidas, reglas redundantes ni ciclos de reglas;
    * *lógicas*, descartando por inspección que haya reglas que puedan producir contradicciones lógicas, subsunción de reglas ni reglas con conclusiones o antecedentes redundantes; y
    * *semánticas*, revisando que no haya valores ilegales en ninguna variable.
- Tenemos un sistema **preciso** sin errores de sintaxis en la base de datos. Se han revisado con detalle todos los hechos introducidos, viendo que se utilizaban correctamente y sin errores en su escritura.
- Tenemos un sistema **completo**, en el sentido de que no hay lagunas deductivas. Se ha comprobado que todas las ramas y asignaturas son recomendables para una cierta combinación de valores de entrada. Además, el sistema siempre responde sea cual sea la situación, terminando siempre el procedimiento por completo y proporcionando una eventual recomendación.

Además, para verificar que el sistema de prioridades de reglas funciona correctamente y el funcionamiento del sistema no depende del orden concreto en el que se escriben las reglas con la misma prioridad, se han realizado algunas ejecuciones activando en CLIPS la estrategia `(set-strategy random)`, observando que finalizaba con éxito en todos los casos.

Para la **validación**, hemos comprobado en primer lugar que se cumplen las especificaciones del modelo de diseño y los criterios generales de validación:

- El sistema representa el conocimiento necesario para resolver el problema, de forma suficientemente simple y entendible, reflejo del modelo conceptual construido previamente.
- Se proporciona un diseño modularizado, donde cada módulo cumple una función concreta y claramente especificada. El código en cada caso está debidamente comentado.
- El sistema es fácil de mantener y escalable; cualquier persona podría extender el sistema y añadir conocimiento en forma de preguntas, asignaturas o reglas de deducción.
- Hay una buena comunicación entre los módulos, de forma que los hechos de salida de uno son hechos de entrada a otros. También hay una buena comunicación usuario-sistema, con una interfaz comprensible y clara. Además, el sistema informa cuando algunos de los datos recibidos no se adecúa con lo que se esperaba, facilitando aún más esta comunicación.
- El sistema explica los razonamientos y justifica las decisiones; además, se adquiere nuevo conocimiento o se modifican los conocimientos anteriores a través de las preguntas realizadas.
- Cumple los requisitos de tiempo de ejecución: en todos los casos el razonamiento es casi instantáneo.

Se ha realizado una validación extensiva de los dos subsistemas, introduciendo varios casos de prueba y comprobando con el experto que los resultados son suficientemente buenos. Además, se ha validado la integración de ambos subsistemas, viendo que funcionan bien de forma conjunta y no producen razonamientos extraños. Se ha probado también con casos de prueba inusuales, situaciones poco naturales o que sería raro que apareciesen en un uso común (por ejemplo, pedir recomendaciones de asignaturas sin contestar ninguna pregunta), y también el sistema proporciona una respuesta satisfactoria en estos casos. Durante este proceso se encontraron algunos errores por comisión y por omisión que fueron subsanados en una revisión del sistema.

En general, podemos afirmar que se ha obtenido un sistema completo y eficiente, que es confiable en cuanto a su funcionamiento y cubre las expectativas para lo que fue construido.

# Descripción del sistema

Pasamos a realizar una descripción detallada del sistema, en la que dividiremos cuando sea necesario la explicación por subsistemas. Como ya hemos comentado, el sistema se inicia con un menú que permite al usuario elegir si quiere recibir recomendaciones de rama o de asignatura. A partir de aquí se considera una estructura modular, estableciendo en cada regla hechos de tipo `(modulo NOMBRE_MODULO)` y avanzando entre los módulos de forma automática.

### Subsistema RR {.unlisted .unnumbered}

En el caso de **recomendaciones de rama**, el sistema realiza una serie de preguntas para establecer la afinidad del usuario con cada una de las ramas, en base al conocimiento disponible y adquirido a través de estas preguntas.
Para ello se consideran algunas características significativas, como el gusto por las matemáticas, los planes de futuro o la nota media, entre otras. Finalmente se recomiendan la rama o ramas que más puntuación hayan obtenido según esta medida de afinidad, teniendo en cuenta que detrás de cada modificación en los puntos hay un motivo que se ve reflejado en la recomendación final, estableciendo además su nivel de peso en la recomendación (poco, medio, mucho). Se permite seleccionar al comienzo si se desean ver absolutamente todos los motivos, o solo los más relevantes.

Con el objetivo de calcular estas afinidades sin perder de vista los motivos cualitativos de la elección, se mantiene para cada respuesta del usuario una variable numérica y otra categórica, convirtiendo de la una a la otra según un criterio establecido por el experto en cada caso. Es por esto que el sistema no se limita únicamente a calcular afinidad, sino que razona en función del conocimiento disponible y establece unos motivos en base a los cuales seleccionar unas ramas y descartar otras.

Hay también una serie de excepciones a las recomendaciones automáticas, de forma que se permite realizar una recomendación manual si se considera que se cumplen los requisitos para ello (por ejemplo, si el usuario indica que le gusta el *hardware* siempre va a recibir como una de las recomendaciones la rama de Ingeniería de Computadores).

Por último, se permite no contestar a cualquier pregunta, y en ese caso simplemente se omite esa información y se trabaja con las respuestas del resto.

### Subsistema RA {.unlisted .unnumbered}

Para las **recomendaciones de asignaturas**, el procedimiento es similar, pero cambia un poco la filosofía de razonamiento. En este caso la idea es que a partir de un subconjunto de asignaturas a matricular y un número de créditos tenemos que elegir cuáles de ellas se recomiendan. Una vez que tenemos esta información , se pregunta por el curso actual en el que se encuentra el usuario, y después procede a realizar una serie de preguntas en las condiciones del subsistema anterior, teniendo en cuenta que ahora pretendemos acoplar características de las asignaturas con características del estudiante.

El sistema intentará recomendar tantas asignaturas como pueda con los créditos disponibles. El comportamiento esperado es que el número de créditos a matricular sea menor que el número de créditos totales de las asignaturas de la lista, pues si no utilizar este sistema no tiene sentido. Puede darse el caso en que no haya asignaturas suficientes para cubrir todos los créditos a matricular, en cuyo caso se recomiendan el mayor número posible.

En este caso tenemos implementado un **manejo de incertidumbre** en dos vertientes. En primer lugar, si se omite la respuesta a alguna pregunta (contestando `NS` a una pregunta categórica o `-2` a una numérica) o se  finaliza prematuramente el proceso de preguntas (contestando `X` a una pregunta categórica o `-1` a una numérica), el sistema tiene unos valores *por defecto*, que se consideran válidos para la mayoría de los estudiantes. Se toma como referencia un estudiante medio de grado, y como su propio nombre indica, todos los valores por defecto son 'medio', salvo el caso de la afinidad por la programación que se considera 'alta'. Para las áreas de conocimiento se considera que por defecto solo interesa el desarrollo de software (`DS`). El sistema informa por pantalla cuando se está utilizando un valor por defecto para una característica, así como el valor por defecto asumido.

En segundo lugar, disponemos de un conocimiento por defecto que no depende directamente de las preguntas: daremos prioridad a las asignaturas correspondientes a cursos menores o igual es que el del usuario. Sin embargo, es posible que este conocimiento se vea retractado si se cumple una condición concreta: que la capacidad de trabajo sea alta o que la nota sea alta. En cualquiera de estos casos se informa por pantalla de que se elimina la restricción en cuanto a los cursos.

Para decidir unas asignaturas u otras, en esta ocasión disponemos de un conjunto de reglas de tipo SI-ENTONCES, a partir de las cuales iremos seleccionando las asignaturas que más de ellas cumplan de acuerdo a las características especificadas en los consecuentes. Estas reglas siguen el formato
$$\text{SI } A_1 \land A_2 \land \dots \land A_N \text{ ENTONCES } C_1 \land C_2 \land \dots \land C_M,$$
donde los $A_i$ son los antecedentes y los $C_i$ los consecuentes. ada uno de ellos está formado por una pareja de característica y valor, compartiendo todos los consecuentes la misma caracteristica (solo va variando el valor). Cada regla puede ser *positiva*, en el sentido de que su cumplimiento acerca más a ser recomendada, o *negativa* en caso contrario. Por ejemplo, una regla válida sería
`(capacidad baja) (nota baja) => (dificultad baja)`,
indicando que si la capacidad de trabajo del estudiante es baja y su nota es baja, se favorece recomendar asignaturas con dificultad baja.

Todas las reglas tienen el mismo valor si se satisfacen. Además, hay un comportamiento paralelo a las reglas que sirve solo para sumar motivos positivos a las asignaturas: la correspondencia entre las áreas de conocimiento que el estudiante indica que le gustan y las áreas de conocimiento en la que se enmarca cada asignatura, sumando esta el doble que una regla normal por cada vez que haya una coincidencia (se considera que estos gustos son un factor decisivo a la hora de hacer las recomendaciones).

Junto a cada regla hay asociada una explicación de la misma, que se guarda para las asignaturas que activen la regla y se expone al final en la justificación de motivos. Estos motivos además se diferencian en motivos *por defecto* (simbolizados con un `+`) y motivos *seguros* (simbolizados con un `*`), según si las reglas asociadas fueron disparadas gracias a información segura o no. Ahora ya no mantenemos la dualidad de respuestas numéricas-categóricas, sino que solo nos interesa el grado (bajo, medio o alto) en el que se evalúan las características (las respuestas numéricas se transforman en categóricas). Un detalle a tener en cuenta es que se pregunta al usuario si quiere ver los principales motivos por los que las asignaturas descartadas no han sido elegidas. Como se puede adivinar, estos motivos son los que van asociados a las reglas que antes llamamos *negativas*.

De modo análogo a las recomendaciones manuales del otro subsistema, en esta ocasión se consideran un conjunto muy reducido de *asignaturas favoritas* (en este caso, solo se tiene una). Estas son asignaturas que el experto considera que, independientemente de otros factores, son esenciales para cualquier ingeniero/a informático/a, y siempre que tenga la posibilidad la va a recomendar. Esto no se trata de una opinión personal, sino de un consenso generalizado sobre la importancia de esas asignaturas.

**Nota:** en este subsistema, todos los hechos que se generan y se mantienen en el tiempo están predecidos por el símbolo `RA`, de forma que después puedan limpiarse fácilmente. En lo sucesivo omitiremos por claridad este símbolo al mostrar cualquier hecho del subsistema, aunque en el código sí lo tenga realmente.

## Variables de entrada

Además de las variables de entrada que listamos a continuación, podemos considerar como "constantes de entrada" la lista de asignaturas y de ramas de las que poseemos información, cuya estructura se explica con detalle en la parte de [Conocimiento global].

### Sistema principal {.unlisted .unnumbered}

`(OpcionElegidaMenu ?opc)`
 : representa la opción elegida en el menú principal. Puede ser `a` para pasar al subsistema RR, `b` para el subsistema `RA`, ó `c` para salir.

### Subsistema RR {.unlisted .unnumbered}

`(Modo_completo S|N)`
 : indica si se desean ver todos los motivos de cada rama (`S`), o solo los más relevantes (`N`). En el caso de que todos los motivos sean poco relevantes, se ignora esta opción y se muestran todos.

`(Respuesta_num ?caract ?valor)`
 : representa la evaluación numérica de una característica por parte del usuario.

`(Evaluacion ?caract bajo|medio|alto|desconocido)`
 : representa la evaluación categórica de una característica por parte del usuario. Inicialmente todas toman el valor `desconocido`.

### Subsistema RA {.unlisted .unnumbered}

`(OpcionElegida ?opc)`
 : representa la opción elegida en el menú de este subsistema. Puede ser `a` para mostrar una lista de las asignaturas disponibles en la base de conocimiento, `b` para iniciar el proceso de recomendación, ó `c` para volver al menú principal.

`(ListaAsig $?lasig)`
 : contiene los identificadores de las asignaturas entre las que hay que elegir.

`(Creditos ?num)`
 : representa el número de créditos de los que nos queremos matricular. Se asume que es múltiplo de 6, pues todas las asignaturas del grado tienen 6 créditos (en cualquier caso, no se producen errores de ejecución si esto no es así).

 `(Curso ?c)`
 : curso actual del estudiante.

 `(dato_num ?caract ?valor)`
 : representa la evaluación numérica de una característica por parte del usuario.

 `(dato ?caract por_defecto|segura ?$valor)`
 : representa la evaluación categórica de una característica por parte del usuario (en el caso de que sea `segura`) o por parte del sistema (en caso de que sea `por_defecto`). El último elemento es un multicampo para cubrir el caso de la característica de áreas de conocimiento que permite respuesta múltiple. En el resto de casos, los valores permitidos son `B|M|A` (bajo, medio o alto).

 `(Mostrar_neg)`
 : si está presente, indica que se desean mostrar, si hay, los motivos por los que las asignaturas descartadas no han sido elegidas.

## Variables de salida

Además de las variables listadas a continuación, se muestran varios mensajes informativos por pantalla para facilitar al usuario la comprensión del comportamiento del sistema, tales como asunciones por defecto o aclaraciones de las preguntas que se hacen.

### Subsistema RR {.unlisted .unnumbered}

`(Consejo ?rama ?motivo ?experto)`
 : este hecho representa una recomendación de la rama `?rama` personalizada para el usuario, hecha por el experto `?experto`. En el campo `?motivo` se encuentran contatenados los motivos que han llevado a recomendar esta rama, con indicación de la importancia de cada uno.

### Subsistema RA {.unlisted .unnumbered}

`(AsigRecomendadas $?lrec)`
 : contiene la lista de identificadores de las asginaturas recomendadas por el sistema. La lista de asignaturas no recomendadas se representa implícitamente como la diferencia entre esta lista y la lista de entrada de asignaturas a recomendar.

`(CreditosRecomendados ?cr)`
 : especifica el número de créditos recomendados finalmente (como mucho puede llegar al número de créditos especificados inicialmente como entrada).

`(motivos-pos ?id ?mot)`
 : indica todos los motivos *positivos* por los que la asignatura `?id` es recomendada.

`(motivos-neg ?id ?mot)`
 : indica todos los motivos *negativos* por los que la asignatura `?id` no es recomendada.

## Conocimiento global

El conocimiento global del sistema se distribuye principalmente en los dos ficheros de datos que se proporcionan. Aunque en todo momento el sistema posee todo este conocimiento global, a la hora de describirlo lo separamos por subsistemas.

### Sistema principal {.unlisted .unnumbered}

`(Preguntar_inicial)`
  : hecho que siempre está presente al inicio del sistema, indicando que debemos mostrar el menú al usuario y preguntarle qué quiere hacer.

### Subsistema RR {.unlisted .unnumbered}

`(Rama ?id)`
 : representa el identificador de cada una de las ramas. En nuestro sistema consideramos 5 ramas: CSI, IS, IC, SI y TI.

`(Nombre_rama ?id ?nombre)`
 : representa el nombre de cada una de las ramas.

`(Descripcion ?id ?descr)`
 : una pequeña descripción de cada rama, realizada por el experto.

`(Equivalencia_texto ?caract ?texto)`
 : representa una descripción para cada característica considerada. Las posibles características son: `mat` para el grado de interés por las matemáticas, `hw` para el gusto por el hardware, `prog` para el grado de interés por la programación, `nota` para la nota media, `trabajador` para indicar si se es trabajador, `web` para indicar el gusto por las tecnologías web, `bbdd` para el gusto por las bases de datos, y finalmente `futuro` para indicar dónde se desea trabajar en un futuro.

 `(Abreviado ?cosa ?tipo ?abr)`
  : contiene las abreviaturas de los distintos valores que pueden tomar las características, teniendo en cuenta el género de los sustantivos.

`(Contribuye ?caract ?id ?valor)`
 : son los hechos claves para el sistema de razonamiento, que representan la adquisición de conocimiento realizada. Expresa que la característica `?caract` contribuye a la rama `?id` de forma **directa** en grado `?valor`; es decir, cuando más alta sea esa característica, más alta será la contribución.

`(Contribuye_inv ?caract ?id ?valor)`
 : análogo a los hechos anteriores, pero en este caso las constribuciones son **inversas**: a menor valor de la característica, mayor contribución a la rama en cuestión.

`(Puntuacion ?id 0)`
 : inicializa la puntuación de cada rama a 0.

`(Motivo ?id "")`
 : inicializa los motivos de elección de cada rama con la cadena vacía.

### Subsistema RA {.unlisted .unnumbered}

`(Opciones a b c)`
 : lista de opciones válidas para el menú del subsistema.

`(equivalencia_cat ?caract u1|u2 ?num)`
 : representa la transformación de variables numéricas a categóricas, donde se indica según los umbrales si el valor debe ser considerado bajo (menor que `u1`), medio (entre `u1` y `u2`) ó alto (mayor que `u2`).

`(equivalencia_area ?area ?texto)`
 : representa una pequeña descripción de los códigos de áreas de conocimiento considerados: IA (Inteligencia artificial), BD (Bases de datos), DS (Desarrollo de Software), RS (Redes), IT (Informática Teórica), WB (Tecnologías Web) y HW (Hardware).

`(Asignatura_fav ?asig)`
 : representa una asignatura que se recomienda siempre.

`(Explicacion_fav ?asig)`
 : explicación de por qué la asignatura se recomienda siempre.

`(variable ?caract ?defecto)`
 : sirve una doble función: por un lado nos permite tener un listado de todas las características de los estudiantes consideradas útiles para la elección de asignaturas, y por otro sirve para darles un valor por defecto. Las características consideradas son la nota media (`nota`), las horas diarias que se dedican al estudio (`horas`), las áreas de conocimiento en las que se tiene interés (`areas`), la capacidad de trabajo (`capacidad`), el gusto por la programación (`programacion`) y el interés en las aplicaciones pŕacticas (`practicas`).

`(asignatura (id ?id) (nombre ?nombre) (curso ?curso) (?caract1 ?valor1)`
  : $\ $

`... (?caractN ?valorN))`
 : representa una asignatura del Grado de la que se tiene información, de acuerdo a la plantilla comentada al principio. En concreto, se guarda información del identificador, el nombre y el curso al que pertenece, y después vienen un total de 6 características que describen la asignatura: la dificultad, la carga de trabajo, si es práctica o teórica, el nivel de programación que hay, si está relacionada con el hardware, y las áreas de conocimiento de la informática con las que más se identifica. En total tenemos almacenadas 20 asignaturas, 4 de cada una de las 5 ramas, repartida en 10 de tercer curso y 10 de cuarto curso. Fácilmente podrían añadirse más asignaturas de otros cursos rellenando hechos como estos.

`(regla ?num antecedentes ?c1 ?v1 ... ?cN ?vN)`
  : parte esencial del método de razonamiento. Representa los antecedentes de la regla `?num`-ésima, en forma de parejas característica-valor.

`(regla ?num 1|-1 consecuentes ?c1 ?v1 ... ?vM)`
  : representa los consecuentes de una regla, en forma de la caracteristica afectada y los valores a los que afecta. Se especifica además si lo hace de forma positiva (`1`) ó negativa (`-1`).

`(regla ?num explicacion ?expl)`
 : contiene la explicación de cada regla, mostrando de qué forma los antecedentes están relacionados con los consecuentes.

## Especificación de los módulos

En total existen **7 módulos** en el sistema: 3 para el subsistema RR y 4 para el subsistema RA. En cada subsistema, cada uno de los módulos tiene una función concreta a realizar, que se puede considerar equivalente al correspondiente módulo en el otro subsistema (en el subsistema RA hay un módulo extra que representa un submenú). Tras el procedimiento de encapsulación seguido se resume el funcionamiento en tres pasos: *obtener información*, *razonar* y *recomendar*. Al inicio de cada subsistema se activa el módulo correspondiente a la obtención de información (pasando primero por el menú en el caso de RA), cuando se concluye se avanza al razonamiento, y cuando este termina se llega finalmente al módulo destinado a aconsejar.

### Módulo PREGUNTAR_RECOMENDAR_RAMA {.unlisted .unnumbered}

Se trata del primer módulo del subsistema RR, al que se accede cuando el usuario indica desde el menú principal que quiere activar este subsistema.

- **Objetivo**: realizar una serie de preguntas al usuario para obtener información sobre las características que se consideran relevantes a la hora de elegir rama.
- **Conocimiento que se utiliza**: además del conocimiento global del subsistema, se utilizan hechos temporales para controlar si debemos seguir haciendo preguntas.
- **Conocimiento que se deduce**: se deducen las respuestas del usuario a las preguntas que haya decidido contestar, diferenciando las que son numéricas y las que son categóricas. Se materaliza con los hechos `(Respuesta_num ...)` y `(Evaluacion ...)`, respectivamente.

### Módulo RAZONAR_RECOMENDAR_RAMA {.unlisted .unnumbered}

Segundo módulo del subsistema RR, al que se accede cuando finaliza el primero (concluyen las preguntas).

- **Objetivo**: obtener una manera de ordenar las ramas de forma que se adecúe a los criterios del experto, según las respuestas del usuario. Se quiere mantener también una recopilación de los motivos por los que se avanza en el ranking.

- **Conocimiento que utiliza**: utiliza la salida del módulo anterior, es decir, las evaluaciones numéricas y categóricas de las respuestas, junto al conocimiento global de las contribuciones de cada característica a cada rama. Además, se obtienen las correspondientes evaluaciones duales (numérica-categórica) atendiendo a la siguiente regla:
  * Bajo: entre 0 y 5.
  * Medio: entre 5 y 8.
  * Alto: entre 8 y 10.
  * Si: 10.
  * No: 0.

  Se calculan para cada rama las contribuciones totales y los motivos y justificaciones de estas contribuciones. Se utilizan de nuevo hechos temporales para ir sumando puntos, agregando motivos y no repetir razonamientos.

- **Conocimiento que deduce**: Los hechos `(Puntuacion ?rama ?n)` que reflejan la preferencia de cada rama para ser escogida (a mayor puntuación, mayor preferencia). También los hechos `(Motivo ?rama ?motivo)` indicando los motivos de recomendación de cada rama.

### Módulo ACONSEJAR_RECOMENDAR_RAMA {.unlisted .unnumbered}

Tercer y último módulo del subsistema RR, activado cuando finaliza el módulo de razonamiento.

- **Objetivo:** recomendar por pantalla al usuario las ramas que según el sistema se ajustan más a sus intereses, exponiendo los motivos.
- **Conocimiento que utiliza**: los hechos deducidos por el subsistema anterior, y la información introducida al principio por el usuario sobre si quería ver la lista completa de motivos o solo los más relevantes. Utiliza hechos temporales del tipo `(Consejo_preliminar ?rama)` para tratar las ramas con mayor puntuación y añadirlas junto a sus motivos en un único hecho final.
- **Conocimiento que deduce**: Hechos del tipo `(Consejo ?rama ?motivo ?experto)`, que simbolizan las recomendaciones definitivas de rama.

### Módulo MENU_RECOMENDAR_ASIG {.unlisted .unnumbered}

Representa un menú inicial en el subsistema RA, al que se accede cuando el usuario así lo indica desde el menú principal.

- **Objetivo:** Permitir al usuario elegir entre tres opciones: mostrar asignaturas, comenzar recomendación o volver.
- **Conocimiento que se utiliza**: La información que introduzca el usuario sobre la elección en el menú. Además, se utiliza un hecho `(Limpia_temp)` para borrar todos los hechos de una posible ejecución previa antes de iniciar una nueva.
- **Conocimiento que se deduce:** cuando se finaliza el módulo, se sabe que el usuario quiere comenzar el proceso de recomendación de asignaturas.

### Módulo PREGUNTAR_RECOMENDAR_ASIG {.unlisted .unnumbered}

Segundo módulo del subsistema RA, al que se accede cuando el usuario así lo indica desde el menú del subsistema.

- **Objetivo**: realizar una serie de preguntas al usuario para obtener información sobre las características que se consideran relevantes a la hora de elegir asignaturas. También se realizan inicialmente preguntas sobre la lista de asignatruas de entre las que elegir, el número de créditos a matricular y el número de asignaturas en el caso de que se elija la segunda opción. Además, se transforman las respuestas numéricas a categóricas directamente, ya que no se van a utilizar en su forma numérica.
- **Conocimiento que se utiliza**: además del conocimiento global del subsistema, se utilizan hechos temporales para controlar si debemos seguir haciendo preguntas.
- **Conocimiento que se deduce**: se deducen las respuestas del usuario a las preguntas que haya decidido contestar, y se añaden los valores por defecto a aquellas que no hayan sido contestadas (se muestra un mensaje cuando se presente esta situación). Se materializa con hechos de tipo `(dato ?caract segura|por_defecto ?valor)`.

### Módulo RAZONAR_RECOMENDAR_ASIG {.unlisted .unnumbered}

Tercer módulo del subsistema RA, al que se accede cuando finaliza el primero (concluyen las preguntas).

- **Objetivo**: obtener una manera de ordenar las asignaturas de forma que se adecúe a los criterios del experto, según las respuestas del usuario. Se quiere mantener también una recopilación de los motivos por los que se avanza en el ranking, tanto positivos como negativos.
- **Conocimiento que utiliza**: utiliza la salida del módulo anterior, es decir, las categóricas de las respuestas, junto al conocimiento global de las reglas de tipo SI-ENTONCES que ligan cada característica a cada asignatura.
Se calcula para cada asignatura las contribuciones totales y los motivos y justificaciones de estas contribuciones. Se utilizan de nuevo hechos temporales para ir sumando puntos, agregando motivos y no repetir razonamientos.
- **Conocimiento que deduce**: El hecho `(AsigRecomendadas $?lasig)` contiene la lista de asignaturas recomendadas en orden de preferencia, el hecho `(CreditosRecomendados ?c)` el número de créditos correspondientes a las asignaturas recomendadas, y los hechos `(explicacion-positiva ?id ?expl segura|por_defecto)` y `(explicacion-negativa ?id ?expl segura|por_defecto)` contienen las explicaciones a favor o en contra de cada asignatura, según las reglas evaluadas.

### Módulo ACONSEJAR_RECOMENDAR_ASIG {.unlisted .unnumbered}

Cuarto y último módulo del subsistema RA, activado cuando finaliza el módulo de razonamiento.

- **Objetivo:** recomendar por pantalla al usuario las asignaturas que según el sistema se ajustan más a sus intereses, exponiendo los motivos. Opcionalmente se exponen las asignaturas que no han sido recomendadas y los motivos por los cuales no lo han sido.
- **Conocimiento que utiliza**: los hechos deducidos por el subsistema anterior, y la información introducida por el usuario sobre si quiere ver la lista de descartes y los motivos asociados. También emplea los hechos iniciales sobre la lista de asignaturas y el número de créditos a matricular
- **Conocimiento que deduce**: Se puede considerar como salida de este módulo las deducciones del módulo anterior en cuanto a recomendaciones. Además, se deducen hechos del tipo `(motivos-pos ?id ?experto ?mot)` y `(motivos-neg ?id ?experto ?mot)` con la lista completa de motivos en cada caso.

## Hechos y reglas

Mostramos ahora un recuento de todos los hechos y reglas del sistema, divididos por módulos (los hechos saldrán repetidos una vez por cada módulo que los utilice). Se añade además la primera vez que se mencionen una pequeña descripción de aquellos **que no hayan sido comentados ya en alguno de los apartados anteriores**.

Las reglas del subsistema RR comienzan siempre con `r_`, las del subsistema RA con `a_`, y los hechos siempre se escriben con paréntesis.

### MAIN {.unlisted .unnumbered}

`Resetear`
 : deja el sistema en su estado inicial, solo con el conocimiento global.

`(Resetear)`
  : hecho que indica que se debe resetear el sistema.

`(Preguntar_inicial)`
 : $\ $

`Preguntar_menu_principal`
 : mostrar el menú principal.

`(OpcionElegidaMenu)`
 : $\ $

`Opcion_no_valida_menu_principal`
 : cuando la opción introducida no sea válida se vuelve a mostrar el menú.

`Modulo_recomendar_rama`
  : activa el subsistema recomendador de rama.

`Modulo_recomendar_asig`
  : activa el subsistema recomendador de asignaturas.

### PREGUNTAR_RECOMENDAR_RAMA {.unlisted .unnumbered}

`r_Abreviado_resto_num_masc`
 : incluye las abreviaciones que faltan para las variables numéricas en masculino.

`r_Abreviado_resto_num_fem`
 : incluye las abreviaciones que faltan para las variables numéricas en femenino.

`r_Abreviado_resto_cat`
 : incluye las abreviaciones que faltan para las variables categóricas, en género neutro.

`(Evaluacion ?caract ?valor)`
  : $\ $

`(Abreviado ?caract ?tipo ?abr)`
 : $\ $

`r_Mensaje_bienvenida`
 : muestra un mensaje de bienvenida.

`r_Modo_verbose`
 : Pregunta si quiere verse toda la exposición de motivos o solo los más relevantes.

`(Modo_completo S|N)`
 : $\ $

`r_Parar_num`
 : regla para detectar si a alguna pregunta numérica se ha contestado '-1' y se debe parar.

`r_Parar_cat`
  : regla para detectar si a alguna pregunta categórica se ha contestado 'X' y se debe parar.

`(Parar)`
 : indica que debemos parar de hacer preguntas.

`(Respuesta_num ?caract ?x)`
  : $\ $

`r_Pregunta_i`
 : ($i=1,\dots,8$) realizan una pregunta por cada una de las características que se consideran, tanto numéricas como categóricas.

`r_Avanzar_modulo_razonamiento`
 : avanza al siguiente módulo.

### RAZONAR_RECOMENDAR_RAMA {.unlisted .unnumbered}

`(Evaluacion ?caract ?valor)`
  : $\ $

`(Respuesta_num ?caract ?x)`
  : $\ $

`(Modo_completo S|N)`
 : $\ $

`r_Transforma_futuro_TIPO`
 : (TIPO = docencia, publica, empresa) transforman a números la respuesta sobre dónde se quiere trabajar en el futuro. En concreto, se asigna 10 a la respuesta dada y 0 a las demás opciones.

`r_Transforma_S`
 : transforma a numéricas las respuestas categóricas con respuesta afirmativa (10 puntos).

`r_Transforma_N`
 : transforma a numéricas las respuestas categóricas con respuesta negativa (0 puntos).

`r_Evalua_TIPO`
 : (TIPO = bajo, medio, alto) convierte las preguntas numéricas a categóricas.

`r_Sumar_puntos_futuro_directo`
 : Suma los puntos por las contribuciones directas de la característica 'futuro', que se trata por separado porque tiene tres posibles respuestas.

`r_Sumar_puntos_futuro_inverso`
 : Suma los puntos de contribuciones inversas de 'futuro'.

`r_Sumar_puntos_resto_directo`
 : Suma los puntos por contribuciones directas del resto de características.

`r_Sumar_puntos_resto_inverso`
 : Suma los puntos por contribuciones inversas del resto de características.

`(Contribuye ?caract ?rama ?factor)`
 : $\ $

`(Contribuye_inv ?caract ?rama ?factor)`
 : $\ $

`(Puntuacion ?rama ?n)`
 : $\ $

`(Sumado ?caract ?rama)`
 : indica si ya se ha sumado la eventual contribución de una característica a una rama.

`(Agregar_motivo ?caract ?rama ?puntos)`
 : indica que se debe agregar un motivo a una rama, por una característica concreta y un peso determinado.

`(Equivalencia_texto ?cosa ?texto)`
  : $\ $

`r_Agregar_motivo_poco_importante`
  : agrega un motivo poco importante a la lista de motivos de una rama, si estamos en el modo completo.

`r_Agregar_motivo_neutral`
  : agrega un motivo neutral.

`r_Agregar_motivo_importante`
 : agrega un motivo importante.

`(Agregado ?cosa ?rama)`
 : indica que se ha agregado el motivo correspondiente a una característica a una rama.

`(Motivo ?rama ?expl)`
 : $\ $

`r_Avanzar_modulo_aconsejar`
 : avanza al siguiente módulo.

### ACONSEJAR_RECOMENDAR_RAMA {.unlisted .unnumbered}

`(Puntuacion ?rama ?n)`
 : $\ $

`r_Max_puntuacion`
 : calcula la rama o ramas con mayor puntuación.

`(Consejo_preliminar ?rama)`
 : $\ $

`r_Aconsejar_RAMA_automatico`
 : (RAMA = CSI, IC, IS, TI, SI) integra los motivos en una rama con puntuación maximal para producir un consejo definitivo.

`r_Aconsejar_RAMA_automatico`
 : (RAMA = CSI, IC, IS, TI, SI) integra los motivos en una rama para producir un consejo definitivo, en base a consejos manuales e independientes de los puntos.

`(Motivo ?rama ?motivo)`
 : $\ $

`(Evaluacion ?caract ?valor)`
  : $\ $

`r_Agregar_motivo_poco_importante_2`
 : si en una rama no hay motivos de relevancia media-alta, añadir los de relevancia baja ignorando el valor de `(Modo_completo)`.

`(Consejo ?rama ?motivo ?experto)`
 : $\ $

`(Equivalencia_texto ?cosa ?texto)`
 : $\ $

`(Agregar_motivo ?cosa ?rama ?puntos)`
 : $\ $

`(Agregado ?cosa ?rama)`
 : $\ $

`(Abreviado ?cosa ?eval_abreviado ?eval)`
 : $\ $

`r_Aviso_parcial`
 : avisa si no se ha contestado a todas las preguntas que la recomendación puede no ser la más refinada.

`(Parar)`
 : $\ $

`r_Interpretacion`
 : muestra un mensaje aclaratorio para facilitar la interpretación de la salida.

`r_Aconsejar_rama`
 : muestra los consejos de rama.

`(Nombre_rama ?rama ?nombre)`
 : $\ $

`(Descripcion ?rama ?desc)`
 : $\ $

`r_No_recomendar`
 : regla que se activa cuando no hay información suficiente para dar ningún consejo.

`(Resetear)`
 : $\ $

`r_Volver_menu_principal`
 : volver al menú principal.

### MENU_RECOMENDAR_ASIG {.unlisted .unnumbered}

`a_Activar_pregunta`
 : activar el submenú

`(Preguntar)`
 : $\ $

`a_Preguntar`
 : muestra las opciones del menú

`(OpcionElegida ?r)`
  : $\ $

`a_Opcion_no_valida`
 : si la opción no es válida repite la pregunta.

`(Opciones a b c)`
  : opciones permitidas.

`a_Volver_menu_principal`
 : vuelve al menú principal

`(Resetear)`
 : $\ $

`a_Muestra_asig`
 : muestra la lista de asignaturas.

`(Limpia_temp)`
 : $\ $

`a_Limpia_previo`
 : indica que hay que limpiar la información de una posible ejecución previa.

`a_Limpia_temp`
 : realiza la limpieza de hechos propiamente dicha.

`a_Avanza_preguntas`
 : avanza al siguiente módulo.

### PREGUNTAR_RECOMENDAR_ASIG {.unlisted .unnumbered}

`a_Pregunta_lista_asig`
 : pregunta la lista de asignaturas.

`(ListaAsig $?lasig)`
 : $\ $

`a_Pregunta_cred`
 : preguntar créditos a matricular.

`(Creditos ?c)`
 : $\ $

`a_Pregunta_curso`
 : pregunta el curso al que va el estudiante.

`(Curso ?c)`
 : $\ $

`a_Mensaje_bienvenida`
 : muestra un mensaje de bienvenida.

`a_Respuestas_por_defecto`
 : establece las respuestas por defecto.

`(variable ?cosa $?defecto)`
 : $\ $

`(dato ?cosa $?)`
 : $\ $

`(dato_num ?cosa ?n)`
 : $\ $

`a_Parar_num`
 : establece que se ha contestado '-1' a una pregunta numérica y debemos parar.

`a_Parar_cat`
 : establece que se ha contestado 'X' a una pregunta categórica y debemos parar.

`(Parar)`
 : indica que debemos parar e ignorar la última respuesta.

`(Parar_preguntas)`
 : indica que no debemos seguir preguntando.

`a_Pregunta_i`
 : ($i=1,\dots,6$) realiza las preguntas correspondientes a las características de interés.

`a_Evalua_TIPO`
 : (TIPO = bajo, medio, alto) convierte respuestas numéricas a categóricas según los umbrales establecidos.

`(equivalencia_cat ?cosa u1|u2 ?x)`
 : $\ $

`a_Mensaje_por_defecto`
 : muestra las características para las que finalmente se asumen valores por defecto.

`(Mensaje_mostrado ?caract)`
 : controla si ya se ha mostrado el mensaje informativo sobre el valor por defecto para una cierta característica.

`a_Avanzar_razonador`
 : avanza al siguiente módulo.

### RAZONAR_RECOMENDAR_ASIG {.unlisted .unnumbered}

`(ListaAsig $?lasig)`
 : $\ $

`(Curso ?c)`
 : $\ $

`(CreditosRecomendados ?c)`
 : $\ $

`(AsigRecomendadas $?lrec)`
 : $\ $

`(RecomendarCurso menor_igual|cualquiera)`
 : controla si se priorizan las asignaturas de cursos menores o iguales al del estudiante.

`(Puntos ?id ?n)`
  : puntos de cada asignatura.

`(motivos-pos ?id ?experto ?mot)`
 : $\ $

`(motivos-neg ?id ?experto ?mot)`
 : $\ $

`(explicacion-positiva ?id ?expl ?defecto)`
 : motivos positivos para una asignatura, posiblemente gracias a información por defecto.

`(explicacion-negativa ?id ?expl ?defecto)`
 : motivos negativos para una asignatura, posiblemente gracias a información por defecto.

`a_Inicializar`
 : inicializa información para el razonamiento, tales como puntos, motivos o lista de recomendadas, entre otros.

`a_Retractar_curso_por_defecto`
 : retracta el comportamiento por defecto sobre los cursos si se cumplen unas condiciones.

`a_Retractar_curso_por_defecto_motivos`
 : si se ha retractado el comportamiento por defecto sobre los cursos, elimina también los motivos por defecto.

`a_Retractar_curso_por_defecto_puntos`
 : si se ha retractado el comportamiento por defecto sobre los cursos, elimina también los puntos por defecto.

`a_Procesar_antecedentes`
 : encuentra los antecedentes de todas las reglas y los marca para comprobarlos.

`(regla ?num antecedentes $?ant)`
 : $\ $

`(seguridad ?num segura|por_defecto)`
  : indica si la regla se ha aplicado utilizando alguna información por defecto o no.

`(Procesar_consecuentes ?num)`
 : indica que se deben procesar los consecuentes de una regla.

`(check-antecedente ?num ?c ?v)`
 : indica que se debe comprobar si se verifica que el valor de una característica `?c` es `?v`.

`a_Check-antecedentes`
 : comprueba si se cumplen unos antecedentes.

`(dato ?cosa $?)`
 : $\ $

`a_Procesar_consecuentes`
 : añade explicación y puntuación para aquellas asignaturas para las que se cumplan los antecedentes; para ello utiliza la información de los consecuentes.

`(contar ?id ?s $?)`
 : indica que se debe contabilizar un valor `?s` para la asignatura `?id`. Se pueden indicar los motivos en el hecho, aunque se cuentan por otro lado.

`a_Contar_puntos_area`
 : contabiliza los puntos por las áreas de conocimiento, que se miden de forma independiente a las reglas.

`a_Contar_puntos`
 : contabilizar los puntos por cumplimiento de reglas.

`a_Puntos_asignatura_favorita`
 : contabilizar los puntos de las asignaturas favoritas.

`(Contada_fav ?id)`
  : indica que ya se ha contabilizado una asignatura favorita concreta.

`(Asignatura_fav ?id)`
 : $\ $

`(Explicacion_fav ?id ?expl)`
 : $\ $

`a_Max_puntos`
 : ordena las asignaturas según los puntos obtenidos, y las mete en la lista de `AsigRecomendadas`. También actualiza el número de créditos recomendados.

`(Creditos ?c)`
 : $\ $

`a_Avanzar_recomendador`
 : avanza al último módulo.

### ACONSEJAR_RECOMENDAR_ASIG {.unlisted .unnumbered}

`a_Juntar_motivos_positivos`
 : concatena todos los motivos positivos de una asignatura en un único hecho.

`a_Juntar_motivos_negativos`
 : concatena todos los motivos negativos de una asignatura en un único hecho.

`(motivos-pos ?id ?experto ?mot)`
 : $\ $

`(motivos-neg ?id ?experto ?mot)`
 : $\ $

`(explicacion-positiva ?id ?expl ?defecto)`
 : $\ $

`(explicacion-negativa ?id ?expl ?defecto)`
 : $\ $

`a_Recomendar`
 : mostrar las recomendaciones de asignaturas.

`(Creditos ?c)`
 : $\ $

`(CreditosRecomendados ?c)`
 : $\ $

`(AsigRecomendadas $?lrec)`
 : $\ $

`a_Pregunta_mostrar_motivos_neg`
 : pregunta al usuario si quiere ver los motivos de rechazo del resto de asignaturas.

`(Mostrar_neg)`
 : indica que hay que mostrar los motivos negativos.

`(ListaAsig $?lasig)`
 : $\ $

`a_Mostrar_motivos_neg`
 : muestra por pantalla las asignaturas no recomendadas junto a los motivos negativos.

`a_No_neg`
 : indica que no había motivos negativos.

`(Preguntar)`
 : $\ $

`a_Volver_menu_recomendar`
 : vuelve al submenú del subsistema de recomendar asignatura.

# Manual de uso del sistema

Se proporciona un archivo `run.bat` para ejecutar el sistema, que simplemente carga los 5 archivos `.clp` que lo forman, resetea la memoria de trabajo y comienza la ejecución con `(run)`. Así, para ejecutar nuestro sistema experto invocamos simplemente la orden `clips -f run.bat`. Una vez iniciado, podemos elegir si queremos utilizar el recomendador de ramas o de asignaturas mediante un menú con opciones `a` y `b`, o salir del programa con la opción `c`.

Dentro del subsistema de recomendación de ramas, simplemente vamos contestando a las preguntas que se nos plantean utilizando los símbolos que se indican en cada caso, hasta finalizarlas todas o indicar con un `-1` (en las preguntas numéricas) o con una `X` (en las preguntas categóricas) que queremos parar. Una vez completado el razonamiento, se muestran por pantalla la(s) rama(s) recomendada(s) y los motivos. Escribiendo cualquier cosa volveremos al menú principal, limpiando los hechos generados.

Para el subsistema de recomendación de asignaturas el procedimiento es muy similar al ya descrito, con la diferencia de que al iniciarlo nos encontraremos con un segundo menú que nos permite visualizar la lista de asignaturas de las que hay información en la base de datos (opción `a`), iniciar el proceso de recomendación (opción `b`) ó volver al menú principal (opción `c`). Una vez iniciado el proceso de recomendación se plantearán tres preguntas obligatorias: los códigos de las asignaturas entre las que estamos dudando, el número de créditos que queremos matricular y el curso al que vamos. Posteriormente deberemos contestar a una serie de preguntas con las mismas consideraciones que en el otro subsistema, y finalmente veremos las recomendaciones y los motivos en pantalla. En este momento volvemos al menú propio de este subsistema, y si volvemos a elegir activar el proceso de recomendación, se limpian todos los hechos generados y se vuelve a empezar. Si decidimos volver al menú principal, también se limpian los hechos generados.


# Anexo I: funciones de manejo de hechos {.unnumbered}

Como en el desarrollo del sistema se han usado funciones de manejo de hechos que no forman parte del repertorio básico de CLIPS, se comentan brevemente a continuación. Es importante notar que los hechos que son de tipo *ordered facts* tienen internamente un *deftemplate* implícito con un único *multislot*, referido en CLIPS con la palabra clave `implied`.

### Funciones de búsqueda {.unlisted .unnumbered}

La función `fact-index` nos devuelve el índice de un hecho dentro de CLIPS. Con `find-fact` podemos buscar si existe un hecho de un *deftemplate* cumpliendo ciertas condiciones, obteniendo en su caso la dirección del mismo. La función `find-all-facts` realiza esto mismo pero devuelve todos los hechos que cumplan la condición.

### Funciones de bucles {.unlisted .unnumbered}

Se ha utilizado la función `do-for-all-facts`, que recorre todos los hechos del *template* indicado que verifiquen una condición, y para cada uno de ellos realiza una acción que le indiquemos. Su sintaxis básica es
```
(do-for-all-facts ((?t TEMPLATE)) COND ACTIONS)
```

También se usa la función `while`, con la que podemos realizar un clásico bucle mientras se cumpla alguna condición. Con `foreach` podemos recorrer los elementos de un *multifield* y realizar una acción para cada uno de ellos. Finalmente con `loop-for-count` imitamos el clásico bucle `for` con una variable que hace de índice.

### Funciones de manejo de elementos *multifield* {.unlisted .unnumbered}

Con `explode$` convertimos lo que nos devuelve la función `readline` en un *ordered fact*. Con `nth$` podemos acceder a la posición concreta de un vector, y devuelve `nil` si realizamos una acceso ilegal. Con `member$` podemos comprobar si un elemento forma parte de un *multifield*. Con `length$` obtenemos la longitud de un vector. Finalmente, con la función `fact-slot-value` podemos acceder a un *slot* concreto de un hecho. Si tenemos la dirección del hecho, digamos `?a`, un alias para hacer esto es usar el operador `:`, por ejemplo `?a:id`.

# Anexo II: ejemplos de ejecución {.unnumbered}

Se reproduce a continuación un ejemplo concreto de ejecución para cada subsistema.

### Subsistema RR {.unlisted .unnumbered}

```clips
Bienvenido al sistema de ayuda de eleccion de rama. Te hare una serie
de preguntas y te recomendare una(s) rama(s) como lo haria un estudiante.
Si a cualquier  pregunta numerica contestas '-1' o a cualquier pregunta
categorica contestas 'X', el sistema parara de hacer preguntas. Ademas,
en las preguntas numericas si contestas  un numero mayor que 10, es
equivalente a contestar 'no se'.

Quieres que en la exposicion de motivos salgan absolutamente todos los
factores que han influido? (si respondes que no, solo saldran los mas
relevantes) (S/N): N

Cual es tu grado de afinidad con las matematicas? (0-10): 2
Te gusta el hardware? (S/N/NS): S
Cual es tu grado de afinidad con la programacion? (0-10): 8
Cual es tu nota media? (5-10): 8.5
Eres trabajador? (S/N/NS): S
Te gustaria trabajar en (D)ocencia, en la administracion (P)ublica o en
una (E)mpresa privada? (D/P/E/NS): P
Te gustan las tecnologias web? (S/N/NS): S
Te interesa el funcionamiento de las bases de datos? (S/N/NS): S

Cuantos mas asteriscos haya delante de un motivo, mas importante ha sido
a la hora de hacer la recomendacion.

Recomendacion: Ingenieria de Computadores
---------------------------------------------
Descripcion de la rama: La rama del hardware por excelencia. Si quieres
huir de las matematicas y eres trabajador, las empresas lo valoraran
bastante.
Experto: Javier Saez
Motivos:
  *** Te gusta el hardware: si

Recomendacion: Sistemas de Informacion
---------------------------------------------
Descripcion de la rama: En esta rama se tocan temas tanto de programacion,
como de tecnologias web y de bases de datos. Un buen popurri que te
permitira preparar unas oposiciones para trabajar en la administracion.
Experto: Javier Saez
Motivos:
  ** Eres trabajador: si
  *** En el futuro quieres trabajar en: administracion publica
  ** Tu grado de interes por la programacion es alto
  *** Te interesan las bases de datos: si
  ** Te gustan las tecnologias web: si
```

### Subsistema RA {.unlisted .unnumbered}

```clips
Elige una de estas opciones:
  a] Ver lista de asignaturas disponibles en la BBDD y sus codigos
  b] Comenzar proceso de recomendacion de asignaturas
  c] Volver al menu principal
Opcion elegida: b

Escribe los codigos de las asignaturas posibles (separados por espacios):
SPSI VC IC SMP CPD TW NPI
Escribe los creditos totales a matricular: 18
Cuantos cursos llevas en la carrera? (0+): 3

Bienvenido al sistema de ayuda de eleccion de asignaturas. Te hare una
serie de preguntas y te recomendare unas asignaturas como lo haria un
estudiante. A las preguntas categoricas puedes contestar Bajo/a (B),
Medio/a (M), Alto/a (A) o No se (NS). Si a cualquier pregunta numerica
contestas '-1' o a cualquier pregunta categorica contestas 'X', el sistema
parara de hacer preguntas. Ademas, en las preguntas numericas si contestas
-2, es equivalente a contestar 'no se'.

Cual(es) de estas areas de la informatica te gusta(n) mas?
  - Inteligencia artificial (IA)
  - Bases de datos (BD)
  - Desarrollo de software (DS)
  - Redes (RS)
  - Informatica Teorica (IT)
  - Tecnologias web (WB)
  - Hardware (HW)
Respuesta (separadas por espacios): IA DS BD
Como calificarias tu capacidad de trabajo? (B/M/A/NS): B
Como calificarias tu gusto por la programacion? (B/M/A/NS): A
Como calificarias tu preferencia por las aplicaciones practicas frente
a las teoricas? (B/M/A/NS): A
Cual es tu nota media? (5-10): 6
Cuantas horas al dia aparte de las clases le sueles dedicar a la carrera?
(0-24): -2

!! Estoy asumiendo por defecto que el valor de 'horas' es: M

Numero de creditos que te recomiendo matricular: 18
Aqui esta la lista de asignaturas que te recomiendo, ordenada de forma que
conforme mas arriba este, mas fuerte es la recomendacion. Se indica con el
simbolo '+' cuando el motivo contenga informacion asumida por defecto.

Recomendacion: Tecnologias Web
---------------------------------------
Experto: Javier Saez
Curso: 3
Motivos:
  + Por defecto te recomiendo primero asignaturas de tu curso o menor
  * Es de dificultad baja, te la recomiendo porque tu capacidad de trabajo
    es baja
  * Tiene un contenido esencialmente practico, como me has indicado que
    prefieres
  * Tiene un contenido medio o alto en programacion, acorde a tu gusto por
    ella (alto)
  + Tiene una carga normal o baja, con las horas que le dedicas al estudio
    es suficiente para superarla

Recomendacion: Ingeniera del Conocimiento
---------------------------------------
Experto: Javier Saez
Curso: 3
Motivos:
  + Por defecto te recomiendo primero asignaturas de tu curso o menor
  * Es afin al area de conocimiento Inteligencia artificial, asi que creo
    que te gustaran los contenidos
  + Tiene una carga normal o baja, con las horas que le dedicas al estudio
    es suficiente para superarla
  * Es de dificultad baja, te la recomiendo porque tu capacidad de trabajo
    es baja

Recomendacion: Sistemas con Microprocesadores
---------------------------------------
Experto: Javier Saez
Curso: 3
Motivos:
  + Por defecto te recomiendo primero asignaturas de tu curso o menor
  + Tiene una carga normal o baja, con las horas que le dedicas al estudio
    es suficiente para superarla
  * Tiene un contenido esencialmente practico, como me has indicado que
    prefieres

Quieres ver los principales motivos por los que el resto de asignaturas
no han sido recomendadas? (S/N): S

Seguridad y Proteccion de los Sistemas Informaticos
---------------------------------------
Experto: Javier Saez
Curso: 4
Motivos de rechazo:
  + Esta asignatura es de un curso superior, y por defecto no te la
    recomiendo primero
  * Es de dificultad media o alta, por tu nota y tu capacidad bajas
    prefiero no recomendartela
  * Es teorica y me has dicho que prefieres mas bien cosas practicas

Vision por Computador
---------------------------------------
Experto: Javier Saez
Curso: 4
Motivos de rechazo:
  + Esta asignatura es de un curso superior, y por defecto no te la
    recomiendo primero
  * Es de dificultad media o alta, por tu nota y tu capacidad bajas
    prefiero no recomendartela
  * Es teorica y me has dicho que prefieres mas bien cosas practicas

Centros de Procesamiento de Datos
---------------------------------------
Experto: Javier Saez
Curso: 4
Motivos de rechazo:
  + Esta asignatura es de un curso superior, y por defecto no te la
    recomiendo primero

Nuevos Paradigmas de Interaccion
---------------------------------------
Experto: Javier Saez
Curso: 4
Motivos de rechazo:
  + Esta asignatura es de un curso superior, y por defecto no te la
    recomiendo primero
  * Es de dificultad media o alta, por tu nota y tu capacidad bajas
    prefiero no recomendartela
```
