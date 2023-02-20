%% Stvaramo labirint cije su velicine neparni brojevi zbog podijele liste %%

%Funkcija za stvaranje labirinta
stvori_lab(Visina, Sirina, Var):-
    %Provjeravamo uvjete
    %Velicina labirinta mora biti veca od 5x5 zbog prakticnosti
    (Visina =< 5; Sirina =< 5) -> writeln('Visina i Sirina labirinta moraju biti vece od 5'), Var = invalid; %Postavljamo Var varijablu na gresku
    % , = and, ; = or
    %Uvjet da sirina i visina moraju biti neparni brojevi
    Visina mod 2 == 0, Sirina mod 2 == 0 -> writeln('Visina i sirina moraju biti neparni brojevi'), Var = invalid;
    %Stvaramo listu stpaca (jer Prolog nije Objektno orijentiran pa nema klase)
    length(Stupci,Visina), % Stupci su lista veličine Visine
    Var =.. [c|Stupci], %c je atom liste Stupci. Ovaj izraz jednak je Var = c(Stupci)
    %Stvori redove matrice
    redovi(Var, Visina, Sirina, 1),
    %Stvori zidove labirinta
    zidovi(Var, Visina, Sirina),
    %Funkcija koja stvara putove u labirintu
    stvoriPuteve(Var, 1, Visina, 1, Sirina),
    %Funkcija za postavljanje kraja i početka
    krajPocetak(Var,Visina,Sirina),
    crtaj(Var),
    !.

%Funkcija za stvaranje i popunjavanje redova matrice labirinta
redovi(_,Visina,_, Stupac):- % _ zamjenjujemo argument koji nam trenutno nije zanimljiv, a kasnije je potreban
    Stupac > Visina. % U slucaju prelaska preko vrijednosti visine, potrebno je zaustaviti izvođenje rekurzije
redovi(Var, Visina, Sirina, Stupac):-
    Stupac =< Visina, %elif uvjet
    length(Red, Sirina), %Stvara se lista red koja je duljine vrijednosti Sirine
    TrenutniRed =..[r|Red],
    setarg(Stupac, Var, TrenutniRed), %Mjenja vrijednost argumenta Vara
    succ(Stupac, SljedeciStupac), %Određuje nasljednika stupca i pohranjuje ga u varijablu SljedeciStupac
    redovi(Var, Visina, Sirina, SljedeciStupac). %Poziv rekurzije

%Funkcija za postavljanje rubnih zidova
zidovi(Var, Visina, Sirina):-
    arg(1, Var, PrviRed), %U varijablu PrviRed sprema se vrijednost Var[1]
    arg(Visina, Var, ZadnjiRed), %u varijablu ZadnjiRed sprema se vrijednost Var[Visina]
    %spremanje vrijednosti liste u Varijable Red1 i RedKraj
    PrviRed =.. [r|Red1], 
    ZadnjiRed =..[r|RedKraj],
    %Provodi se obrazac map koji postavlja + na sve elemente prvog i zadnjeg reda
    maplist(=(+), Red1), 
    maplist(=(+), RedKraj),
    %Potrebno je postaviti jos vertikalne zidove
    vertikalniZidovi(Var,Visina,Sirina,2).

%Funkcija za postavljanje vertikalnih zidova
vertikalniZidovi(Var,Visina,Sirina,I):-
    I < Visina -> %Uvjet kojim osiguravamo da index reda ne prelazi visinu
    arg(I, Var, TrenutniRed), %Var[I] = TrenutniRed
    %Postavi + za sve rubne vrijednosti reda
    TrenutniRed =.. [r|Red],
    append([+|Ostatak], [+], Red), %Ostatak su sve varijable na kojima se nije primjenila append funkcija
    %Postavi prazan prostor na sve ostale vrijednosti
    maplist(=(' '), Ostatak),
    succ(I, Sljedeci), %Određuje se naslijednik indexa I i pohranjuje u Sljedeci
    vertikalniZidovi(Var, Visina, Sirina, Sljedeci); %Rekurzivni poziv
    true.

