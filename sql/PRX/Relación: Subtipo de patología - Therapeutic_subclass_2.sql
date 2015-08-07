/*{{{*//*{{{*//* "Relación: Subtipo de patología - Therapeutic_subclass_2" schema */
/*}}}*/
/*{{{*/create schema "Relación: Subtipo de patología - Therapeutic_subclass_2";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
  ( "identity" bigserial not null primary key  , "Subtype_of_diagnosis version" bigint not null references "Subtype_of_diagnosis"."journal" deferrable initially deferred  , "Therapeutic_subclass_2 version" bigint not null references "Therapeutic_subclass_2"."journal" deferrable initially deferred
  , unique ("Subtype_of_diagnosis version", "Therapeutic_subclass_2 version")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation"
  ( "entry"           bigint                   not null primary key references "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Relación: Subtipo de patología - Therapeutic_subclass_2"."succession"
  ( "entry"     bigint                   not null primary key references "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation"
  , "successor" bigint                   not null unique      references "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Relación: Subtipo de patología - Therapeutic_subclass_2"."active"
  ( "identity" bigint not null primary key references "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
  , "entry"    bigint not null unique      references "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* "prioridad" */
/*}}}*/
/*{{{*/create table "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad state"
  ( "prioridad state" bigserial not null primary key
  , "prioridad" integer not null
  )
;
/*}}}*/
/*{{{*/create table "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy"
  ( "entry" bigint not null primary key references "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
  , "prioridad state" bigint not null references "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad state"
  )
;
/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Relación: Subtipo de patología - Therapeutic_subclass_2"."version" as
  select
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry",
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."timestamp" as "journal timestamp",
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation"."end timestamp",
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."succession"."successor",
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version",
    "Subtype_of_diagnosis identity"."código" as "Subtype_of_diagnosis -> código"
,
    "Subtype_of_diagnosis identity"."Type_of_diagnosis version" as "Subtype_of_diagnosis -> Type_of_diagnosis version"
,
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version",
    "Therapeutic_subclass_2 identity"."Therapeutic_subclass version" as "Therapeutic_subclass_2 -> Therapeutic_subclass version"
,
    "Therapeutic_subclass_2 identity"."código" as "Therapeutic_subclass_2 -> código"
,
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad state"."prioridad"
  from "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity" natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
  left outer join "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation" on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry" = "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation"."entry")
  left outer join "Relación: Subtipo de patología - Therapeutic_subclass_2"."succession" on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry" = "Relación: Subtipo de patología - Therapeutic_subclass_2"."succession"."entry")
  inner join "Subtype_of_diagnosis"."journal" as "Subtype_of_diagnosis journal" on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = "Subtype_of_diagnosis journal"."entry")
  inner join "Subtype_of_diagnosis"."identity" as "Subtype_of_diagnosis identity" on ("Subtype_of_diagnosis journal"."identity" = "Subtype_of_diagnosis identity"."identity")

  inner join "Therapeutic_subclass_2"."journal" as "Therapeutic_subclass_2 journal" on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = "Therapeutic_subclass_2 journal"."entry")
  inner join "Therapeutic_subclass_2"."identity" as "Therapeutic_subclass_2 identity" on ("Therapeutic_subclass_2 journal"."identity" = "Therapeutic_subclass_2 identity"."identity")

  left outer join "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy"
    on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry" = "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy"."entry")
  left outer join "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad state"
    using ("prioridad state")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Relación: Subtipo de patología - Therapeutic_subclass_2" as
  select
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version",
    "Subtype_of_diagnosis identity"."código" as "Subtype_of_diagnosis -> código"
,
    "Subtype_of_diagnosis identity"."Type_of_diagnosis version" as "Subtype_of_diagnosis -> Type_of_diagnosis version"
,
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version",
    "Therapeutic_subclass_2 identity"."Therapeutic_subclass version" as "Therapeutic_subclass_2 -> Therapeutic_subclass version"
,
    "Therapeutic_subclass_2 identity"."código" as "Therapeutic_subclass_2 -> código"
,
    "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad state"."prioridad"
  from "Relación: Subtipo de patología - Therapeutic_subclass_2"."active" natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity" natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
  inner join "Subtype_of_diagnosis"."journal" as "Subtype_of_diagnosis journal" on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = "Subtype_of_diagnosis journal"."entry")
  inner join "Subtype_of_diagnosis"."identity" as "Subtype_of_diagnosis identity" on ("Subtype_of_diagnosis journal"."identity" = "Subtype_of_diagnosis identity"."identity")

  inner join "Therapeutic_subclass_2"."journal" as "Therapeutic_subclass_2 journal" on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = "Therapeutic_subclass_2 journal"."entry")
  inner join "Therapeutic_subclass_2"."identity" as "Therapeutic_subclass_2 identity" on ("Therapeutic_subclass_2 journal"."identity" = "Therapeutic_subclass_2 identity"."identity")

  left outer join "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy"
    on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry" = "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy"."entry")
  left outer join "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad state"
    using ("prioridad state")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtipo de patología - Therapeutic_subclass_2"."view insert"
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
      if new."Subtype_of_diagnosis version" is not null then
        raise exception 'insertions into % view must not specify %', 'Relación: Subtipo de patología - Therapeutic_subclass_2', 'Subtype_of_diagnosis version';
      end if;

      if new."Therapeutic_subclass_2 version" is not null then
        raise exception 'insertions into % view must not specify %', 'Relación: Subtipo de patología - Therapeutic_subclass_2', 'Therapeutic_subclass_2 version';
      end if;

      select     "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."identity", "Subtype_of_diagnosis"."active"."entry", "Therapeutic_subclass_2"."active"."entry"
      into       "new identity", new."Subtype_of_diagnosis version", new."Therapeutic_subclass_2 version"
      from       "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
      inner join ("Subtype_of_diagnosis"."identity" natural join "Subtype_of_diagnosis"."journal" natural join "Subtype_of_diagnosis"."active") on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = "Subtype_of_diagnosis"."journal"."entry")
      inner join ("Therapeutic_subclass_2"."identity" natural join "Therapeutic_subclass_2"."journal" natural join "Therapeutic_subclass_2"."active") on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = "Therapeutic_subclass_2"."journal"."entry")
      where      "Subtype_of_diagnosis"."identity"."código" = new."Subtype_of_diagnosis -> código" and "Subtype_of_diagnosis"."identity"."Type_of_diagnosis version" = new."Subtype_of_diagnosis -> Type_of_diagnosis version"
      and        "Therapeutic_subclass_2"."identity"."Therapeutic_subclass version" = new."Therapeutic_subclass_2 -> Therapeutic_subclass version" and "Therapeutic_subclass_2"."identity"."código" = new."Therapeutic_subclass_2 -> código"
      ;

      if not found then
        select "Subtype_of_diagnosis"."active"."entry"
        into   new."Subtype_of_diagnosis version"
        from   ("Subtype_of_diagnosis"."identity" natural join "Subtype_of_diagnosis"."journal" natural join "Subtype_of_diagnosis"."active")
        where  "Subtype_of_diagnosis"."identity"."código" = new."Subtype_of_diagnosis -> código"
        and    "Subtype_of_diagnosis"."identity"."Type_of_diagnosis version" = new."Subtype_of_diagnosis -> Type_of_diagnosis version"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Subtype_of_diagnosis', 'Subtype_of_diagnosis', 'Relación: Subtipo de patología - Therapeutic_subclass_2';
        end if;

        select "Therapeutic_subclass_2"."active"."entry"
        into   new."Therapeutic_subclass_2 version"
        from   ("Therapeutic_subclass_2"."identity" natural join "Therapeutic_subclass_2"."journal" natural join "Therapeutic_subclass_2"."active")
        where  "Therapeutic_subclass_2"."identity"."Therapeutic_subclass version" = new."Therapeutic_subclass_2 -> Therapeutic_subclass version"
        and    "Therapeutic_subclass_2"."identity"."código" = new."Therapeutic_subclass_2 -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Therapeutic_subclass_2', 'Therapeutic_subclass_2', 'Relación: Subtipo de patología - Therapeutic_subclass_2';
        end if;

        insert into "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
          ("Subtype_of_diagnosis version", "Therapeutic_subclass_2 version") values
          (new."Subtype_of_diagnosis version", new."Therapeutic_subclass_2 version")
        returning "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
        (    "identity") values
        ("new identity")
      returning "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry" into "new entry"
      ;

      insert into "Relación: Subtipo de patología - Therapeutic_subclass_2"."active"
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
instead of insert on public."Relación: Subtipo de patología - Therapeutic_subclass_2"
for each row execute procedure "Relación: Subtipo de patología - Therapeutic_subclass_2"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtipo de patología - Therapeutic_subclass_2"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation" ("entry", "start timestamp")
      select       "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry", "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."timestamp"
      from         "Relación: Subtipo de patología - Therapeutic_subclass_2"."active"
      natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
      natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
      where        "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = old."Subtype_of_diagnosis version"
      and          "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = old."Therapeutic_subclass_2 version"
      ;

      delete from "Relación: Subtipo de patología - Therapeutic_subclass_2"."active"
      using       "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity" natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
      where       "Relación: Subtipo de patología - Therapeutic_subclass_2"."active"."entry" = "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry"
      and         "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = old."Subtype_of_diagnosis version"
      and         "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = old."Therapeutic_subclass_2 version"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Relación: Subtipo de patología - Therapeutic_subclass_2"
