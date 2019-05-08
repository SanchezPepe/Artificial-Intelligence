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
    (L > 0, R =< Count -> station(System,Left,_,_,Line, L), station(System,Right,_,_,Line, R), Stations = [Left, Right] 
    ; (L =:= 0 -> station(System,Right,_,_,Line, R), Stations = [Right] ; station(System,Left,_,_,Line, L), Stations = [Left])), !.

% Regresa 1 si es a la derecha/abajo, -1 a la izq/arriba
checkDirection([H|[T]],_,Goal,_, Direction):-
    norma(H,Goal, Left),
    norma(T,Goal, Right),
    (Left < Right -> Direction is -1 ; Direction is 1).
checkDirection([H|[]],Start, _,Line, Dir):- % Si es terminal o inicio de línea
    station(_,Start,_,_,Line,StartOrder),    
    station(_,H,_,_,Line,Order),
    Dif is StartOrder-Order,
    (Dif > 0 -> Dir is -1 ; Dir is 1).

checkConnections(Station, Conections):-
    findall([Station, Line, System] ,station(System,Station,_,_,Line,_),Conections).

getChildNodes(Sys, Node, Line, Goal, Childs):-
    station(Sys, Node, _,_,Line,Ind),
    adyacentStations(Sys, Node, Line, Ad),
    checkDirection(Ad, Node, Goal, Line, Dir),
    I is Ind + Dir,
    station(Sys, Child, _,_,Line,I),  % Estación adyacente al nodo más cerana al Goal
    checkConnections(Node, Conections), % Estaciones de transbordo
    ChildInSameLine = [Child, Line, Sys],
    append(Conections, [ChildInSameLine], Childs), !.
    
test:-
    getChildNodes(metro,el_rosario,7, zapata, D),
    write(D).

priority-queue :-
    TL0 = [3-'Clear drains',
           4-'Feed cat'],
   
    % we can create a priority queue from a list
    list_to_heap(TL0, Heap0),
   
    % alternatively we can start from an empty queue
    % get from empty_heap/1.
   
    % now we add the other elements
    add_to_heap(Heap0, 5, 'Make tea', Heap1),
    add_to_heap(Heap1, 1, 'Solve RC tasks', Heap2),
    add_to_heap(Heap2, 2, 'Tax return', Heap3),
   
    % we list the content of the heap:
    heap_to_list(Heap3, TL1),
    writeln('Content of the queue'), maplist(writeln, TL1),
    nl,
   
    % now we retrieve the minimum-priority pair
    get_from_heap(Heap3, Priority, Key, Heap4),
    format('Retrieve top of the queue : Priority ~w, Element ~w~n', [Priority, Key]),
    nl,
   
    % we list the content of the heap:
    heap_to_list(Heap4, TL2),
    writeln('Content of the queue'), maplist(writeln, TL2).
