:-dynamic numeros/1.
:-dynamic desconocidas/1.
:-dynamic mano/1.
:-dynamic turno/1.
:-dynamic noTiene/1. 
:-dynamic tablero/1.    
:-dynamic extremoDerecho/1.
:-dynamic extremoIzquierdo/1.
:-dynamic pozo/1.
:-dynamic posibles/1.

/**
 * INSTITUTO TECNOLÓGICO AUTÓNOMO DE MÉXICO
 * Inteligencia Artificial
 * Implementación de un juego de Dominó con Poda Alfa-Beta.
 * Diego Villalvazo - 155844
 * José Sánchez - 156190
 * Sebastián Aranda - 157465
 * */

pozo(14).  /*Al inicio de cada juego de 1v1, el pozo empieza en 14 fichas. */
tablero([]).
noTiene([]).
mano([]).
numeros([8,8,8,8,8,8,8]).
desconocidas([[0, 0],
            [1, 0],[1, 1],
            [2, 0],[2, 1],[2, 2],
            [3, 0],[3, 1],[3, 2],[3, 3],
            [4, 0],[4, 1],[4, 2],[4, 3],[4, 4],
            [5, 0],[5, 1],[5, 2],[5, 3],[5, 4],[5, 5],
            [6, 0],[6, 1],[6, 2],[6, 3],[6, 4],[6, 5],[6, 6]]).

/* 
    Para iniciar el juego se consulta "main.". Posteriormente, te pedirá las 7 fichas iniciales 
    y se tendrán que meter en el formato "[a,b].". Después de ingresar la séptima ficha, se tendrá
    que ingresar "fin.".
    Después le tendremos que indicar al programa quién tiene el primer movimiento por medio de "yo."
    o "el." En ambos casos, tenemos que ingresar cuál es la primera ficha del juego. 
*/
main:-
    inicio,
    mano(Z),
    delete(Z, fin, Y),
    retract(mano(Z)),
    assert(mano(Y)),
    write("¿Quién tiene el primer movimiento? yo/el"),nl,
    read(Resp),
    Resp==yo,
    write("¿Cuál es la primera ficha que tiro? "),nl,
    read(Ficha),
    mano(X),
    delete(X,Ficha,M),
    retract(mano(X)),
    assert(mano(M)),
    actualizaPrim(Ficha),
    sacaCola(Ficha,A),sacaCola2(Ficha,B),
    decrementa(A),decrementa(B),
    tiroOponente.
main:-
    primerTiroOponente.

/*
    En caso de que empieze el oponente, esta regla recibe la ficha y llama otra regla que actualiza los
    extremos del tablero. 
*/
primerTiroOponente:-    
    write("¿Qué ficha tiró el oponente?"),nl,
    read(Ficha),
    desconocidas(DESC),
    delete(DESC,Ficha,NUEVDESC),
    retract(desconocidas(DESC)),
    assert(desconocidas(NUEVDESC)),
    sacaCola(Ficha,A),sacaCola2(Ficha,B),
    decrementa(A),decrementa(B),
    actualizaPrim(Ficha),tiro,!.


/*
    Cuando se llama esta regla, se pone un punto de retroceso.
*/
repite.
repite:-
    repite.

/*
    Esta regla lee de la consola las 7 fichas iniciales y las ingresa a la lista guardada en el 
    hecho "mano". Igualmente, cada que lee una ficha la quita del hecho "desconocidas".
 */
inicio():-
    write("Ingresa las 7 fichas iniciales. "),nl,
    repite,
    read(Ficha), 
    mano(X),   
    append(X,[Ficha],Y),
    retract(mano(X)),
    assert(mano(Y)),
    desconocidas(DESC),
    delete(DESC,Ficha,NUEVDESC),
    retract(desconocidas(DESC)),
    assert(desconocidas(NUEVDESC)),
    Ficha==fin,!.

list_not_empty([_]).

ladoFicha(X, SIDE):-
    extremoDerecho(ED),
    member(ED,X),
    SIDE is 0,
    write("Se tiro del lado derecho. "),nl,!.
ladoFicha(_,SIDE):-
    SIDE is 1,
    write("Se tiro del lado izquierdo. "),nl,!.


