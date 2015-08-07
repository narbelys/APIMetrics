/*{{{*//*{{{*//* "Desviación de Related_diagnosis" schema */
/*}}}*/
/*{{{*/create schema "Desviación de Related_diagnosis";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Desviación de Related_diagnosis"."identity"
  ( "identity" bigserial not null primary key
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Desviación de Related_diagnosis"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Desviación de Related_diagnosis"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Desviación de Related_diagnosis"."revocation"
  ( "entry"           bigint                   not null primary key references "Desviación de Related_diagnosis"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Desviación de Related_diagnosis"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Desviación de Related_diagnosis"."succession"
  ( "entry"     bigint                   not null primary key references "Desviación de Related_diagnosis"."revocation"
  , "successor" bigint                   not null unique      references "Desviación de Related_diagnosis"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Desviación de Related_diagnosis"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Desviación de Related_diagnosis"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Desviación de Related_diagnosis"."active"
  ( "identity" bigint not null primary key references "Desviación de Related_diagnosis"."identity"
  , "entry"    bigint not null unique      references "Desviación de Related_diagnosis"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Desviación de Related_diagnosis"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* "tipo de desviación" */
/*}}}*/
/*{{{*/create table "Desviación de Related_diagnosis"."tipo de desviación reference"
  ( "entry" bigint not null primary key references "Desviación de Related_diagnosis"."journal"
  , "tipo de desviación reference" bigint not null references "Tipo de desviación"."journal" ("entry") deferrable initially deferred
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "Related_diagnosis" */
/*}}}*/
/*{{{*/create table "Desviación de Related_diagnosis"."Related_diagnosis reference"
  ( "entry" bigint not null primary key references "Desviación de Related_diagnosis"."journal"
  , "Related_diagnosis reference" bigint not null references "Related_diagnosis"."journal" ("entry") deferrable initially deferred
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "ignorada" */
/*}}}*/
/*{{{*/create table "Desviación de Related_diagnosis"."ignorada state"
  ( "ignorada state" bigserial not null primary key
  , "ignorada" bool not null
  )
;
/*}}}*/
/*{{{*/create table "Desviación de Related_diagnosis"."ignorada proxy"
  ( "entry" bigint not null primary key references "Desviación de Related_diagnosis"."journal"
  , "ignorada state" bigint not null references "Desviación de Related_diagnosis"."ignorada state"
  )
;
/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Desviación de Related_diagnosis"."version" as
  select
    "Desviación de Related_diagnosis"."journal"."entry",
    "Desviación de Related_diagnosis"."journal"."timestamp" as "journal timestamp",
    "Desviación de Related_diagnosis"."revocation"."end timestamp",
    "Desviación de Related_diagnosis"."succession"."successor",
    "Desviación de Related_diagnosis"."identity"."identity",
    "Desviación de Related_diagnosis"."tipo de desviación reference"."tipo de desviación reference" as "tipo de desviación version",
    "tipo de desviación identity"."identity" as "tipo de desviación -> identity"
,
    "Desviación de Related_diagnosis"."Related_diagnosis reference"."Related_diagnosis reference" as "Related_diagnosis version",
    "Related_diagnosis identity"."Related_medication version" as "Related_diagnosis -> Related_medication version"
,
    "Related_diagnosis identity"."diagnóstico version" as "Related_diagnosis -> diagnóstico version"
,
    "Desviación de Related_diagnosis"."ignorada state"."ignorada"
  from "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."journal"
  left outer join "Desviación de Related_diagnosis"."revocation" on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."revocation"."entry")
  left outer join "Desviación de Related_diagnosis"."succession" on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."succession"."entry")
  left outer join "Desviación de Related_diagnosis"."tipo de desviación reference"
    on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."tipo de desviación reference"."entry")
  left outer join "Tipo de desviación"."journal" as "tipo de desviación journal"
    on ("Desviación de Related_diagnosis"."tipo de desviación reference"."tipo de desviación reference" = "tipo de desviación journal"."entry")
  left outer join "Tipo de desviación"."identity" as "tipo de desviación identity"
    on ("tipo de desviación journal"."identity" = "tipo de desviación identity"."identity")

  left outer join "Desviación de Related_diagnosis"."Related_diagnosis reference"
    on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."Related_diagnosis reference"."entry")
  left outer join "Related_diagnosis"."journal" as "Related_diagnosis journal"
    on ("Desviación de Related_diagnosis"."Related_diagnosis reference"."Related_diagnosis reference" = "Related_diagnosis journal"."entry")
  left outer join "Related_diagnosis"."identity" as "Related_diagnosis identity"
    on ("Related_diagnosis journal"."identity" = "Related_diagnosis identity"."identity")

  left outer join "Desviación de Related_diagnosis"."ignorada proxy"
    on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."ignorada proxy"."entry")
  left outer join "Desviación de Related_diagnosis"."ignorada state"
    using ("ignorada state")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Desviación de Related_diagnosis" as
  select
    "Desviación de Related_diagnosis"."identity"."identity",
    "Desviación de Related_diagnosis"."tipo de desviación reference"."tipo de desviación reference" as "tipo de desviación version",
    "tipo de desviación identity"."identity" as "tipo de desviación -> identity"
,
    "Desviación de Related_diagnosis"."Related_diagnosis reference"."Related_diagnosis reference" as "Related_diagnosis version",
    "Related_diagnosis identity"."Related_medication version" as "Related_diagnosis -> Related_medication version"
,
    "Related_diagnosis identity"."diagnóstico version" as "Related_diagnosis -> diagnóstico version"
,
    "Desviación de Related_diagnosis"."ignorada state"."ignorada"
  from "Desviación de Related_diagnosis"."active" natural join "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."journal"
  left outer join "Desviación de Related_diagnosis"."tipo de desviación reference"
    on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."tipo de desviación reference"."entry")
  left outer join "Tipo de desviación"."journal" as "tipo de desviación journal"
    on ("Desviación de Related_diagnosis"."tipo de desviación reference"."tipo de desviación reference" = "tipo de desviación journal"."entry")
  left outer join "Tipo de desviación"."identity" as "tipo de desviación identity"
    on ("tipo de desviación journal"."identity" = "tipo de desviación identity"."identity")

  left outer join "Desviación de Related_diagnosis"."Related_diagnosis reference"
    on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."Related_diagnosis reference"."entry")
  left outer join "Related_diagnosis"."journal" as "Related_diagnosis journal"
    on ("Desviación de Related_diagnosis"."Related_diagnosis reference"."Related_diagnosis reference" = "Related_diagnosis journal"."entry")
  left outer join "Related_diagnosis"."identity" as "Related_diagnosis identity"
    on ("Related_diagnosis journal"."identity" = "Related_diagnosis identity"."identity")

  left outer join "Desviación de Related_diagnosis"."ignorada proxy"
    on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."ignorada proxy"."entry")
  left outer join "Desviación de Related_diagnosis"."ignorada state"
    using ("ignorada state")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_diagnosis"."view insert"
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
        raise exception 'insertions into % view must not specify surrogate key value', 'Desviación de Related_diagnosis';
      end if;
      select     "Desviación de Related_diagnosis"."identity"."identity"
      into       "new identity"
      from       "Desviación de Related_diagnosis"."identity"
      where      "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
      ;

      if not found then
        insert into "Desviación de Related_diagnosis"."identity"
          ("identity") values
          (default   )
        returning "Desviación de Related_diagnosis"."identity"."identity"
        into "new identity"
        ;
        new."identity" := "new identity";
      end if;

      insert into "Desviación de Related_diagnosis"."journal"
        (    "identity") values
        ("new identity")
      returning "Desviación de Related_diagnosis"."journal"."entry" into "new entry"
      ;

      insert into "Desviación de Related_diagnosis"."active"
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
instead of insert on public."Desviación de Related_diagnosis"
for each row execute procedure "Desviación de Related_diagnosis"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_diagnosis"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Desviación de Related_diagnosis"."revocation" ("entry", "start timestamp")
      select       "Desviación de Related_diagnosis"."journal"."entry", "Desviación de Related_diagnosis"."journal"."timestamp"
      from         "Desviación de Related_diagnosis"."active"
      natural join "Desviación de Related_diagnosis"."identity"
      natural join "Desviación de Related_diagnosis"."journal"
      where        "Desviación de Related_diagnosis"."identity"."identity" = old."identity"
      ;

      delete from "Desviación de Related_diagnosis"."active"
      using       "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."journal"
      where       "Desviación de Related_diagnosis"."active"."entry" = "Desviación de Related_diagnosis"."journal"."entry"
      and         "Desviación de Related_diagnosis"."identity"."identity" = old."identity"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Desviación de Related_diagnosis"
