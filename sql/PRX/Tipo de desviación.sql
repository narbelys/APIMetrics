/*{{{*//*{{{*//* "Tipo de desviación" schema */
/*}}}*/
/*{{{*/create schema "Tipo de desviación";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Tipo de desviación"."identity"
  ( "identity" bigserial not null primary key
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Tipo de desviación"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Tipo de desviación"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Tipo de desviación"."revocation"
  ( "entry"           bigint                   not null primary key references "Tipo de desviación"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Tipo de desviación"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Tipo de desviación"."succession"
  ( "entry"     bigint                   not null primary key references "Tipo de desviación"."revocation"
  , "successor" bigint                   not null unique      references "Tipo de desviación"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Tipo de desviación"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Tipo de desviación"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Tipo de desviación"."active"
  ( "identity" bigint not null primary key references "Tipo de desviación"."identity"
  , "entry"    bigint not null unique      references "Tipo de desviación"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Tipo de desviación"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* "descripción" */
/*}}}*/
/*{{{*/create table "Tipo de desviación"."descripción state"
  ( "descripción state" bigserial not null primary key
  , "descripción" text not null
  )
;
/*}}}*/
/*{{{*/create table "Tipo de desviación"."descripción proxy"
  ( "entry" bigint not null primary key references "Tipo de desviación"."journal"
  , "descripción state" bigint not null references "Tipo de desviación"."descripción state"
  )
;
/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Tipo de desviación"."version" as
  select
    "Tipo de desviación"."journal"."entry",
    "Tipo de desviación"."journal"."timestamp" as "journal timestamp",
    "Tipo de desviación"."revocation"."end timestamp",
    "Tipo de desviación"."succession"."successor",
    "Tipo de desviación"."identity"."identity",
    "Tipo de desviación"."descripción state"."descripción"
  from "Tipo de desviación"."identity" natural join "Tipo de desviación"."journal"
  left outer join "Tipo de desviación"."revocation" on ("Tipo de desviación"."journal"."entry" = "Tipo de desviación"."revocation"."entry")
  left outer join "Tipo de desviación"."succession" on ("Tipo de desviación"."journal"."entry" = "Tipo de desviación"."succession"."entry")
  left outer join "Tipo de desviación"."descripción proxy"
    on ("Tipo de desviación"."journal"."entry" = "Tipo de desviación"."descripción proxy"."entry")
  left outer join "Tipo de desviación"."descripción state"
    using ("descripción state")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Tipo de desviación" as
  select
    "Tipo de desviación"."identity"."identity",
    "Tipo de desviación"."descripción state"."descripción"
  from "Tipo de desviación"."active" natural join "Tipo de desviación"."identity" natural join "Tipo de desviación"."journal"
  left outer join "Tipo de desviación"."descripción proxy"
    on ("Tipo de desviación"."journal"."entry" = "Tipo de desviación"."descripción proxy"."entry")
  left outer join "Tipo de desviación"."descripción state"
    using ("descripción state")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Tipo de desviación"."view insert"
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
      if new."identity" is not null then
        raise exception 'insertions into % view must not specify surrogate key value', 'Tipo de desviación';
      end if;
      select     "Tipo de desviación"."identity"."identity"
      into       "new identity"
      from       "Tipo de desviación"."identity"
      where      "Tipo de desviación"."identity"."identity" = new."identity"
      ;

      if not found then
        insert into "Tipo de desviación"."identity"
          ("identity") values
          (default   )
        returning "Tipo de desviación"."identity"."identity"
        into "new identity"
        ;
        new."identity" := "new identity";
      end if;

      insert into "Tipo de desviación"."journal"
        (    "identity") values
        ("new identity")
      returning "Tipo de desviación"."journal"."entry" into "new entry"
      ;

      insert into "Tipo de desviación"."active"
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
instead of insert on public."Tipo de desviación"
for each row execute procedure "Tipo de desviación"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Tipo de desviación"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Tipo de desviación"."revocation" ("entry", "start timestamp")
      select       "Tipo de desviación"."journal"."entry", "Tipo de desviación"."journal"."timestamp"
      from         "Tipo de desviación"."active"
      natural join "Tipo de desviación"."identity"
      natural join "Tipo de desviación"."journal"
      where        "Tipo de desviación"."identity"."identity" = old."identity"
      ;

      delete from "Tipo de desviación"."active"
      using       "Tipo de desviación"."identity" natural join "Tipo de desviación"."journal"
      where       "Tipo de desviación"."active"."entry" = "Tipo de desviación"."journal"."entry"
      and         "Tipo de desviación"."identity"."identity" = old."identity"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Tipo de desviación"
for each row execute procedure "Tipo de desviación"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Tipo de desviación"."update function"
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
      if new."identity" is not null and new."identity" <> old."identity" then
        raise exception 'updates to % view must not set surrogate key value', 'Tipo de desviación';
      end if;

      select "Tipo de desviación"."active"."entry"
      into   "old entry"
      from   "Tipo de desviación"."active" natural join "Tipo de desviación"."identity"
      where  "Tipo de desviación"."identity"."identity" = old."identity"
      ;

      delete from public."Tipo de desviación"
      where       public."Tipo de desviación"."identity" = old."identity"
      ;

      select "Tipo de desviación"."identity"."identity"
      into   "new identity"
      from   "Tipo de desviación"."identity"
      where  "Tipo de desviación"."identity"."identity" = new."identity"
      ;
      if not found then
        insert into "Tipo de desviación"."identity"
          ("identity") values
          (default   )
        returning "Tipo de desviación"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Tipo de desviación"."journal"
        (    "identity") values
        ("new identity")
      returning "Tipo de desviación"."journal"."entry"
      into "new entry"
      ;

      insert into "Tipo de desviación"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Tipo de desviación"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Tipo de desviación"."revocation"."end timestamp"
      from        "Tipo de desviación"."revocation"
      where       "Tipo de desviación"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Tipo de desviación"
for each row execute procedure "Tipo de desviación"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* "descripción" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Tipo de desviación"."insert or update descripción function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    declare
      "new descripción state" bigint;
    begin
      if
        new."descripción" is not null
      then
        if
          tg_op = 'INSERT'
          or not (old."descripción" is not null and old."descripción" = new."descripción")
        then
          insert into "Tipo de desviación"."descripción state"
            (    "descripción") values
            (new."descripción")
          returning   "Tipo de desviación"."descripción state"."descripción state"
          into        "new descripción state"
          ;
        else
          select     "Tipo de desviación"."descripción proxy"."descripción state"
          into       "new descripción state"
          from       "Tipo de desviación"."identity" natural join "Tipo de desviación"."active" natural join "Tipo de desviación"."journal"
          inner join "Tipo de desviación"."succession" on ("Tipo de desviación"."journal"."entry" = "Tipo de desviación"."succession"."successor")
          inner join "Tipo de desviación"."descripción proxy" on ("Tipo de desviación"."succession"."entry" = "Tipo de desviación"."descripción proxy"."entry")
          where      "Tipo de desviación"."identity"."identity" = new."identity"
          ;
        end if;

        insert into  "Tipo de desviación"."descripción proxy" ("entry", "descripción state")
        select       "Tipo de desviación"."active"."entry", "new descripción state"
        from         "Tipo de desviación"."identity" inner join "Tipo de desviación"."active" using ("identity")
        where        "Tipo de desviación"."identity"."identity" = new."identity"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update descripción"
instead of insert or update on public."Tipo de desviación"
for each row execute procedure "Tipo de desviación"."insert or update descripción function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Reference triggers */
/*}}}*//*}}}*//*}}}*//*}}}*/
