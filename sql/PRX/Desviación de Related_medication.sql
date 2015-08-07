/*{{{*//*{{{*//* "Desviación de Related_medication" schema */
/*}}}*/
/*{{{*/create schema "Desviación de Related_medication";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Desviación de Related_medication"."identity"
  ( "identity" bigserial not null primary key
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Desviación de Related_medication"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Desviación de Related_medication"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Desviación de Related_medication"."revocation"
  ( "entry"           bigint                   not null primary key references "Desviación de Related_medication"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Desviación de Related_medication"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Desviación de Related_medication"."succession"
  ( "entry"     bigint                   not null primary key references "Desviación de Related_medication"."revocation"
  , "successor" bigint                   not null unique      references "Desviación de Related_medication"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Desviación de Related_medication"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Desviación de Related_medication"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Desviación de Related_medication"."active"
  ( "identity" bigint not null primary key references "Desviación de Related_medication"."identity"
  , "entry"    bigint not null unique      references "Desviación de Related_medication"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Desviación de Related_medication"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* "tipo de desviación" */
/*}}}*/
/*{{{*/create table "Desviación de Related_medication"."tipo de desviación reference"
  ( "entry" bigint not null primary key references "Desviación de Related_medication"."journal"
  , "tipo de desviación reference" bigint not null references "Tipo de desviación"."journal" ("entry") deferrable initially deferred
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "Related_medication" */
/*}}}*/
/*{{{*/create table "Desviación de Related_medication"."Related_medication reference"
  ( "entry" bigint not null primary key references "Desviación de Related_medication"."journal"
  , "Related_medication reference" bigint not null references "Related_medication"."journal" ("entry") deferrable initially deferred
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "cantidad máxima aprobada" */
/*}}}*/
/*{{{*/create table "Desviación de Related_medication"."cantidad máxima aprobada state"
  ( "cantidad máxima aprobada state" bigserial not null primary key
  , "cantidad máxima aprobada" integer not null
  )
;
/*}}}*/
/*{{{*/create table "Desviación de Related_medication"."cantidad máxima aprobada proxy"
  ( "entry" bigint not null primary key references "Desviación de Related_medication"."journal"
  , "cantidad máxima aprobada state" bigint not null references "Desviación de Related_medication"."cantidad máxima aprobada state"
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "ignorada" */
/*}}}*/
/*{{{*/create table "Desviación de Related_medication"."ignorada state"
  ( "ignorada state" bigserial not null primary key
  , "ignorada" bool not null
  )
;
/*}}}*/
/*{{{*/create table "Desviación de Related_medication"."ignorada proxy"
  ( "entry" bigint not null primary key references "Desviación de Related_medication"."journal"
  , "ignorada state" bigint not null references "Desviación de Related_medication"."ignorada state"
  )
;
/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Desviación de Related_medication"."version" as
  select
    "Desviación de Related_medication"."journal"."entry",
    "Desviación de Related_medication"."journal"."timestamp" as "journal timestamp",
    "Desviación de Related_medication"."revocation"."end timestamp",
    "Desviación de Related_medication"."succession"."successor",
    "Desviación de Related_medication"."identity"."identity",
    "Desviación de Related_medication"."tipo de desviación reference"."tipo de desviación reference" as "tipo de desviación version",
    "tipo de desviación identity"."identity" as "tipo de desviación -> identity"
,
    "Desviación de Related_medication"."Related_medication reference"."Related_medication reference" as "Related_medication version",
    "Related_medication identity"."Requested_medication version" as "Related_medication -> Requested_medication version"
,
    "Related_medication identity"."Prescribed_drug version" as "Related_medication -> Prescribed_drug version"
,
    "Desviación de Related_medication"."cantidad máxima aprobada state"."cantidad máxima aprobada",
    "Desviación de Related_medication"."ignorada state"."ignorada"
  from "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."journal"
  left outer join "Desviación de Related_medication"."revocation" on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."revocation"."entry")
  left outer join "Desviación de Related_medication"."succession" on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."succession"."entry")
  left outer join "Desviación de Related_medication"."tipo de desviación reference"
    on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."tipo de desviación reference"."entry")
  left outer join "Tipo de desviación"."journal" as "tipo de desviación journal"
    on ("Desviación de Related_medication"."tipo de desviación reference"."tipo de desviación reference" = "tipo de desviación journal"."entry")
  left outer join "Tipo de desviación"."identity" as "tipo de desviación identity"
    on ("tipo de desviación journal"."identity" = "tipo de desviación identity"."identity")

  left outer join "Desviación de Related_medication"."Related_medication reference"
    on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."Related_medication reference"."entry")
  left outer join "Related_medication"."journal" as "Related_medication journal"
    on ("Desviación de Related_medication"."Related_medication reference"."Related_medication reference" = "Related_medication journal"."entry")
  left outer join "Related_medication"."identity" as "Related_medication identity"
    on ("Related_medication journal"."identity" = "Related_medication identity"."identity")

  left outer join "Desviación de Related_medication"."cantidad máxima aprobada proxy"
    on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."cantidad máxima aprobada proxy"."entry")
  left outer join "Desviación de Related_medication"."cantidad máxima aprobada state"
    using ("cantidad máxima aprobada state")

  left outer join "Desviación de Related_medication"."ignorada proxy"
    on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."ignorada proxy"."entry")
  left outer join "Desviación de Related_medication"."ignorada state"
    using ("ignorada state")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Desviación de Related_medication" as
  select
    "Desviación de Related_medication"."identity"."identity",
    "Desviación de Related_medication"."tipo de desviación reference"."tipo de desviación reference" as "tipo de desviación version",
    "tipo de desviación identity"."identity" as "tipo de desviación -> identity"
,
    "Desviación de Related_medication"."Related_medication reference"."Related_medication reference" as "Related_medication version",
    "Related_medication identity"."Requested_medication version" as "Related_medication -> Requested_medication version"
,
    "Related_medication identity"."Prescribed_drug version" as "Related_medication -> Prescribed_drug version"
,
    "Desviación de Related_medication"."cantidad máxima aprobada state"."cantidad máxima aprobada",
    "Desviación de Related_medication"."ignorada state"."ignorada"
  from "Desviación de Related_medication"."active" natural join "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."journal"
  left outer join "Desviación de Related_medication"."tipo de desviación reference"
    on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."tipo de desviación reference"."entry")
  left outer join "Tipo de desviación"."journal" as "tipo de desviación journal"
    on ("Desviación de Related_medication"."tipo de desviación reference"."tipo de desviación reference" = "tipo de desviación journal"."entry")
  left outer join "Tipo de desviación"."identity" as "tipo de desviación identity"
    on ("tipo de desviación journal"."identity" = "tipo de desviación identity"."identity")

  left outer join "Desviación de Related_medication"."Related_medication reference"
    on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."Related_medication reference"."entry")
  left outer join "Related_medication"."journal" as "Related_medication journal"
    on ("Desviación de Related_medication"."Related_medication reference"."Related_medication reference" = "Related_medication journal"."entry")
  left outer join "Related_medication"."identity" as "Related_medication identity"
    on ("Related_medication journal"."identity" = "Related_medication identity"."identity")

  left outer join "Desviación de Related_medication"."cantidad máxima aprobada proxy"
    on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."cantidad máxima aprobada proxy"."entry")
  left outer join "Desviación de Related_medication"."cantidad máxima aprobada state"
    using ("cantidad máxima aprobada state")

  left outer join "Desviación de Related_medication"."ignorada proxy"
    on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."ignorada proxy"."entry")
  left outer join "Desviación de Related_medication"."ignorada state"
    using ("ignorada state")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."view insert"
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
        raise exception 'insertions into % view must not specify surrogate key value', 'Desviación de Related_medication';
      end if;
      select     "Desviación de Related_medication"."identity"."identity"
      into       "new identity"
      from       "Desviación de Related_medication"."identity"
      where      "Desviación de Related_medication"."identity"."identity" = new."identity"
      ;

      if not found then
        insert into "Desviación de Related_medication"."identity"
          ("identity") values
          (default   )
        returning "Desviación de Related_medication"."identity"."identity"
        into "new identity"
        ;
        new."identity" := "new identity";
      end if;

      insert into "Desviación de Related_medication"."journal"
        (    "identity") values
        ("new identity")
      returning "Desviación de Related_medication"."journal"."entry" into "new entry"
      ;

      insert into "Desviación de Related_medication"."active"
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
instead of insert on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Desviación de Related_medication"."revocation" ("entry", "start timestamp")
      select       "Desviación de Related_medication"."journal"."entry", "Desviación de Related_medication"."journal"."timestamp"
      from         "Desviación de Related_medication"."active"
      natural join "Desviación de Related_medication"."identity"
      natural join "Desviación de Related_medication"."journal"
      where        "Desviación de Related_medication"."identity"."identity" = old."identity"
      ;

      delete from "Desviación de Related_medication"."active"
      using       "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."journal"
      where       "Desviación de Related_medication"."active"."entry" = "Desviación de Related_medication"."journal"."entry"
      and         "Desviación de Related_medication"."identity"."identity" = old."identity"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."update function"
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
        raise exception 'updates to % view must not set surrogate key value', 'Desviación de Related_medication';
      end if;

      select "Desviación de Related_medication"."active"."entry"
      into   "old entry"
      from   "Desviación de Related_medication"."active" natural join "Desviación de Related_medication"."identity"
      where  "Desviación de Related_medication"."identity"."identity" = old."identity"
      ;

      delete from public."Desviación de Related_medication"
      where       public."Desviación de Related_medication"."identity" = old."identity"
      ;

      select "Desviación de Related_medication"."identity"."identity"
      into   "new identity"
      from   "Desviación de Related_medication"."identity"
      where  "Desviación de Related_medication"."identity"."identity" = new."identity"
      ;
      if not found then
        insert into "Desviación de Related_medication"."identity"
          ("identity") values
          (default   )
        returning "Desviación de Related_medication"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Desviación de Related_medication"."journal"
        (    "identity") values
        ("new identity")
      returning "Desviación de Related_medication"."journal"."entry"
      into "new entry"
      ;

      insert into "Desviación de Related_medication"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Desviación de Related_medication"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Desviación de Related_medication"."revocation"."end timestamp"
      from        "Desviación de Related_medication"."revocation"
      where       "Desviación de Related_medication"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* "tipo de desviación" */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."insert tipo de desviación function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if new."tipo de desviación version" is not null
      then
        raise exception 'insertions into % view must not specify % version', 'Desviación de Related_medication', 'tipo de desviación';
      end if;

      if new."tipo de desviación -> identity" is not null then
        insert into "Desviación de Related_medication"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de Related_medication"."active"."entry", "Tipo de desviación"."active"."entry"
        from        "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."active",
                    "Tipo de desviación"."identity" natural join "Tipo de desviación"."active"
        where       "Desviación de Related_medication"."identity"."identity" = new."identity"
      and         "Tipo de desviación"."identity"."identity" = new."tipo de desviación -> identity"
        ;
        if not found then
          raise exception 'no active % row matches insert into % table % reference', 'Tipo de desviación', 'Desviación de Related_medication', 'tipo de desviación';
        end if;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert tipo de desviación"
