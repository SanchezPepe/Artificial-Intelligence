:-ensure_loaded(estaciones).
:-dynamic path/1.

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

adyacentStations(System, Station, Line, Stations):-
    station(System, Station, _, _, Line, Index),
    L is Index-1,
    R is Index+1,
    numStations(System, Line, Count),
    (L > 0, R =< Count -> station(System,Left,_,_,Line, L), station(System,Right,_,_,Line, R), Stations = [Left, Right] 
    ; (L =:= 0 -> station(System,Right,_,_,Line, R), Stations = [Right] ; station(System,Left,_,_,Line, L), Stations = [Left])), !.

% Regresa 1 si es a la derecha/abajo, -1 a la izq/arriba
getDirection([H|[T]],_,Goal,_, Direction):-
    norma(H,Goal, Left),
    norma(T,Goal, Right),
    (Left < Right -> Direction is -1 ; Direction is 1).
getDirection([H|[]],Start, _,Line, Dir):- % Si es terminal o inicio de línea
    station(_,Start,_,_,Line,StartOrder),    
    station(_,H,_,_,Line,Order),
    Dif is StartOrder-Order,
    (Dif > 0 -> Dir is -1 ; Dir is 1).

getSameStations(Station, Conections):-
    findall([System, Station, Line] ,station(System,Station,_,_,Line,_),Conections).

getConnections(Sys, Node, Line, Connection):-
    getSameStations(Node, Con),
    delete(Con, [Sys,Node,Line], Connection).

getAdyacentStationsCon([], _, Ans):-
    Ans = [].
getAdyacentStationsCon(Conections, Goal, Ans):-
    getHead(Conections, [Sys, Name, Line]),
    adyacentStations(Sys, Name, Line, Ad),
    getDirection(Ad, Name, Goal, Line, Direction),
    station(Sys, Name, _, _, Line, Order),
    Index is Order + Direction,
    station(Sys, Next, _, _, Line, Index),
    getTail(Conections, Rest),
    getAdyacentStationsCon(Rest, Goal, Con),
    append([[Sys, Next, Line]], Con, Ans), !.
    

weightNodes([], _, _, _).
weightNodes(Nodes, Goal, Prev, Weighted):-
    getTail(Nodes, Tail),
    weightNodes(Tail, Goal, Prev, W),
    getHead(Nodes, Head),
    getG(Prev, PrevG),
    getName(Prev, PrevName),
    nodeValue(Head, Goal, PrevName, PrevG, NodeVal),
    getHead(NodeVal, Weights),
    getHead(Weights, G),   
    getLast(Weights, H),
    F is G + H,
    addToPriorityQueue(NodeVal, F, W, Weighted), !.

getChildNodes([W, Sys, Node, Line], Goal, WeightedChilds):-
    station(Sys, Node, _,_,Line,Ind),
    adyacentStations(Sys, Node, Line, Ad),
    getDirection(Ad, Node, Goal, Line, Dir),
    I is Ind + Dir,
    station(Sys, Child, _,_,Line,I),  % Estación adyacente al nodo más cerana al Goal
    getConnections(Sys, Node, Line, Connections), % Estaciones de transbordo
    getAdyacentStationsCon(Conections, Goal, AdCon),
    ChildInSameLine = [Sys, Child, Line],
    append(AdCon, [ChildInSameLine], Childs), 
    weightNodes(Childs, Goal, [W, Sys, Node, Line] , WeightedChilds), !.

nodeValue([Sys|[Node|[Line]]], Goal, Prev, PrevG, List):-
    (norma(Node, Prev, G) -> SumG is G + PrevG ; SumG is PrevG),   % Peso del nodo previo al actual
    norma(Node, Goal, H),   % Valor heurístico
    List = [[SumG,H],Sys, Node, Line].

% SuccessorCurrentCost = g(n) + dist(actual a sucesor)
evaluateCurrentAndSuccessor(Current, Succesor, Ans):-
    getG(Current, G),
    getG(Succesor, W),
    Ans = G + W.

/**
 * Inicia con la estación Start con el formato [[g(n)=0, h(n)], Sys, Station, Line].
 * **/
a_star(Parent, Goal, Path):-
    getName(Parent, PName),
    PName \= Goal,
    getChildNodes(Parent, Goal, Childs), % Obtiene los nodos hijos para la estación actual
    getHead(Childs, Succesor), % Obtiene el primer hijo ordenado (f(n) más chico)
    a_star(Succesor, Goal, Closed),
    append([PName], Closed, Path), !.
a_star(_, Goal, Path):-
    Path = [Goal]. % Si se llegó al destino, Start = Goal

test:-
    Goal = el_caminero,
    Start = olivo,
    station(Sys, Start, _,_,Line,_),
    a_star([[0,0], Sys, Start, Line],Goal,Path),
    write(Path).
    /**
    getConnections(metro, tacubaya, 9, Con),
    getAdyacentStationsCon(Con, mixcoac, C),
    write(C).

    getH([[3.3,7.93],metro,mixcoac,12], Ans),
    writeln(Ans),
    %getChildNodes(metro,mixcoac,7, zapata, D),
    Queue = [],
    %writeln(Val),
    addToPriorityQueue([14,metro,auditorio,7], Queue, Res),
    %writeln(Val1
    addToPriorityQueue([7,metro,auditorio,7], Res, Res2),    
    %writeln(Val2),
    addToPriorityQueue([1,metro,auditorio,7], Res2, Res3), writeln(Res3),
    % Pop
    popPriorityQueue(Res3, X, Y),
    writeln("Se quitó: "), writeln(Y),
    writeln("Quedó "), writeln(X),

    nodeValue([metro,el_rosario, 7], pantitlan, mixcoac, List),
    writeln(List),

    **/

    /**
     * 
    nodeValue([metro, polanco, 7], mixcoac, nil, Node),
    a_star(polanco, mixcoac, [Node], Path)
    **/