/*{{{*//*{{{*//* "Póliza" schema */
/*}}}*/
/*{{{*/create schema "Póliza";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Póliza"."identity"
  ( "identity" bigserial not null primary key  , "Insurer version" bigint not null references "Insurer"."journal" deferrable initially deferred
  , "código" text not null
  , unique ("Insurer version", "código")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Póliza"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Póliza"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Póliza"."revocation"
  ( "entry"           bigint                   not null primary key references "Póliza"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Póliza"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Póliza"."succession"
  ( "entry"     bigint                   not null primary key references "Póliza"."revocation"
  , "successor" bigint                   not null unique      references "Póliza"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Póliza"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Póliza"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Póliza"."active"
  ( "identity" bigint not null primary key references "Póliza"."identity"
  , "entry"    bigint not null unique      references "Póliza"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Póliza"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Póliza"."version" as
  select
    "Póliza"."journal"."entry",
    "Póliza"."journal"."timestamp" as "journal timestamp",
    "Póliza"."revocation"."end timestamp",
    "Póliza"."succession"."successor",
    "Póliza"."identity"."Insurer version",
    "Insurer identity"."identity" as "Insurer -> identity"
,
    "Póliza"."identity"."código"
  from "Póliza"."identity" natural join "Póliza"."journal"
  left outer join "Póliza"."revocation" on ("Póliza"."journal"."entry" = "Póliza"."revocation"."entry")
  left outer join "Póliza"."succession" on ("Póliza"."journal"."entry" = "Póliza"."succession"."entry")
  inner join "Insurer"."journal" as "Insurer journal" on ("Póliza"."identity"."Insurer version" = "Insurer journal"."entry")
  inner join "Insurer"."identity" as "Insurer identity" on ("Insurer journal"."identity" = "Insurer identity"."identity")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Póliza" as
  select
    "Póliza"."identity"."Insurer version",
    "Insurer identity"."identity" as "Insurer -> identity"
,
    "Póliza"."identity"."código"
  from "Póliza"."active" natural join "Póliza"."identity" natural join "Póliza"."journal"
  inner join "Insurer"."journal" as "Insurer journal" on ("Póliza"."identity"."Insurer version" = "Insurer journal"."entry")
  inner join "Insurer"."identity" as "Insurer identity" on ("Insurer journal"."identity" = "Insurer identity"."identity")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Póliza"."view insert"
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
      if new."Insurer version" is not null then
        raise exception 'insertions into % view must not specify %', 'Póliza', 'Insurer version';
      end if;

      select     "Póliza"."identity"."identity", "Insurer"."active"."entry"
      into       "new identity", new."Insurer version"
      from       "Póliza"."identity"
      inner join ("Insurer"."identity" natural join "Insurer"."journal" natural join "Insurer"."active") on ("Póliza"."identity"."Insurer version" = "Insurer"."journal"."entry")
      where      "Insurer"."identity"."identity" = new."Insurer -> identity"
      and        "Póliza"."identity"."código" = new."código"
      ;

      if not found then
        select "Insurer"."active"."entry"
        into   new."Insurer version"
        from   ("Insurer"."identity" natural join "Insurer"."journal" natural join "Insurer"."active")
        where  "Insurer"."identity"."identity" = new."Insurer -> identity"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Insurer', 'Insurer', 'Póliza';
        end if;

        insert into "Póliza"."identity"
          ("Insurer version", "código") values
          (new."Insurer version", new."código")
        returning "Póliza"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Póliza"."journal"
        (    "identity") values
        ("new identity")
      returning "Póliza"."journal"."entry" into "new entry"
      ;

      insert into "Póliza"."active"
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
instead of insert on public."Póliza"
for each row execute procedure "Póliza"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Póliza"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Póliza"."revocation" ("entry", "start timestamp")
      select       "Póliza"."journal"."entry", "Póliza"."journal"."timestamp"
      from         "Póliza"."active"
      natural join "Póliza"."identity"
      natural join "Póliza"."journal"
      where        "Póliza"."identity"."Insurer version" = old."Insurer version"
      and          "Póliza"."identity"."código" = old."código"
      ;

      delete from "Póliza"."active"
      using       "Póliza"."identity" natural join "Póliza"."journal"
      where       "Póliza"."active"."entry" = "Póliza"."journal"."entry"
      and         "Póliza"."identity"."Insurer version" = old."Insurer version"
      and         "Póliza"."identity"."código" = old."código"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Póliza"
for each row execute procedure "Póliza"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Póliza"."update function"
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
      if new."Insurer -> identity" is null then
        raise exception 'null value in column % violates not-null constraint', 'Insurer -> identity';
      end if;

      if new."código" is null then
        raise exception 'null value in column % violates not-null constraint', 'código';
      end if;

      if
        new."Insurer version" is not null and
        old."Insurer version" <> new."Insurer version"
      then
        raise exception 'updates to % view must not set %', 'Póliza', 'Insurer version';
      elsif
        new."Insurer version" is null
        or old."Insurer -> identity" <> new."Insurer -> identity"
      then
        select "Insurer"."active"."entry"
        into   new."Insurer version"
        from   "Insurer"."active" natural join "Insurer"."identity"
        where  "Insurer"."identity"."identity" = new."Insurer -> identity"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Insurer', 'Insurer', 'Póliza';
        end if;
      end if;

      select "Póliza"."active"."entry"
      into   "old entry"
      from   "Póliza"."active" natural join "Póliza"."identity"
      where  "Póliza"."identity"."Insurer version" = old."Insurer version"
      and    "Póliza"."identity"."código" = old."código"
      ;

      delete from public."Póliza"
      where       public."Póliza"."Insurer version" = old."Insurer version"
      and         public."Póliza"."código" = old."código"
      ;

      select "Póliza"."identity"."identity"
      into   "new identity"
      from   "Póliza"."identity"
      where  "Póliza"."identity"."Insurer version" = new."Insurer version"
      and    "Póliza"."identity"."código" = new."código"
      ;
      if not found then
        insert into "Póliza"."identity"
          ("Insurer version", "código") values
          (new."Insurer version", new."código")
        returning "Póliza"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Póliza"."journal"
        (    "identity") values
        ("new identity")
      returning "Póliza"."journal"."entry"
      into "new entry"
      ;

      insert into "Póliza"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Póliza"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Póliza"."revocation"."end timestamp"
      from        "Póliza"."revocation"
      where       "Póliza"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Póliza"
for each row execute procedure "Póliza"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* Reference triggers */
/*}}}*/
/*{{{*//*{{{*//* cascade on update to "Insurer" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Póliza"."cascade update on Póliza view Insurer reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Póliza"
      set
        ( "Insurer version"
        , "Insurer -> identity"
        )
      = ( null
        , "Insurer"."version"."identity"
        )
      from  "Insurer"."version"
      where new."entry" = public."Póliza"."Insurer version"
      and   new."entry" = "Insurer"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Póliza view Insurer reference"
after insert on "Insurer"."succession"
for each row execute procedure "Póliza"."cascade update on Póliza view Insurer reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Insurer" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Póliza"."restrict delete on Póliza view Insurer reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Póliza"
      where   public."Póliza"."Insurer version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Insurer'
        , 'Póliza'
        , 'Insurer'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Póliza view Insurer reference"
after insert on "Insurer"."revocation"
deferrable initially deferred
for each row execute procedure "Póliza"."restrict delete on Póliza view Insurer reference"();/*}}}*//*}}}*//*}}}*//*}}}*//*}}}*//*}}}*/
