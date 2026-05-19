% -- Hechos (Base de Conocimientos) --
personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).

mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragon', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).

% -- Reglas Aritmeticas y Recursivas --

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

% -- NLP: conjugacion verbal --

tiempo(presente). tiempo(pasado). tiempo(futuro).
persona(primera). persona(segunda). persona(tercera).
numero(singular). numero(plural).

ser(presente, tercera, singular, "es").
ser(pasado,   tercera, singular, "fue").
ser(futuro,   tercera, singular, "será").
ser(presente, primera, singular, "soy").
ser(presente, primera, plural,   "somos").
% plural para grupos
ser(presente, tercera, plural, "son").
ser(pasado,   tercera, plural, "fueron").
ser(futuro,   tercera, plural, "serán").

conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion) :-
    tiempo(Tiempo), persona(Persona), numero(Numero),
    ( Verbo = "ser" ->
        ser(Tiempo, Persona, Numero, R),
        Conjugacion = R
    ;   Conjugacion = Verbo
    ).

% -- Logica de grupos --

% suma la XP de todos los personajes en la lista
sumar_xp_grupo([], 0).
sumar_xp_grupo([H|T], Total) :-
    personaje(H, Nivel, _),
    xp_acumulada(Nivel, XP_H),
    sumar_xp_grupo(T, XP_T),
    Total is XP_H + XP_T.

% el grupo puede ir si su XP combinada alcanza la requerida
grupo_puede_aceptar(Grupo, MisionID) :-
    mision(MisionID, _, _, XP_Requerida),
    sumar_xp_grupo(Grupo, XP_Total),
    XP_Total >= XP_Requerida.

% verifica que algun miembro del grupo tenga cada objeto requerido
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

% -- Generacion de reporte narrativo --

% caso exitoso: XP suficiente y equipo completo
generar_reporte_grupo(Grupo, MisionID, Mensaje) :-
    grupo_puede_aceptar(Grupo, MisionID),
    grupo_cumple_requisitos(Grupo, MisionID),
    mision(MisionID, NombreMision, _, XP_Requerida),
    sumar_xp_grupo(Grupo, XP_Total),
    unir_nombres(Grupo, Nombres),
    length(Grupo, N),
    ( N =:= 1 ->
        conjugar_accion("ser", presente, tercera, singular, Verbo),
        Etiqueta = 'El aventurero'
    ;
        conjugar_accion("ser", presente, tercera, plural, Verbo),
        Etiqueta = 'El grupo'
    ),
    atomic_list_concat(
        [Nombres, '(', Etiqueta, ')', Verbo,
         'capaces de completar:', NombreMision,
         '| XP requerida:', XP_Requerida,
         '| XP del grupo:', XP_Total],
        ' ', Mensaje
    ).

% caso fallo por XP insuficiente
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

% caso fallo por equipo incompleto
generar_reporte_grupo(Grupo, MisionID, Mensaje) :-
    grupo_puede_aceptar(Grupo, MisionID),
    \+ grupo_cumple_requisitos(Grupo, MisionID),
    mision(MisionID, NombreMision, _, _),
    unir_nombres(Grupo, Nombres),
    atomic_list_concat(
        [Nombres, 'tienen XP suficiente pero les falta equipamiento para:', NombreMision],
        ' ', Mensaje
    ).