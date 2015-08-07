/*{{{*//*{{{*//* "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica" schema */
/*}}}*/
/*{{{*/create schema "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
  ( "identity" bigserial not null primary key  , "Therapeutic_subclass_3 version" bigint not null references "Therapeutic_subclass_3"."journal" deferrable initially deferred  , "Active_ingredient-therapeutic_class version" bigint not null references "Active_ingredient-therapeutic_class"."journal" deferrable initially deferred
  , unique ("Therapeutic_subclass_3 version", "Active_ingredient-therapeutic_class version")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation"
  ( "entry"           bigint                   not null primary key references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."succession"
  ( "entry"     bigint                   not null primary key references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation"
  , "successor" bigint                   not null unique      references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active"
  ( "identity" bigint not null primary key references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
  , "entry"    bigint not null unique      references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* "prioridad" */
/*}}}*/
/*{{{*/create table "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad state"
  ( "prioridad state" bigserial not null primary key
  , "prioridad" integer not null
  )
;
/*}}}*/
/*{{{*/create table "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy"
  ( "entry" bigint not null primary key references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
  , "prioridad state" bigint not null references "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad state"
  )
;
/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."version" as
  select
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry",
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."timestamp" as "journal timestamp",
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation"."end timestamp",
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."succession"."successor",
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version",
    "Therapeutic_subclass_3 identity"."Therapeutic_subclass_2 version" as "Therapeutic_subclass_3 -> Therapeutic_subclass_2 version"
,
    "Therapeutic_subclass_3 identity"."código" as "Therapeutic_subclass_3 -> código"
,
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version",
    "Active_ingredient-therapeutic_class identity"."Active_ingredient version" as "Active_ingredient-therapeutic_class -> Active_ingredient version"
,
    "Active_ingredient-therapeutic_class identity"."variante" as "Active_ingredient-therapeutic_class -> variante"
,
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad state"."prioridad"
  from "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity" natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
  left outer join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation" on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry" = "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation"."entry")
  left outer join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."succession" on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry" = "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."succession"."entry")
  inner join "Therapeutic_subclass_3"."journal" as "Therapeutic_subclass_3 journal" on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = "Therapeutic_subclass_3 journal"."entry")
  inner join "Therapeutic_subclass_3"."identity" as "Therapeutic_subclass_3 identity" on ("Therapeutic_subclass_3 journal"."identity" = "Therapeutic_subclass_3 identity"."identity")

  inner join "Active_ingredient-therapeutic_class"."journal" as "Active_ingredient-therapeutic_class journal" on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = "Active_ingredient-therapeutic_class journal"."entry")
  inner join "Active_ingredient-therapeutic_class"."identity" as "Active_ingredient-therapeutic_class identity" on ("Active_ingredient-therapeutic_class journal"."identity" = "Active_ingredient-therapeutic_class identity"."identity")

  left outer join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy"
    on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry" = "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy"."entry")
  left outer join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad state"
    using ("prioridad state")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica" as
  select
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version",
    "Therapeutic_subclass_3 identity"."Therapeutic_subclass_2 version" as "Therapeutic_subclass_3 -> Therapeutic_subclass_2 version"
,
    "Therapeutic_subclass_3 identity"."código" as "Therapeutic_subclass_3 -> código"
,
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version",
    "Active_ingredient-therapeutic_class identity"."Active_ingredient version" as "Active_ingredient-therapeutic_class -> Active_ingredient version"
,
    "Active_ingredient-therapeutic_class identity"."variante" as "Active_ingredient-therapeutic_class -> variante"