instead of insert on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."insert tipo de desviación function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."update tipo de desviación function"
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
        raise exception 'updates to % view must not set % version to non-null values', 'Desviación de Related_medication', 'tipo de desviación';

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
        insert into "Desviación de Related_medication"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de Related_medication"."active"."entry", "Tipo de desviación"."active"."entry"
        from        "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."active",
                    "Tipo de desviación"."identity" natural join "Tipo de desviación"."active"
        where       "Desviación de Related_medication"."identity"."identity" = new."identity"
        and         "Tipo de desviación"."identity"."identity" = new."tipo de desviación -> identity"
        ;
        if not found then
          raise exception 'no active % row matches update to % table % reference', 'Tipo de desviación', 'Desviación de Related_medication', 'tipo de desviación';
        end if;

      -- If the reference was unchanged in this update, and a reference actually existed (it was not null), then the new referrer version should refer to the same referred version as the old version.  This works just like regular attributes: the proxy pointer is copied in the new version if it exists.
      elsif
        old."tipo de desviación version" is not null and new."tipo de desviación version" is not null
        and old."tipo de desviación version" = new."tipo de desviación version"
        and new."tipo de desviación -> identity" is not null
        and old."tipo de desviación -> identity" = new."tipo de desviación -> identity"
      then
        insert into "Desviación de Related_medication"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de Related_medication"."active"."entry", new."tipo de desviación version"
        from        "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."active"
        where       "Desviación de Related_medication"."identity"."identity" = new."identity"
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
instead of update on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."update tipo de desviación function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* "Related_medication" */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."insert Related_medication function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if new."Related_medication version" is not null
      then
        raise exception 'insertions into % view must not specify % version', 'Desviación de Related_medication', 'Related_medication';
      end if;

      if new."Related_medication -> Requested_medication version" is not null and new."Related_medication -> Prescribed_drug version" is not null then
        insert into "Desviación de Related_medication"."Related_medication reference" ("entry", "Related_medication reference")
        select      "Desviación de Related_medication"."active"."entry", "Related_medication"."active"."entry"
        from        "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."active",
                    "Related_medication"."identity" natural join "Related_medication"."active"
        where       "Desviación de Related_medication"."identity"."identity" = new."identity"
      and         "Related_medication"."identity"."Requested_medication version" = new."Related_medication -> Requested_medication version"
      and         "Related_medication"."identity"."Prescribed_drug version" = new."Related_medication -> Prescribed_drug version"
        ;
        if not found then
          raise exception 'no active % row matches insert into % table % reference', 'Related_medication', 'Desviación de Related_medication', 'Related_medication';
        end if;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert Related_medication"
