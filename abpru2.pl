
%TicTacToe using Alpha-Beta Pruning

% goal: play(6), for example.

play(Depth):-
  depth_limits(MinDepth, MaxDepth),
  Depth >= MinDepth,
  Depth =< MaxDepth,
  prompt(_, ''),
  nl,
  initialise(Position, Player),
  play_1(Depth, Position, Player), !
  ;
  nl, write(`***Depth is outside limits***`), nl, fail.

play_1(_, Position, Player):-
  show_position(Position, Player),
  game_over(Position, Result), !,
  result(Result, Player).
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

next_player(computer, opponent).
next_player(opponent, computer).

game_over(Position, lost):-  game_lost(Position), !.
game_over(Position, drawn):- \+(move(Position, _, _)).

result(lost, computer):- write(`You have won`), nl, nl.
result(lost, opponent):- write(`You have lost`), nl, nl.
result(drawn, _):-       write(`Game drawn`), nl, nl.

initialise(p(0,0,0,0,0,0,0,0,0), computer):-rand_int(2, J), J = 1, !.
initialise(p(0,0,0,0,0,0,0,0,0), opponent).

depth_limits(1, 9).

% rand_int(I, J) is true if J is a pseudo-random integer in the range
%   1 to I.
rand_int(I, J):- 
    J is int(rand(I)) + 1.

recommended_moves(Position, [Move]):-
  % If there is a winning move, recommend it, and ignore all other moves
  move(Position, Move, _),
  winning_move(Position, Move), !.
recommended_moves(Position, [Move]):-
  % If the other player has a potential winning move, recommend the
  %   move which would prevent it, and ignore all other moves
  move(Position, Move, _),
  swap_position(Position, Position1),
  winning_move(Position1, Move), !.
recommended_moves(Position, Moves):-
  % Otherwise, recommend all valid moves
  findall(Move, move(Position, Move, _), Moves).

move(p(0,B,C,D,E,F,G,H,I), 7, p(1,B,C,D,E,F,G,H,I)).
move(p(A,0,C,D,E,F,G,H,I), 8, p(A,1,C,D,E,F,G,H,I)).
move(p(A,B,0,D,E,F,G,H,I), 9, p(A,B,1,D,E,F,G,H,I)).
move(p(A,B,C,0,E,F,G,H,I), 4, p(A,B,C,1,E,F,G,H,I)).
move(p(A,B,C,D,0,F,G,H,I), 5, p(A,B,C,D,1,F,G,H,I)).
move(p(A,B,C,D,E,0,G,H,I), 6, p(A,B,C,D,E,1,G,H,I)).
move(p(A,B,C,D,E,F,0,H,I), 1, p(A,B,C,D,E,F,1,H,I)).
move(p(A,B,C,D,E,F,G,0,I), 2, p(A,B,C,D,E,F,G,1,I)).
move(p(A,B,C,D,E,F,G,H,0), 3, p(A,B,C,D,E,F,G,H,1)).

winning_move(p(0,1,1,_,_,_,_,_,_), 7):-!.
winning_move(p(1,0,1,_,_,_,_,_,_), 8):-!.
winning_move(p(1,1,0,_,_,_,_,_,_), 9):-!.
winning_move(p(_,_,_,0,1,1,_,_,_), 4):-!.
winning_move(p(_,_,_,1,0,1,_,_,_), 5):-!.
winning_move(p(_,_,_,1,1,0,_,_,_), 6):-!.
winning_move(p(_,_,_,_,_,_,0,1,1), 1):-!.
winning_move(p(_,_,_,_,_,_,1,0,1), 2):-!.
winning_move(p(_,_,_,_,_,_,1,1,0), 3):-!.
winning_move(p(0,_,_,1,_,_,1,_,_), 7):-!.
winning_move(p(1,_,_,0,_,_,1,_,_), 4):-!.
winning_move(p(1,_,_,1,_,_,0,_,_), 1):-!.
winning_move(p(_,0,_,_,1,_,_,1,_), 8):-!.
winning_move(p(_,1,_,_,0,_,_,1,_), 5):-!.
winning_move(p(_,1,_,_,1,_,_,0,_), 2):-!.
winning_move(p(_,_,0,_,_,1,_,_,1), 9):-!.
winning_move(p(_,_,1,_,_,0,_,_,1), 6):-!.
winning_move(p(_,_,1,_,_,1,_,_,0), 3):-!.
winning_move(p(0,_,_,_,1,_,_,_,1), 7):-!.
winning_move(p(1,_,_,_,0,_,_,_,1), 5):-!.
winning_move(p(1,_,_,_,1,_,_,_,0), 3):-!.
winning_move(p(_,_,0,_,1,_,1,_,_), 9):-!.
winning_move(p(_,_,1,_,0,_,1,_,_), 5):-!.
winning_move(p(_,_,1,_,1,_,0,_,_), 1):-!.