,
    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad state"."prioridad"
  from "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active" natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity" natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
  inner join "Therapeutic_subclass_3"."journal" as "Therapeutic_subclass_3 journal" on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = "Therapeutic_subclass_3 journal"."entry")
  inner join "Therapeutic_subclass_3"."identity" as "Therapeutic_subclass_3 identity" on ("Therapeutic_subclass_3 journal"."identity" = "Therapeutic_subclass_3 identity"."identity")

  inner join "Active_ingredient-therapeutic_class"."journal" as "Active_ingredient-therapeutic_class journal" on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = "Active_ingredient-therapeutic_class journal"."entry")
  inner join "Active_ingredient-therapeutic_class"."identity" as "Active_ingredient-therapeutic_class identity" on ("Active_ingredient-therapeutic_class journal"."identity" = "Active_ingredient-therapeutic_class identity"."identity")

  left outer join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy"
    on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry" = "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy"."entry")
  left outer join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad state"
    using ("prioridad state")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."view insert"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    declare
      "new identity" bigint;
      "new entry"    bigint;
    begin
      if new."Therapeutic_subclass_3 version" is not null then
        raise exception 'insertions into % view must not specify %', 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica', 'Therapeutic_subclass_3 version';
      end if;

      if new."Active_ingredient-therapeutic_class version" is not null then
        raise exception 'insertions into % view must not specify %', 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica', 'Active_ingredient-therapeutic_class version';
      end if;

      select     "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."identity", "Therapeutic_subclass_3"."active"."entry", "Active_ingredient-therapeutic_class"."active"."entry"
      into       "new identity", new."Therapeutic_subclass_3 version", new."Active_ingredient-therapeutic_class version"
      from       "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
      inner join ("Therapeutic_subclass_3"."identity" natural join "Therapeutic_subclass_3"."journal" natural join "Therapeutic_subclass_3"."active") on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = "Therapeutic_subclass_3"."journal"."entry")
      inner join ("Active_ingredient-therapeutic_class"."identity" natural join "Active_ingredient-therapeutic_class"."journal" natural join "Active_ingredient-therapeutic_class"."active") on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = "Active_ingredient-therapeutic_class"."journal"."entry")
      where      "Therapeutic_subclass_3"."identity"."Therapeutic_subclass_2 version" = new."Therapeutic_subclass_3 -> Therapeutic_subclass_2 version" and "Therapeutic_subclass_3"."identity"."código" = new."Therapeutic_subclass_3 -> código"
      and        "Active_ingredient-therapeutic_class"."identity"."Active_ingredient version" = new."Active_ingredient-therapeutic_class -> Active_ingredient version" and "Active_ingredient-therapeutic_class"."identity"."variante" = new."Active_ingredient-therapeutic_class -> variante"
      ;

      if not found then
        select "Therapeutic_subclass_3"."active"."entry"
        into   new."Therapeutic_subclass_3 version"
        from   ("Therapeutic_subclass_3"."identity" natural join "Therapeutic_subclass_3"."journal" natural join "Therapeutic_subclass_3"."active")
        where  "Therapeutic_subclass_3"."identity"."Therapeutic_subclass_2 version" = new."Therapeutic_subclass_3 -> Therapeutic_subclass_2 version"
        and    "Therapeutic_subclass_3"."identity"."código" = new."Therapeutic_subclass_3 -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Therapeutic_subclass_3', 'Therapeutic_subclass_3', 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica';
        end if;

        select "Active_ingredient-therapeutic_class"."active"."entry"
        into   new."Active_ingredient-therapeutic_class version"
        from   ("Active_ingredient-therapeutic_class"."identity" natural join "Active_ingredient-therapeutic_class"."journal" natural join "Active_ingredient-therapeutic_class"."active")
        where  "Active_ingredient-therapeutic_class"."identity"."Active_ingredient version" = new."Active_ingredient-therapeutic_class -> Active_ingredient version"
        and    "Active_ingredient-therapeutic_class"."identity"."variante" = new."Active_ingredient-therapeutic_class -> variante"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Active_ingredient-therapeutic_class', 'Active_ingredient-therapeutic_class', 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica';
        end if;

        insert into "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
          ("Therapeutic_subclass_3 version", "Active_ingredient-therapeutic_class version") values
          (new."Therapeutic_subclass_3 version", new."Active_ingredient-therapeutic_class version")
        returning "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
        (    "identity") values
        ("new identity")
      returning "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry" into "new entry"
      ;

      insert into "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 insert"
instead of insert on public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
for each row execute procedure "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation" ("entry", "start timestamp")
      select       "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry", "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."timestamp"
      from         "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active"
      natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
      natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
      where        "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = old."Therapeutic_subclass_3 version"
      and          "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = old."Active_ingredient-therapeutic_class version"
      ;

      delete from "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active"
      using       "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity" natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
      where       "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active"."entry" = "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry"
      and         "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = old."Therapeutic_subclass_3 version"
      and         "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = old."Active_ingredient-therapeutic_class version"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
