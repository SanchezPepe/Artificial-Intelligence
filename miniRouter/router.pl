:-ensure_loaded(metro).

/**
 * Funciones auxiliares 
 **/

/**
 * Regla que permite calcular la norma euclidiana de dos estaciones, se 
 * proporcionan como parámetros las cordenadas X,Y de cada estación (latitud y longitud).
 **/
normaEuclidiana(X1, Y1, X2, Y2, Norm):-
    X is (X2-X1),
    Y is (Y2-Y1), 
    SUM is (X*X) + (Y*Y),
    N is 100*sqrt(SUM),
    round(N, 2, Norm).

norma(Est1,Est2,Dist):-
    station(_,Est1,Cord1,Cord2,_,_),
    station(_,Est2,C1,C2,_,_),
    normaEuclidiana(Cord1,Cord2,C1,C2,Dist),!.

getHead([H|_], Head):-
    Head = H.

getTail([_|T], Tail):-
    Tail = T.

getLast(List, Last):-
    reverse(List, Rev),
    getHead(Rev, Last).

round(X,D,Ans):- 
    Z is X * 10^D, 
    round(Z, ZA), 
    Ans is ZA / 10^D.

getG(Node, Ans):-
    getHead(Node, Values),
    getHead(Values, Ans).

getH(Node, Ans):-
    getHead(Node, Head),
    reverse(Head, R),
    getHead(R, Ans).

getName([_,_,Station, _], Name):-
    Name = Station.
getName([_,Station, _], Name):-
    Name = Station.

% Añadir a cola de prioridades.
addToPriorityQueue(Elem, _, [], First):-
    First = [Elem], !.
addToPriorityQueue(Node, Priority, [Queue|Tail], Ans):-
    getHead(Queue, Weights),
    getHead(Weights, G),   
    getLast(Weights, H),
    HeadPriority is G + H,    % Prioridad del primer elemento de la cola
    Priority > HeadPriority,
    addToPriorityQueue(Node, Priority, Tail, Rest),
    append([Queue], Rest, Ans), !.
addToPriorityQueue(Node, _, Queue, Ans):-
    append([Node], Queue, Ans), !.

popPriorityQueue([Queue|T], Rest, Elem):-
    Rest = T, 
    Elem = Queue.

numStations(System, Line, Count):-
    aggregate_all(count, station(System,_,_,_,Line,_), Count).

adyacentStations([System, Station, Line], Stations):-
    station(System, Station, _, _, Line, Index),
    L is Index-1,
    R is Index+1,
    numStations(System, Line, Count),
    (L > 0, R =< Count -> station(System,Left,_,_,Line, L), station(System,Right,_,_,Line, R), Stations = [Left, Right] 
    ; (L =:= 0 -> station(System,Right,_,_,Line, R), Stations = [Right] ; station(System,Left,_,_,Line, L), Stations = [Left])), !.

getSameStations(Station, Conections):-
    findall([System, Station, Line] ,station(System,Station,_,_,Line,_),Conections).

getConnections([_, Sys, Node, Line], Connection):-
    getSameStations(Node, Con),
    delete(Con, [Sys,Node,Line], Connection).

checkDirection([H|[T]],Start,Goal,Line, Direction):-
    norma(H,Goal, Left),
    norma(T,Goal, Right),
    station(_, Start, _ ,_, Line, Index),
    (Left < Right -> Direction is Index-1 ; Direction is Index+1).
checkDirection([H|[]],Start, _,Line, Dir):- % Si es terminal o inicio de línea
    station(_,Start,_,_,Line,StartOrder),    
    station(_,H,_,_,Line,Order),
    Dif is StartOrder-Order,
    (Dif > 0 -> Dir is StartOrder-1 ; Dir is StartOrder+1).

getDirection([Sys, Node, Line], Goal, New):-
    adyacentStations([Sys, Node, Line], Stations),
    checkDirection(Stations, Node, Goal, Line, Dir), 
    station(Sys, Next, _ , _, Line, Dir),
    New = [Sys, Next, Line], !.