game_lost(p(-1,-1,-1, _, _, _, _, _, _)):-!.
game_lost(p( _, _, _,-1,-1,-1, _, _, _)):-!.
game_lost(p( _, _, _, _, _, _,-1,-1,-1)):-!.
game_lost(p(-1, _, _,-1, _, _,-1, _, _)):-!.
game_lost(p( _,-1, _, _,-1, _, _,-1, _)):-!.
game_lost(p( _, _,-1, _, _,-1, _, _,-1)):-!.
game_lost(p(-1, _, _, _,-1, _, _, _,-1)):-!.
game_lost(p( _, _,-1, _,-1, _,-1, _, _)):-!.

swap_position(p(A0,B0,C0,D0,E0,F0,G0,H0,I0), p(A,B,C,D,E,F,G,H,I)):-
  A is -A0, B is -B0, C is -C0, 
  D is -D0, E is -E0, F is -F0, 
  G is -G0, H is -H0, I is -I0.

value(Position, -1000):-
  game_lost(Position), !.
value(Position, Value):-
  promising_lines(Position,  2, 0, N1),
  promising_lines(Position, -2, 0, N2),
  Value is 2 * N1 - N2.

promising_lines(Position, M, Acc, N):-
  lines(Position, Lines),
  promising_lines_1(Lines, M, Acc, N).

promising_lines_1([Line|Lines], M, Acc, N):-
  promising_line(Line, M), !,
  Acc1 is Acc + 1,
  promising_lines_1(Lines, M, Acc1, N)
  ;
  promising_lines_1(Lines, M, Acc, N).
promising_lines_1([], _, N, N).

promising_line(l(A,B,C), M):-
  % A promising line is one that has M (=2) Xs (or Os) in it
  M is A + B + C.

lines(p(A,B,C,D,E,F,G,H,I),
  [l(A,B,C),l(D,E,F),l(G,H,I),l(A,D,G),l(B,E,H),l(C,F,I),l(A,E,I),l(C,E,G)]).

show_position(Position, computer):-
  show1(Position).
show_position(Position, opponent):-
  swap_position(Position, NewPosition),
  show1(NewPosition).

show1(Position):-
  posn_list(Position, IntList),
  ints_chars(IntList, CharList),
  show2(CharList).

show2([A,B,C,D,E,F,G,H,I]):-
  write_list([`      7|8|9     `, A, '|', B, '|', C]), nl,
  write_list([`      -+-+-     -+-+-`]), nl,
  write_list([`      4|5|6     `, D, '|', E, '|', F]), nl,
  write_list([`      -+-+-     -+-+-`]), nl,
  write_list([`      1|2|3     `, G, '|', H, '|', I]), nl, nl.

ints_chars([], []).
ints_chars([0|Xs],  [' '|Ys]):-ints_chars(Xs, Ys).
ints_chars([1|Xs],  ['O'|Ys]):-ints_chars(Xs, Ys).
ints_chars([-1|Xs], ['X'|Ys]):-ints_chars(Xs, Ys).

posn_list(p(A,B,C,D,E,F,G,H,I), [A,B,C,D,E,F,G,H,I]).

write_list([]).
write_list([X|Xs]):-
  write(X),
  write_list(Xs).