instead of insert on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."insert Related_medication function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."update Related_medication function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if
        new."Related_medication version" is not null
        and (
          not (old."Related_medication version" is not null)
          or old."Related_medication version" <> new."Related_medication version"
        )
      then
        raise exception 'updates to % view must not set % version to non-null values', 'Desviación de Related_medication', 'Related_medication';

      elsif (
        -- If the referred identity did not change, and the referred version was set to null, the user requested updating the reference to the currently active version of the same row (“same” by identity).
        old."Related_medication version" is not null
        and not (new."Related_medication version" is not null)
        and new."Related_medication -> Requested_medication version" is not null and old."Related_medication -> Requested_medication version" = new."Related_medication -> Requested_medication version"
          and new."Related_medication -> Prescribed_drug version" is not null and old."Related_medication -> Prescribed_drug version" = new."Related_medication -> Prescribed_drug version"

        -- If the referred version did not change, but the referred identity did, the user requested making the reference point to the currently active version of another row (“another” by identity).
      ) or (new."Related_medication -> Requested_medication version" is not null
        and new."Related_medication -> Prescribed_drug version" is not null
        and (
          not (old."Related_medication -> Requested_medication version" is not null) or old."Related_medication -> Requested_medication version" <> new."Related_medication -> Requested_medication version"
          or not (old."Related_medication -> Prescribed_drug version" is not null) or old."Related_medication -> Prescribed_drug version" <> new."Related_medication -> Prescribed_drug version"
        )
      ) then
        -- In either case, find the currently active version of the requested row and establish the reference.
        insert into "Desviación de Related_medication"."Related_medication reference" ("entry", "Related_medication reference")
        select      "Desviación de Related_medication"."active"."entry", "Related_medication"."active"."entry"
        from        "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."active",
                    "Related_medication"."identity" natural join "Related_medication"."active"
        where       "Desviación de Related_medication"."identity"."identity" = new."identity"
        and         "Related_medication"."identity"."Requested_medication version" = new."Related_medication -> Requested_medication version"
        and         "Related_medication"."identity"."Prescribed_drug version" = new."Related_medication -> Prescribed_drug version"
        ;
        if not found then
          raise exception 'no active % row matches update to % table % reference', 'Related_medication', 'Desviación de Related_medication', 'Related_medication';
        end if;

      -- If the reference was unchanged in this update, and a reference actually existed (it was not null), then the new referrer version should refer to the same referred version as the old version.  This works just like regular attributes: the proxy pointer is copied in the new version if it exists.
      elsif
        old."Related_medication version" is not null and new."Related_medication version" is not null
        and old."Related_medication version" = new."Related_medication version"
        and new."Related_medication -> Requested_medication version" is not null
        and new."Related_medication -> Prescribed_drug version" is not null
        and old."Related_medication -> Requested_medication version" = new."Related_medication -> Requested_medication version"
        and old."Related_medication -> Prescribed_drug version" = new."Related_medication -> Prescribed_drug version"
      then
        insert into "Desviación de Related_medication"."Related_medication reference" ("entry", "Related_medication reference")
        select      "Desviación de Related_medication"."active"."entry", new."Related_medication version"
        from        "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."active"
        where       "Desviación de Related_medication"."identity"."identity" = new."identity"
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
create trigger "10 update Related_medication"
instead of update on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."update Related_medication function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* "cantidad máxima aprobada" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."insert or update cantidad máxima aprobada function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    declare
      "new cantidad máxima aprobada state" bigint;
    begin
      if
        new."cantidad máxima aprobada" is not null
      then
        if
          tg_op = 'INSERT'
          or not (old."cantidad máxima aprobada" is not null and old."cantidad máxima aprobada" = new."cantidad máxima aprobada")
        then
          insert into "Desviación de Related_medication"."cantidad máxima aprobada state"
            (    "cantidad máxima aprobada") values
            (new."cantidad máxima aprobada")
          returning   "Desviación de Related_medication"."cantidad máxima aprobada state"."cantidad máxima aprobada state"
          into        "new cantidad máxima aprobada state"
          ;
        else
          select     "Desviación de Related_medication"."cantidad máxima aprobada proxy"."cantidad máxima aprobada state"
          into       "new cantidad máxima aprobada state"
          from       "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."active" natural join "Desviación de Related_medication"."journal"
          inner join "Desviación de Related_medication"."succession" on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."succession"."successor")
          inner join "Desviación de Related_medication"."cantidad máxima aprobada proxy" on ("Desviación de Related_medication"."succession"."entry" = "Desviación de Related_medication"."cantidad máxima aprobada proxy"."entry")
          where      "Desviación de Related_medication"."identity"."identity" = new."identity"
          ;
        end if;

        insert into  "Desviación de Related_medication"."cantidad máxima aprobada proxy" ("entry", "cantidad máxima aprobada state")
        select       "Desviación de Related_medication"."active"."entry", "new cantidad máxima aprobada state"
        from         "Desviación de Related_medication"."identity" inner join "Desviación de Related_medication"."active" using ("identity")
        where        "Desviación de Related_medication"."identity"."identity" = new."identity"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update cantidad máxima aprobada"