for each row execute procedure "Desviación de Related_diagnosis"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_diagnosis"."update function"
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
        raise exception 'updates to % view must not set surrogate key value', 'Desviación de Related_diagnosis';
      end if;

      select "Desviación de Related_diagnosis"."active"."entry"
      into   "old entry"
      from   "Desviación de Related_diagnosis"."active" natural join "Desviación de Related_diagnosis"."identity"
      where  "Desviación de Related_diagnosis"."identity"."identity" = old."identity"
      ;

      delete from public."Desviación de Related_diagnosis"
      where       public."Desviación de Related_diagnosis"."identity" = old."identity"
      ;

      select "Desviación de Related_diagnosis"."identity"."identity"
      into   "new identity"
      from   "Desviación de Related_diagnosis"."identity"
      where  "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
      ;
      if not found then
        insert into "Desviación de Related_diagnosis"."identity"
          ("identity") values
          (default   )
        returning "Desviación de Related_diagnosis"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Desviación de Related_diagnosis"."journal"
        (    "identity") values
        ("new identity")
      returning "Desviación de Related_diagnosis"."journal"."entry"
      into "new entry"
      ;

      insert into "Desviación de Related_diagnosis"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Desviación de Related_diagnosis"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Desviación de Related_diagnosis"."revocation"."end timestamp"
      from        "Desviación de Related_diagnosis"."revocation"
      where       "Desviación de Related_diagnosis"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Desviación de Related_diagnosis"
