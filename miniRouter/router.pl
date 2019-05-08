:- ensure_loaded(estaciones).
:-dynamic path/1.

path([]).

/**
 * Funciones auxiliares 
 **/

/**
 * Regla que permite calcular la norma euclidiana de dos estaciones, se proporcionan como parámetros las cordenadas
 * X,Y de cada estación (latitud y longitud).
 **/
normaEuclidiana(X1, Y1, X2, Y2, N):-
    X is (X2-X1),
    Y is (Y2-Y1), 
    SUM is (X*X) + (Y*Y),
    N is 100*sqrt(SUM).

norma(Est1,Est2,Dist):-
    station(_,Est1,Cord1,Cord2,_,_),
    station(_,Est2,C1,C2,_,_),
    normaEuclidiana(Cord1,Cord2,C1,C2,Dist),!.

numStations(System, Line, Count):-
    aggregate_all(count, station(System,_,_,_,Line,_), Count).

adyacentStations(System, Station, Line, Stations):-
    station(System, Station, _, _, Line, Index),
    L is Index-1,
    R is Index+1,
    station(System,Left,_,_,Line, L),
    station(System,Right,_,_,Line, R),
    Stations = [Left, Right], !.
adyacentStations(System, Station, Line, Stations):-
    station(System, Station, _, _, Line, Index),
    R is Index+1,
    station(System,Right,_,_,Line, R),
    Stations = [[], Right], !.
adyacentStations(System, Station, Line, Stations):-
    station(System, Station, _, _, Line, Index),
    L is Index-1,
    station(System,Left,_,_,Line, L),
    Stations = [Left,[]], !.

% Regresa 1 si es a la derecha, 0 a la izq
checkDirection([H|[T]], Goal, Direction):-
    norma(H,Goal, Left),
    norma(T,Goal, Right),
    (Left < Right -> Direction is 0 ; Direction is 1).


checkConnections(Station, Conections):-
    findall([Line, System] ,station(System,Station,_,_,Line,_),Conections).

test:-
    checkConnections(tacubaya, D),
    write(D).