tiro:-
    mano(X),
    retractall(posibles(_)),
    assert(posibles([])),
    movimientosPosibles(X), %Cuando esté la poda, aquí se llamará y nos regresará un elemento Y
    encuentraMov([A|B]),
    ladoFicha([A|B], Z),    
    write("------------------- "),write([A|B]),nl,
    delete(X,[A|B],M),
    retract(mano(X)),
    assert(mano(M)),
    actualizaExtremo([A|B],Z),
    sacaCola2([A|B],C),
    decrementa(A),decrementa(C),
    tiroOponente.
  
tiro:-
    roba.

/*
    Cuando no podeomos tirar ninguna ficha, se llama a "roba.". Primero, revisa si hay fichas en el pozo.
    En caso positivo, pide y lee una ficha y la ingresa a la mano, la quita de desconocidas y resta una
    unidad del pozo. 
*/
roba:-
   pozo(0),
   write("Pozo vacío, paso."),nl,
   tiroOponente.
roba:-
    write("Dame la ficha que robo. "),nl,
    read(Ficha), 
    mano(X),   
    append(X,[Ficha],Y),
    retract(mano(X)),
    assert(mano(Y)),
    desconocidas(DESC),
    delete(DESC,Ficha,NUEVDESC),
    retract(desconocidas(DESC)),
    assert(desconocidas(NUEVDESC)),
    pozo(P),
    A is P-1,
    retract(pozo(P)),
    assert(pozo(A)),
    tiro.
/*
    En las primeras 3 filas de la regla, le ingresamos al programa si el oponente tiró alguna ficha o no.
    En caso afirmativo, ingresamos por medio de la consola qué ficha tiró, de qué lado del tablero la tiró.
    Después, se llama a una regla que actualiza los extremos.
    En caso negativo (el oponente no tira ninguna ficha) ingresamos cuántas fichas robó del pozo y 
    actualizamos el número de fichas en el pozo. Finalmente, ingresamos los valores de los extremos el
    tablero a un hecho llamado "noTiene" para guardar cuáles son los valores que hacen pasar al oponente. 
*/
tiroOponente:-
    write("¿El oponente tiró alguna ficha? si/no"),nl,
    read(Resp),
    Resp==si,
    write("¿Qué ficha tiró el oponente?"),nl,
    read(Ficha),
    desconocidas(DESC),
    delete(DESC,Ficha,NUEVDESC),
    retract(desconocidas(DESC)),
    assert(desconocidas(NUEVDESC)),
    write("¿De qué lado del tablero tiró el oponente? d/i"),nl,
    read(Lado),
    actualizaExtremo(Ficha, Lado),
    sacaCola(Ficha,A),sacaCola2(Ficha,B),
    decrementa(A),decrementa(B),
    tiro.
tiroOponente:-    
    write("¿Cuántas fichas tomó del pozo? "),nl,
    read(Num),
    pozo(X),
    Y is X-Num,
    retract(pozo(X)),
    assert(pozo(Y)),        
    extremoDerecho(ValDer),
    extremoIzquierdo(ValIzq),
    noTiene(N),
    append(N, [ValIzq], S),
    append(S, [ValDer], Z),
    retract(noTiene(N)),
    assert(noTiene(Z)),
    pozo(0),
    tiro.
tiroOponente:-
    tiroOponente.

/*
    Esta regla se llama una vez al inicio del juego y se encarga de actualizar los extremos del tablero.
*/
actualizaPrim([A|ColaA]):-
     sacaCola(ColaA,B),assert(extremoDerecho(B)),
     assert(extremoIzquierdo(A)).

/*
    Esta regla se llama cada que alguien tira una ficha, y se encarga de actualizar los extremos del tablero.
*/
actualizaExtremo(Ficha, Lado):-
    (Lado=1) -> actEI(Ficha);
    actED(Ficha).

/*
    Esta regla te regresa la cola de una lista.
*/
sacaCola([A|_],B):-
    B is A.
sacaCola2([_|A],B):-
    B is A.

/*
    Esta regla actualiza el extremo derecho del tablero.
*/

actED([A|[ColaA]]):-
    extremoDerecho(ED),
    ED==A,
    retractall(extremoDerecho(_)),
    retractall(extremoDerecho(_)),
    assert(extremoDerecho(ColaA)),!.
