/*{{{*//*{{{*//* "Forma de identificación" schema */
/*}}}*/
/*{{{*/create schema "Forma de identificación";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Forma de identificación"."identity"
  ( "identity" bigserial not null primary key
  , "nombre" text not null
  , unique ("nombre")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Forma de identificación"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Forma de identificación"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Forma de identificación"."revocation"
  ( "entry"           bigint                   not null primary key references "Forma de identificación"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Forma de identificación"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Forma de identificación"."succession"
  ( "entry"     bigint                   not null primary key references "Forma de identificación"."revocation"
  , "successor" bigint                   not null unique      references "Forma de identificación"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Forma de identificación"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Forma de identificación"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Forma de identificación"."active"
  ( "identity" bigint not null primary key references "Forma de identificación"."identity"
  , "entry"    bigint not null unique      references "Forma de identificación"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Forma de identificación"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Forma de identificación"."version" as
  select
    "Forma de identificación"."journal"."entry",
    "Forma de identificación"."journal"."timestamp" as "journal timestamp",
    "Forma de identificación"."revocation"."end timestamp",
    "Forma de identificación"."succession"."successor",
    "Forma de identificación"."identity"."nombre"
  from "Forma de identificación"."identity" natural join "Forma de identificación"."journal"
  left outer join "Forma de identificación"."revocation" on ("Forma de identificación"."journal"."entry" = "Forma de identificación"."revocation"."entry")
  left outer join "Forma de identificación"."succession" on ("Forma de identificación"."journal"."entry" = "Forma de identificación"."succession"."entry")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Forma de identificación" as
  select
    "Forma de identificación"."identity"."nombre"
  from "Forma de identificación"."active" natural join "Forma de identificación"."identity" natural join "Forma de identificación"."journal"

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Forma de identificación"."view insert"
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
      select     "Forma de identificación"."identity"."identity"
      into       "new identity"
      from       "Forma de identificación"."identity"
      where      "Forma de identificación"."identity"."nombre" = new."nombre"
      ;

      if not found then
        insert into "Forma de identificación"."identity"
          ("nombre") values
          (new."nombre")
        returning "Forma de identificación"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Forma de identificación"."journal"
        (    "identity") values
        ("new identity")
      returning "Forma de identificación"."journal"."entry" into "new entry"
      ;

      insert into "Forma de identificación"."active"
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
instead of insert on public."Forma de identificación"
for each row execute procedure "Forma de identificación"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Forma de identificación"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Forma de identificación"."revocation" ("entry", "start timestamp")
      select       "Forma de identificación"."journal"."entry", "Forma de identificación"."journal"."timestamp"
      from         "Forma de identificación"."active"
      natural join "Forma de identificación"."identity"
      natural join "Forma de identificación"."journal"
      where        "Forma de identificación"."identity"."nombre" = old."nombre"
      ;

      delete from "Forma de identificación"."active"
      using       "Forma de identificación"."identity" natural join "Forma de identificación"."journal"
      where       "Forma de identificación"."active"."entry" = "Forma de identificación"."journal"."entry"
      and         "Forma de identificación"."identity"."nombre" = old."nombre"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Forma de identificación"
for each row execute procedure "Forma de identificación"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Forma de identificación"."update function"
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
      if new."nombre" is null then
        raise exception 'null value in column % violates not-null constraint', 'nombre';
      end if;

      select "Forma de identificación"."active"."entry"
      into   "old entry"
      from   "Forma de identificación"."active" natural join "Forma de identificación"."identity"
      where  "Forma de identificación"."identity"."nombre" = old."nombre"
      ;

      delete from public."Forma de identificación"
      where       public."Forma de identificación"."nombre" = old."nombre"
      ;

      select "Forma de identificación"."identity"."identity"
      into   "new identity"
      from   "Forma de identificación"."identity"
      where  "Forma de identificación"."identity"."nombre" = new."nombre"
      ;
      if not found then
        insert into "Forma de identificación"."identity"
          ("nombre") values
          (new."nombre")
        returning "Forma de identificación"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Forma de identificación"."journal"
        (    "identity") values
        ("new identity")
      returning "Forma de identificación"."journal"."entry"
      into "new entry"
      ;

      insert into "Forma de identificación"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Forma de identificación"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Forma de identificación"."revocation"."end timestamp"
      from        "Forma de identificación"."revocation"
      where       "Forma de identificación"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Forma de identificación"
for each row execute procedure "Forma de identificación"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Column triggers */
/*}}}*/
/*{{{*//* Reference triggers */
/*}}}*//*}}}*//*}}}*//*}}}*/
