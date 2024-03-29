
:- consult(['mostrar', 'tests']).

%% Ejercicio 1

%dimension(+Tablero, -N, -M).
dimension(T,N,M):- nonvar(T), dimensionNonvar(T,N,M).
dimension(T,N,M):- var(T), dimensionVar(T,N,M).

dimensionNonvar(T, N, M):- length(T, N), nth0(0, T, L), length(L, M).

dimensionVar(T, N, M):- length(T, N), repetir(N,M,X), maplist(length,T,X).


repetir(0,N,[]).
repetir(I,N,[N|M]):- I > 0, I1 is I-1, repetir(I1,N,M).

% posicion(+Tablero, -I, -J).
posicion(T, I, J):- dimension(T, N, M), N1 is N-1, M1 is M-1, between(0, N1, I), between(0, M1, J).


%% Ejercicio 2

% subtablero(+Tablero, +I, +J, -Subtablero).
subtablero(T, I, J, L):- dimension(T, N, M), I >= N, L = [].
subtablero(T, I, J, L):- dimension(T, N, M), I < N, I2 is I+1, subtablero(T, I2, J, L2), nth0(I, T, Fila),
					sacarN(J, Fila, Col), L = [Col | L2].

% sacarN(+N, +L, -L2)
sacarN(0, L1, L1).
sacarN(N, [L|L1], L2):- N1 is N-1, sacarN(N1, L1, L2).

%% Ejercicio 3

% transponer(+Tablero, -Transpuesto).
transponer(T, Trans):- transponerAux(T, Trans, 0).

transponerAux(T,Trans,I):- dimension(T, N, M), I>=M, Trans=[].
transponerAux(T,Trans,I):- dimension(T, N, M), I< M, I1 is I+1, transponerAux(T, Rec, I1), getCol(T, I, Col),
				Trans = [Col|Rec].
		
%getCol(T,C,L):- dimension(T,N,M), C < M, getColAux(T,C,0,L).
getCol(T,C,L):- getColAux(T,C,0,L).

getColAux(T,C,I,L):- dimension(T,N,M), I>=N, L=[].
getColAux(T,C,I,L):- dimension(T,N,M), I< N, I1 is I+1, getColAux(T, C, I1, L1), nth0(I, T, F), nth0(C, F, R), L = [R|L1].

%% Ejercicio 4

% asignarPeso(+Silueta, +Peso, -SiluetaConPeso).
asignarPeso(S, P, SP):- asignarAux(S,0,P,SP).

asignarAux(S,I,P,SP):- dimension(S,N,M), I>=N, SP=[].
asignarAux(S,I,P,SP):- dimension(S,N,M), I< N, IR is I+1, asignarAux(S, IR, P, LR), nth0(I, S, F), reformado(F,P,C),
				SP=[C|LR].

reformado([],P,[]).
reformado([L|LS],P,[C|CS]):- reformado(LS,P,CS), ((nonvar(L), C = P )| var(L)).

elemento(S,I,J,E):- nth0(I,S,R), nth0(J,R,E).

%% Ejercicio 5

%ubicarSilueta(+Silueta, -I, -J, -Tablero).
ubicarSilueta(S, I, J, T):- posicion(T,I,J), subtablero(T,I,J,ST), entraSiluetaArriba(S,ST).

entraSiluetaArriba(S,T):- length(S,LS), length(T,LT), LS =< LT, L is LT-LS, recortar(T,L,TR), maplist(entraFila,S,TR).

entraFila(S,T):- length(S,LS), length(T,LT), LS =< LT, L is LT-LS, recortar(T,L,TR), maplist(entraCelda,S,TR).

%recortar(+List,+N,?List)
recortar(L,N,R):- reverse(L,RL), sacarN(N,RL,RLR), reverse(RLR,R).

entraCelda(X,Y):-nonvar(X) -> var(Y) ; true.


%% Ejercicio 6

% ubicarPieza(+NombrePieza, +Peso, +DiccionarioPiezas, -I, -J, -Tablero).
ubicarPieza(NP, P, DP, I, J, T):- member(orientacion(NP,S),DP), asignarPeso(S,P,SP), ubicarSilueta(SP,I,J,T), tieneSilueta(SP,I,J,T).

tieneSilueta(S, I, J, T):- posicion(T,I,J), subtablero(T,I,J,ST), matchSiluetaArriba(S,ST).

matchSiluetaArriba(S,T):- length(S,LS), length(T,LT), LS =< LT, L is LT-LS, recortar(T,L,TR), maplist(matchFila,S,TR).

matchFila(S,T):- length(S,LS), length(T,LT), LS =< LT, L is LT-LS, recortar(T,L,TR), maplist(igualCelda,S,TR).

igualCelda(X,Y):- nonvar(X) -> Y is X ; true.

%% Ejercicio 7

% solucionValida(-Juego).
solucionValida(juego(T,RF,RC)):- tableroLleno(T) ,dimension(T,N,M), length(RF,N), length(RC,M), maplist(sumlist,T,RF), transponer(T,TT), maplist(sumlist,TT,RC).

tableroLleno([]).
tableroLleno(T):- not(ubicarSilueta([[1]],I,J,T)) 

%% Ejercicio 8
% resolver(+DiccionarioPiezas, +PiezasDisponibles, -Juego).
resolver(DiccP, [pieza(Nomb,Peso)|PDisp], juego(T,RF,RC)):- ubicarPieza(Nom,Peso,DiccP,I,J,T), resolver(DiccP, PDisp, juego(T,RF,RC)) .
resolver(DiccP, [], juego(T,RF,RC)):- solucionValida(juego(T,RF,RC)).