actED([A|_]):-
    retractall(extremoDerecho(_)),
    retractall(extremoDerecho(_)),
    assert(extremoDerecho(A)),!.

test:-
    actED([6,1]),
    extremoDerecho(X),
write(X).

/*
    Esta regla actualiza el extremo izquierdo del tablero.
*/
actEI([A|ColaA]):-
    extremoIzquierdo(EI),
    (A==EI)->retractall(extremoIzquierdo(_)),sacaCola(ColaA,B),assert(extremoIzquierdo(B));
    retractall(extremoIzquierdo(_)),assert(extremoIzquierdo(A)).

/**
 * Regla que decrementa la lista que guarda cuántas fichas quedan de cada grupo, se utliza en la 
 * función eurística para dar información al sistema al momento de utlizar la función eurística.
 **/
decrementa(X):-
    numeros(Y),
    % Obtiene de la lista
    nth0(X,Y,Z),
    % Quita de la lista
    I is X+1,
    nth1(I,Y, _, W),
    A is Z-1,
    % Inserta en la lsita
    nth0(X, B, A, W),
    retract(numeros(Y)),
    assert(numeros(B)).

/**
 * Regla que busca las fichas posibles para tirar en cada jugada dependiendo del estado actual del tablero.
 * Regresa una sublista posibles([]) de la mano actual
 **/
movimientosPosibles([]).
movimientosPosibles([H|T]) :-
    extremoDerecho(Y),
    extremoIzquierdo(X),
    posibles(W),
    (member(X, H) ; member(Y,H)),
    append(W, [H], Z),
    retract(posibles(W)),
    assert(posibles(Z)),
    movimientosPosibles(T),!.
movimientosPosibles([_|T]):-
movimientosPosibles(T),!.

/**
 * Métodos para alfabeta pruning
 * */

/**
 * Hechos auxiliares para controlar si la llamada al alfa beta es MIN o MAX
 * **/
turno(1, 0).
turno(0, 1).

/**
 * Regla que implementa la búsqueda alfa beta con poda, recibe el turno del jugador
 * la profundidad deseada, la posición del juego (tablero), las cotas alfa y beta, una
 * ficha compatible y regresa el peso si es que llegó a la profundidad deseada.
 * **/
alfa_beta(Player,Profundidad,Posicion,Alpha,Beta,Ficha,Peso) :- 
    Profundidad > 0,
    compatibles(Player,Posicion,Movs),
    Alpha1 is -Beta,
    Beta1 is -Alpha,
    NuevaProf is Profundidad-1,
    evalua(Player,Movs,Posicion,NuevaProf,Alpha1,Beta1,nil,(Ficha,Peso)).
 alfa_beta(_Player,0,Ficha,_Alpha,_Beta,_SinMov, Peso) :- 
    desconocidas(Desc),
    length(Desc, NumDesc),
    pozo(P),  
    pesoNodo(NumDesc, P, Ficha, Peso).

/**
 * Regla que evalúa el turno de un jugador con sus fichas disponibles, realiza una llamada
 * recursiva a alfa beta para evaluar cada una de las fichas disponibles de la mano del jugador,
 * una vez obtenido el peso de cada nodo hoja, llama a la función poda que se encarga de evaluar.
 * **/
evalua(Jugador1,[Ficha|Resto],Posicion,Profundidad,Alpha,Beta,Record,Mejor) :-
   %compatibles(Jugador1, Ficha, [Movs|_]),
   turno(Jugador1,Jugador2),
   alfa_beta(Jugador2 ,Profundidad,Ficha,Alpha,Beta,_OtroMov,Peso),
   Peso1 is -Peso,
   poda(Jugador1,Ficha,Peso1,Profundidad,Alpha,Beta,Resto,Posicion,Record,Mejor).
evalua(_Player,[],_Posicion,_D,Alpha,_Beta,Move,(Move,Alpha)).


/**
 * Regla que evalúa el peso obtenido de cada nodo hoja con las cotas alfa y beta para decidir si
 * se detiene la ejecución (poda) e iniciar el retroceso, regresa la mejor ficha disponible.
 * **/
poda(_Jugador,Ficha,Peso,_Profundidad,_Alpha,Beta,_Resto,_Posicion,_Record,(Ficha,Peso)) :- 
   Peso >= Beta,!.
