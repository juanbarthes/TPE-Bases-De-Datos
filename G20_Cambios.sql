ALTER TABLE GR20_USUARIO
ADD COLUMN cantidad_grupos_comun int,
ADD COLUMN cantidad_grupos_excl  int;

ALTER TABLE GR20_INTEGRA
ADD COLUMN activo bool;

--FUNCIONES  Y TRIGGERS ACTIVADOS POR EVENTOS DE LA TABLA GR20_USUARIO--

--Esta funcion sirve para insertar la fila con los campos cantidad_grupos_comun y cantidad_grupos_excl en valor 0
-- De esta forma se evita que algun usuario o aplicacion inserte una fila con estas cantidades iniciadas en algun valor diferente--
create or replace function TRFN_GR20_userInsert()
returns trigger as $$
    begin
        new.cantidad_grupos_excl := 0;
        new.cantidad_grupos_comun := 0;
        return new;
    end;
    $$
language 'plpgsql';

--Este trigger despierta cada vez que se quiere insertar una fila en la tabla usuario--
create trigger TR_GR20_GR20_USUARIO_userInsert
    before insert on GR20_USUARIO
    for each row
    execute procedure TRFN_GR20_userInsert();

/* insert into gr20_usuario
values ('t01', 2727, 'Cordoba', 'Marco', 'marqui', 1, 2); */

/*insert into gr20_usuario
values ('t02', 7272, 'Barthes', 'Juan', 'ryuma');*/

/*insert into gr20_grupo
values (101, 'Crnogorci', 6, 'e');*/
------------------------------------------------------------------------------------------------------------------------

--FUNCIONES  Y TRIGGERS ACTIVADOS POR EVENTOS DE LA TABLA GR20_INTEGRA--

/* Esta funcion se encarga de chequear si es necesario actualizar la tabla USUARIO en base al valor del campo activo
   del INSERT, de ser asi efectua dicha actualizacion*/
create or replace function TRFN_GR20_rowInsert()
returns trigger as $$
    declare
        grupType char(1);
        n record;
    begin
        select * into n
        from newTable;
        if (n.activo = true) then
            select gr.tipo_gr into grupType -- Se obtiene el tipo de grupo para determinar que campo de USUARIO actualizar.
        from GR20_GRUPO as gr
        where gr.nro_grupo = n.nro_grupo;
        if (upper(grupType) like 'C') then -- C para tipo de grupo comun--
            update GR20_USUARIO as usuario
            set cantidad_grupos_comun = cantidad_grupos_comun + 1
            where usuario.tipo_usuario = n.tipo_usuario and usuario.cod_usuario = n.cod_usuario;
            else
                if (upper(grupType) like 'E') then -- E para tipo de grupo exclusivo --
                    update GR20_USUARIO as usuario
                    set cantidad_grupos_excl = cantidad_grupos_excl + 1
                    where usuario.tipo_usuario = n.tipo_usuario and usuario.cod_usuario = n.cod_usuario;
                    end if;
            end if;
        end if;
        return null;
    end;
    $$
language 'plpgsql';

/* Este trigger despierta luego de realizar un INSERT en la tabla INTEGRA */
create trigger TR_GR20_INTEGRA_rowInsert
    after insert
    on GR20_INTEGRA
    referencing NEW TABLE  as newTable
    execute procedure TRFN_GR20_rowInsert();

------------------------------------------------------------------------------------------------------------------------

/*Esta funcion se encarga de determinar si las filas de la tabla INTEGRA que fueron borradas poseian el campo activo en
  false, de ser asi procede a actualizar la tabla USUARIO deacuerdo a la nueva cantidad de grupos en los que el
  usuario esta activo*/
create or replace function TRFN_GR20_rowDelete()
    returns trigger as
$$
declare
    grupType char(1);
    rec      record;
    oldTableCursor Cursor for select *
                              from oldTable;