for each row execute procedure "Relación: Subtipo de patología - Therapeutic_subclass_2"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtipo de patología - Therapeutic_subclass_2"."update function"
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
      if new."Subtype_of_diagnosis -> código" is null then
        raise exception 'null value in column % violates not-null constraint', 'Subtype_of_diagnosis -> código';
      end if;

      if new."Subtype_of_diagnosis -> Type_of_diagnosis version" is null then
        raise exception 'null value in column % violates not-null constraint', 'Subtype_of_diagnosis -> Type_of_diagnosis version';
      end if;

      if new."Therapeutic_subclass_2 -> Therapeutic_subclass version" is null then
        raise exception 'null value in column % violates not-null constraint', 'Therapeutic_subclass_2 -> Therapeutic_subclass version';
      end if;

      if new."Therapeutic_subclass_2 -> código" is null then
        raise exception 'null value in column % violates not-null constraint', 'Therapeutic_subclass_2 -> código';
      end if;

      if
        new."Subtype_of_diagnosis version" is not null and
        old."Subtype_of_diagnosis version" <> new."Subtype_of_diagnosis version"
      then
        raise exception 'updates to % view must not set %', 'Relación: Subtipo de patología - Therapeutic_subclass_2', 'Subtype_of_diagnosis version';
      elsif
        new."Subtype_of_diagnosis version" is null
        or old."Subtype_of_diagnosis -> código" <> new."Subtype_of_diagnosis -> código"
        or old."Subtype_of_diagnosis -> Type_of_diagnosis version" <> new."Subtype_of_diagnosis -> Type_of_diagnosis version"
      then
        select "Subtype_of_diagnosis"."active"."entry"
        into   new."Subtype_of_diagnosis version"
        from   "Subtype_of_diagnosis"."active" natural join "Subtype_of_diagnosis"."identity"
        where  "Subtype_of_diagnosis"."identity"."código" = new."Subtype_of_diagnosis -> código"
        and    "Subtype_of_diagnosis"."identity"."Type_of_diagnosis version" = new."Subtype_of_diagnosis -> Type_of_diagnosis version"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Subtype_of_diagnosis', 'Subtype_of_diagnosis', 'Relación: Subtipo de patología - Therapeutic_subclass_2';
        end if;
      end if;

      if
        new."Therapeutic_subclass_2 version" is not null and
        old."Therapeutic_subclass_2 version" <> new."Therapeutic_subclass_2 version"
      then
        raise exception 'updates to % view must not set %', 'Relación: Subtipo de patología - Therapeutic_subclass_2', 'Therapeutic_subclass_2 version';
      elsif
        new."Therapeutic_subclass_2 version" is null
        or old."Therapeutic_subclass_2 -> Therapeutic_subclass version" <> new."Therapeutic_subclass_2 -> Therapeutic_subclass version"
        or old."Therapeutic_subclass_2 -> código" <> new."Therapeutic_subclass_2 -> código"
      then
        select "Therapeutic_subclass_2"."active"."entry"
        into   new."Therapeutic_subclass_2 version"
        from   "Therapeutic_subclass_2"."active" natural join "Therapeutic_subclass_2"."identity"
        where  "Therapeutic_subclass_2"."identity"."Therapeutic_subclass version" = new."Therapeutic_subclass_2 -> Therapeutic_subclass version"
        and    "Therapeutic_subclass_2"."identity"."código" = new."Therapeutic_subclass_2 -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Therapeutic_subclass_2', 'Therapeutic_subclass_2', 'Relación: Subtipo de patología - Therapeutic_subclass_2';
        end if;
      end if;

      select "Relación: Subtipo de patología - Therapeutic_subclass_2"."active"."entry"
      into   "old entry"
      from   "Relación: Subtipo de patología - Therapeutic_subclass_2"."active" natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
      where  "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = old."Subtype_of_diagnosis version"
      and    "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = old."Therapeutic_subclass_2 version"
      ;

      delete from public."Relación: Subtipo de patología - Therapeutic_subclass_2"
      where       public."Relación: Subtipo de patología - Therapeutic_subclass_2"."Subtype_of_diagnosis version" = old."Subtype_of_diagnosis version"
      and         public."Relación: Subtipo de patología - Therapeutic_subclass_2"."Therapeutic_subclass_2 version" = old."Therapeutic_subclass_2 version"
      ;

      select "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."identity"
      into   "new identity"
      from   "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
      where  "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = new."Subtype_of_diagnosis version"
      and    "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = new."Therapeutic_subclass_2 version"
      ;
      if not found then
        insert into "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"
          ("Subtype_of_diagnosis version", "Therapeutic_subclass_2 version") values
          (new."Subtype_of_diagnosis version", new."Therapeutic_subclass_2 version")
        returning "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
        (    "identity") values
        ("new identity")
      returning "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry"
      into "new entry"
      ;

      insert into "Relación: Subtipo de patología - Therapeutic_subclass_2"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Relación: Subtipo de patología - Therapeutic_subclass_2"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation"."end timestamp"
      from        "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation"
      where       "Relación: Subtipo de patología - Therapeutic_subclass_2"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Relación: Subtipo de patología - Therapeutic_subclass_2"