%Funkcija koja stvara put između cvorova
stvoriPuteve(Var, Gore, Dolje ,Lijevo ,Desno):-
    Len = 3, % minimalna udaljenost između susjeda
    %Uvjet za provjeru udaljenosti
    abs(Gore - Dolje) > Len, abs(Lijevo - Desno) > Len ->
    %Poziv funkcije koja odvaja slobodne susjede postavljanjem zidova
    podijeli(Var, Gore, Dolje, Lijevo, Desno, Red, Stupac),
    %Rekurzivni pozivi za provjere susjeda cvora
    stvoriPuteve(Var, Red, Dolje, Stupac, Desno),
    stvoriPuteve(Var, Red, Dolje, Lijevo, Stupac),
    stvoriPuteve(Var, Gore, Red, Stupac, Desno),
    stvoriPuteve(Var, Gore, Red, Lijevo, Stupac);
    true.

%Funkcija koja postavlja zidove između slobodnih susjeda
podijeli(Var, Gore, Dolje, Lijevo, Desno, Red, Stupac):-
    %Pozivi funkcija koji postavljaju vertikalne i horizontalne zidove između cvorova te funkcije koja generira put
    postaviZidv(Var,Gore,Dolje,Lijevo,Desno,Stupac),
    postaviZidh(Var, Gore,Dolje,Lijevo,Desno, Red),
    put(Var, Gore, Dolje, Lijevo, Desno, Red, Stupac).

%Funkcija koja stvara put između cvorova
put(Var,Gore,Dolje,Lijevo,Desno,Red,Stupac):-
    random_between(1,4,Broj), %U varijablu broj sprema se random broj od 1-4 koji predstavlja strane susjeda
    %Uvjeti koji ako vrijede - rusi se zid između ta dva cvora i stvara se put
    (Broj =\= 1 -> stvoriVertikalni(Var, Stupac, Gore, Red); true),
    (Broj =\= 2 -> stvoriVertikalni(Var, Stupac, Red, Dolje); true),
    (Broj =\= 3 -> stvoriHorizontalni(Var, Red, Lijevo, Stupac); true),
    (Broj =\= 4 -> stvoriHorizontalni(Var, Red, Stupac, Desno); true).

%Funkcija koja postavlja vertikalne zidove između susjednih cvorova lijevo i desno
postaviZidv(Var, Gore,Dolje,Lijevo,Desno,Stupac):-
    % Stvaramo L i D kao varijable kojima određujemo moguće pozicije zidova između cvorova
    L is (Lijevo + 2) // 2,
    D is (Desno - 2) // 2,
    %Zidove postavimo na random poziciju između definiranih varijabli L i D
    random_between(L, D, Mult),
    Stupac is 2 * Mult + 1,
    %Pozivamo funkciju za crtanje zida
    stvoriVertikalniZid(Var, Stupac, Gore, Dolje).

%Funkcija koja posjecene susjede pretvara u zidove
stvoriVertikalniZid(Var, Stupac, Gore, Dolje):-
    %Postavimo uvjet kako bi se osigurali da se nalazimo unutar grida labirinta
    Gore =< Dolje ->
    %U varijablu Red spremamo vrijednost Var[Gore] odnosno vrijednost gornjeg susjeda
    arg(Gore, Var, Red),
    %Pretvaramo gornjeg susjeda u zid
    setarg(Stupac, Red, '+'),
    %Trazimo nasljednika gornjeg susjeda i spremamo ga u varijablu G
    succ(Gore, G), % G = Gore + 1
    stvoriVertikalniZid(Var, Stupac, G, Dolje); %Rekurzivni poziv funkcije
    true.
