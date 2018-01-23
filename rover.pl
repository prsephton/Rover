% Uses SWI Prolog
%
%  Goal :-
%    Read the first line, interpret it as width and height,
%    Read the second line, interpret it as x, y pos and direction,
%    Read the third line, apply instructions in the line,
%    Output the final position and direction
%
%  With Prolog development, each predicate may succeed or fail, and
%  so testing and conditions form part of the code.
%
%  Each individual predicate may be tested in isolation.  For example,
%     turn(From, Dir, To),
%     writef("Turn %w from %w faces %w\n", [Dir, From, To]),
%     fail.
%  produces:
%     Turn L from E faces N
%     Turn L from S faces E
%     Turn L from W faces S
%     Turn L from N faces W
%     Turn R from N faces E
%     Turn R from E faces S
%     Turn R from S faces W
%     Turn R from W faces N
%
%  To run this program, install SWI Prolog, and do:
%     swipl -g script -s rover.pl
%
go :-
	get_gridsize(H, V),
	get_start_pos(H, V, X, Y, Direction),
	get_instructions(IList),
	translate_instructions(Direction, IList, 0, Translated),
	calc_final_pos(pos(X, Y), Translated, pos(Xf, Yf), Facing),
	writef("%w %w %w", [Xf, Yf, Facing]), nl.

script :- go, fail.
script :- halt.

read_line(Line) :-  % Just read a single line and return the string
	read_line_to_codes(current_input, Codes),
	atom_codes(Line, Codes).

% Reads the grid size as a two digit integer.  Fails if we cannot.
get_gridsize(H, V) :-
	read_line(Line),
	atom_chars(Line, [Hc, Vc]),
	number_chars(H, [Hc]), number_chars(V, [Vc]),
	check_grid_range(H, V), !.
get_gridsize(_, _) :-
	write('Cannot read grid size.'), nl, fail.

% Checks the range of the grid size values
check_grid_range(H, V) :-
	between(1, 9, H), between(1, 9, V), !.
check_grid_range(_, _) :-
	write('Grid values are out of range.'), nl, fail.

% Reads the starting position and direction as a two digit integer
% followed by a space and a direction indicator.  Fails if it cannot.
get_start_pos(HSize, VSize, X, Y, Direction) :-
	read_line(Line),
	atom_chars(Line, [Xc, Yc, ' ', Direction]),
	number_chars(X, [Xc]), number_chars(Y, [Yc]),
	check_grid_pos(X, HSize, 'Horizontal'), check_grid_pos(Y, VSize, 'Vertical'),
	check_direction(Direction), !.
get_start_pos(_, _, _, _, _) :-
	write('Cannot read starting position and direction.'), nl, fail.

% Checks that the position is valid, and fails if it is not.
check_grid_pos(Pos, Size, _) :-
	between(1, Size, Pos), !.
check_grid_pos(_, _, What) :-
	writef("%s position is outside the grid", [What]), nl, fail.

% Checks that the direction is in the valid set of directions, or fails
check_direction(Direction) :- memberchk(Direction, ['N', 'E', 'S', 'W']), !.
check_direction(Direction) :-
	writef("%s is not a valid direction", [Direction]).

% Reads the instruction list and checks that it is valid.
get_instructions(IList) :-
	read_line(Line), atom_chars(Line, IList),
	check_instructions(IList), !.
get_instructions(_) :-
	write('Instruction list is invalid'), nl, fail.

% Check whether each instruction in the list is valid, or fails.
check_instructions([]).
check_instructions([I|IList]) :-
	memberchk(I, ['M','L','R']),
	!, check_instructions(IList).
check_instructions([I|_]) :-
	writef("Invalid instruction in list: %w", [I]), nl, fail.

% The set of valid turns.  Right from N is E, and left from E is N
turns('N', 'E').
turns('E', 'S').
turns('S', 'W').
turns('W', 'N').

% Execute a turn in the indicated direction, returning the new direction
turn(Direction, 'L', NewDirection) :-
	turns(NewDirection, Direction).
turn(Direction, 'R', NewDirection) :-
	turns(Direction, NewDirection).

% Translates a set of instructions into a list of movements.  For example,
% the movements MMLMRMMRRMML starting facing east is translated into:
%   [ins(0+1+1, 'E'), ins(0+1, 'N'), ins(0+1+1, 'E'), ins(0+1+1, 'W'), final('S')]
translate_instructions(Direction, ['M'|IList], N, Translated) :-
	!, translate_instructions(Direction, IList, N+1, Translated).
translate_instructions(Direction, [Turn|IList], 0, Translated) :-
	turn(Direction, Turn, NewDirection), !,
	translate_instructions(NewDirection, IList, 0, Translated).
translate_instructions(Direction, [Turn|IList], N, [ins(N, Direction)|Translated]) :-
	turn(Direction, Turn, NewDirection), !,
	translate_instructions(NewDirection, IList, 0, Translated).
translate_instructions(Direction, [], 0, [final(Direction)]) :- !.
translate_instructions(Direction, [], N, [ins(N, Direction)|Translated]) :-
	!, translate_instructions(Direction, [], 0, Translated).

% Final position and facing direction is calculated from initial
% XY coordinate by processing the movement instruction list.  We report
% an error if the position moves beyond the grid boundaries.
calc_final_pos(pos(X,Y), _, _, _) :-
	not((between(1,9,X), between(1,9,Y))), !,
	write('Movement beyond the range of the grid'), nl, fail.
calc_final_pos(Pos, [final(Facing)], Pos, Facing).
calc_final_pos(pos(X,Y), [ins(N, 'N')|Instructions], Pos, Facing) :-
	Yn is Y + N, !, calc_final_pos(pos(X, Yn), Instructions, Pos, Facing).
calc_final_pos(pos(X,Y), [ins(N, 'S')|Instructions], Pos, Facing) :-
	Yn is Y - N, !, calc_final_pos(pos(X, Yn), Instructions, Pos, Facing).
calc_final_pos(pos(X,Y), [ins(N, 'E')|Instructions], Pos, Facing) :-
	Xn is X + N, !, calc_final_pos(pos(Xn, Y), Instructions, Pos, Facing).
calc_final_pos(pos(X,Y), [ins(N, 'W')|Instructions], Pos, Facing) :-
	Xn is X - N, !, calc_final_pos(pos(Xn, Y), Instructions, Pos, Facing).

