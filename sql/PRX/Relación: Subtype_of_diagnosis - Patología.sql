/*{{{*//*{{{*//* "Relación: Subtype_of_diagnosis - Patología" schema */
/*}}}*/
/*{{{*/create schema "Relación: Subtype_of_diagnosis - Patología";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Relación: Subtype_of_diagnosis - Patología"."identity"
  ( "identity" bigserial not null primary key  , "Subtype_of_diagnosis version" bigint not null references "Subtype_of_diagnosis"."journal" deferrable initially deferred  , "Diagnosis version" bigint not null references "Diagnosis"."journal" deferrable initially deferred
  , unique ("Subtype_of_diagnosis version", "Diagnosis version")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Relación: Subtype_of_diagnosis - Patología"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Relación: Subtype_of_diagnosis - Patología"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Relación: Subtype_of_diagnosis - Patología"."revocation"
  ( "entry"           bigint                   not null primary key references "Relación: Subtype_of_diagnosis - Patología"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Relación: Subtype_of_diagnosis - Patología"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Relación: Subtype_of_diagnosis - Patología"."succession"
  ( "entry"     bigint                   not null primary key references "Relación: Subtype_of_diagnosis - Patología"."revocation"
  , "successor" bigint                   not null unique      references "Relación: Subtype_of_diagnosis - Patología"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Relación: Subtype_of_diagnosis - Patología"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Relación: Subtype_of_diagnosis - Patología"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Relación: Subtype_of_diagnosis - Patología"."active"
  ( "identity" bigint not null primary key references "Relación: Subtype_of_diagnosis - Patología"."identity"
  , "entry"    bigint not null unique      references "Relación: Subtype_of_diagnosis - Patología"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Relación: Subtype_of_diagnosis - Patología"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Relación: Subtype_of_diagnosis - Patología"."version" as
  select
    "Relación: Subtype_of_diagnosis - Patología"."journal"."entry",
    "Relación: Subtype_of_diagnosis - Patología"."journal"."timestamp" as "journal timestamp",
    "Relación: Subtype_of_diagnosis - Patología"."revocation"."end timestamp",
    "Relación: Subtype_of_diagnosis - Patología"."succession"."successor",
    "Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version",
    "Subtype_of_diagnosis identity"."código" as "Subtype_of_diagnosis -> código"
,
    "Subtype_of_diagnosis identity"."Type_of_diagnosis version" as "Subtype_of_diagnosis -> Type_of_diagnosis version"
,
    "Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version",
    "Diagnosis identity"."código" as "Diagnosis -> código"

  from "Relación: Subtype_of_diagnosis - Patología"."identity" natural join "Relación: Subtype_of_diagnosis - Patología"."journal"
  left outer join "Relación: Subtype_of_diagnosis - Patología"."revocation" on ("Relación: Subtype_of_diagnosis - Patología"."journal"."entry" = "Relación: Subtype_of_diagnosis - Patología"."revocation"."entry")
  left outer join "Relación: Subtype_of_diagnosis - Patología"."succession" on ("Relación: Subtype_of_diagnosis - Patología"."journal"."entry" = "Relación: Subtype_of_diagnosis - Patología"."succession"."entry")
  inner join "Subtype_of_diagnosis"."journal" as "Subtype_of_diagnosis journal" on ("Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version" = "Subtype_of_diagnosis journal"."entry")
  inner join "Subtype_of_diagnosis"."identity" as "Subtype_of_diagnosis identity" on ("Subtype_of_diagnosis journal"."identity" = "Subtype_of_diagnosis identity"."identity")

  inner join "Diagnosis"."journal" as "Diagnosis journal" on ("Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version" = "Diagnosis journal"."entry")
  inner join "Diagnosis"."identity" as "Diagnosis identity" on ("Diagnosis journal"."identity" = "Diagnosis identity"."identity")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Relación: Subtype_of_diagnosis - Patología" as
  select
    "Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version",
    "Subtype_of_diagnosis identity"."código" as "Subtype_of_diagnosis -> código"
,
    "Subtype_of_diagnosis identity"."Type_of_diagnosis version" as "Subtype_of_diagnosis -> Type_of_diagnosis version"
,
    "Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version",
    "Diagnosis identity"."código" as "Diagnosis -> código"

  from "Relación: Subtype_of_diagnosis - Patología"."active" natural join "Relación: Subtype_of_diagnosis - Patología"."identity" natural join "Relación: Subtype_of_diagnosis - Patología"."journal"
  inner join "Subtype_of_diagnosis"."journal" as "Subtype_of_diagnosis journal" on ("Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version" = "Subtype_of_diagnosis journal"."entry")
  inner join "Subtype_of_diagnosis"."identity" as "Subtype_of_diagnosis identity" on ("Subtype_of_diagnosis journal"."identity" = "Subtype_of_diagnosis identity"."identity")

  inner join "Diagnosis"."journal" as "Diagnosis journal" on ("Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version" = "Diagnosis journal"."entry")
  inner join "Diagnosis"."identity" as "Diagnosis identity" on ("Diagnosis journal"."identity" = "Diagnosis identity"."identity")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtype_of_diagnosis - Patología"."view insert"
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
        raise exception 'insertions into % view must not specify %', 'Relación: Subtype_of_diagnosis - Patología', 'Subtype_of_diagnosis version';
      end if;

      if new."Diagnosis version" is not null then
        raise exception 'insertions into % view must not specify %', 'Relación: Subtype_of_diagnosis - Patología', 'Diagnosis version';
      end if;

      select     "Relación: Subtype_of_diagnosis - Patología"."identity"."identity", "Subtype_of_diagnosis"."active"."entry", "Diagnosis"."active"."entry"
      into       "new identity", new."Subtype_of_diagnosis version", new."Diagnosis version"
      from       "Relación: Subtype_of_diagnosis - Patología"."identity"
      inner join ("Subtype_of_diagnosis"."identity" natural join "Subtype_of_diagnosis"."journal" natural join "Subtype_of_diagnosis"."active") on ("Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version" = "Subtype_of_diagnosis"."journal"."entry")
      inner join ("Diagnosis"."identity" natural join "Diagnosis"."journal" natural join "Diagnosis"."active") on ("Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version" = "Diagnosis"."journal"."entry")
      where      "Subtype_of_diagnosis"."identity"."código" = new."Subtype_of_diagnosis -> código" and "Subtype_of_diagnosis"."identity"."Type_of_diagnosis version" = new."Subtype_of_diagnosis -> Type_of_diagnosis version"
      and        "Diagnosis"."identity"."código" = new."Diagnosis -> código"
      ;

      if not found then
        select "Subtype_of_diagnosis"."active"."entry"
        into   new."Subtype_of_diagnosis version"
        from   ("Subtype_of_diagnosis"."identity" natural join "Subtype_of_diagnosis"."journal" natural join "Subtype_of_diagnosis"."active")
        where  "Subtype_of_diagnosis"."identity"."código" = new."Subtype_of_diagnosis -> código"
        and    "Subtype_of_diagnosis"."identity"."Type_of_diagnosis version" = new."Subtype_of_diagnosis -> Type_of_diagnosis version"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Subtype_of_diagnosis', 'Subtype_of_diagnosis', 'Relación: Subtype_of_diagnosis - Patología';
        end if;

        select "Diagnosis"."active"."entry"
        into   new."Diagnosis version"
        from   ("Diagnosis"."identity" natural join "Diagnosis"."journal" natural join "Diagnosis"."active")
        where  "Diagnosis"."identity"."código" = new."Diagnosis -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Diagnosis', 'Diagnosis', 'Relación: Subtype_of_diagnosis - Patología';
        end if;

        insert into "Relación: Subtype_of_diagnosis - Patología"."identity"
          ("Subtype_of_diagnosis version", "Diagnosis version") values
          (new."Subtype_of_diagnosis version", new."Diagnosis version")
        returning "Relación: Subtype_of_diagnosis - Patología"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Relación: Subtype_of_diagnosis - Patología"."journal"
        (    "identity") values
        ("new identity")
      returning "Relación: Subtype_of_diagnosis - Patología"."journal"."entry" into "new entry"
      ;

      insert into "Relación: Subtype_of_diagnosis - Patología"."active"
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
instead of insert on public."Relación: Subtype_of_diagnosis - Patología"
for each row execute procedure "Relación: Subtype_of_diagnosis - Patología"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtype_of_diagnosis - Patología"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Relación: Subtype_of_diagnosis - Patología"."revocation" ("entry", "start timestamp")
      select       "Relación: Subtype_of_diagnosis - Patología"."journal"."entry", "Relación: Subtype_of_diagnosis - Patología"."journal"."timestamp"
      from         "Relación: Subtype_of_diagnosis - Patología"."active"
      natural join "Relación: Subtype_of_diagnosis - Patología"."identity"
      natural join "Relación: Subtype_of_diagnosis - Patología"."journal"
      where        "Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version" = old."Subtype_of_diagnosis version"
      and          "Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version" = old."Diagnosis version"
      ;

      delete from "Relación: Subtype_of_diagnosis - Patología"."active"
      using       "Relación: Subtype_of_diagnosis - Patología"."identity" natural join "Relación: Subtype_of_diagnosis - Patología"."journal"
      where       "Relación: Subtype_of_diagnosis - Patología"."active"."entry" = "Relación: Subtype_of_diagnosis - Patología"."journal"."entry"
      and         "Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version" = old."Subtype_of_diagnosis version"
      and         "Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version" = old."Diagnosis version"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Relación: Subtype_of_diagnosis - Patología"
for each row execute procedure "Relación: Subtype_of_diagnosis - Patología"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtype_of_diagnosis - Patología"."update function"
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

      if new."Diagnosis -> código" is null then
        raise exception 'null value in column % violates not-null constraint', 'Diagnosis -> código';
      end if;

      if
        new."Subtype_of_diagnosis version" is not null and
        old."Subtype_of_diagnosis version" <> new."Subtype_of_diagnosis version"
      then
        raise exception 'updates to % view must not set %', 'Relación: Subtype_of_diagnosis - Patología', 'Subtype_of_diagnosis version';
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
          raise exception 'no active % row matches % reference on update to % row', 'Subtype_of_diagnosis', 'Subtype_of_diagnosis', 'Relación: Subtype_of_diagnosis - Patología';
        end if;
      end if;

      if
        new."Diagnosis version" is not null and
        old."Diagnosis version" <> new."Diagnosis version"
      then
        raise exception 'updates to % view must not set %', 'Relación: Subtype_of_diagnosis - Patología', 'Diagnosis version';
      elsif
        new."Diagnosis version" is null
        or old."Diagnosis -> código" <> new."Diagnosis -> código"
      then
        select "Diagnosis"."active"."entry"
        into   new."Diagnosis version"
        from   "Diagnosis"."active" natural join "Diagnosis"."identity"
        where  "Diagnosis"."identity"."código" = new."Diagnosis -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Diagnosis', 'Diagnosis', 'Relación: Subtype_of_diagnosis - Patología';
        end if;
      end if;

      select "Relación: Subtype_of_diagnosis - Patología"."active"."entry"
      into   "old entry"
      from   "Relación: Subtype_of_diagnosis - Patología"."active" natural join "Relación: Subtype_of_diagnosis - Patología"."identity"
      where  "Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version" = old."Subtype_of_diagnosis version"
      and    "Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version" = old."Diagnosis version"
      ;

      delete from public."Relación: Subtype_of_diagnosis - Patología"
      where       public."Relación: Subtype_of_diagnosis - Patología"."Subtype_of_diagnosis version" = old."Subtype_of_diagnosis version"
      and         public."Relación: Subtype_of_diagnosis - Patología"."Diagnosis version" = old."Diagnosis version"
      ;

      select "Relación: Subtype_of_diagnosis - Patología"."identity"."identity"
      into   "new identity"
      from   "Relación: Subtype_of_diagnosis - Patología"."identity"
      where  "Relación: Subtype_of_diagnosis - Patología"."identity"."Subtype_of_diagnosis version" = new."Subtype_of_diagnosis version"
      and    "Relación: Subtype_of_diagnosis - Patología"."identity"."Diagnosis version" = new."Diagnosis version"
      ;
      if not found then
        insert into "Relación: Subtype_of_diagnosis - Patología"."identity"
          ("Subtype_of_diagnosis version", "Diagnosis version") values
          (new."Subtype_of_diagnosis version", new."Diagnosis version")
        returning "Relación: Subtype_of_diagnosis - Patología"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Relación: Subtype_of_diagnosis - Patología"."journal"
        (    "identity") values
        ("new identity")
      returning "Relación: Subtype_of_diagnosis - Patología"."journal"."entry"
      into "new entry"
      ;

      insert into "Relación: Subtype_of_diagnosis - Patología"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Relación: Subtype_of_diagnosis - Patología"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Relación: Subtype_of_diagnosis - Patología"."revocation"."end timestamp"
      from        "Relación: Subtype_of_diagnosis - Patología"."revocation"
      where       "Relación: Subtype_of_diagnosis - Patología"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Relación: Subtype_of_diagnosis - Patología"
for each row execute procedure "Relación: Subtype_of_diagnosis - Patología"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* Reference triggers */
/*}}}*/
/*{{{*//*{{{*//* cascade on update to "Subtype_of_diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtype_of_diagnosis - Patología"."cascade update on Relación: Subtype_of_diagnosis - Patología view Subtype_of_diagnosis reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Relación: Subtype_of_diagnosis - Patología"
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
      where new."entry" = public."Relación: Subtype_of_diagnosis - Patología"."Subtype_of_diagnosis version"
      and   new."entry" = "Subtype_of_diagnosis"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Relación: Subtype_of_diagnosis - Patología view Subtype_of_diagnosis reference"
after insert on "Subtype_of_diagnosis"."succession"
for each row execute procedure "Relación: Subtype_of_diagnosis - Patología"."cascade update on Relación: Subtype_of_diagnosis - Patología view Subtype_of_diagnosis reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Subtype_of_diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtype_of_diagnosis - Patología"."restrict delete on Relación: Subtype_of_diagnosis - Patología view Subtype_of_diagnosis reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Relación: Subtype_of_diagnosis - Patología"
      where   public."Relación: Subtype_of_diagnosis - Patología"."Subtype_of_diagnosis version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Subtype_of_diagnosis'
        , 'Relación: Subtype_of_diagnosis - Patología'
        , 'Subtype_of_diagnosis'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Relación: Subtype_of_diagnosis - Patología view Subtype_of_diagnosis reference"
after insert on "Subtype_of_diagnosis"."revocation"
deferrable initially deferred
for each row execute procedure "Relación: Subtype_of_diagnosis - Patología"."restrict delete on Relación: Subtype_of_diagnosis - Patología view Subtype_of_diagnosis reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* cascade on update to "Diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtype_of_diagnosis - Patología"."cascade update on Relación: Subtype_of_diagnosis - Patología view Diagnosis reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Relación: Subtype_of_diagnosis - Patología"
      set
        ( "Diagnosis version"
        , "Diagnosis -> código"
        )
      = ( null
        , "Diagnosis"."version"."código"
        )
      from  "Diagnosis"."version"
      where new."entry" = public."Relación: Subtype_of_diagnosis - Patología"."Diagnosis version"
      and   new."entry" = "Diagnosis"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Relación: Subtype_of_diagnosis - Patología view Diagnosis reference"
after insert on "Diagnosis"."succession"
for each row execute procedure "Relación: Subtype_of_diagnosis - Patología"."cascade update on Relación: Subtype_of_diagnosis - Patología view Diagnosis reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Relación: Subtype_of_diagnosis - Patología"."restrict delete on Relación: Subtype_of_diagnosis - Patología view Diagnosis reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Relación: Subtype_of_diagnosis - Patología"
      where   public."Relación: Subtype_of_diagnosis - Patología"."Diagnosis version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Diagnosis'
        , 'Relación: Subtype_of_diagnosis - Patología'
        , 'Diagnosis'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Relación: Subtype_of_diagnosis - Patología view Diagnosis reference"
after insert on "Diagnosis"."revocation"
deferrable initially deferred
for each row execute procedure "Relación: Subtype_of_diagnosis - Patología"."restrict delete on Relación: Subtype_of_diagnosis - Patología view Diagnosis reference"();/*}}}*//*}}}*//*}}}*//*}}}*//*}}}*//*}}}*/