begin
    for rec in oldTableCursor
        loop
            if (rec.activo = true) then
                select gr.tipo_gr
                into grupType
                from GR20_GRUPO as gr
                where gr.nro_grupo = rec.nro_grupo;
                if (upper(grupType) = 'C') then -- C para tipo de grupo comun--
                    update GR20_USUARIO usuario
                    set cantidad_grupos_comun = cantidad_grupos_comun - 1
                    where usuario.tipo_usuario = rec.tipo_usuario
                      and usuario.cod_usuario = rec.cod_usuario
                      and usuario.cantidad_grupos_comun > 0;
                else
                    if (upper(grupType) = 'E') then -- E para tipo de grupo exclusivo --
                        update GR20_USUARIO usuario
                        set cantidad_grupos_excl = cantidad_grupos_excl - 1
                        where usuario.tipo_usuario = rec.tipo_usuario
                          and usuario.cod_usuario = rec.cod_usuario
                          and usuario.cantidad_grupos_excl > 0;
                    end if;
                end if;
            end if;
        end loop;
    return null;
end;
$$
    language 'plpgsql';

/*Este trigger despierta cuando realizar un DELETE en la tabla INTEGRA*/
create trigger TR_GR20_INTEGRA_rowDelete
    after delete
    on GR20_INTEGRA
    referencing OLD TABLE  as oldTable
    execute procedure TRFN_GR20_rowDelete();

-----------------------------------------------------------------------------------------------------------------------

/*Esta funcion se encarga de checkear si es necesario realizar cambios en la tabla USUARIO en vase a analizar los
 distintos valores de la columna activo en la tabla INTEGRA, de ser necesario procede con la actualizacion de la tabla USUARIO*/
create or replace function TRFN_GR20_rowUpdate()
    returns trigger as
$$
declare
    grupType char(1);
    oldRec   record;
    newRec   record;
    oldTableCursor cursor for select *
                              from oldTable;
    newTableCursor cursor for select *
                              from newTable;
begin
    open oldTableCursor;
    open newTableCursor;
    fetch oldTableCursor into oldRec;
    fetch newTableCursor into newRec;
    while (found)
        loop
            select gr.tipo_gr
            into grupType
            from GR20_GRUPO as gr
            where gr.nro_grupo = newRec.nro_grupo;
            if (upper(grupType) = 'C') then -- C indica que el grupo es del tipo comun.
                if ((oldRec.activo = FALSE) and (newRec.activo = TRUE)) then
                    update GR20_USUARIO as usuario
                    set cantidad_grupos_comun = cantidad_grupos_comun + 1
                    where (usuario.tipo_usuario = newRec.tipo_usuario and usuario.cod_usuario = newRec.cod_usuario);
                end if;
                if ((oldRec.activo = TRUE) and (newRec.activo = FALSE)) then
                    update GR20_USUARIO as usuario
                    set cantidad_grupos_comun = cantidad_grupos_comun - 1
                    where (usuario.tipo_usuario = newRec.tipo_usuario and usuario.cod_usuario = newRec.cod_usuario);
                end if;
            end if;
            if (upper(grupType) = 'E') then -- E indica que el grupo es del tipo exclusivo.
                if ((oldRec.activo = FALSE) and (newRec.activo = TRUE)) then -- Comprueba si la columna activo cambio a un valor diferente luego del update.
                    update GR20_USUARIO as usuario
                    set cantidad_grupos_excl = cantidad_grupos_excl + 1
                    where (usuario.tipo_usuario = newRec.tipo_usuario and usuario.cod_usuario = newRec.cod_usuario);
                end if;
                if ((oldRec.activo = TRUE) and (newRec.activo = FALSE)) then -- Comprueba si la columna activo cambio a un valor diferente luego del update.
                    update GR20_USUARIO as usuario
                    set cantidad_grupos_excl = cantidad_grupos_excl - 1
                    where (usuario.tipo_usuario = newRec.tipo_usuario and usuario.cod_usuario = newRec.cod_usuario);
                end if;
            end if;
            fetch oldTableCursor into oldRec;
            fetch newTableCursor into newRec;
        end loop;
    return null;
end;
$$
    language 'plpgsql';


