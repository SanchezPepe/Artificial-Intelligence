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
    posibles([[A|B]|_]),
    list_not_empty([[A|B]|_]),
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
    tiro.

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
 * 
 * */
decrementaListaAux(Index, Lista, Ret):-
    % Obtiene de la lista
    nth0(Index,Lista,Cant),
    % Quita de la lista
    nth1(Index,Lista, _, W),
    Dec is Cant-1,
    % Inserta en la lsita
    nth0(Index, Nva, Dec, W),
    append(Nva, [], Ret).

%LLAMADA INICIAL = alfabeta(origen, profundidad, -inf, +inf, max) 
abp([H|T], 0, _, _, _, Value):-
    length(desconocidas, X),
    pozo(Y),
    pesoNodo(X, Y, [H|T], Peso),
    Value is Peso.
% MAX
abp(Nodo, Prof, Alfa, Beta, 1, Peso):-
    ProfR is Prof-1,
    desconocidasCompatibles(Nodo, [D|T]),
    abp(D, ProfR, Alfa, Beta, 0, Peso2),
    Alfa is max(Alfa, Peso2),
    Alfa >= Beta,
    %poda(Beta)
    Peso is Alfa.
% MIN
abp(Nodo, Prof, Alfa, Beta, 0, Peso):-
    ProfR is Prof-1,
    ma(Mano),
    manoCompatible(Nodo, Mano, [Compat|T]),
    abp(Compat, ProfR, Alfa, Beta, 1, Peso2),
    Beta is min(Beta, Peso2),
    Alfa >= Beta,
    %poda(Alfa),
    Peso is Beta.

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
    rivalPaso(N, [H|T], NoTiene),
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

/**
 * Funciones Auxiliares
 * */
fichaCompatible(Tablero, [H|[T|_]]):-
    (member(H, Tablero) ; member(T, Tablero)).

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
manoCompatible(Tab, Mano, Compat):-
    fichasCompatibles(Tab, Mano, Compat), !.

desconocidasCompatibles(Tab, Desc):-
    desconocidas(X),
    fichasCompatibles(Tab, X, Desc), !.

max(X, Y, Z):-
    Z is max(X, Y).

min(X, Y, Z):-
    Z is min(X, Y).
