%Base de datos con la notaci�n de [[6,6], costo]

%listaAbierta([_,[_]]).
%listaFichas([[6,6],_],[[5,6],_],[[4,6],_],[[3,6],_],[[2,6],_],[[1,6],_],[[0,6],_],[[5,5],_],[[4,5],_],[[3,5],_],[[2,5],_],[[1,5],_],[[0,5],_],[[4,4],_],[[3,4],_],[[2,4],_],[[1,4],_],[[0,4],_],[[3,3],_],[[2,3],_],[[1,3],_],[[0,3],_],[[2,2],_],[[1,2],_],[[0,2],_],[[1,1],_],[[0,1],_],[[0,0],_]).
% listaEnMano().
% listaEnMesa().
% NumComer(14).
% miMano(N).
% manoOponente(M).

% listaIncognitas([],_,_,_):-
%     !.
% listaIncognitas(ListaFichas,ListaEnMano,ListaEnMesa,ListaIncognitos):-
%     ListaFichas = [CabezaF|ColaF],
%     (member(CabezaF,ListaEnMano) == false ->
%     append(CabezaF,ListaIncognitos,ListaIncognitos)),
%     (member(CabezaF,ListaEnMesa)== false ->
%     append(CabezaF,ListaIncognitos,ListaIncognitos)),
%     listaIncognitas(ColaF,ListaEnMano,ListaEnMesa,ListaIncognitos).

%EjemploArbol is [[6,6],[[6,5],[6,4]]].%
%BaseDatos is [[6,6],[5,6],[4,6],[3,6],[2,6],[1,6],[0,6],[5,5],[4,5],[3,5],[2,5],[1,5],[0,5],[4,4],[3,4],[2,4],[1,4],[0,4],[3,3],[2,3],[1,3],[0,3],[2,2],[1,2],[0,2],[1,1],[0,1],[0,0]].%
%Abierto is lista de 2.%
%Incognitas is lista de piezas que no sabemos.%
%MiJuego is  lista de fichas que yo tengo.%

% Arbol is arbol que vamos a estar generando en el momento - se va a%
% estar generan%do en cada turno.%

% alphaBeta([[_,Val]|[]],_,_,_,_,ValorH):-
%     ValorH is Val,!.

alphaBeta(_,_,_,Nodo,0,_,_,_,ValorH):-
    ValorH is Nodo,!.


alphaBeta(MisPiezas,Incognitas,Abiertas,[[Cab]|[]],Depth,Alpha,Beta,1,ValorH,Fcont):-
    generaArbol(MisPiezas,Abiertas,Hijos),
    (Hijos == [] ->
        (MisPiezas == []-> 
        ValorH = [[Cab]|550*Depth]);
        (ValorH = [[Cab]|0]) );
    generaArbol(MisPiezas,Abiertas,Hijos),
    alphaBeta(MisPiezas,Incognitas,Abiertas,[[]|Hijos],Depth,Alpha,Beta,0,ValorH,Fcont).

alphaBeta(MisPiezas,Incognitas,Abiertas, [[Cab]|[]],Depth,Alpha,Beta,0,ValorH,Fcont):-
    (Fcont =:= 0 -> 
        ValorH = [[Cab]|-550*Depth]);
    generaArbol(Incognitas,Abiertas,Hijos),
    (Hijos == [] ->
        ValorH = [[Cab]|100*Depth]);    
    generaArbol(MisPiezas,Abiertas,Hijos),
    alphaBeta(MisPiezas,Incognitas,Abiertas, [[]|Hijos],Depth,Alpha,Beta,1,ValorH,Fcont).

alphaBeta(MisPiezas,Incognitas,Abiertas, [],Depth,Alpha,Beta,1,ValorH,Fcont):-
    generaArbol(MisPiezas,Abiertas,Hijos),
    append([Abiertas],Hijos,Arbol),
    alphaBeta(MisPiezas,Incognitas,Abiertas, Arbol,Depth,Alpha,Beta,1,ValorH,Fcont).
    
alphaBeta(MisPiezas,Incognitas,Abiertas, [],Depth,Alpha,Beta,0,ValorH,Fcont):-
    generaArbol(Incognitas,Abiertas,Hijos),
    append([Abiertas],Hijos,Arbol),
    alphaBeta(MisPiezas,Incognitas,Abiertas, Arbol,Depth,Alpha,Beta,1,ValorH,Fcont).

% alphaBeta(MisPiezas,Incognitas,Abiertas, [_,[Children]|Cuerpo],Depth,Alpha,Beta,Player,ValorH,Fcont):-
%     alphaBeta(MisPiezas,Incognitas,Abiertas, Children,Depth,Alpha,Beta,Player,ValorH),
%     alphaBeta(MisPiezas,Incognitas,Abiertas, Cuerpo,Depth,Alpha,Beta,Player,ValorH,Fcont),!.

alphaBeta(MisPiezas,Incognitas,Abiertas, [_|Children],Depth,Alpha,Beta,1,ValorH,Fcont):-
    Value = [[]|Alpha],
    forEachAlpha(MisPiezas,Incognitas,Abiertas,Children,Value,Depth,Alpha,Beta,ValorH,Fcont),!.

alphaBeta(MisPiezas,Incognitas,Abiertas,[_|Children],Depth,Alpha,Beta,0,ValorH,Fcont):-
    Value = [[]|Beta],
    forEachBeta(MisPiezas,Incognitas,Abiertas,Children,Value,Depth,Alpha,Beta,ValorH,Fcont).