%Funkcija koja postavlja horizontalne zidove između susjednih cvorova lijevo i desno
%Radi na istom principu kao  funkcija za vertikalne zidove samo umjesto Lijevo-Desno koristi susjede Gore - Dolje te umjesto
%Stupaca, prolazi po redovima matrice (grida labirinta)
postaviZidh(Var, Gore, Dolje, Lijevo, Desno, Red):-
    G is (Gore + 2) // 2,
    D is (Dolje -2) // 2,
    random_between(G,D,Mult),
    Red is 2*Mult + 1,
    stvoriHorizontalniZid(Var,Red,Lijevo, Desno).
%Funkcija koja stvara horizontalne zidove između susjednih cvorova gore i dolje
stvoriHorizontalniZid(Var, Ired, Lijevo, Desno):-
    Lijevo =< Desno ->
    arg(Ired, Var, Red),
    setarg(Lijevo, Red, '+'),
    succ(Lijevo,L), % L = Lijevo +1
    stvoriHorizontalniZid(Var,Ired,L,Desno);
    true.

%Funkcija koja na isti način kao što postavlja zidove, postavlja praznine koje prikazuju put labirinta
stvoriHorizontalni(Var,Ired,Lijevo,Desno):-
    L is (Lijevo + 1) // 2,
    D is (Desno -1) // 2,
    random_between(L, D, Mult),
    Istupac is 2*Mult,
    arg(Ired, Var, Red),
    setarg(Istupac, Red, ' '). %Na nasumičnoj poziciji susjednog cvora postavlja se praznina=' ' umjesto zida='+'
%Funkcija koja postavlja vertikalne praznine - isto kao prethodna funkcija za horizontalne
stvoriVertikalni(Var, Istupac, Gore, Dolje):-
    G is (Gore +1) // 2,
    D is (Dolje - 1) // 2,
    random_between(G,D,Mult),
    Ired is 2* Mult,
    arg(Ired,Var, Red),
    setarg(Istupac, Red, ' ').

%Funkcija kojom definiramo ulaz i izlaz labirinta na rubnim zidovima
krajPocetak(Var,Visina,Sirina):-
    S is (Sirina - 1) // 2, 
    random_between(1, S, MultPocetak), %Odabiremo nasumican broj između pocetnog i posljednjeg elementa reda (trenutno zida) kojeg pretvaramo u prazninu odnosno ulaz
    random_between(1, S, MultKraj), %Na isti način stvaramo varijablu koja će u zadnjem redu pretstavljati graj
    arg(1,Var,Vrh), %Spremamo prvi red u varijablu Vrh
    Pocetak is MultPocetak * 2, %Stvaramo varijablu Pocetak u koju pohranjujemo poziciju na kojoj se nalazi ulaz
    setarg(Pocetak, Vrh, ' '), %Pretvaramo zid na toj poziciju u prazninu
    %Sljedi isti postupak za dno
    arg(Visina, Var, Dno), 
    Kraj is MultKraj * 2,
    setarg(Kraj, Dno, ' ').

%Funkcija koja crta labirint
crtaj(Var):-
    functor(Var, _, Visina), %ovo je nesto slicno lambda funkciji koji omogucava pokretanje prethodne funkcije u kojoj je naveden sve dok se ona ne izvrsi
    nl, %nl = new line - novi red u prikazu u terminal
    crtaj(Var, Visina, 1). %Poziv funkcije sa argumentima

crtaj(Var, Visina, I):-
    %Rubni uvjet da se labirint crta dok index ne dosegne vrijednost visine
    I =< Visina ->
    arg(I,Var, Red), %Red = Var[I]
    Red =.. [r|Lista], %Lista = elementi reda
    writeln(Lista), %pisemo elemente pohranjene u Listu (izg. [+, ,+,+,+,+...])
    succ(I,Sljedeci), %Nasljednik indexa I (i=i+1 -> sljedeci=I+1)
    crtaj(Var, Visina, Sljedeci); %Pokrece se rekurzija
    nl,true.