for each row execute procedure "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."update function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    declare
      "old entry" bigint;
      "new identity" bigint;
      "new entry" bigint;
    begin
      if new."Therapeutic_subclass_3 -> Therapeutic_subclass_2 version" is null then
        raise exception 'null value in column % violates not-null constraint', 'Therapeutic_subclass_3 -> Therapeutic_subclass_2 version';
      end if;

      if new."Therapeutic_subclass_3 -> código" is null then
        raise exception 'null value in column % violates not-null constraint', 'Therapeutic_subclass_3 -> código';
      end if;

      if new."Active_ingredient-therapeutic_class -> Active_ingredient version" is null then
        raise exception 'null value in column % violates not-null constraint', 'Active_ingredient-therapeutic_class -> Active_ingredient version';
      end if;

      if new."Active_ingredient-therapeutic_class -> variante" is null then
        raise exception 'null value in column % violates not-null constraint', 'Active_ingredient-therapeutic_class -> variante';
      end if;

      if
        new."Therapeutic_subclass_3 version" is not null and
        old."Therapeutic_subclass_3 version" <> new."Therapeutic_subclass_3 version"
      then
        raise exception 'updates to % view must not set %', 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica', 'Therapeutic_subclass_3 version';
      elsif
        new."Therapeutic_subclass_3 version" is null
        or old."Therapeutic_subclass_3 -> Therapeutic_subclass_2 version" <> new."Therapeutic_subclass_3 -> Therapeutic_subclass_2 version"
        or old."Therapeutic_subclass_3 -> código" <> new."Therapeutic_subclass_3 -> código"
      then
        select "Therapeutic_subclass_3"."active"."entry"
        into   new."Therapeutic_subclass_3 version"
        from   "Therapeutic_subclass_3"."active" natural join "Therapeutic_subclass_3"."identity"
        where  "Therapeutic_subclass_3"."identity"."Therapeutic_subclass_2 version" = new."Therapeutic_subclass_3 -> Therapeutic_subclass_2 version"
        and    "Therapeutic_subclass_3"."identity"."código" = new."Therapeutic_subclass_3 -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Therapeutic_subclass_3', 'Therapeutic_subclass_3', 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica';
        end if;
      end if;

      if
        new."Active_ingredient-therapeutic_class version" is not null and
        old."Active_ingredient-therapeutic_class version" <> new."Active_ingredient-therapeutic_class version"
      then
        raise exception 'updates to % view must not set %', 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica', 'Active_ingredient-therapeutic_class version';
      elsif
        new."Active_ingredient-therapeutic_class version" is null
        or old."Active_ingredient-therapeutic_class -> Active_ingredient version" <> new."Active_ingredient-therapeutic_class -> Active_ingredient version"
        or old."Active_ingredient-therapeutic_class -> variante" <> new."Active_ingredient-therapeutic_class -> variante"
      then
        select "Active_ingredient-therapeutic_class"."active"."entry"
        into   new."Active_ingredient-therapeutic_class version"
        from   "Active_ingredient-therapeutic_class"."active" natural join "Active_ingredient-therapeutic_class"."identity"
        where  "Active_ingredient-therapeutic_class"."identity"."Active_ingredient version" = new."Active_ingredient-therapeutic_class -> Active_ingredient version"
        and    "Active_ingredient-therapeutic_class"."identity"."variante" = new."Active_ingredient-therapeutic_class -> variante"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Active_ingredient-therapeutic_class', 'Active_ingredient-therapeutic_class', 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica';
        end if;
      end if;

      select "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active"."entry"
      into   "old entry"
      from   "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active" natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
      where  "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = old."Therapeutic_subclass_3 version"
      and    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = old."Active_ingredient-therapeutic_class version"
      ;

      delete from public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
      where       public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."Therapeutic_subclass_3 version" = old."Therapeutic_subclass_3 version"
      and         public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."Active_ingredient-therapeutic_class version" = old."Active_ingredient-therapeutic_class version"
      ;

      select "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."identity"
      into   "new identity"
      from   "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
      where  "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = new."Therapeutic_subclass_3 version"
      and    "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = new."Active_ingredient-therapeutic_class version"
      ;
      if not found then
        insert into "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"
          ("Therapeutic_subclass_3 version", "Active_ingredient-therapeutic_class version") values
          (new."Therapeutic_subclass_3 version", new."Active_ingredient-therapeutic_class version")
        returning "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
        (    "identity") values
        ("new identity")
      returning "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry"
      into "new entry"
      ;

      insert into "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation"."end timestamp"
      from        "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation"
      where       "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
