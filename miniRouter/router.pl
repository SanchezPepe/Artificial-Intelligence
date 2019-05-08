:-ensure_loaded(estaciones).
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
    findall([System, Station, Line] ,station(System,Station,_,_,Line,_),Conections).

getChildNodes(Sys, Node, Line, Goal, Childs):-
    station(Sys, Node, _,_,Line,Ind),
    adyacentStations(Sys, Node, Line, Ad),
    checkDirection(Ad, Node, Goal, Line, Dir),
    I is Ind + Dir,
    station(Sys, Child, _,_,Line,I),  % Estación adyacente al nodo más cerana al Goal
    checkConnections(Node, Conections), % Estaciones de transbordo
    delete(Conections, [Sys, Node, Line], Con),
    ChildInSameLine = [Sys, Child, Line],
    append(Con, [ChildInSameLine], Childs), !.

nodeValue([Sys|[Node|[Line]]], Goal, Prev, List):-
    norma(Node, Goal, H),   % Valor heurístico
    norma(Node, Prev, G),   % Peso del nodo previo al actual
    F is G + H,
    List = [F,Sys, Node, Line].

getHead([H|_], Head):-
    Head = H.

getTail([_|T], Tail):-
    Tail is T.

% Añadir a cola de prioridades.
addToPriorityQueue(Elem, [], First):-
    First = [Elem], !.
addToPriorityQueue(Node, [Queue|Tail], Ans):-
    getHead(Node, Priority), % Prioridad del nodo a insertar
    getHead(Queue, HeadPriority),    % Prioridad del primer elemento de la cola
    Priority > HeadPriority,
    addToPriorityQueue(Node, Tail, Rest),
    append([Queue], Rest, Ans), !.
addToPriorityQueue(Node, Queue, Ans):-
    append([Node], Queue, Ans), !.

popPriorityQueue([Queue|T], Rest, Elem):-
    Rest = T, 
    Elem = Queue.

test:-
    %getChildNodes(metro,mixcoac,7, zapata, D),
    Queue = [],
    %writeln(Val),
    addToPriorityQueue([14,metro,auditorio,7], Queue, Res),
    %writeln(Val1),
    addToPriorityQueue([7,metro,auditorio,7], Res, Res2),    
    %writeln(Val2),
    addToPriorityQueue([1,metro,auditorio,7], Res2, Res3), writeln(Res3),
    % Pop
    popPriorityQueue(Res3, X, Y),
    writeln("Se quitó: "), writeln(Y),
    writeln("Quedó "), writeln(X),

    getChildNodes(metro, pantitlan, 9, mixcoac, C),
    writeln(C).
    