/*Este trigger despierta luego de realizar un UPDATE en la tabla INTEGRA*/
create trigger TR_GR20_INTEGRA_rowUpdate
    after update
    on GR20_INTEGRA
    referencing OLD TABLE as oldTable
                NEW TABLE as newTable
    execute procedure TRFN_GR20_rowUpdate();

------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------VISTAS---------------------------------------------------------

/*Esta vista contiene los datos de las tablas GRUPO y GR_COMUN para todos los grupos comunes*/
create view GR20_V_GRUPO_COMUN as
    select grupo.nro_grupo, grupo.nombre_grupo, grupo.limite_integrantes, grComun.caracteristica
    from GR20_GRUPO grupo join GR20_GR_COMUN grComun
        on grupo.nro_grupo = grComun.nro_grupo
    order by grupo.nro_grupo;


/*Esta vista contiene los datos de las tablas GRUPO y GR_EXCLUSIVO para todos los grupos exclusivos*/
create view GR20_V_GRUPO_EXCLUSIVO as
    select grupo.nro_grupo, grupo.nombre_grupo, grupo.limite_integrantes, grExclusivo.perfil
    from GR20_GRUPO grupo join GR20_GR_EXCLUSIVO grExclusivo
        on grupo.nro_grupo = grExclusivo.nro_grupo
    order by grupo.nro_grupo;


/*Esta vista contiene los grupos que son integrados por todos los usuarios.*/
create view  GR20_V_GRUPOS_COMP as
    select i.nro_grupo, g.nombre_grupo
    from GR20_INTEGRA i join GR20_GRUPO g
    on i.nro_grupo = g.nro_grupo
    group by i.nro_grupo, g.nombre_grupo
    having count(*) = (select count(*) from GR20_USUARIO);


/*Esta vista contiene todos los datos de los grupos, incluidos los de las tablas GR_COMUN Y GR_EXCLUSIVO,
  tambien contiene la cantidad de usuarios de cada grupo.*/
create view GR20_V_GRUPOS_INTEG as
    select g.*, (select gr_c.caracteristica as caracteristica
        from gr20_gr_comun gr_c
        where g.nro_grupo = gr_c.nro_grupo),
           (select gr_e.perfil as perfil
           from gr20_gr_exclusivo gr_e
               where g.nro_grupo = gr_e.nro_grupo),
           (select count(*) as cantidad_usuarios
               from gr20_integra i
               where g.nro_grupo = i.nro_grupo)
    from gr20_grupo g;

--------------------------TRIGGERS Y FUNCIONES PARA TR_GR20_V_GRUPO_COMUN ----------------------------------------------

/*Esta funcion se encarga de realizar INSERT en las tablas GRUPO y GR_COMUN*/
create or replace function TRFN_GR20_commonGroupViewInsert()
returns trigger as $$
    begin
        insert into GR20_GRUPO
        values (new.nro_grupo, new.nombre_grupo, new.limite_integrantes, 'C');
        insert into GR20_GR_COMUN
        values (new.nro_grupo, new.caracteristica);
        return new;
    end
    $$
language 'plpgsql';


/*Este trigger despierta cuando se intenta realizar un INSERT en la vista V_GRUPO_COMUN*/
create trigger TR_GR20_V_GRUPO_COMUN_rowInsert
    instead of insert
    on GR20_V_GRUPO_COMUN
    for each row
    execute procedure TRFN_GR20_commonGroupViewInsert();



/*Esta funcion se encarga de actualizar las tablas GRUPO y GR_COMUN*/
create or replace function TRFN_GR20_commonGroupViewUpdate()
returns trigger as $$
    begin
        update GR20_GRUPO
        set nombre_grupo = new.nombre_grupo,
            limite_integrantes = new.limite_integrantes,
            tipo_gr = 'C'
        where nro_grupo = new.nro_grupo;
        update GR20_GR_COMUN
        set caracteristica = new.caracteristica
        where nro_grupo = new.nro_grupo;
        return new;
    end;
    $$
language 'plpgsql';