for each row execute procedure "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* "prioridad" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."insert or update prioridad function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    declare
      "new prioridad state" bigint;
    begin
      if
        new."prioridad" is not null
      then
        if
          tg_op = 'INSERT'
          or not (old."prioridad" is not null and old."prioridad" = new."prioridad")
        then
          insert into "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad state"
            (    "prioridad") values
            (new."prioridad")
          returning   "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad state"."prioridad state"
          into        "new prioridad state"
          ;
        else
          select     "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy"."prioridad state"
          into       "new prioridad state"
          from       "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity" natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active" natural join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"
          inner join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."succession" on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."journal"."entry" = "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."succession"."successor")
          inner join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy" on ("Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."succession"."entry" = "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy"."entry")
          where      "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = new."Therapeutic_subclass_3 version"
          and        "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = new."Active_ingredient-therapeutic_class version"
          ;
        end if;

        insert into  "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."prioridad proxy" ("entry", "prioridad state")
        select       "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active"."entry", "new prioridad state"
        from         "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity" inner join "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."active" using ("identity")
        where        "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Therapeutic_subclass_3 version" = new."Therapeutic_subclass_3 version"
        and          "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."identity"."Active_ingredient-therapeutic_class version" = new."Active_ingredient-therapeutic_class version"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update prioridad"
instead of insert or update on public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
for each row execute procedure "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."insert or update prioridad function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Reference triggers */
/*}}}*/
/*{{{*//*{{{*//* cascade on update to "Therapeutic_subclass_3" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."cascade update on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Therapeutic_subclass_3 reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
      set
        ( "Therapeutic_subclass_3 version"
        , "Therapeutic_subclass_3 -> Therapeutic_subclass_2 version"
        , "Therapeutic_subclass_3 -> código"
        )
      = ( null
        , "Therapeutic_subclass_3"."version"."Therapeutic_subclass_2 version"
        , "Therapeutic_subclass_3"."version"."código"
        )
      from  "Therapeutic_subclass_3"."version"
      where new."entry" = public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."Therapeutic_subclass_3 version"
      and   new."entry" = "Therapeutic_subclass_3"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Therapeutic_subclass_3 reference"
after insert on "Therapeutic_subclass_3"."succession"
for each row execute procedure "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."cascade update on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Therapeutic_subclass_3 reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Therapeutic_subclass_3" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."restrict delete on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Therapeutic_subclass_3 reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
      where   public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."Therapeutic_subclass_3 version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Therapeutic_subclass_3'
        , 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica'
        , 'Therapeutic_subclass_3'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Therapeutic_subclass_3 reference"
after insert on "Therapeutic_subclass_3"."revocation"
deferrable initially deferred
for each row execute procedure "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."restrict delete on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Therapeutic_subclass_3 reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* cascade on update to "Active_ingredient-therapeutic_class" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."cascade update on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Active_ingredient-therapeutic_class reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
      set
        ( "Active_ingredient-therapeutic_class version"
        , "Active_ingredient-therapeutic_class -> Active_ingredient version"
        , "Active_ingredient-therapeutic_class -> variante"
        )
      = ( null
        , "Active_ingredient-therapeutic_class"."version"."Active_ingredient version"
        , "Active_ingredient-therapeutic_class"."version"."variante"
        )
      from  "Active_ingredient-therapeutic_class"."version"
      where new."entry" = public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."Active_ingredient-therapeutic_class version"
      and   new."entry" = "Active_ingredient-therapeutic_class"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Active_ingredient-therapeutic_class reference"
after insert on "Active_ingredient-therapeutic_class"."succession"
for each row execute procedure "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."cascade update on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Active_ingredient-therapeutic_class reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Active_ingredient-therapeutic_class" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."restrict delete on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Active_ingredient-therapeutic_class reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"
      where   public."Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."Active_ingredient-therapeutic_class version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Active_ingredient-therapeutic_class'
        , 'Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica'
        , 'Active_ingredient-therapeutic_class'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Active_ingredient-therapeutic_class reference"
after insert on "Active_ingredient-therapeutic_class"."revocation"
deferrable initially deferred
for each row execute procedure "Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica"."restrict delete on Relación: Therapeutic_subclass_3 - Principio activo discriminado por clase terapéutica view Active_ingredient-therapeutic_class reference"();/*}}}*//*}}}*//*}}}*//*}}}*//*}}}*//*}}}*/
