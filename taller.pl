% -- Hechos (Base de Conocimientos) --
personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).

% Personajes nuevos --- Estructura (Nombre, Nivel, Vida).
personaje('Kratos',7, 150).
personaje('Nathan Drake', 5, 90).
personaje('Crash Bandicoot', 2, 50).

mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragon', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).

inventario('Kratos',[hacha_leviatan, espadas_caos, lanza_espartana]).
inventario('Nathan Drake',[diario, pistola, rifle_m16]).
inventario('Crash Bandicoot',[pato_ule, mascara, zapatos_velocidad]).

% Armas con puntos de ataque --- Estructura (Nombre, PuntosAtaque)
arma(espada, 10).
arma(pocion, 2).
arma(escudo, 3).
arma(arco, 20).
arma(varita, 50).
arma(grimorio, 60).
arma(hacha_leviatan, 200).
arma(espadas_caos, 250).
arma(lanza_espartana, 100).
arma(pistola, 75).
arma(rifle_m16, 90).
arma(pato_ule, 1).
arma(zapatos_velocidad, 30).

% Tipos de enemigos --- Estructura (Nombre, Franquicia, Vida)
enemigo('Valkyria', 'God of War', 300).
enemigo('Mercenario', 'Uncharted', 80).
enemigo('Jabali', 'Crash Bandicoot', 25).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).


% -- Reglas originales --

puede_aceptar(Personaje, ID_Mision) :-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _),
    Nivel >= Dificultad.

xp_acumulada(0, 0).
xp_acumulada(N, Total) :-
    N > 0,
    N1 is N - 1,
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).

tiene_requerido(Personaje, Objeto) :-
    inventario(Personaje, Lista),
    member(Objeto, Lista).

mismo_nivel(P1, P2) :-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.

es_balanceado(Personaje) :-
    personaje(Personaje, _, Vida),
    Vida =:= 100.

fusionar_equipo(P1, P2, EquipoFusionado) :-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).


% -- Nuevas reglas --

% Regla 1: El personaje tiene al menos un arma en su inventario
tiene_arma(Personaje) :-
    inventario(Personaje, Lista),
    member(Arma, Lista),
    arma(Arma, _).

% Regla 2: El personaje es de alto nivel (mayor a 5)
es_alto_nivel(Personaje) :-
    personaje(Personaje, Nivel, _),
    Nivel > 5.


% -- Conjugacion verbal --

tiempo(presente). tiempo(pasado). tiempo(futuro).
persona(primera). persona(segunda). persona(tercera).
numero(singular). numero(plural).

ser(presente, tercera, singular, 'es').
ser(pasado,   tercera, singular, 'fue').
ser(futuro,   tercera, singular, 'sera').
ser(presente, primera, singular, 'soy').
ser(presente, primera, plural,   'somos').
ser(presente, tercera, plural,   'son').
ser(pasado,   tercera, plural,   'fueron').
ser(futuro,   tercera, plural,   'seran').

derrotar(presente, tercera, singular, 'derrota').
derrotar(pasado,   tercera, singular, 'derroto').
derrotar(futuro,   tercera, singular, 'derrotara').
derrotar(presente, tercera, plural,   'derrotan').
derrotar(pasado,   tercera, plural,   'derrotaron').
derrotar(futuro,   tercera, plural,   'derrotaran').

eliminar(presente, tercera, singular, 'elimina').
eliminar(pasado,   tercera, singular, 'elimino').
eliminar(futuro,   tercera, singular, 'eliminara').
eliminar(presente, tercera, plural,   'eliminan').
eliminar(pasado,   tercera, plural,   'eliminaron').
eliminar(futuro,   tercera, plural,   'eliminaran').

sobrevivir(presente, tercera, singular, 'sobrevive').
sobrevivir(pasado,   tercera, singular, 'sobrevivio').
sobrevivir(futuro,   tercera, singular, 'sobrevivira').
sobrevivir(presente, tercera, plural,   'sobreviven').
sobrevivir(pasado,   tercera, plural,   'sobrevivieron').
sobrevivir(futuro,   tercera, plural,   'sobreviviran').

conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion) :-
    tiempo(Tiempo), persona(Persona), numero(Numero),
    ( Verbo = ser        -> ser(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = derrotar   -> derrotar(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = eliminar   -> eliminar(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = sobrevivir -> sobrevivir(Tiempo, Persona, Numero, Conjugacion)
    ;                       Conjugacion = Verbo
    ).


% -- Logica de grupos y misiones --

sumar_xp_grupo([], 0).
sumar_xp_grupo([H|T], Total) :-
    personaje(H, Nivel, _),
    xp_acumulada(Nivel, XP_H),
    sumar_xp_grupo(T, XP_T),
    Total is XP_H + XP_T.

grupo_puede_aceptar(Grupo, MisionID) :-
    mision(MisionID, _, _, XP_Requerida),
    sumar_xp_grupo(Grupo, XP_Total),
    XP_Total >= XP_Requerida.

grupo_cumple_requisitos(Grupo, MisionID) :-
    forall(
        requiere(MisionID, Objeto),
        (member(P, Grupo), tiene_requerido(P, Objeto))
    ).

unir_nombres([Unico], Unico).
unir_nombres([P1, P2], R) :-
    atomic_list_concat([P1, 'y', P2], ' ', R).
unir_nombres([P1|Resto], R) :-
    unir_nombres(Resto, TextoResto),
    atomic_list_concat([P1, ',', TextoResto], ' ', R).

generar_reporte_grupo(Grupo, MisionID, Mensaje) :-
    grupo_puede_aceptar(Grupo, MisionID),
    grupo_cumple_requisitos(Grupo, MisionID),
    mision(MisionID, NombreMision, _, XP_Requerida),
    sumar_xp_grupo(Grupo, XP_Total),
    unir_nombres(Grupo, Nombres),
    length(Grupo, N),
    ( N =:= 1 ->
        conjugar_accion(ser, presente, tercera, singular, Verbo),
        Etiqueta = 'El aventurero'
    ;
        conjugar_accion(ser, presente, tercera, plural, Verbo),
        Etiqueta = 'El grupo'
    ),
    atomic_list_concat(
        [Nombres, '(', Etiqueta, ')', Verbo,
         'capaces de completar:', NombreMision,
         '| XP requerida:', XP_Requerida,
         '| XP del grupo:', XP_Total],
        ' ', Mensaje
    ).

generar_reporte_grupo(Grupo, MisionID, Mensaje) :-
    \+ grupo_puede_aceptar(Grupo, MisionID),
    mision(MisionID, NombreMision, _, XP_Requerida),
    sumar_xp_grupo(Grupo, XP_Total),
    unir_nombres(Grupo, Nombres),
    atomic_list_concat(
        [Nombres, 'no tienen XP suficiente para:', NombreMision,
         '| XP requerida:', XP_Requerida,
         '| XP del grupo:', XP_Total],
        ' ', Mensaje
    ).

generar_reporte_grupo(Grupo, MisionID, Mensaje) :-
    grupo_puede_aceptar(Grupo, MisionID),
    \+ grupo_cumple_requisitos(Grupo, MisionID),
    mision(MisionID, NombreMision, _, _),
    unir_nombres(Grupo, Nombres),
    atomic_list_concat(
        [Nombres, 'tienen XP suficiente pero les falta equipamiento para:', NombreMision],
        ' ', Mensaje
    ).


% -- Combate --

arma_mas_fuerte([Item], Item) :-
    arma(Item, _), !.
arma_mas_fuerte([Item|Resto], MejorArma) :-
    \+ arma(Item, _), !,
    arma_mas_fuerte(Resto, MejorArma).
arma_mas_fuerte([Item|Resto], MejorArma) :-
    arma(Item, _),
    ( arma_mas_fuerte(Resto, MejorResto) ->
        arma(Item, D1),
        arma(MejorResto, D2),
        ( D1 >= D2 -> MejorArma = Item ; MejorArma = MejorResto )
    ;
        MejorArma = Item
    ).

danio_jugador(Personaje, Arma, Danio) :-
    inventario(Personaje, Inventario),
    arma_mas_fuerte(Inventario, Arma),
    arma(Arma, Danio).

danio_grupo([], [], 0).
danio_grupo([P|Resto], [Arma|ArmasResto], Total) :-
    danio_jugador(P, Arma, D),
    danio_grupo(Resto, ArmasResto, DResto),
    Total is D + DResto.

% Caso A: el ataque MATA al enemigo
ejecutar_ataque(Grupo, Enemigo, Mensaje) :-
    danio_grupo(Grupo, Armas, Total),
    enemigo(Enemigo, _, Vida),
    Total >= Vida,
    length(Grupo, N),
    ( N =:= 1 ->
        conjugar_accion(derrotar, pasado, tercera, singular, Verbo)
    ;
        conjugar_accion(derrotar, pasado, tercera, plural, Verbo)
    ),
    unir_nombres(Grupo, Jugadores),
    unir_nombres(Armas, NombresArmas),
    atomic_list_concat(
        [Jugadores, 'atacaron con', NombresArmas,
         'causando', Total, 'de danio y', Verbo, 'a', Enemigo],
        ' ', Mensaje
    ).

% Caso B: el ataque NO mata al enemigo
ejecutar_ataque(Grupo, Enemigo, Mensaje) :-
    danio_grupo(Grupo, Armas, Total),
    enemigo(Enemigo, _, Vida),
    Total < Vida,
    length(Grupo, N),
    ( N =:= 1 ->
        conjugar_accion(sobrevivir, pasado, tercera, singular, Verbo)
    ;
        conjugar_accion(sobrevivir, pasado, tercera, plural, Verbo)
    ),
    unir_nombres(Grupo, Jugadores),
    unir_nombres(Armas, NombresArmas),
    atomic_list_concat(
        [Jugadores, 'atacaron con', NombresArmas,
         'causando', Total, 'de danio pero', Enemigo, Verbo, 'al ataque'],
        ' ', Mensaje
    ).