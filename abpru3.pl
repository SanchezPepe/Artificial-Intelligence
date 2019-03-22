play_1(Depth, Position, Player):-
    choose_move(Depth, Position, Player, Move),
    move(Position, Move, NewPosition), !,
    swap_position(NewPosition, NextPosition),
    next_player(Player, NextPlayer),
    play_1(Depth, NextPosition, NextPlayer).

choose_move(Depth, Position, computer, Move):-
    alphabeta(Depth, Position, -32767, 32767, Move, _),
    write(`My move is: `),
    write(Move), nl, nl.

choose_move(Depth, Position, opponent, Move):-
    write(`Choose your move: `),
    fread(i, 0, 0, Move), nl,
    move(Position, Move, _), !
    ;
    write(`***Invalid move***`), nl, nl,
    choose_move(Depth, Position, opponent, Move).
  
alphabeta(_, Position, _, _, 0, -1000):-
    game_lost(Position), !.

alphabeta(Depth, Position, Alpha, Beta, BestMove, Value):-
    Depth > 0,
    recommended_moves(Position, Moves),
    Moves = [_|_], !,
    NewDepth is Depth - 1,
    Alpha1 is -Beta,
    Beta1 is -Alpha,
    bestmove(Moves, Position, NewDepth, Alpha1, Beta1, 0, BestMove, Value).

alphabeta(_, Position, _, _, 0, Value):-
    value(Position, Value). % Depth is 0, or no moves left
  
bestmove([Move|Moves], Posn, Depth, Alpha, Beta, Move0, Move1, Value1):-
    move(Posn, Move, NewPosn0), !,
    swap_position(NewPosn0, NewPosn),
    alphabeta(Depth, NewPosn, Alpha, Beta, _, MinusValue),
    Value is -MinusValue,
    cutoff(Move, Value, Depth, Alpha, Beta, Moves, Posn, Move0, Move1, Value1).

bestmove([], _, _, Alpha, _, Move, Move, Alpha).
  
cutoff(_, Value, Depth, Alpha, Beta, Moves, Position, Move0, Move1, Value1):-
    Value =< Alpha, !,
    bestmove(Moves, Position, Depth, Alpha, Beta, Move0, Move1, Value1).
cutoff(Move, Value, Depth, _, Beta, Moves, Position, _, Move1, Value1):-
    Value < Beta, !,
    bestmove(Moves, Position, Depth, Value, Beta, Move, Move1, Value1).
cutoff(Move, Value, _, _, _, _, _, _, Move, Value).
  