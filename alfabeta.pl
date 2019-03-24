:- ensure_loaded(pepe).

%LLAMADA INICIAL = alfabeta(origen, profundidad, -inf, +inf, max) 


% Caso en el que bajó hasta la profundidad deseada.
alfabeta(Nodo, 0, _, _, _, Peso):-
    pesoNodo(Nodo, Peso).
% MAX
alfabeta(Nodo, Prof, Alfa, Beta, 1, Peso):-
    posibles(X),
    ProfR is Prof-1,
    % PARA CADA HIJO DEL NODO
    alfabeta(Hijo, ProfR, Alfa, Beta, 0, Peso2),
    Alfa is max(Alfa, Peso2),
    Alfa =< Beta,
    poda(Beta),
    % PARA CADA HIJO DEL NODO
    Peso is Alfa.
% MIN
alfabeta(Nodo, Prof, Alfa, Beta, 0, Peso):-
    posibles(X),
    ProfR is Prof-1,
    % PARA CADA HIJO DEL NODO
    alfabeta(Hijo, ProfR, Alfa, Beta, 0, Peso2),
    Beta is min(Beta, Peso2),
    Beta =< Alfa,
    poda(Alfa),
    % PARA CADA HIJO DEL NODO
    Peso is Beta.

/**
 * Funciones Auxiliares
 * **/

manoCompatible(C):-
    mano(X),
    fichasCompatibles(X, C).

desconocidasCompatibles(D):-
    desconocidas(X),
    fichasCompatibles(X, D).

max(X, Y, Z):-
    Z is max(X, Y).

min(X, Y, Z):-
    Z is min(X, Y).

fichaCompatible([H|[T|_]]):-
    tablero(X),
    (member(H, X) ; member(T, X)).

fichasCompatibles([],[]).
fichasCompatibles([H|T], X):-
    fichaCompatible(H),
    fichasCompatibles(T, Z),
    append([H], Z, X).
fichasCompatibles([_|T], X):-
    fichasCompatibles(T, X). 

/**
 * Regla que asigna un peso a un nodo determinado dependiendo del estado actual del
 * juego, para la determinación del peso se consideran las fichas que el sistema
 * desconoce, el número de fichas en el pozo, cúantas fichas compatibles con el 
 * tablero quedan todavía y las fichas que sabemos que el rival no tiene por que
 * ha pasado.
 * **/
pesoNodo(Nodo, S):-
    numeros(Y), 
    extremoDerecho(ED), 
    extremoIzquierdo(EI),
    rivalPaso(ED, Y),
    rivalPaso(EI, Z),
    estimacion(Nodo, X),
	S is (2*X)+Y+Z.

/**
 * Regla que evalua si el rival no tiene un número (la lista 'noTiene' registra 
 * cuando el rival toma del pozo o pasa)
 * **/
rivalPaso(Num, Resp):-
    noTiene(X),
    member(Num, X) -> Resp is 2;
    Resp is 0.

/* Regla que estima la posibilidad de que el rival no tenga un número determinado,
 * recibe el número de fichas desconocidas totales. Utilizar para generar la estimación
 * la lista queg guarda cuantas fichas de cada grupo aún se desconocen.
 */
estimacion(Num, Est):-
    length(desconocidas, Desc),
    pozo(TamPozo),
    numeros(Y),
    nth0(Num, Y, X),
	(TamPozo = 0) -> Est is 0;
	(TamPozo \= 0) -> Est is (1-(X/Desc)).