for each row execute procedure "Desviación de Related_diagnosis"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* "tipo de desviación" */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_diagnosis"."insert tipo de desviación function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if new."tipo de desviación version" is not null
      then
        raise exception 'insertions into % view must not specify % version', 'Desviación de Related_diagnosis', 'tipo de desviación';
      end if;

      if new."tipo de desviación -> identity" is not null then
        insert into "Desviación de Related_diagnosis"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de Related_diagnosis"."active"."entry", "Tipo de desviación"."active"."entry"
        from        "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."active",
                    "Tipo de desviación"."identity" natural join "Tipo de desviación"."active"
        where       "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
      and         "Tipo de desviación"."identity"."identity" = new."tipo de desviación -> identity"
        ;
        if not found then
          raise exception 'no active % row matches insert into % table % reference', 'Tipo de desviación', 'Desviación de Related_diagnosis', 'tipo de desviación';
        end if;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert tipo de desviación"
instead of insert on public."Desviación de Related_diagnosis"
for each row execute procedure "Desviación de Related_diagnosis"."insert tipo de desviación function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_diagnosis"."update tipo de desviación function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if
        new."tipo de desviación version" is not null
        and (
          not (old."tipo de desviación version" is not null)
          or old."tipo de desviación version" <> new."tipo de desviación version"
        )
      then
        raise exception 'updates to % view must not set % version to non-null values', 'Desviación de Related_diagnosis', 'tipo de desviación';

      elsif (
        -- If the referred identity did not change, and the referred version was set to null, the user requested updating the reference to the currently active version of the same row (“same” by identity).
        old."tipo de desviación version" is not null
        and not (new."tipo de desviación version" is not null)
        and new."tipo de desviación -> identity" is not null and old."tipo de desviación -> identity" = new."tipo de desviación -> identity"

        -- If the referred version did not change, but the referred identity did, the user requested making the reference point to the currently active version of another row (“another” by identity).
      ) or (new."tipo de desviación -> identity" is not null
        and (
          not (old."tipo de desviación -> identity" is not null) or old."tipo de desviación -> identity" <> new."tipo de desviación -> identity"
        )
      ) then
        -- In either case, find the currently active version of the requested row and establish the reference.
        insert into "Desviación de Related_diagnosis"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de Related_diagnosis"."active"."entry", "Tipo de desviación"."active"."entry"
        from        "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."active",
                    "Tipo de desviación"."identity" natural join "Tipo de desviación"."active"
        where       "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
        and         "Tipo de desviación"."identity"."identity" = new."tipo de desviación -> identity"
        ;
        if not found then
          raise exception 'no active % row matches update to % table % reference', 'Tipo de desviación', 'Desviación de Related_diagnosis', 'tipo de desviación';
        end if;

      -- If the reference was unchanged in this update, and a reference actually existed (it was not null), then the new referrer version should refer to the same referred version as the old version.  This works just like regular attributes: the proxy pointer is copied in the new version if it exists.
      elsif
        old."tipo de desviación version" is not null and new."tipo de desviación version" is not null
        and old."tipo de desviación version" = new."tipo de desviación version"
        and new."tipo de desviación -> identity" is not null
        and old."tipo de desviación -> identity" = new."tipo de desviación -> identity"
      then
        insert into "Desviación de Related_diagnosis"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de Related_diagnosis"."active"."entry", new."tipo de desviación version"
        from        "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."active"
        where       "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
        ;
        -- FIXME: what if the referenced entity version is no longer active?  should this restrict, leave the reference as-is, or try to update it?
        -- FIXME: is it possible for the referenced entity version to no longer be active if this is a proper covariant reference with on delete/update cascade/restrict triggers?
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 update tipo de desviación"
instead of update on public."Desviación de Related_diagnosis"
for each row execute procedure "Desviación de Related_diagnosis"."update tipo de desviación function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* "Related_diagnosis" */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_diagnosis"."insert Related_diagnosis function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if new."Related_diagnosis version" is not null
      then
        raise exception 'insertions into % view must not specify % version', 'Desviación de Related_diagnosis', 'Related_diagnosis';
      end if;

      if new."Related_diagnosis -> Related_medication version" is not null and new."Related_diagnosis -> diagnóstico version" is not null then
        insert into "Desviación de Related_diagnosis"."Related_diagnosis reference" ("entry", "Related_diagnosis reference")
        select      "Desviación de Related_diagnosis"."active"."entry", "Related_diagnosis"."active"."entry"
        from        "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."active",
                    "Related_diagnosis"."identity" natural join "Related_diagnosis"."active"
        where       "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
      and         "Related_diagnosis"."identity"."Related_medication version" = new."Related_diagnosis -> Related_medication version"
      and         "Related_diagnosis"."identity"."diagnóstico version" = new."Related_diagnosis -> diagnóstico version"
        ;
        if not found then
          raise exception 'no active % row matches insert into % table % reference', 'Related_diagnosis', 'Desviación de Related_diagnosis', 'Related_diagnosis';
        end if;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert Related_diagnosis"