for each row execute procedure "Relación: Subtipo de patología - Therapeutic_subclass_2"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* "prioridad" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtipo de patología - Therapeutic_subclass_2"."insert or update prioridad function"
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
          insert into "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad state"
            (    "prioridad") values
            (new."prioridad")
          returning   "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad state"."prioridad state"
          into        "new prioridad state"
          ;
        else
          select     "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy"."prioridad state"
          into       "new prioridad state"
          from       "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity" natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."active" natural join "Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"
          inner join "Relación: Subtipo de patología - Therapeutic_subclass_2"."succession" on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."journal"."entry" = "Relación: Subtipo de patología - Therapeutic_subclass_2"."succession"."successor")
          inner join "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy" on ("Relación: Subtipo de patología - Therapeutic_subclass_2"."succession"."entry" = "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy"."entry")
          where      "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = new."Subtype_of_diagnosis version"
          and        "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = new."Therapeutic_subclass_2 version"
          ;
        end if;

        insert into  "Relación: Subtipo de patología - Therapeutic_subclass_2"."prioridad proxy" ("entry", "prioridad state")
        select       "Relación: Subtipo de patología - Therapeutic_subclass_2"."active"."entry", "new prioridad state"
        from         "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity" inner join "Relación: Subtipo de patología - Therapeutic_subclass_2"."active" using ("identity")
        where        "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Subtype_of_diagnosis version" = new."Subtype_of_diagnosis version"
        and          "Relación: Subtipo de patología - Therapeutic_subclass_2"."identity"."Therapeutic_subclass_2 version" = new."Therapeutic_subclass_2 version"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update prioridad"
