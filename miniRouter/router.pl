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

getChildNodes([_, Sys, Node, Line], Goal, Childs):-
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
    (norma(Node, Prev, G) -> G is G ; G is 0),   % Peso del nodo previo al actual
    norma(Node, Goal, H),   % Valor heurístico
    List = [[G,H],Sys, Node, Line].

weightNodes([], _, _, _).
weightNodes(Nodes, Goal, Pivot, Weighted):-
    getTail(Nodes, Tail),
    weightNodes(Tail, Goal, Pivot, W),
    getHead(Nodes, Head),
    nodeValue(Head, Goal, Pivot, NodeVal),
    getHead(NodeVal, Weights),
    getHead(Weights, G),   
    getLast(Weights, H),
    F is G + H,
    addToPriorityQueue(NodeVal, F, W, Weighted), !.

evaluateChildNodes(Parent, Childs, Ans):-
    !.



a_star(Start, Goal, [], Path):- % Caso en el que llegó a la estación destino.
    (Start =:= Goal -> Path = [Goal] ; false).
a_star(Start, Goal, Open, Path):- % Se llama con la estación Start en la lista open
    getHead(Open, First),
    getChildNodes(First, Goal, Childs), % Expandir nodos
    weightNodes(Childs, Goal, Start, Weighted).

    


test:-
    /**
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
    getChildNodes([_,metro, pantitlan, 9], mixcoac, C),
    weightNodes(C, zocalo, puebla, W),
    write("Cola de prioridades con pesos: "),
    writeln(W).

    /**
     * 
    nodeValue([metro, polanco, 7], mixcoac, nil, Node),
    a_star(polanco, mixcoac, [Node], Path)
    **/