instead of insert or update on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."insert or update cantidad máxima aprobada function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* "ignorada" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de Related_medication"."insert or update ignorada function"
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
          insert into "Desviación de Related_medication"."ignorada state"
            (    "ignorada") values
            (new."ignorada")
          returning   "Desviación de Related_medication"."ignorada state"."ignorada state"
          into        "new ignorada state"
          ;
        else
          select     "Desviación de Related_medication"."ignorada proxy"."ignorada state"
          into       "new ignorada state"
          from       "Desviación de Related_medication"."identity" natural join "Desviación de Related_medication"."active" natural join "Desviación de Related_medication"."journal"
          inner join "Desviación de Related_medication"."succession" on ("Desviación de Related_medication"."journal"."entry" = "Desviación de Related_medication"."succession"."successor")
          inner join "Desviación de Related_medication"."ignorada proxy" on ("Desviación de Related_medication"."succession"."entry" = "Desviación de Related_medication"."ignorada proxy"."entry")
          where      "Desviación de Related_medication"."identity"."identity" = new."identity"
          ;
        end if;

        insert into  "Desviación de Related_medication"."ignorada proxy" ("entry", "ignorada state")
        select       "Desviación de Related_medication"."active"."entry", "new ignorada state"
        from         "Desviación de Related_medication"."identity" inner join "Desviación de Related_medication"."active" using ("identity")
        where        "Desviación de Related_medication"."identity"."identity" = new."identity"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update ignorada"
instead of insert or update on public."Desviación de Related_medication"
for each row execute procedure "Desviación de Related_medication"."insert or update ignorada function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Reference triggers */
/*}}}*//*}}}*//*}}}*//*}}}*/
