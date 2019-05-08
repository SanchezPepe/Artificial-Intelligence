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



























































































































































































































































% escribe_a_archivo(i).
% Escribe en la base de
% casos una lista dada.
%
% i: Lista
escribe_a_archivo(L) :-
    open('caseFile.txt', append, Stream),
    ( write(Stream, L), write(Stream,"."), nl(Stream), !; true ),
    close(Stream).

% lee_casos(o).
% Lee la base de casos y regresa
% su contenido en una lista.
%
% o: Lista de rutas del metro
lee_casos(L):-
  setup_call_cleanup(
    open('caseFile.txt', read, In),
    lee_datos(In, L),
    close(In)
  ).
lee_datos(In, L):-
    read_term(In, H, []),
    (   H == end_of_file
    ->  L = []
    ;   L = [H|T],
        lee_datos(In,T)
    ).
  
  % imprime_casos().
  % Imprime los datos leidos de
  % lee_casos(o).
  % (Usar bajo su propio riesgo)
  imprime_casos():-
    lee_casos(L),
    imprime(L).
  
  % hay_caso(i,i,o).
  % Dadas dos estaciones verifica si en
  % la base de casos existe uno que
  % contenga una ruta o subruta entre ambas.
  %
  % i: Estación 1
  % i: Estación 2
  % o: Ruta (Vacía en caso de no existir)
  hay_caso(Estacion1,Estacion2,Caso):-
         lee_casos(ListaDeCasos),
         (caso_igual(Estacion1,Estacion2,ListaDeCasos,Caso)->!;aux_hay_caso(Estacion1,Estacion2,ListaDeCasos,Caso)).
/**
hay_caso(Estacion1,Estacion2,Caso):-
        lee_casos(ListaDeCasos),
        aux_hay_caso(Estacion1,Estacion2,ListaDeCasos,Caso).
    */

caso_igual(_,_,[],[]).
caso_igual(Estacion1,Estacion2,[[Start|RestoCasoActual]|CasosSobrantes],Caso):-
        reverse([Start|RestoCasoActual],[Goal|_]),
         ((Estacion1=:=Start,Estacion2=:=Goal) ->
         Caso = [Start|RestoCasoActual]);
         caso_igual(Estacion1, Estacion2,CasosSobrantes,Caso),
         !.
  
  % aux:hay_caso(i,i,i,o).
  % Dadas dos estaciones verifica si en
  % la estación actual es alguna de las dos
  % estaciones dadas.
  %
  % i: Estación 1
  % i: Estación 2
  % i: Ruta visitada
  % o: Ruta (Vacía en caso de no existir)
  aux_hay_caso(_,_,[],[]).
  aux_hay_caso(Estacion1, Estacion2,[CasoActual|CasosSobrantes],Caso):-
         (member(Estacion1,CasoActual),member(Estacion2,CasoActual) ->
         Caso = CasoActual);
         aux_hay_caso(Estacion1, Estacion2,CasosSobrantes,Caso),!.
  
  % limpia_caso(i,i,i,o).
  % Dadas dos estaciones y una ruta que
  % contenga ambas, acota dicha ruta para
  % que empiece en alguna de las estaciones
  % dadas y termina en la otra estación dada.
  %
  % i: Estación 1
  % i: Estación 2
  % i: Ruta que contenga ambas estaciones
  % o: Ruta que empiece en una estación y termine en la otra
  limpia_caso(Estacion1,Estacion2,Caso,Res):-
         encuentra_inicial(Estacion1,Estacion2,Caso,Res1),
         reverse(Res1,Res2),
         encuentra_inicial(Estacion1,Estacion2,Res2,Res).
  
  % encuentra_inicial(i,i,i,o).
  % Dadas dos estaciones y una ruta que
  % contenga ambas, verifica si la primera
  % estación es alguna de las dos dadas, en caso
  % de serlo, procede a buscar la otra.
  %
  % i: Estación 1
  % i: Estación 2
  % i: Ruta que contenga ambas estaciones
  % o: Ruta que empiece en una estación y termine en la otra
  encuentra_inicial(_,_,[],[]):-!.
  encuentra_inicial(Est1,_,[Est1|Resto],[Est1|Resto]):-!.
  encuentra_inicial(_,Est2,[Est2|Resto],[Est2|Resto]):-!.
  encuentra_inicial(Est1,Est2,[_|Resto],Res):-
         encuentra_inicial(Est1,Est2,Resto,Res).
  
  % imprime(i).
  % Imprime, línea a línea, el contenido
  % de una lista.
  %
  % i: Lista
  imprime([]) :-!.
  imprime([Cabeza|Resto]) :-
         write(Cabeza),
         nl,
         imprime(Resto).