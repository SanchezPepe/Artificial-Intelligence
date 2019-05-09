:- ensure_loaded(estaciones).
:-dynamic path/1.

path([]).

/**
 * Funciones auxiliares 
 **/

/**
 * Regla que permite calcular la norma euclidiana de dos estaciones, se 
 * proporcionan como parámetros las cordenadas X,Y de cada estación (latitud y longitud).
 **/
normaEuclidiana(X1, Y1, X2, Y2, N):-
    X is (X2-X1),
    Y is (Y2-Y1), 
    SUM is (X*X) + (Y*Y),
    N is 100*sqrt(SUM).

norma(Station1,Station2,Dist):-
    station(_,Station1,Cord1,Cord2,_,_),
    station(_,Station2,C1,C2,_,_),
    normaEuclidiana(Cord1,Cord2,C1,C2,Dist),!.

numStations(System, Line, Count):-
    aggregate_all(count, station(System,_,_,_,Line,_), Count).

adyacentStations(System, Station, Line, Stations):-
    station(System, Station, _, _, Line, Index),
    L is Index-1,
    R is Index+1,
    numStations(System, Line, Count),
    (L > 0 -> station(System,Left,_,_,Line, L) ; Left is 0),
    (R =< Count -> station(System,Right,_,_,Line, R) ; Right is 0),
    Stations = [Left, Right], !.

% Regresa 1 si es a la derecha, 0 a la izq
checkDirection([H|[T]], Goal, Direction):-
    norma(H,Goal, Left),
    norma(T,Goal, Right),
    (Left < Right -> Direction is 0 ; Direction is 1).

checkConnections(Station, Conections):-
    findall([Line, System] ,station(System,Station,_,_,Line,_),Conections).

test:-
    adyacentStations(metro, pantitlan,9, D),
    write(D).











































































































































































/**
    newCase(input)
    Agrega un nuevo caso a la memoria de datos.
    La memoria de datos se guarda en un .txt llamado caseFile.txt
    Debe estar en la carpeta del proyecto.
    Recibe un parámetro de entrada que es una lista
    que contiene una ruta.
 **/
newCase(List) :-
    open('caseFile.txt', append, Stream),
    (write(Stream, List),
    write(Stream,"."),
    nl(Stream),
    !;
    true),
    close(Stream).

/**
    returnAllCases(output)
    Lee la memoria de casos y los regresa todos en una lista.
    Recibe un parámetro de salida que es una lista.
 **/
returnAllCases(List):-
  setup_call_cleanup(
    open('caseFile.txt', read, In),
    readInfo(In, List),
    close(In)).

/**
    readInfo(input,output)
    Lee un archivo y lo regresa como lista
 **/
readInfo(In, L):-
  read_term(In, H, []),
    (H == end_of_file ->  L = [];
      L = [H|T],
      readInfo(In,T)).

/*
    compatibleCase(input,input,output).
    Regresa una ruta en la cual estén contenidas las dos estaciones.

    i: Estación 1
    i: Estación 2
    o: Ruta
**/
compatibleCase(Station1,Station2,Case):-
       returnAllCases(CaseList),
       auxCompatibleCase(Station1,Station2,CaseList,Case).

/*
    auxCompatibleCase(input,input,input,output).
    Dadas dos estaciones verifica si en
    la estación actual es alguna de las dos
    estaciones dadas.
    input1: Estación 1
    input2: Estación 2
    input3: Ruta visitada
    output: Ruta
**/
auxCompatibleCase(_,_,[],[]).
auxCompatibleCase(Station1, Station2,[Current|Tail],Case):-
       (member(Station1,Current),member(Station2,Current) ->
       Case = Current);
       auxCompatibleCase(Station1,Station2,Tail,Case),!.

/*
    adaptCase(input,input,input,output).
    Acota el la ruta recibida, a las dos estaciones de entrada

    input1: Estación 1
    input2: Estación 2
    input3: Ruta
    o: Ruta que empiece en una estación y termine en la otra
**/
adaptCase(Station1,Station2,Caso,Res):-
       findCase(Station1,Station2,Caso,Res1),
       reverse(Res1,Res2),
       findCase(Station1,Station2,Res2,Res3),
       reverse(Res3,Res).

/*
    findCase(input,input,input,output).
    Busca un caso que tenga de inicio o fin alguna de las dos estaciones
    
    input1: Estación 1
    input2: Estación 2
    input3: Ruta
    output: Ruta que empiece en una estación y termine en la otra
**/
findCase(_,_,[],[]):-
    !.
findCase(Station1,_,[Station1|Tail],[Station1|Tail]):-
    !.
findCase(_,Station2,[Station2|Tail],[Station2|Tail]):-
    !.
findCase(Station1,Station2,[_|Tail],Res):-
    findCase(Station1,Station2,Tail,Res).

/* printList(input).
    Imprime el contenido de una lista.
**/
printList([]) :-!.
printList([Head|Tail]) :-
       write(Head),
       nl,
       printList(Tail).