/*Este trigger despierta cuando se intenta realizar un UPDATE en la vista V_GRUPO_COMUN*/
create trigger TR_GR20_V_GRUPO_COMUN_rowUpdate
    instead of update
    on GR20_V_GRUPO_COMUN
    for each row
    execute procedure TRFN_GR20_commonGroupViewUpdate();


/*Esta funcion se encarga de realizar el DELETE en las tablas GRUPO y GR_COMUN*/
create or replace function TRFN_GR20_commonGroupViewDelete()
returns trigger as $$
    begin
         delete from GR20_GRUPO
        where nro_grupo = old.nro_grupo;
        delete from GR20_GR_COMUN
        where nro_grupo = old.nro_grupo;
    end;
    $$
language 'plpgsql';


/*Este trigger despierta cuando se intenta realizar un DELETE en la vista V_GRUPO_COMUN*/
create trigger TR_GR20_V_GRUPO_COMUN_rowDelete
    instead of DELETE
    on GR20_V_GRUPO_COMUN
    for each row
    execute procedure TRFN_GR20_commonGroupViewDelete();
------------------------------------------------------------------------------------------------------------------------
-----------------------TRIGGERS Y FUNCIONES PARA TR_GR20_V_GRUPO_EXCLUSIVO----------------------------------------------

/*Esta funcion se encarga de realizar INSERT en las tablas GRUPO y GR_EXCLUSIVO*/
create or replace function TRFN_GR20_exclusiveGroupViewInsert()
returns trigger as $$
    begin
        insert into GR20_GRUPO
        values (new.nro_grupo, new.nombre_grupo, new.limite_integrantes, 'E');
        insert into GR20_GR_EXCLUSIVO
        values (new.nro_grupo, new.perfil);
        return new;
    end
    $$
language 'plpgsql';


/*Este trigger despierta cuando se intenta insertar una fila en la vista V_GRUPO_EXCLUSIVO*/
create trigger TR_GR20_V_GRUPO_EXCLUSIVO_rowInsert
    instead of insert
    on GR20_V_GRUPO_EXCLUSIVO
    for each row
    execute procedure TRFN_GR20_exclusiveGroupViewInsert();


/*Esta funcion se encarga de actualizar las tablas GRUPO y GR_EXCLUSIVO*/
create or replace function TRFN_GR20_exclusiveGroupViewUpdate()
returns trigger as $$
    begin
        update GR20_GRUPO
        set nombre_grupo = new.nombre_grupo,
            limite_integrantes = new.limite_integrantes,
            tipo_gr = 'E'
        where nro_grupo = new.nro_grupo;
        update GR20_GR_COMUN
        set perfil = new.perfil
        where nro_grupo = new.nro_grupo;
        return new;
    end;
    $$
language 'plpgsql';

/*Este trigger despierta cuando se intenta realizar un UPDATE en la vista V_GRUPO_EXCLUSIVO*/
create trigger TR_GR20_V_GRUPO_EXCLUSIVO_rowUpdate
    instead of UPDATE
    on GR20_V_GRUPO_EXCLUSIVO
    for each row
    execute procedure TRFN_GR20_exclusiveGroupViewUpdate();

/*Esta funcion se encarga de realizar el DELETE en las tablas GRUPO y GR_EXCLUSIVO*/
create or replace function TRFN_GR20_exclusiveGroupViewDelete()
returns trigger as $$
    begin
        delete from GR20_GRUPO
        where nro_grupo = old.nro_grupo;
        delete from GR20_GR_EXCLUSIVO
        where nro_grupo = old.nro_grupo;
    end;
    $$
language 'plpgsql';


/*Este trigger despierta cuando se intenta realizar un DELETE en la vista V_GRUPO_EXCLUSIVO*/
create trigger TR_GR20_V_GRUPO_EXCLUSIVO_rowDelete
    instead of DELETE
    on GR20_V_GRUPO_EXCLUSIVO
    for each row
    execute procedure TRFN_GR20_exclusiveGroupViewDelete();
------------------------------------------------------------------------------------------------------------------------
