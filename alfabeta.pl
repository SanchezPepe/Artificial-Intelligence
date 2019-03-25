:- ensure_loaded(pepe).

n([7,7,7,7,7,7,7]).
% Para pruebas
ma([[5,2],[8,1], [4,2], [4,0], [1,4]]).
%manoCompatible([2,1], [[5,2],[8,1], [4,2], [4,0], [1,4]], C).
extremoDerecho(5).
extremoIzquierdo(2).

decrementaListaAux(Index, Lista, Ret):-
    % Obtiene de la lista
    nth0(Index,Lista,Cant),
    % Quita de la lista
    nth1(Index,Lista, _, W),
    Dec is Cant-1,
    % Inserta en la lsita
    nth0(Index, Nva, Dec, W),
    append(Nva, [], Ret).

desco([[3, 1],[3, 2]]).

tab([5,2]).
des([[3,2],[0,0],[6,2],[4,1]]).

pab:-
    abp([5,2], 2, -50, 50, 1, X),
    write(X).


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
    desco(X),
    fichasCompatibles(Tab, X, Desc), !.

max(X, Y, Z):-
    Z is max(X, Y).

min(X, Y, Z):-
    Z is min(X, Y).