forEachAlpha(_,_,_,_,_,Alpha,Beta,_,_):-
    Alpha >= Beta,fail.

forEachAlpha(MisPiezas,Incognitas,Abiertas,[Child1|[]],Value,Depth,Alpha,Beta,ValueRet,Fcont):-
     childrenMax(MisPiezas,Incognitas,Abiertas,Child1,Value,Depth,Alpha,Beta,ValueRet,Fcont),!.

forEachAlpha(MisPiezas,Incognitas,Abiertas,[Child1|Childrens],Value,Depth,Alpha,Beta,ValueRet,Fcont):-
    childrenMax(MisPiezas,Incognitas,Abiertas,Child1,Value,Depth,Alpha,Beta,ValueRes,Fcont),
    forEachAlpha(MisPiezas,Incognitas,Abiertas,Childrens,Value,Depth,ValueRes,Beta,ValueRet,Fcont),!.


forEachBeta(_,_,_,_,_,Alpha,Beta,_,_):-
    Alpha >= Beta,fail.

forEachBeta(MisPiezas,Incognitas,Abiertas,[Child1|[]],Value,Depth,Alpha,Beta,ValueRet,Fcont):-
     childrenMin(MisPiezas,Incognitas,Abiertas,Child1,Value,Depth,Alpha,Beta,ValueRet,Fcont).

forEachBeta(MisPiezas,Incognitas,Abiertas,[Child1|Childrens],Value,Depth,Alpha,Beta,ValueRet,Fcont):-
    childrenMin(MisPiezas,Incognitas,Abiertas,Child1,Value,Depth,Alpha,Beta,ValueRes,Fcont),
    forEachBeta(MisPiezas,Incognitas,Abiertas,Childrens,Value,Depth,Alpha,ValueRes,ValueRet,Fcont),!.

maxim([Pieza|Valor1],[_|Valor2],Res):-
    Valor1>Valor2,
    Res is [Pieza|Valor1],!.

maxim(_,[Pieza2|Valor2],Res):-
    Res is [Pieza2|Valor2].

childrenMax(MisPiezas,Incognitas,Abiertas,Children,Value,Depth,Alpha,Beta,ValueRet,Fcont):-
    Abiertas = [A1,A2],
    Children = [[Num1,Num2]|_],
    ((A1 =:= Num1 -> 
        Nabiertas = [Num2,A2]);

    Children = [[Num1,Num2]|_],
    Abiertas = [A1,A2],
    (Nabiertas = [A1,Num2])),

    DepthN is Depth -1,
    alphaBeta(MisPiezas,Incognitas,Nabiertas,[],DepthN,Value,Beta,0,ValorH,Fcont),
    maxim(Value,ValorH,ValueRes),
    maxim(Alpha,ValueRes,AlphaN),
    ValueRet is AlphaN,!.

minmin([Pieza|Valor1],Valor2,Res):-
    Valor1<Valor2,
    Res is [Pieza|Valor1],!.

minmin(_,Valor2,Res):-
    Res is Valor2.

childrenMin(MisPiezas,Incognitas,Abiertas,Children,Value,Depth,Alpha,Beta,ValueRet,Fcont):-
    Children = [[Num1,Num2]|_],
    Abiertas = [A1,A2],
    ((A1 =:= Num1 -> 
        Nabiertas = [Num2,A2]);

    Children = [[Num1,Num2]|_],
    Abiertas = [A1,A2],
    (Nabiertas = [A1,Num2])),

    DepthN is Depth -1,
    Nfcont is Fcont - 1,
    alphaBeta(MisPiezas,Incognitas,Nabiertas,[],DepthN,Alpha,Value,1,ValorH,Nfcont),
    minmin(Value,ValorH,ValueRes),
    minmin(Beta,ValueRes,AlphaN),
    ValueRet is AlphaN,!.

generaArbol(Fichas,[X|[Y]],Hijos):-
    % (X =\= Y ->
    buscaHijo(Fichas,X,[],HijosX),
    buscaHijo(Fichas,Y,[],HijosY),
    append(HijosX,HijosY,Hijos).
    % buscaHijo(Fichas,X,[],HijosX),
    % append(HijosX,Hijos,Hijos).

buscaHijo([],_,Parcial,Hijos):-
    Hijos = Parcial.

buscaHijo([Cabeza|Cola],X,Parcial,Hijos):-
    Cabeza = [NumFicha|[Peso]],
    (member(X,NumFicha) ->
        (NumFicha = [Num1|[Num2]],
        
        (Num1=:=Num2 -> Peso is Num1+Num2+13),
        cambiarHijos([[Num1|[Num2]]|Peso],X,Res),
        append(Parcial,[Res],P2),
        buscaHijo(Cola,X,P2,Hijos);

        NumFicha = [Num1|[Num2]],
        Peso is Num1+Num2,
        cambiarHijos([[Num1|[Num2]]|Peso],X,Res),
        append(Parcial,[Res],P2),
        buscaHijo(Cola,X,P2,Hijos)));

    buscaHijo(Cola,X,Parcial,Hijos),!.

    
cambiarHijos([[Num1|[Num2]]|Peso],X,Res):-
    Num1 =:= X,
    Res = [[Num1|[Num2]],Peso],!.

cambiarHijos([[Num1|[Num2]]|Peso],_,Res):-
    Res = [[Num2|[Num1]],Peso].