getAdyacentStationsCon([], _, Ans):-
    Ans = [].
getAdyacentStationsCon(Connections, Goal, Ans):-
    getHead(Connections, Head),
    getDirection(Head, Goal, Next),
    getTail(Connections, Rest),
    getAdyacentStationsCon(Rest, Goal, Con),
    append([Next], Con, Ans), !.

nodeValue([Sys|[Node|[Line]]], Goal, Prev, PrevG, List):-
    (norma(Node, Prev, G) -> SumG is G + PrevG ; SumG is PrevG),   % Peso del nodo previo al actual
    norma(Node, Goal, H),   % Valor heurístico
    List = [[SumG,H],Sys, Node, Line].
    
weightNodes([], _, _, _, _).
weightNodes(Nodes, Goal, PrevName, PrevG, Weighted):-
    getTail(Nodes, Tail),
    weightNodes(Tail, Goal, PrevName, PrevG, W),
    getHead(Nodes, Head),
    nodeValue(Head, Goal, PrevName, PrevG, NodeVal),
    getHead(NodeVal, Weights),
    getHead(Weights, G),   
    getLast(Weights, H),
    F is G + H,
    addToPriorityQueue(NodeVal, F, W, Weighted), !.

getNextStation([_,_, Prev, _], [_, Sys, Node, Line], Next):-
    station(Sys,Node, _, _, Line, IndexNode),
    station(Sys,Prev, _, _, Line, IndexPrev),
    numStations(Sys, Line, Count),
    (IndexNode =:= 1 -> Direction is 2 ; (IndexNode =:= Count -> Direction is Count-1 ; Direction is IndexNode + (IndexNode - IndexPrev))),
    station(Sys,Name, _, _, Line, Direction),    
    Next = [Sys, Name, Line], !.

getPreviousFirst([Sys, Node, Line], Goal, Next):-
    adyacentStations([Sys, Node, Line], [H|[T]]),
    station(Sys,Node, _, _, Line, IndexNode),
    norma(H,Goal, Left),
    norma(T,Goal, Right),
    (Left < Right -> Direction is IndexNode +1 ; Direction is IndexNode -1),
    station(Sys,Name, _, _, Line, Direction),    
    Next = [[0,0],Sys, Name, Line].
getPreviousFirst([Sys, Node, Line], _, Next):-
    Next = [[0,0],Sys, Node, Line].    


getChildNodes(Prev, Parent, Goal, WeightedChilds):-
    getNextStation(Prev, Parent, Next), % Estación siguiente en la misma línea
    getConnections(Parent, Conections),
    getAdyacentStationsCon(Conections, Goal, AdCon), % Estaciones de transbordo
    append(AdCon, [Next], Childs), 
    (Prev \= [] -> getTail(Prev, PTail) ; PTail is " "),
    delete(Childs, PTail, Cons),
    getName(Prev, PrevName),
    getG(Prev, PrevG),
    weightNodes(Cons, Goal, PrevName, PrevG , WeightedChilds), !.

/**
 * Inicia con la estación Start con el formato [[g(n)=0, h(n)], Sys, Station, Line].
 * **/
a_star(Prev, Parent, Goal, Path):-
    getName(Parent, PName),
    PName \= Goal,
    getChildNodes(Prev, Parent, Goal, Childs), % Obtiene los nodos hijos para la estación actual
    getHead(Childs, Succesor), % Obtiene el primer hijo ordenado (f(n) más chico)
    a_star(Parent, Succesor, Goal, Closed),
    append([PName], Closed, Path), !.
a_star(_, _, Goal, Path):-
    Path = [Goal]. % Si se llegó al destino, Start = Goal

test:-
    %Start = barranca_del_muerto,
    Start = polanco,
    Goal = universidad,
    Line = 7,
    Sys = metro,
    station(Sys, Start, _,_,Line,_),
    getPreviousFirst([Sys, Start, Line], Goal, First),
    a_star(First, [[0,0], Sys, Start, Line], Goal,Path),
    write(Path), !. 