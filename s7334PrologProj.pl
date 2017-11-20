
/*
  Opisy wszystkich lokacji w grze
*/
description(valley,
	    'Jesteś w dolinie, przed Tobą szlak, dostań się na szczyt góry.').
description(path,
	    'idziesz ścieżką wzdłóż wąwozu').
description(cliff,
	    'znalazłeś się tuż nad przepaścią i tracisz równowagę').
description(fork,
	    'w tym miejscu ścieżka się rozwidla').
description(maze(_),
	    'Hm, tutaj wszystkie ścieżki wyglądają tak samo, to jakiś labirynt!').
description(mountaintop,
	    'Dotarłeś na szczyt!').
description(lift,
	    'stoisz przed wyciągiem.').

/*
  report wyświetla opis bieżącej lokalizacji
*/
report :-
  at(you,X),
  description(X,Y),
  write(Y), nl.

/*
  Jesteś w punkcie "X", zostajesz przeniesiony w kierunku "Direction" do
  punktu "Y"
*/
/*
*/
connection(valley,forward,path).
connection(path,right,cliff).
connection(path,left,cliff).
connection(path,forward,fork).
connection(fork,left,maze(0)).
connection(fork,right,lift).
connection(lift,forward,mountaintop).
connection(maze(0),left,maze(1)).
connection(maze(0),right,maze(3)).
connection(maze(1),left,maze(0)).
connection(maze(1),right,maze(2)).
connection(maze(2),left,fork).
connection(maze(2),right,maze(0)).
connection(maze(3),left,maze(0)).
connection(maze(3),right,maze(3)).
/*
  move(Direction) przenosi nas do odpowiedniej lokalizacji i mówi gdzie
  się teraz znajdujemy
*/
move(Direction) :-
  at(you,Location),
  connection(Location,Direction,Next),
  retract(at(you,Location)),
  assert(at(you,Next)),
  report,
  !.

move(_) :-
  write('zły ruch. Przejścia nie ma.\n'),
  report.

/* sterowanie*/
forward :- move(forward).
left :- move(left).
right :- move(right).

/*
  Jeśli jesteś w tym samym miejscu co niedźwiedź, zostajesz zabity i
  jest koniec gry.
*/
bear :-
  at(bear,Location),
  at(you,Location),
  write('Spotkałeś niedźwiedzia\n'),
  write('kończysz jako jego obiad.\n'),
  retract(at(you,Location)),
  assert(at(you,done)),
  !.
/*
  Jeśli nie jesteś w tym samym miejscu co niedźwiedź, nic się nie
  dzieje.
*/
bear.

/*
 * Jeśli jesteś w tym samym miejscu co bilet, podnosisz go.
 */
ticket :-
  at(ticket,Location),
  at(you,Location),
  write('znalazłeś bilet na wyciąg\n'),
  retract(at(ticket,Location)),
  assert(has(ticket)),
  !.

/*
 * jeśli nie jesteś w tym miejscu co bilet, nic się nie dzieje.
 */
ticket.

/*
 * wyciąg, jedyna droga na ten szczyt
 * potrzebujesz biletu, żeby nim pojechać
 */
lift :-
  has(ticket),
  at(you,lift),
  write('masz bilet, możesz jechać na górę \n'),
  move(forward),
  !.

/*
 * Jeśli jesteś przy wyciągu, ale nie masz biletu
 */
lift :-
  at(you,lift),
  write('nie masz biletu, nie możesz jechać wyciągiem\n'),
  write('cofasz się na rozwidlenie drogi\n'),
  retract(at(you,lift)),
  assert(at(you,fork)),
  !.

/*
 * jeśli nie jesteś przy wyciągu, nic się nie dzieje.
 */
lift.

/*
  warunek wygranej
*/
mountaintop :-
  at(mountaintop,Location),
  at(you,Location),
  write('Dotarłeś na szczyt.\n'),
  write('Gratulacje!\n'),
  retract(at(you,Location)),
  assert(at(you,done)),
  !.
/*
  jeśli nie jesteś jeszcze na szczycie, nic siê nie dzieje.
*/
mountaintop.

/*
 * jeśli chcesz upuścić przedmiot
 */
drop :-
  has(ticket),
  write('upuściłeś bilet\n'),
  write('zdmuchnął go wiatr i tyle go widziałeś'),
  retract(has(ticket)),
  assert(has(nothing)),
  !.

drop :-
  write('nie masz nic co mógłbyś upuścić\n'),
  !.

/*
  nad przepaścią
*/
cliff :-
  at(you,cliff),
  write('spadasz w przepaść. Można powiedzieć, że dałeś plamę. Czerwoną.\n'),
  retract(at(you,cliff)),
  assert(at(you,done)),
  !.

/*jeśli nie jesteś nad przepaścią, nic się nie dzieje */
cliff.

/*
  główna pętla gry
*/
main :-
  at(you,done),
  write('Dzięki za grę.\n'),
  !.

main :-
  write('\n Dokąd teraz? '),
  read(Move),
  call(Move),
  lift,
  bear,
  mountaintop,
  cliff,
  ticket,
  main.

/*
  punkt startowy
*/
start :-
  retractall(at(_,_)), /* czyszczenie po poprzednim uruchomieniu */
  retractall(has(_)),
  assert(has(nothing)),
  assert(at(you,valley)),
  assert(at(bear,maze(3))),
  assert(at(ticket,maze(2))),
  assert(at(mountaintop,mountaintop)),
  write('Gra przygodowa \n'),
  write('możesz poruszać siê w lewo (left.), prawo (right.) i naprzód (forward.)\n'),
  write('w celu upuszczenia przedmiotu użyj "drop" \n'),
  report,
  main.
