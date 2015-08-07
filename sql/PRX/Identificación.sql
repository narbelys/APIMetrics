/*{{{*//*{{{*//* "Identificación" schema */
/*}}}*/
/*{{{*/create schema "Identificación";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Identificación"."identity"
  ( "identity" bigserial not null primary key  , "perfil version" bigint not null references "Perfil"."journal" deferrable initially deferred  , "forma de identificación version" bigint not null references "Forma de identificación"."journal" deferrable initially deferred
  , "identificador" text not null
  , unique ("perfil version", "forma de identificación version", "identificador")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Identificación"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Identificación"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Identificación"."revocation"
  ( "entry"           bigint                   not null primary key references "Identificación"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Identificación"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Identificación"."succession"
  ( "entry"     bigint                   not null primary key references "Identificación"."revocation"
  , "successor" bigint                   not null unique      references "Identificación"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Identificación"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Identificación"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Identificación"."active"
  ( "identity" bigint not null primary key references "Identificación"."identity"
  , "entry"    bigint not null unique      references "Identificación"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Identificación"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Identificación"."version" as
  select
    "Identificación"."journal"."entry",
    "Identificación"."journal"."timestamp" as "journal timestamp",
    "Identificación"."revocation"."end timestamp",
    "Identificación"."succession"."successor",
    "Identificación"."identity"."perfil version",
    "perfil identity"."identity" as "perfil -> identity"
,
    "Identificación"."identity"."forma de identificación version",
    "forma de identificación identity"."nombre" as "forma de identificación -> nombre"
,
    "Identificación"."identity"."identificador"
  from "Identificación"."identity" natural join "Identificación"."journal"
  left outer join "Identificación"."revocation" on ("Identificación"."journal"."entry" = "Identificación"."revocation"."entry")
  left outer join "Identificación"."succession" on ("Identificación"."journal"."entry" = "Identificación"."succession"."entry")
  inner join "Perfil"."journal" as "perfil journal" on ("Identificación"."identity"."perfil version" = "perfil journal"."entry")
  inner join "Perfil"."identity" as "perfil identity" on ("perfil journal"."identity" = "perfil identity"."identity")

  inner join "Forma de identificación"."journal" as "forma de identificación journal" on ("Identificación"."identity"."forma de identificación version" = "forma de identificación journal"."entry")
  inner join "Forma de identificación"."identity" as "forma de identificación identity" on ("forma de identificación journal"."identity" = "forma de identificación identity"."identity")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Identificación" as
  select
    "Identificación"."identity"."perfil version",
    "perfil identity"."identity" as "perfil -> identity"
,
    "Identificación"."identity"."forma de identificación version",
    "forma de identificación identity"."nombre" as "forma de identificación -> nombre"
,
    "Identificación"."identity"."identificador"
  from "Identificación"."active" natural join "Identificación"."identity" natural join "Identificación"."journal"
  inner join "Perfil"."journal" as "perfil journal" on ("Identificación"."identity"."perfil version" = "perfil journal"."entry")
  inner join "Perfil"."identity" as "perfil identity" on ("perfil journal"."identity" = "perfil identity"."identity")

  inner join "Forma de identificación"."journal" as "forma de identificación journal" on ("Identificación"."identity"."forma de identificación version" = "forma de identificación journal"."entry")
  inner join "Forma de identificación"."identity" as "forma de identificación identity" on ("forma de identificación journal"."identity" = "forma de identificación identity"."identity")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Identificación"."view insert"
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
      if new."perfil version" is not null then
        raise exception 'insertions into % view must not specify %', 'Identificación', 'perfil version';
      end if;

      if new."forma de identificación version" is not null then
        raise exception 'insertions into % view must not specify %', 'Identificación', 'forma de identificación version';
      end if;

      select     "Identificación"."identity"."identity", "Perfil"."active"."entry", "Forma de identificación"."active"."entry"
      into       "new identity", new."perfil version", new."forma de identificación version"
      from       "Identificación"."identity"
      inner join ("Perfil"."identity" natural join "Perfil"."journal" natural join "Perfil"."active") on ("Identificación"."identity"."perfil version" = "Perfil"."journal"."entry")
      inner join ("Forma de identificación"."identity" natural join "Forma de identificación"."journal" natural join "Forma de identificación"."active") on ("Identificación"."identity"."forma de identificación version" = "Forma de identificación"."journal"."entry")
      where      "Perfil"."identity"."identity" = new."perfil -> identity"
      and        "Forma de identificación"."identity"."nombre" = new."forma de identificación -> nombre"
      and        "Identificación"."identity"."identificador" = new."identificador"
      ;

      if not found then
        select "Perfil"."active"."entry"
        into   new."perfil version"
        from   ("Perfil"."identity" natural join "Perfil"."journal" natural join "Perfil"."active")
        where  "Perfil"."identity"."identity" = new."perfil -> identity"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Perfil', 'perfil', 'Identificación';
        end if;

        select "Forma de identificación"."active"."entry"
        into   new."forma de identificación version"
        from   ("Forma de identificación"."identity" natural join "Forma de identificación"."journal" natural join "Forma de identificación"."active")
        where  "Forma de identificación"."identity"."nombre" = new."forma de identificación -> nombre"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Forma de identificación', 'forma de identificación', 'Identificación';
        end if;

        insert into "Identificación"."identity"
          ("perfil version", "forma de identificación version", "identificador") values
          (new."perfil version", new."forma de identificación version", new."identificador")
        returning "Identificación"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Identificación"."journal"
        (    "identity") values
        ("new identity")
      returning "Identificación"."journal"."entry" into "new entry"
      ;

      insert into "Identificación"."active"
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
instead of insert on public."Identificación"
for each row execute procedure "Identificación"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Identificación"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Identificación"."revocation" ("entry", "start timestamp")
      select       "Identificación"."journal"."entry", "Identificación"."journal"."timestamp"
      from         "Identificación"."active"
      natural join "Identificación"."identity"
      natural join "Identificación"."journal"
      where        "Identificación"."identity"."perfil version" = old."perfil version"
      and          "Identificación"."identity"."forma de identificación version" = old."forma de identificación version"
      and          "Identificación"."identity"."identificador" = old."identificador"
      ;

      delete from "Identificación"."active"
      using       "Identificación"."identity" natural join "Identificación"."journal"
      where       "Identificación"."active"."entry" = "Identificación"."journal"."entry"
      and         "Identificación"."identity"."perfil version" = old."perfil version"
      and         "Identificación"."identity"."forma de identificación version" = old."forma de identificación version"
      and         "Identificación"."identity"."identificador" = old."identificador"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Identificación"
for each row execute procedure "Identificación"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Identificación"."update function"
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
      if new."perfil -> identity" is null then
        raise exception 'null value in column % violates not-null constraint', 'perfil -> identity';
      end if;

      if new."forma de identificación -> nombre" is null then
        raise exception 'null value in column % violates not-null constraint', 'forma de identificación -> nombre';
      end if;

      if new."identificador" is null then
        raise exception 'null value in column % violates not-null constraint', 'identificador';
      end if;

      if
        new."perfil version" is not null and
        old."perfil version" <> new."perfil version"
      then
        raise exception 'updates to % view must not set %', 'Identificación', 'perfil version';
      elsif
        new."perfil version" is null
        or old."perfil -> identity" <> new."perfil -> identity"
      then
        select "Perfil"."active"."entry"
        into   new."perfil version"
        from   "Perfil"."active" natural join "Perfil"."identity"
        where  "Perfil"."identity"."identity" = new."perfil -> identity"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Perfil', 'perfil', 'Identificación';
        end if;
      end if;

      if
        new."forma de identificación version" is not null and
        old."forma de identificación version" <> new."forma de identificación version"
      then
        raise exception 'updates to % view must not set %', 'Identificación', 'forma de identificación version';
      elsif
        new."forma de identificación version" is null
        or old."forma de identificación -> nombre" <> new."forma de identificación -> nombre"
      then
        select "Forma de identificación"."active"."entry"
        into   new."forma de identificación version"
        from   "Forma de identificación"."active" natural join "Forma de identificación"."identity"
        where  "Forma de identificación"."identity"."nombre" = new."forma de identificación -> nombre"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Forma de identificación', 'forma de identificación', 'Identificación';
        end if;
      end if;

      select "Identificación"."active"."entry"
      into   "old entry"
      from   "Identificación"."active" natural join "Identificación"."identity"
      where  "Identificación"."identity"."perfil version" = old."perfil version"
      and    "Identificación"."identity"."forma de identificación version" = old."forma de identificación version"
      and    "Identificación"."identity"."identificador" = old."identificador"
      ;

      delete from public."Identificación"
      where       public."Identificación"."perfil version" = old."perfil version"
      and         public."Identificación"."forma de identificación version" = old."forma de identificación version"
      and         public."Identificación"."identificador" = old."identificador"
      ;

      select "Identificación"."identity"."identity"
      into   "new identity"
      from   "Identificación"."identity"
      where  "Identificación"."identity"."perfil version" = new."perfil version"
      and    "Identificación"."identity"."forma de identificación version" = new."forma de identificación version"
      and    "Identificación"."identity"."identificador" = new."identificador"
      ;
      if not found then
        insert into "Identificación"."identity"
          ("perfil version", "forma de identificación version", "identificador") values
          (new."perfil version", new."forma de identificación version", new."identificador")
        returning "Identificación"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Identificación"."journal"
        (    "identity") values
        ("new identity")
      returning "Identificación"."journal"."entry"
      into "new entry"
      ;

      insert into "Identificación"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Identificación"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Identificación"."revocation"."end timestamp"
      from        "Identificación"."revocation"
      where       "Identificación"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Identificación"
for each row execute procedure "Identificación"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* Reference triggers */
/*}}}*/
/*{{{*//*{{{*//* cascade on update to "perfil" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Identificación"."cascade update on Identificación view perfil reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Identificación"
      set
        ( "perfil version"
        , "perfil -> identity"
        )
      = ( null
        , "Perfil"."version"."identity"
        )
      from  "Perfil"."version"
      where new."entry" = public."Identificación"."perfil version"
      and   new."entry" = "Perfil"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Identificación view perfil reference"
after insert on "Perfil"."succession"
for each row execute procedure "Identificación"."cascade update on Identificación view perfil reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "perfil" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Identificación"."restrict delete on Identificación view perfil reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Identificación"
      where   public."Identificación"."perfil version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Perfil'
        , 'Identificación'
        , 'perfil'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Identificación view perfil reference"
after insert on "Perfil"."revocation"
deferrable initially deferred
for each row execute procedure "Identificación"."restrict delete on Identificación view perfil reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* cascade on update to "forma de identificación" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Identificación"."cascade update on Identificación view forma de identificación reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Identificación"
      set
        ( "forma de identificación version"
        , "forma de identificación -> nombre"
        )
      = ( null
        , "Forma de identificación"."version"."nombre"
        )
      from  "Forma de identificación"."version"
      where new."entry" = public."Identificación"."forma de identificación version"
      and   new."entry" = "Forma de identificación"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Identificación view forma de identificación reference"
after insert on "Forma de identificación"."succession"
for each row execute procedure "Identificación"."cascade update on Identificación view forma de identificación reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "forma de identificación" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Identificación"."restrict delete on Identificación view forma de identificación reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Identificación"
      where   public."Identificación"."forma de identificación version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Forma de identificación'
        , 'Identificación'
        , 'forma de identificación'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Identificación view forma de identificación reference"
after insert on "Forma de identificación"."revocation"
deferrable initially deferred
for each row execute procedure "Identificación"."restrict delete on Identificación view forma de identificación reference"();/*}}}*//*}}}*//*}}}*//*}}}*//*}}}*//*}}}*/
