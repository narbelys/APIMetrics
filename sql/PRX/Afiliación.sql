/*{{{*//*{{{*//* "Afiliación" schema */
/*}}}*/
/*{{{*/create schema "Afiliación";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Afiliación"."identity"
  ( "identity" bigserial not null primary key  , "póliza version" bigint not null references "Póliza"."journal" deferrable initially deferred  , "asegurado version" bigint not null references "Identificación"."journal" deferrable initially deferred
  , unique ("póliza version", "asegurado version")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Afiliación"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Afiliación"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Afiliación"."revocation"
  ( "entry"           bigint                   not null primary key references "Afiliación"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Afiliación"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Afiliación"."succession"
  ( "entry"     bigint                   not null primary key references "Afiliación"."revocation"
  , "successor" bigint                   not null unique      references "Afiliación"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Afiliación"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Afiliación"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Afiliación"."active"
  ( "identity" bigint not null primary key references "Afiliación"."identity"
  , "entry"    bigint not null unique      references "Afiliación"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Afiliación"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Afiliación"."version" as
  select
    "Afiliación"."journal"."entry",
    "Afiliación"."journal"."timestamp" as "journal timestamp",
    "Afiliación"."revocation"."end timestamp",
    "Afiliación"."succession"."successor",
    "Afiliación"."identity"."póliza version",
    "póliza identity"."Insurer version" as "póliza -> Insurer version"
,
    "póliza identity"."código" as "póliza -> código"
,
    "Afiliación"."identity"."asegurado version",
    "asegurado identity"."perfil version" as "asegurado -> perfil version"
,
    "asegurado identity"."forma de identificación version" as "asegurado -> forma de identificación version"
,
    "asegurado identity"."identificador" as "asegurado -> identificador"

  from "Afiliación"."identity" natural join "Afiliación"."journal"
  left outer join "Afiliación"."revocation" on ("Afiliación"."journal"."entry" = "Afiliación"."revocation"."entry")
  left outer join "Afiliación"."succession" on ("Afiliación"."journal"."entry" = "Afiliación"."succession"."entry")
  inner join "Póliza"."journal" as "póliza journal" on ("Afiliación"."identity"."póliza version" = "póliza journal"."entry")
  inner join "Póliza"."identity" as "póliza identity" on ("póliza journal"."identity" = "póliza identity"."identity")

  inner join "Identificación"."journal" as "asegurado journal" on ("Afiliación"."identity"."asegurado version" = "asegurado journal"."entry")
  inner join "Identificación"."identity" as "asegurado identity" on ("asegurado journal"."identity" = "asegurado identity"."identity")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Afiliación" as
  select
    "Afiliación"."identity"."póliza version",
    "póliza identity"."Insurer version" as "póliza -> Insurer version"
,
    "póliza identity"."código" as "póliza -> código"
,
    "Afiliación"."identity"."asegurado version",
    "asegurado identity"."perfil version" as "asegurado -> perfil version"
,
    "asegurado identity"."forma de identificación version" as "asegurado -> forma de identificación version"
,
    "asegurado identity"."identificador" as "asegurado -> identificador"

  from "Afiliación"."active" natural join "Afiliación"."identity" natural join "Afiliación"."journal"
  inner join "Póliza"."journal" as "póliza journal" on ("Afiliación"."identity"."póliza version" = "póliza journal"."entry")
  inner join "Póliza"."identity" as "póliza identity" on ("póliza journal"."identity" = "póliza identity"."identity")

  inner join "Identificación"."journal" as "asegurado journal" on ("Afiliación"."identity"."asegurado version" = "asegurado journal"."entry")
  inner join "Identificación"."identity" as "asegurado identity" on ("asegurado journal"."identity" = "asegurado identity"."identity")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Afiliación"."view insert"
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
      if new."póliza version" is not null then
        raise exception 'insertions into % view must not specify %', 'Afiliación', 'póliza version';
      end if;

      if new."asegurado version" is not null then
        raise exception 'insertions into % view must not specify %', 'Afiliación', 'asegurado version';
      end if;

      select     "Afiliación"."identity"."identity", "Póliza"."active"."entry", "Identificación"."active"."entry"
      into       "new identity", new."póliza version", new."asegurado version"
      from       "Afiliación"."identity"
      inner join ("Póliza"."identity" natural join "Póliza"."journal" natural join "Póliza"."active") on ("Afiliación"."identity"."póliza version" = "Póliza"."journal"."entry")
      inner join ("Identificación"."identity" natural join "Identificación"."journal" natural join "Identificación"."active") on ("Afiliación"."identity"."asegurado version" = "Identificación"."journal"."entry")
      where      "Póliza"."identity"."Insurer version" = new."póliza -> Insurer version" and "Póliza"."identity"."código" = new."póliza -> código"
      and        "Identificación"."identity"."perfil version" = new."asegurado -> perfil version" and "Identificación"."identity"."forma de identificación version" = new."asegurado -> forma de identificación version" and "Identificación"."identity"."identificador" = new."asegurado -> identificador"
      ;

      if not found then
        select "Póliza"."active"."entry"
        into   new."póliza version"
        from   ("Póliza"."identity" natural join "Póliza"."journal" natural join "Póliza"."active")
        where  "Póliza"."identity"."Insurer version" = new."póliza -> Insurer version"
        and    "Póliza"."identity"."código" = new."póliza -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Póliza', 'póliza', 'Afiliación';
        end if;

        select "Identificación"."active"."entry"
        into   new."asegurado version"
        from   ("Identificación"."identity" natural join "Identificación"."journal" natural join "Identificación"."active")
        where  "Identificación"."identity"."perfil version" = new."asegurado -> perfil version"
        and    "Identificación"."identity"."forma de identificación version" = new."asegurado -> forma de identificación version"
        and    "Identificación"."identity"."identificador" = new."asegurado -> identificador"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Identificación', 'asegurado', 'Afiliación';
        end if;

        insert into "Afiliación"."identity"
          ("póliza version", "asegurado version") values
          (new."póliza version", new."asegurado version")
        returning "Afiliación"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Afiliación"."journal"
        (    "identity") values
        ("new identity")
      returning "Afiliación"."journal"."entry" into "new entry"
      ;

      insert into "Afiliación"."active"
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
instead of insert on public."Afiliación"
for each row execute procedure "Afiliación"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Afiliación"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Afiliación"."revocation" ("entry", "start timestamp")
      select       "Afiliación"."journal"."entry", "Afiliación"."journal"."timestamp"
      from         "Afiliación"."active"
      natural join "Afiliación"."identity"
      natural join "Afiliación"."journal"
      where        "Afiliación"."identity"."póliza version" = old."póliza version"
      and          "Afiliación"."identity"."asegurado version" = old."asegurado version"
      ;

      delete from "Afiliación"."active"
      using       "Afiliación"."identity" natural join "Afiliación"."journal"
      where       "Afiliación"."active"."entry" = "Afiliación"."journal"."entry"
      and         "Afiliación"."identity"."póliza version" = old."póliza version"
      and         "Afiliación"."identity"."asegurado version" = old."asegurado version"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Afiliación"
for each row execute procedure "Afiliación"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Afiliación"."update function"
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
      if new."póliza -> Insurer version" is null then
        raise exception 'null value in column % violates not-null constraint', 'póliza -> Insurer version';
      end if;

      if new."póliza -> código" is null then
        raise exception 'null value in column % violates not-null constraint', 'póliza -> código';
      end if;

      if new."asegurado -> perfil version" is null then
        raise exception 'null value in column % violates not-null constraint', 'asegurado -> perfil version';
      end if;

      if new."asegurado -> forma de identificación version" is null then
        raise exception 'null value in column % violates not-null constraint', 'asegurado -> forma de identificación version';
      end if;

      if new."asegurado -> identificador" is null then
        raise exception 'null value in column % violates not-null constraint', 'asegurado -> identificador';
      end if;

      if
        new."póliza version" is not null and
        old."póliza version" <> new."póliza version"
      then
        raise exception 'updates to % view must not set %', 'Afiliación', 'póliza version';
      elsif
        new."póliza version" is null
        or old."póliza -> Insurer version" <> new."póliza -> Insurer version"
        or old."póliza -> código" <> new."póliza -> código"
      then
        select "Póliza"."active"."entry"
        into   new."póliza version"
        from   "Póliza"."active" natural join "Póliza"."identity"
        where  "Póliza"."identity"."Insurer version" = new."póliza -> Insurer version"
        and    "Póliza"."identity"."código" = new."póliza -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Póliza', 'póliza', 'Afiliación';
        end if;
      end if;

      if
        new."asegurado version" is not null and
        old."asegurado version" <> new."asegurado version"
      then
        raise exception 'updates to % view must not set %', 'Afiliación', 'asegurado version';
      elsif
        new."asegurado version" is null
        or old."asegurado -> perfil version" <> new."asegurado -> perfil version"
        or old."asegurado -> forma de identificación version" <> new."asegurado -> forma de identificación version"
        or old."asegurado -> identificador" <> new."asegurado -> identificador"
      then
        select "Identificación"."active"."entry"
        into   new."asegurado version"
        from   "Identificación"."active" natural join "Identificación"."identity"
        where  "Identificación"."identity"."perfil version" = new."asegurado -> perfil version"
        and    "Identificación"."identity"."forma de identificación version" = new."asegurado -> forma de identificación version"
        and    "Identificación"."identity"."identificador" = new."asegurado -> identificador"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Identificación', 'asegurado', 'Afiliación';
        end if;
      end if;

      select "Afiliación"."active"."entry"
      into   "old entry"
      from   "Afiliación"."active" natural join "Afiliación"."identity"
      where  "Afiliación"."identity"."póliza version" = old."póliza version"
      and    "Afiliación"."identity"."asegurado version" = old."asegurado version"
      ;

      delete from public."Afiliación"
      where       public."Afiliación"."póliza version" = old."póliza version"
      and         public."Afiliación"."asegurado version" = old."asegurado version"
      ;

      select "Afiliación"."identity"."identity"
      into   "new identity"
      from   "Afiliación"."identity"
      where  "Afiliación"."identity"."póliza version" = new."póliza version"
      and    "Afiliación"."identity"."asegurado version" = new."asegurado version"
      ;
      if not found then
        insert into "Afiliación"."identity"
          ("póliza version", "asegurado version") values
          (new."póliza version", new."asegurado version")
        returning "Afiliación"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Afiliación"."journal"
        (    "identity") values
        ("new identity")
      returning "Afiliación"."journal"."entry"
      into "new entry"
      ;

      insert into "Afiliación"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Afiliación"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Afiliación"."revocation"."end timestamp"
      from        "Afiliación"."revocation"
      where       "Afiliación"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Afiliación"
for each row execute procedure "Afiliación"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* Reference triggers */
/*}}}*/
/*{{{*//*{{{*//* cascade on update to "póliza" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Afiliación"."cascade update on Afiliación view póliza reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Afiliación"
      set
        ( "póliza version"
        , "póliza -> Insurer version"
        , "póliza -> código"
        )
      = ( null
        , "Póliza"."version"."Insurer version"
        , "Póliza"."version"."código"
        )
      from  "Póliza"."version"
      where new."entry" = public."Afiliación"."póliza version"
      and   new."entry" = "Póliza"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Afiliación view póliza reference"
after insert on "Póliza"."succession"
for each row execute procedure "Afiliación"."cascade update on Afiliación view póliza reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "póliza" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Afiliación"."restrict delete on Afiliación view póliza reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Afiliación"
      where   public."Afiliación"."póliza version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Póliza'
        , 'Afiliación'
        , 'póliza'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Afiliación view póliza reference"
after insert on "Póliza"."revocation"
deferrable initially deferred
for each row execute procedure "Afiliación"."restrict delete on Afiliación view póliza reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* cascade on update to "asegurado" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Afiliación"."cascade update on Afiliación view asegurado reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Afiliación"
      set
        ( "asegurado version"
        , "asegurado -> perfil version"
        , "asegurado -> forma de identificación version"
        , "asegurado -> identificador"
        )
      = ( null
        , "Identificación"."version"."perfil version"
        , "Identificación"."version"."forma de identificación version"
        , "Identificación"."version"."identificador"
        )
      from  "Identificación"."version"
      where new."entry" = public."Afiliación"."asegurado version"
      and   new."entry" = "Identificación"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Afiliación view asegurado reference"
after insert on "Identificación"."succession"
for each row execute procedure "Afiliación"."cascade update on Afiliación view asegurado reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "asegurado" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Afiliación"."restrict delete on Afiliación view asegurado reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Afiliación"
      where   public."Afiliación"."asegurado version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Identificación'
        , 'Afiliación'
        , 'asegurado'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Afiliación view asegurado reference"
after insert on "Identificación"."revocation"
deferrable initially deferred
for each row execute procedure "Afiliación"."restrict delete on Afiliación view asegurado reference"();/*}}}*//*}}}*//*}}}*//*}}}*//*}}}*//*}}}*/
