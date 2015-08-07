/*{{{*//*{{{*//* "Diagnóstico" schema */
/*}}}*/
/*{{{*/create schema "Diagnóstico";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Diagnóstico"."identity"
  ( "identity" bigserial not null primary key  , "Medical_report version" bigint not null references "Medical_report"."journal" deferrable initially deferred  , "Diagnosis version" bigint not null references "Diagnosis"."journal" deferrable initially deferred
  , unique ("Medical_report version", "Diagnosis version")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Diagnóstico"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Diagnóstico"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Diagnóstico"."revocation"
  ( "entry"           bigint                   not null primary key references "Diagnóstico"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Diagnóstico"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Diagnóstico"."succession"
  ( "entry"     bigint                   not null primary key references "Diagnóstico"."revocation"
  , "successor" bigint                   not null unique      references "Diagnóstico"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Diagnóstico"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Diagnóstico"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Diagnóstico"."active"
  ( "identity" bigint not null primary key references "Diagnóstico"."identity"
  , "entry"    bigint not null unique      references "Diagnóstico"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Diagnóstico"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Diagnóstico"."version" as
  select
    "Diagnóstico"."journal"."entry",
    "Diagnóstico"."journal"."timestamp" as "journal timestamp",
    "Diagnóstico"."revocation"."end timestamp",
    "Diagnóstico"."succession"."successor",
    "Diagnóstico"."identity"."Medical_report version",
    "Medical_report identity"."identity" as "Medical_report -> identity"
,
    "Diagnóstico"."identity"."Diagnosis version",
    "Diagnosis identity"."código" as "Diagnosis -> código"

  from "Diagnóstico"."identity" natural join "Diagnóstico"."journal"
  left outer join "Diagnóstico"."revocation" on ("Diagnóstico"."journal"."entry" = "Diagnóstico"."revocation"."entry")
  left outer join "Diagnóstico"."succession" on ("Diagnóstico"."journal"."entry" = "Diagnóstico"."succession"."entry")
  inner join "Medical_report"."journal" as "Medical_report journal" on ("Diagnóstico"."identity"."Medical_report version" = "Medical_report journal"."entry")
  inner join "Medical_report"."identity" as "Medical_report identity" on ("Medical_report journal"."identity" = "Medical_report identity"."identity")

  inner join "Diagnosis"."journal" as "Diagnosis journal" on ("Diagnóstico"."identity"."Diagnosis version" = "Diagnosis journal"."entry")
  inner join "Diagnosis"."identity" as "Diagnosis identity" on ("Diagnosis journal"."identity" = "Diagnosis identity"."identity")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Diagnóstico" as
  select
    "Diagnóstico"."identity"."Medical_report version",
    "Medical_report identity"."identity" as "Medical_report -> identity"
,
    "Diagnóstico"."identity"."Diagnosis version",
    "Diagnosis identity"."código" as "Diagnosis -> código"

  from "Diagnóstico"."active" natural join "Diagnóstico"."identity" natural join "Diagnóstico"."journal"
  inner join "Medical_report"."journal" as "Medical_report journal" on ("Diagnóstico"."identity"."Medical_report version" = "Medical_report journal"."entry")
  inner join "Medical_report"."identity" as "Medical_report identity" on ("Medical_report journal"."identity" = "Medical_report identity"."identity")

  inner join "Diagnosis"."journal" as "Diagnosis journal" on ("Diagnóstico"."identity"."Diagnosis version" = "Diagnosis journal"."entry")
  inner join "Diagnosis"."identity" as "Diagnosis identity" on ("Diagnosis journal"."identity" = "Diagnosis identity"."identity")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Diagnóstico"."view insert"
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
      if new."Medical_report version" is not null then
        raise exception 'insertions into % view must not specify %', 'Diagnóstico', 'Medical_report version';
      end if;

      if new."Diagnosis version" is not null then
        raise exception 'insertions into % view must not specify %', 'Diagnóstico', 'Diagnosis version';
      end if;

      select     "Diagnóstico"."identity"."identity", "Medical_report"."active"."entry", "Diagnosis"."active"."entry"
      into       "new identity", new."Medical_report version", new."Diagnosis version"
      from       "Diagnóstico"."identity"
      inner join ("Medical_report"."identity" natural join "Medical_report"."journal" natural join "Medical_report"."active") on ("Diagnóstico"."identity"."Medical_report version" = "Medical_report"."journal"."entry")
      inner join ("Diagnosis"."identity" natural join "Diagnosis"."journal" natural join "Diagnosis"."active") on ("Diagnóstico"."identity"."Diagnosis version" = "Diagnosis"."journal"."entry")
      where      "Medical_report"."identity"."identity" = new."Medical_report -> identity"
      and        "Diagnosis"."identity"."código" = new."Diagnosis -> código"
      ;

      if not found then
        select "Medical_report"."active"."entry"
        into   new."Medical_report version"
        from   ("Medical_report"."identity" natural join "Medical_report"."journal" natural join "Medical_report"."active")
        where  "Medical_report"."identity"."identity" = new."Medical_report -> identity"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Medical_report', 'Medical_report', 'Diagnóstico';
        end if;

        select "Diagnosis"."active"."entry"
        into   new."Diagnosis version"
        from   ("Diagnosis"."identity" natural join "Diagnosis"."journal" natural join "Diagnosis"."active")
        where  "Diagnosis"."identity"."código" = new."Diagnosis -> código"
        ;
        if not found then
          raise exception 'no active % row matches % reference on insert into % table', 'Diagnosis', 'Diagnosis', 'Diagnóstico';
        end if;

        insert into "Diagnóstico"."identity"
          ("Medical_report version", "Diagnosis version") values
          (new."Medical_report version", new."Diagnosis version")
        returning "Diagnóstico"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Diagnóstico"."journal"
        (    "identity") values
        ("new identity")
      returning "Diagnóstico"."journal"."entry" into "new entry"
      ;

      insert into "Diagnóstico"."active"
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
instead of insert on public."Diagnóstico"
for each row execute procedure "Diagnóstico"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Diagnóstico"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Diagnóstico"."revocation" ("entry", "start timestamp")
      select       "Diagnóstico"."journal"."entry", "Diagnóstico"."journal"."timestamp"
      from         "Diagnóstico"."active"
      natural join "Diagnóstico"."identity"
      natural join "Diagnóstico"."journal"
      where        "Diagnóstico"."identity"."Medical_report version" = old."Medical_report version"
      and          "Diagnóstico"."identity"."Diagnosis version" = old."Diagnosis version"
      ;

      delete from "Diagnóstico"."active"
      using       "Diagnóstico"."identity" natural join "Diagnóstico"."journal"
      where       "Diagnóstico"."active"."entry" = "Diagnóstico"."journal"."entry"
      and         "Diagnóstico"."identity"."Medical_report version" = old."Medical_report version"
      and         "Diagnóstico"."identity"."Diagnosis version" = old."Diagnosis version"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Diagnóstico"
for each row execute procedure "Diagnóstico"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Diagnóstico"."update function"
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
      if new."Medical_report -> identity" is null then
        raise exception 'null value in column % violates not-null constraint', 'Medical_report -> identity';
      end if;

      if new."Diagnosis -> código" is null then
        raise exception 'null value in column % violates not-null constraint', 'Diagnosis -> código';
      end if;

      if
        new."Medical_report version" is not null and
        old."Medical_report version" <> new."Medical_report version"
      then
        raise exception 'updates to % view must not set %', 'Diagnóstico', 'Medical_report version';
      elsif
        new."Medical_report version" is null
        or old."Medical_report -> identity" <> new."Medical_report -> identity"
      then
        select "Medical_report"."active"."entry"
        into   new."Medical_report version"
        from   "Medical_report"."active" natural join "Medical_report"."identity"
        where  "Medical_report"."identity"."identity" = new."Medical_report -> identity"
        ;
        if not found then
          raise exception 'no active % row matches % reference on update to % row', 'Medical_report', 'Medical_report', 'Diagnóstico';
        end if;
      end if;

      if
        new."Diagnosis version" is not null and
        old."Diagnosis version" <> new."Diagnosis version"
      then
        raise exception 'updates to % view must not set %', 'Diagnóstico', 'Diagnosis version';
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
          raise exception 'no active % row matches % reference on update to % row', 'Diagnosis', 'Diagnosis', 'Diagnóstico';
        end if;
      end if;

      select "Diagnóstico"."active"."entry"
      into   "old entry"
      from   "Diagnóstico"."active" natural join "Diagnóstico"."identity"
      where  "Diagnóstico"."identity"."Medical_report version" = old."Medical_report version"
      and    "Diagnóstico"."identity"."Diagnosis version" = old."Diagnosis version"
      ;

      delete from public."Diagnóstico"
      where       public."Diagnóstico"."Medical_report version" = old."Medical_report version"
      and         public."Diagnóstico"."Diagnosis version" = old."Diagnosis version"
      ;

      select "Diagnóstico"."identity"."identity"
      into   "new identity"
      from   "Diagnóstico"."identity"
      where  "Diagnóstico"."identity"."Medical_report version" = new."Medical_report version"
      and    "Diagnóstico"."identity"."Diagnosis version" = new."Diagnosis version"
      ;
      if not found then
        insert into "Diagnóstico"."identity"
          ("Medical_report version", "Diagnosis version") values
          (new."Medical_report version", new."Diagnosis version")
        returning "Diagnóstico"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Diagnóstico"."journal"
        (    "identity") values
        ("new identity")
      returning "Diagnóstico"."journal"."entry"
      into "new entry"
      ;

      insert into "Diagnóstico"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Diagnóstico"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Diagnóstico"."revocation"."end timestamp"
      from        "Diagnóstico"."revocation"
      where       "Diagnóstico"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Diagnóstico"
for each row execute procedure "Diagnóstico"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* Reference triggers */
/*}}}*/
/*{{{*//*{{{*//* cascade on update to "Medical_report" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Diagnóstico"."cascade update on Diagnóstico view Medical_report reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Diagnóstico"
      set
        ( "Medical_report version"
        , "Medical_report -> identity"
        )
      = ( null
        , "Medical_report"."version"."identity"
        )
      from  "Medical_report"."version"
      where new."entry" = public."Diagnóstico"."Medical_report version"
      and   new."entry" = "Medical_report"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Diagnóstico view Medical_report reference"
after insert on "Medical_report"."succession"
for each row execute procedure "Diagnóstico"."cascade update on Diagnóstico view Medical_report reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Medical_report" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Diagnóstico"."restrict delete on Diagnóstico view Medical_report reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Diagnóstico"
      where   public."Diagnóstico"."Medical_report version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Medical_report'
        , 'Diagnóstico'
        , 'Medical_report'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Diagnóstico view Medical_report reference"
after insert on "Medical_report"."revocation"
deferrable initially deferred
for each row execute procedure "Diagnóstico"."restrict delete on Diagnóstico view Medical_report reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* cascade on update to "Diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Diagnóstico"."cascade update on Diagnóstico view Diagnosis reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      update public."Diagnóstico"
      set
        ( "Diagnosis version"
        , "Diagnosis -> código"
        )
      = ( null
        , "Diagnosis"."version"."código"
        )
      from  "Diagnosis"."version"
      where new."entry" = public."Diagnóstico"."Diagnosis version"
      and   new."entry" = "Diagnosis"."version"."entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "20 cascade update on Diagnóstico view Diagnosis reference"
after insert on "Diagnosis"."succession"
for each row execute procedure "Diagnóstico"."cascade update on Diagnóstico view Diagnosis reference"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* restrict on delete to "Diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Diagnóstico"."restrict delete on Diagnóstico view Diagnosis reference"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      perform *
      from    public."Diagnóstico"
      where   public."Diagnóstico"."Diagnosis version" = new."entry"
      limit   1
      ;
      if found then
        raise exception '% on % table breaks % table % reference'
        , 'delete'
        , 'Diagnosis'
        , 'Diagnóstico'
        , 'Diagnosis'
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create constraint trigger "20 restrict delete on Diagnóstico view Diagnosis reference"
after insert on "Diagnosis"."revocation"
deferrable initially deferred
for each row execute procedure "Diagnóstico"."restrict delete on Diagnóstico view Diagnosis reference"();/*}}}*//*}}}*//*}}}*//*}}}*//*}}}*//*}}}*/