instead of insert on public."Desviación de Related_diagnosis"
for each row execute procedure "Desviación de Related_diagnosis"."insert Related_diagnosis function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_diagnosis"."update Related_diagnosis function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if
        new."Related_diagnosis version" is not null
        and (
          not (old."Related_diagnosis version" is not null)
          or old."Related_diagnosis version" <> new."Related_diagnosis version"
        )
      then
        raise exception 'updates to % view must not set % version to non-null values', 'Desviación de Related_diagnosis', 'Related_diagnosis';

      elsif (
        -- If the referred identity did not change, and the referred version was set to null, the user requested updating the reference to the currently active version of the same row (“same” by identity).
        old."Related_diagnosis version" is not null
        and not (new."Related_diagnosis version" is not null)
        and new."Related_diagnosis -> Related_medication version" is not null and old."Related_diagnosis -> Related_medication version" = new."Related_diagnosis -> Related_medication version"
          and new."Related_diagnosis -> diagnóstico version" is not null and old."Related_diagnosis -> diagnóstico version" = new."Related_diagnosis -> diagnóstico version"

        -- If the referred version did not change, but the referred identity did, the user requested making the reference point to the currently active version of another row (“another” by identity).
      ) or (new."Related_diagnosis -> Related_medication version" is not null
        and new."Related_diagnosis -> diagnóstico version" is not null
        and (
          not (old."Related_diagnosis -> Related_medication version" is not null) or old."Related_diagnosis -> Related_medication version" <> new."Related_diagnosis -> Related_medication version"
          or not (old."Related_diagnosis -> diagnóstico version" is not null) or old."Related_diagnosis -> diagnóstico version" <> new."Related_diagnosis -> diagnóstico version"
        )
      ) then
        -- In either case, find the currently active version of the requested row and establish the reference.
        insert into "Desviación de Related_diagnosis"."Related_diagnosis reference" ("entry", "Related_diagnosis reference")
        select      "Desviación de Related_diagnosis"."active"."entry", "Related_diagnosis"."active"."entry"
        from        "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."active",
                    "Related_diagnosis"."identity" natural join "Related_diagnosis"."active"
        where       "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
        and         "Related_diagnosis"."identity"."Related_medication version" = new."Related_diagnosis -> Related_medication version"
        and         "Related_diagnosis"."identity"."diagnóstico version" = new."Related_diagnosis -> diagnóstico version"
        ;
        if not found then
          raise exception 'no active % row matches update to % table % reference', 'Related_diagnosis', 'Desviación de Related_diagnosis', 'Related_diagnosis';
        end if;

      -- If the reference was unchanged in this update, and a reference actually existed (it was not null), then the new referrer version should refer to the same referred version as the old version.  This works just like regular attributes: the proxy pointer is copied in the new version if it exists.
      elsif
        old."Related_diagnosis version" is not null and new."Related_diagnosis version" is not null
        and old."Related_diagnosis version" = new."Related_diagnosis version"
        and new."Related_diagnosis -> Related_medication version" is not null
        and new."Related_diagnosis -> diagnóstico version" is not null
        and old."Related_diagnosis -> Related_medication version" = new."Related_diagnosis -> Related_medication version"
        and old."Related_diagnosis -> diagnóstico version" = new."Related_diagnosis -> diagnóstico version"
      then
        insert into "Desviación de Related_diagnosis"."Related_diagnosis reference" ("entry", "Related_diagnosis reference")
        select      "Desviación de Related_diagnosis"."active"."entry", new."Related_diagnosis version"
        from        "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."active"
        where       "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
        ;
        -- FIXME: what if the referenced entity version is no longer active?  should this restrict, leave the reference as-is, or try to update it?
        -- FIXME: is it possible for the referenced entity version to no longer be active if this is a proper covariant reference with on delete/update cascade/restrict triggers?
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 update Related_diagnosis"
instead of update on public."Desviación de Related_diagnosis"
for each row execute procedure "Desviación de Related_diagnosis"."update Related_diagnosis function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* "ignorada" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_diagnosis"."insert or update ignorada function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    declare
      "new ignorada state" bigint;
    begin
      if
        new."ignorada" is not null
      then
        if
          tg_op = 'INSERT'
          or not (old."ignorada" is not null and old."ignorada" = new."ignorada")
        then
          insert into "Desviación de Related_diagnosis"."ignorada state"
            (    "ignorada") values
            (new."ignorada")
          returning   "Desviación de Related_diagnosis"."ignorada state"."ignorada state"
          into        "new ignorada state"
          ;
        else
          select     "Desviación de Related_diagnosis"."ignorada proxy"."ignorada state"
          into       "new ignorada state"
          from       "Desviación de Related_diagnosis"."identity" natural join "Desviación de Related_diagnosis"."active" natural join "Desviación de Related_diagnosis"."journal"
          inner join "Desviación de Related_diagnosis"."succession" on ("Desviación de Related_diagnosis"."journal"."entry" = "Desviación de Related_diagnosis"."succession"."successor")
          inner join "Desviación de Related_diagnosis"."ignorada proxy" on ("Desviación de Related_diagnosis"."succession"."entry" = "Desviación de Related_diagnosis"."ignorada proxy"."entry")
          where      "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
          ;
        end if;

        insert into  "Desviación de Related_diagnosis"."ignorada proxy" ("entry", "ignorada state")
        select       "Desviación de Related_diagnosis"."active"."entry", "new ignorada state"
        from         "Desviación de Related_diagnosis"."identity" inner join "Desviación de Related_diagnosis"."active" using ("identity")
        where        "Desviación de Related_diagnosis"."identity"."identity" = new."identity"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update ignorada"
instead of insert or update on public."Desviación de Related_diagnosis"
for each row execute procedure "Desviación de Related_diagnosis"."insert or update ignorada function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Reference triggers */
/*}}}*//*}}}*//*}}}*//*}}}*/