instead of insert or update on public."Relación: Subtipo de patología - Therapeutic_subclass_2"
for each row execute procedure "Relación: Subtipo de patología - Therapeutic_subclass_2"."insert or update prioridad function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Reference triggers */
/*}}}*/
/*{{{*//*{{{*//* cascade on update to "Subtype_of_diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtipo de patología - Therapeutic_subclass_2"."cascade update on Relación: Subtipo de patología - Therapeutic_subclass_2 view Subtype_of_diagnosis reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Relación: Subtipo de patología - Therapeutic_subclass_2"
      set
        ( "Subtype_of_diagnosis version"
        , "Subtype_of_diagnosis -> código"
        , "Subtype_of_diagnosis -> Type_of_diagnosis version"
        )
      = ( null
        , "Subtype_of_diagnosis"."version"."código"
        , "Subtype_of_diagnosis"."version"."Type_of_diagnosis version"
        )
      from  "Subtype_of_diagnosis"."version"
      where new."entry" = public."Relación: Subtipo de patología - Therapeutic_subclass_2"."Subtype_of_diagnosis version"
      and   new."entry" = "Subtype_of_diagnosis"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Relación: Subtipo de patología - Therapeutic_subclass_2 view Subtype_of_diagnosis reference"
after insert on "Subtype_of_diagnosis"."succession"
for each row execute procedure "Relación: Subtipo de patología - Therapeutic_subclass_2"."cascade update on Relación: Subtipo de patología - Therapeutic_subclass_2 view Subtype_of_diagnosis reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Subtype_of_diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtipo de patología - Therapeutic_subclass_2"."restrict delete on Relación: Subtipo de patología - Therapeutic_subclass_2 view Subtype_of_diagnosis reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Relación: Subtipo de patología - Therapeutic_subclass_2"
      where   public."Relación: Subtipo de patología - Therapeutic_subclass_2"."Subtype_of_diagnosis version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Subtype_of_diagnosis'
        , 'Relación: Subtipo de patología - Therapeutic_subclass_2'
        , 'Subtype_of_diagnosis'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Relación: Subtipo de patología - Therapeutic_subclass_2 view Subtype_of_diagnosis reference"
after insert on "Subtype_of_diagnosis"."revocation"
deferrable initially deferred
for each row execute procedure "Relación: Subtipo de patología - Therapeutic_subclass_2"."restrict delete on Relación: Subtipo de patología - Therapeutic_subclass_2 view Subtype_of_diagnosis reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* cascade on update to "Therapeutic_subclass_2" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtipo de patología - Therapeutic_subclass_2"."cascade update on Relación: Subtipo de patología - Therapeutic_subclass_2 view Therapeutic_subclass_2 reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Relación: Subtipo de patología - Therapeutic_subclass_2"
      set
        ( "Therapeutic_subclass_2 version"
        , "Therapeutic_subclass_2 -> Therapeutic_subclass version"
        , "Therapeutic_subclass_2 -> código"
        )
      = ( null
        , "Therapeutic_subclass_2"."version"."Therapeutic_subclass version"
        , "Therapeutic_subclass_2"."version"."código"
        )
      from  "Therapeutic_subclass_2"."version"
      where new."entry" = public."Relación: Subtipo de patología - Therapeutic_subclass_2"."Therapeutic_subclass_2 version"
      and   new."entry" = "Therapeutic_subclass_2"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Relación: Subtipo de patología - Therapeutic_subclass_2 view Therapeutic_subclass_2 reference"
after insert on "Therapeutic_subclass_2"."succession"
for each row execute procedure "Relación: Subtipo de patología - Therapeutic_subclass_2"."cascade update on Relación: Subtipo de patología - Therapeutic_subclass_2 view Therapeutic_subclass_2 reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Therapeutic_subclass_2" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtipo de patología - Therapeutic_subclass_2"."restrict delete on Relación: Subtipo de patología - Therapeutic_subclass_2 view Therapeutic_subclass_2 reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Relación: Subtipo de patología - Therapeutic_subclass_2"
      where   public."Relación: Subtipo de patología - Therapeutic_subclass_2"."Therapeutic_subclass_2 version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Therapeutic_subclass_2'
        , 'Relación: Subtipo de patología - Therapeutic_subclass_2'
        , 'Therapeutic_subclass_2'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Relación: Subtipo de patología - Therapeutic_subclass_2 view Therapeutic_subclass_2 reference"
after insert on "Therapeutic_subclass_2"."revocation"
deferrable initially deferred
for each row execute procedure "Relación: Subtipo de patología - Therapeutic_subclass_2"."restrict delete on Relación: Subtipo de patología - Therapeutic_subclass_2 view Therapeutic_subclass_2 reference"();/*}}}*//*}}}*//*}}}*//*}}}*//*}}}*//*}}}*/
