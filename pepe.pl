/**
Funciones a implementar:
    1.- Tirar ficha
    2.- Tirar ficha rival usar decremento para controlar núms
    3.- Función eurística (28-Tiradas-Mías= Fichas del Rival y pozo) 1/2
        a) Cuando el rival tome del pozo, guardar las fichas que no tiene
        b) Deshacerse lo más rápido posible de las mulas
        c) Mantener variada la mano de fichas
    4.- Alpha beta
**/

:-dynamic mano/1.
:-dynamic desconocidas/1.
:-dynamic noTiene/1. 
:-dynamic tablero/1.    
:-dynamic pozo/1.

desconocidas([[0, 0],
            [1, 0],[1, 1],
            [2, 0],[2, 1],[2, 2],
            [3, 0],[3, 1],[3, 2],[3, 3],
            [4, 0],[4, 1],[4, 2],[4, 3],[4, 4],
            [5, 0],[5, 1],[5, 2],[5, 3],[5, 4],[5, 5],
            [6, 0],[6, 1],[6, 2],[6, 3],[6, 4],[6, 5],[6, 6]]).

/*Al inicio de cada juego de 1v1, el pozo empieza en 14 fichas. */
numeros([7,7,7,7,7,7,7]).
pozo(14).  
tablero([]).
noTiene([]).
mano([]).

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
    retract(desconocidas(Ficha)),
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
    retract(desconocidas(Ficha)),
    Ficha==fin,!.

list_not_empty([_]).

ladoFicha([_|[T]], SIDE):-
    extremoDerecho(ED),
    write(ED), nl, 
    write(T == ED),
    SIDE is 0, !.
ladoFicha([H|_], SIDE):-
    extremoIzquierdo(EI),
    write(EI), nl, 
    write(H == EI),
    SIDE is 1, !.

tiro:-
    mano(X),
    retractall(posibles(_)),
    assert(posibles([])),
    movimientosPosibles(X), %Cuando esté la poda, aquí se llamará y nos regresará un elemento Y
    posibles([[A|B]|_]),
    ladoFicha([A|B], Z),
    list_not_empty([[A|B]|_]),
    write("------------------- "),write([A|B]),nl,
    delete(X,[A|B],M),
    retract(mano(X)),
    assert(mano(M)),
    actualizaExtremo([A|B],Z),
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
    retract(desconocidas(Ficha)),
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
    retract(desconocidas(Ficha)),
    write("¿De qué lado del tablero tiró el oponente? d/i"),nl,
    read(Lado),
    actualizaExtremo(Ficha, Lado),tiro.
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
    assert(noTiene(Z)),tiro.

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

/*
    Esta regla actualiza el extremo derecho del tablero.
*/
actED([A|ColaA]):-
    extremoDerecho(ED),
    (A==ED)->retractall(extremoDerecho(_)), sacaCola(ColaA,B),assert(extremoDerecho(B));
    retractall(extremoDerecho(_)),assert(extremoDerecho(A)).

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
    nth1(X,Y, _, W),
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