poda(Jugador,Ficha,Peso,Profundidad,Alpha,Beta,Resto,Posicion,_Record,Mejor) :- 
   Alpha < Peso,
   Peso < Beta,!,
   evalua(Jugador,Resto,Posicion,Profundidad,Peso,Beta,Ficha,Mejor).
poda(Jugador,_Ficha,Peso,Profundidad,Alpha,Beta,Resto,Posicion,Record,Mejor) :- 
   Peso =< Alpha,!,
   evalua(Jugador,Resto,Posicion,Profundidad,Alpha,Beta,Record,Mejor).

/**
 * Reglas que maneja la llamada al método de búsuqeda.
 * **/
encuentraMov(X):-
    extremoDerecho(D),
    extremoIzquierdo(I),
    Posicion = [I|D],
    mejorFicha(2, Posicion, -25, 25, X).

mejorFicha(Profundidad, Tablero, Alfa, Beta, (Ficha, Peso)):-
    alfa_beta(1, Profundidad, Tablero, Alfa, Beta, Ficha, (Ficha, Peso)).
mejorFicha(_, Tablero, _, _, Ficha):-
    compatibles(1, Tablero, Moves),
    length(Moves, L),
    random(0, L, I),
    nth0(I,Moves,Ficha), !.



/**
* Regla que asigna un peso a un nodo determinado dependiendo del estado actual del
* juego, para la determinación del peso se consideran las fichas que el sistema
* desconoce, el número de fichas en el pozo, cúantas fichas compatibles con el 
* tablero quedan todavía y las fichas que sabemos que el rival no tiene por que
* ha pasado.
* **/
pesoNodo(Desconocidas, NumPozo, [H|[T]], Peso):-
   noTiene(N),
   numeros(Nums),
   nth0(H,Nums,L1),
   nth0(T,Nums,L2),
   estimacion(Desconocidas, NumPozo, L1, E1),
   estimacion(Desconocidas, NumPozo, L2, E2),
   Estimacion is E1 + E2,
   Tab = [H|[T]],
   rivalPaso(N, Tab, NoTiene),
  Peso is Estimacion + NoTiene.

/**
* Regla que evalua si el rival no tiene un número (la lista 'noTiene' registra 
* cuando el rival toma del pozo o pasa)
* **/
rivalPaso(_,[], 0):- !.
rivalPaso(RivalPaso, [H|T], Ans):-
   member(H, RivalPaso),
   rivalPaso(RivalPaso, T, Resp),
   Ans is 2 + Resp, !.
rivalPaso(RivalPaso, [_|T], Ans):-
   rivalPaso(RivalPaso, T, Ans).

/* Regla que estima la posibilidad de que el rival no tenga un número determinado,
* recibe el número de fichas desconocidas totales. Utilizar para generar la estimación
* la lista que guarda cuantas fichas de cada grupo aún se desconocen.
*/
estimacion(Desconocidas, NumPozo, QuedanNum, Estimacion):-
  (NumPozo = 0) -> Estimacion is 0;
  (NumPozo \= 0) -> Estimacion is (1-(QuedanNum/Desconocidas)).

% Reglas Auxiliares

/**
* Reglas que compara dos fichas para comprobar si se puede utilizar en el tiro.
* */
fichaCompatible(Tablero, [H|[T|_]]):-
   (member(H, Tablero) ; member(T, Tablero)).

/**
* Regla que recibe el estado del tablero y un conjunto de fichas. Regresa una lista
* de fichas que se pueden tirar. Ya sea de la mano o de las desconocidas 
**/

fichasCompatibles(_,[],[]).
fichasCompatibles(Tablero, [H|T], X):-
   fichaCompatible(Tablero, H),
   fichasCompatibles(Tablero, T, Z),
   append([H], Z, X).
fichasCompatibles(Tablero,[_|T], X):-
   fichasCompatibles(Tablero, T, X). 

/**
* Fichas compatibles para una mano determinada
* **/
compatibles(0, Ficha, Moves):-
   desconocidas(X),
   fichasCompatibles(Ficha, X, Moves), !.
compatibles(1, Ficha, Moves):-
   mano(X),
   fichasCompatibles(Ficha, X, Moves), !.

max(X, Y, Z):-
   Z is max(X, Y).

min(X, Y, Z):-
   Z is min(X, Y).

