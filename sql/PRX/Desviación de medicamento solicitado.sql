/*{{{*//*{{{*//* "Desviación de medicamento solicitado" schema */
/*}}}*/
/*{{{*/create schema "Desviación de medicamento solicitado";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Desviación de medicamento solicitado"."identity"
  ( "identity" bigserial not null primary key
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Desviación de medicamento solicitado"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Desviación de medicamento solicitado"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Desviación de medicamento solicitado"."revocation"
  ( "entry"           bigint                   not null primary key references "Desviación de medicamento solicitado"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Desviación de medicamento solicitado"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Desviación de medicamento solicitado"."succession"
  ( "entry"     bigint                   not null primary key references "Desviación de medicamento solicitado"."revocation"
  , "successor" bigint                   not null unique      references "Desviación de medicamento solicitado"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Desviación de medicamento solicitado"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Desviación de medicamento solicitado"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Desviación de medicamento solicitado"."active"
  ( "identity" bigint not null primary key references "Desviación de medicamento solicitado"."identity"
  , "entry"    bigint not null unique      references "Desviación de medicamento solicitado"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Desviación de medicamento solicitado"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* "tipo de desviación" */
/*}}}*/
/*{{{*/create table "Desviación de medicamento solicitado"."tipo de desviación reference"
  ( "entry" bigint not null primary key references "Desviación de medicamento solicitado"."journal"
  , "tipo de desviación reference" bigint not null references "Tipo de desviación"."journal" ("entry") deferrable initially deferred
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "Requested_medication" */
/*}}}*/
/*{{{*/create table "Desviación de medicamento solicitado"."Requested_medication reference"
  ( "entry" bigint not null primary key references "Desviación de medicamento solicitado"."journal"
  , "Requested_medication reference" bigint not null references "Requested_medication"."journal" ("entry") deferrable initially deferred
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "precio unitario máximo aprobado" */
/*}}}*/
/*{{{*/create table "Desviación de medicamento solicitado"."precio unitario máximo aprobado state"
  ( "precio unitario máximo aprobado state" bigserial not null primary key
  , "precio unitario máximo aprobado" money not null
  )
;
/*}}}*/
/*{{{*/create table "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy"
  ( "entry" bigint not null primary key references "Desviación de medicamento solicitado"."journal"
  , "precio unitario máximo aprobado state" bigint not null references "Desviación de medicamento solicitado"."precio unitario máximo aprobado state"
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "ignorada" */
/*}}}*/
/*{{{*/create table "Desviación de medicamento solicitado"."ignorada state"
  ( "ignorada state" bigserial not null primary key
  , "ignorada" bool not null
  )
;
/*}}}*/
/*{{{*/create table "Desviación de medicamento solicitado"."ignorada proxy"
  ( "entry" bigint not null primary key references "Desviación de medicamento solicitado"."journal"
  , "ignorada state" bigint not null references "Desviación de medicamento solicitado"."ignorada state"
  )
;
/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Desviación de medicamento solicitado"."version" as
  select
    "Desviación de medicamento solicitado"."journal"."entry",
    "Desviación de medicamento solicitado"."journal"."timestamp" as "journal timestamp",
    "Desviación de medicamento solicitado"."revocation"."end timestamp",
    "Desviación de medicamento solicitado"."succession"."successor",
    "Desviación de medicamento solicitado"."identity"."identity",
    "Desviación de medicamento solicitado"."tipo de desviación reference"."tipo de desviación reference" as "tipo de desviación version",
    "tipo de desviación identity"."identity" as "tipo de desviación -> identity"
,
    "Desviación de medicamento solicitado"."Requested_medication reference"."Requested_medication reference" as "Requested_medication version",
    "Requested_medication identity"."identity" as "Requested_medication -> identity"
,
    "Desviación de medicamento solicitado"."precio unitario máximo aprobado state"."precio unitario máximo aprobado",
    "Desviación de medicamento solicitado"."ignorada state"."ignorada"
  from "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."journal"
  left outer join "Desviación de medicamento solicitado"."revocation" on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."revocation"."entry")
  left outer join "Desviación de medicamento solicitado"."succession" on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."succession"."entry")
  left outer join "Desviación de medicamento solicitado"."tipo de desviación reference"
    on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."tipo de desviación reference"."entry")
  left outer join "Tipo de desviación"."journal" as "tipo de desviación journal"
    on ("Desviación de medicamento solicitado"."tipo de desviación reference"."tipo de desviación reference" = "tipo de desviación journal"."entry")
  left outer join "Tipo de desviación"."identity" as "tipo de desviación identity"
    on ("tipo de desviación journal"."identity" = "tipo de desviación identity"."identity")

  left outer join "Desviación de medicamento solicitado"."Requested_medication reference"
    on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."Requested_medication reference"."entry")
  left outer join "Requested_medication"."journal" as "Requested_medication journal"
    on ("Desviación de medicamento solicitado"."Requested_medication reference"."Requested_medication reference" = "Requested_medication journal"."entry")
  left outer join "Requested_medication"."identity" as "Requested_medication identity"
    on ("Requested_medication journal"."identity" = "Requested_medication identity"."identity")

  left outer join "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy"
    on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy"."entry")
  left outer join "Desviación de medicamento solicitado"."precio unitario máximo aprobado state"
    using ("precio unitario máximo aprobado state")

  left outer join "Desviación de medicamento solicitado"."ignorada proxy"
    on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."ignorada proxy"."entry")
  left outer join "Desviación de medicamento solicitado"."ignorada state"
    using ("ignorada state")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Desviación de medicamento solicitado" as
  select
    "Desviación de medicamento solicitado"."identity"."identity",
    "Desviación de medicamento solicitado"."tipo de desviación reference"."tipo de desviación reference" as "tipo de desviación version",
    "tipo de desviación identity"."identity" as "tipo de desviación -> identity"
,
    "Desviación de medicamento solicitado"."Requested_medication reference"."Requested_medication reference" as "Requested_medication version",
    "Requested_medication identity"."identity" as "Requested_medication -> identity"
,
    "Desviación de medicamento solicitado"."precio unitario máximo aprobado state"."precio unitario máximo aprobado",
    "Desviación de medicamento solicitado"."ignorada state"."ignorada"
  from "Desviación de medicamento solicitado"."active" natural join "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."journal"
  left outer join "Desviación de medicamento solicitado"."tipo de desviación reference"
    on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."tipo de desviación reference"."entry")
  left outer join "Tipo de desviación"."journal" as "tipo de desviación journal"
    on ("Desviación de medicamento solicitado"."tipo de desviación reference"."tipo de desviación reference" = "tipo de desviación journal"."entry")
  left outer join "Tipo de desviación"."identity" as "tipo de desviación identity"
    on ("tipo de desviación journal"."identity" = "tipo de desviación identity"."identity")

  left outer join "Desviación de medicamento solicitado"."Requested_medication reference"
    on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."Requested_medication reference"."entry")
  left outer join "Requested_medication"."journal" as "Requested_medication journal"
    on ("Desviación de medicamento solicitado"."Requested_medication reference"."Requested_medication reference" = "Requested_medication journal"."entry")
  left outer join "Requested_medication"."identity" as "Requested_medication identity"
    on ("Requested_medication journal"."identity" = "Requested_medication identity"."identity")

  left outer join "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy"
    on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy"."entry")
  left outer join "Desviación de medicamento solicitado"."precio unitario máximo aprobado state"
    using ("precio unitario máximo aprobado state")

  left outer join "Desviación de medicamento solicitado"."ignorada proxy"
    on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."ignorada proxy"."entry")
  left outer join "Desviación de medicamento solicitado"."ignorada state"
    using ("ignorada state")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."view insert"
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
        raise exception 'insertions into % view must not specify surrogate key value', 'Desviación de medicamento solicitado';
      end if;
      select     "Desviación de medicamento solicitado"."identity"."identity"
      into       "new identity"
      from       "Desviación de medicamento solicitado"."identity"
      where      "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
      ;

      if not found then
        insert into "Desviación de medicamento solicitado"."identity"
          ("identity") values
          (default   )
        returning "Desviación de medicamento solicitado"."identity"."identity"
        into "new identity"
        ;
        new."identity" := "new identity";
      end if;

      insert into "Desviación de medicamento solicitado"."journal"
        (    "identity") values
        ("new identity")
      returning "Desviación de medicamento solicitado"."journal"."entry" into "new entry"
      ;

      insert into "Desviación de medicamento solicitado"."active"
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
instead of insert on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Desviación de medicamento solicitado"."revocation" ("entry", "start timestamp")
      select       "Desviación de medicamento solicitado"."journal"."entry", "Desviación de medicamento solicitado"."journal"."timestamp"
      from         "Desviación de medicamento solicitado"."active"
      natural join "Desviación de medicamento solicitado"."identity"
      natural join "Desviación de medicamento solicitado"."journal"
      where        "Desviación de medicamento solicitado"."identity"."identity" = old."identity"
      ;

      delete from "Desviación de medicamento solicitado"."active"
      using       "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."journal"
      where       "Desviación de medicamento solicitado"."active"."entry" = "Desviación de medicamento solicitado"."journal"."entry"
      and         "Desviación de medicamento solicitado"."identity"."identity" = old."identity"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."update function"
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
        raise exception 'updates to % view must not set surrogate key value', 'Desviación de medicamento solicitado';
      end if;

      select "Desviación de medicamento solicitado"."active"."entry"
      into   "old entry"
      from   "Desviación de medicamento solicitado"."active" natural join "Desviación de medicamento solicitado"."identity"
      where  "Desviación de medicamento solicitado"."identity"."identity" = old."identity"
      ;

      delete from public."Desviación de medicamento solicitado"
      where       public."Desviación de medicamento solicitado"."identity" = old."identity"
      ;

      select "Desviación de medicamento solicitado"."identity"."identity"
      into   "new identity"
      from   "Desviación de medicamento solicitado"."identity"
      where  "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
      ;
      if not found then
        insert into "Desviación de medicamento solicitado"."identity"
          ("identity") values
          (default   )
        returning "Desviación de medicamento solicitado"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Desviación de medicamento solicitado"."journal"
        (    "identity") values
        ("new identity")
      returning "Desviación de medicamento solicitado"."journal"."entry"
      into "new entry"
      ;

      insert into "Desviación de medicamento solicitado"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Desviación de medicamento solicitado"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Desviación de medicamento solicitado"."revocation"."end timestamp"
      from        "Desviación de medicamento solicitado"."revocation"
      where       "Desviación de medicamento solicitado"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* "tipo de desviación" */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."insert tipo de desviación function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if new."tipo de desviación version" is not null
      then
        raise exception 'insertions into % view must not specify % version', 'Desviación de medicamento solicitado', 'tipo de desviación';
      end if;

      if new."tipo de desviación -> identity" is not null then
        insert into "Desviación de medicamento solicitado"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de medicamento solicitado"."active"."entry", "Tipo de desviación"."active"."entry"
        from        "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."active",
                    "Tipo de desviación"."identity" natural join "Tipo de desviación"."active"
        where       "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
      and         "Tipo de desviación"."identity"."identity" = new."tipo de desviación -> identity"
        ;
        if not found then
          raise exception 'no active % row matches insert into % table % reference', 'Tipo de desviación', 'Desviación de medicamento solicitado', 'tipo de desviación';
        end if;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert tipo de desviación"
instead of insert on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."insert tipo de desviación function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."update tipo de desviación function"
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
        raise exception 'updates to % view must not set % version to non-null values', 'Desviación de medicamento solicitado', 'tipo de desviación';

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
        insert into "Desviación de medicamento solicitado"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de medicamento solicitado"."active"."entry", "Tipo de desviación"."active"."entry"
        from        "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."active",
                    "Tipo de desviación"."identity" natural join "Tipo de desviación"."active"
        where       "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
        and         "Tipo de desviación"."identity"."identity" = new."tipo de desviación -> identity"
        ;
        if not found then
          raise exception 'no active % row matches update to % table % reference', 'Tipo de desviación', 'Desviación de medicamento solicitado', 'tipo de desviación';
        end if;

      -- If the reference was unchanged in this update, and a reference actually existed (it was not null), then the new referrer version should refer to the same referred version as the old version.  This works just like regular attributes: the proxy pointer is copied in the new version if it exists.
      elsif
        old."tipo de desviación version" is not null and new."tipo de desviación version" is not null
        and old."tipo de desviación version" = new."tipo de desviación version"
        and new."tipo de desviación -> identity" is not null
        and old."tipo de desviación -> identity" = new."tipo de desviación -> identity"
      then
        insert into "Desviación de medicamento solicitado"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de medicamento solicitado"."active"."entry", new."tipo de desviación version"
        from        "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."active"
        where       "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
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
instead of update on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."update tipo de desviación function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* "Requested_medication" */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."insert Requested_medication function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if new."Requested_medication version" is not null
      then
        raise exception 'insertions into % view must not specify % version', 'Desviación de medicamento solicitado', 'Requested_medication';
      end if;

      if new."Requested_medication -> identity" is not null then
        insert into "Desviación de medicamento solicitado"."Requested_medication reference" ("entry", "Requested_medication reference")
        select      "Desviación de medicamento solicitado"."active"."entry", "Requested_medication"."active"."entry"
        from        "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."active",
                    "Requested_medication"."identity" natural join "Requested_medication"."active"
        where       "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
      and         "Requested_medication"."identity"."identity" = new."Requested_medication -> identity"
        ;
        if not found then
          raise exception 'no active % row matches insert into % table % reference', 'Requested_medication', 'Desviación de medicamento solicitado', 'Requested_medication';
        end if;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert Requested_medication"
instead of insert on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."insert Requested_medication function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."update Requested_medication function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if
        new."Requested_medication version" is not null
        and (
          not (old."Requested_medication version" is not null)
          or old."Requested_medication version" <> new."Requested_medication version"
        )
      then
        raise exception 'updates to % view must not set % version to non-null values', 'Desviación de medicamento solicitado', 'Requested_medication';

      elsif (
        -- If the referred identity did not change, and the referred version was set to null, the user requested updating the reference to the currently active version of the same row (“same” by identity).
        old."Requested_medication version" is not null
        and not (new."Requested_medication version" is not null)
        and new."Requested_medication -> identity" is not null and old."Requested_medication -> identity" = new."Requested_medication -> identity"

        -- If the referred version did not change, but the referred identity did, the user requested making the reference point to the currently active version of another row (“another” by identity).
      ) or (new."Requested_medication -> identity" is not null
        and (
          not (old."Requested_medication -> identity" is not null) or old."Requested_medication -> identity" <> new."Requested_medication -> identity"
        )
      ) then
        -- In either case, find the currently active version of the requested row and establish the reference.
        insert into "Desviación de medicamento solicitado"."Requested_medication reference" ("entry", "Requested_medication reference")
        select      "Desviación de medicamento solicitado"."active"."entry", "Requested_medication"."active"."entry"
        from        "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."active",
                    "Requested_medication"."identity" natural join "Requested_medication"."active"
        where       "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
        and         "Requested_medication"."identity"."identity" = new."Requested_medication -> identity"
        ;
        if not found then
          raise exception 'no active % row matches update to % table % reference', 'Requested_medication', 'Desviación de medicamento solicitado', 'Requested_medication';
        end if;

      -- If the reference was unchanged in this update, and a reference actually existed (it was not null), then the new referrer version should refer to the same referred version as the old version.  This works just like regular attributes: the proxy pointer is copied in the new version if it exists.
      elsif
        old."Requested_medication version" is not null and new."Requested_medication version" is not null
        and old."Requested_medication version" = new."Requested_medication version"
        and new."Requested_medication -> identity" is not null
        and old."Requested_medication -> identity" = new."Requested_medication -> identity"
      then
        insert into "Desviación de medicamento solicitado"."Requested_medication reference" ("entry", "Requested_medication reference")
        select      "Desviación de medicamento solicitado"."active"."entry", new."Requested_medication version"
        from        "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."active"
        where       "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
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
create trigger "10 update Requested_medication"
instead of update on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."update Requested_medication function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* "precio unitario máximo aprobado" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."insert or update precio unitario máximo aprobado function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    declare
      "new precio unitario máximo aprobado state" bigint;
    begin
      if
        new."precio unitario máximo aprobado" is not null
      then
        if
          tg_op = 'INSERT'
          or not (old."precio unitario máximo aprobado" is not null and old."precio unitario máximo aprobado" = new."precio unitario máximo aprobado")
        then
          insert into "Desviación de medicamento solicitado"."precio unitario máximo aprobado state"
            (    "precio unitario máximo aprobado") values
            (new."precio unitario máximo aprobado")
          returning   "Desviación de medicamento solicitado"."precio unitario máximo aprobado state"."precio unitario máximo aprobado state"
          into        "new precio unitario máximo aprobado state"
          ;
        else
          select     "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy"."precio unitario máximo aprobado state"
          into       "new precio unitario máximo aprobado state"
          from       "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."active" natural join "Desviación de medicamento solicitado"."journal"
          inner join "Desviación de medicamento solicitado"."succession" on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."succession"."successor")
          inner join "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy" on ("Desviación de medicamento solicitado"."succession"."entry" = "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy"."entry")
          where      "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
          ;
        end if;

        insert into  "Desviación de medicamento solicitado"."precio unitario máximo aprobado proxy" ("entry", "precio unitario máximo aprobado state")
        select       "Desviación de medicamento solicitado"."active"."entry", "new precio unitario máximo aprobado state"
        from         "Desviación de medicamento solicitado"."identity" inner join "Desviación de medicamento solicitado"."active" using ("identity")
        where        "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update precio unitario máximo aprobado"
instead of insert or update on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."insert or update precio unitario máximo aprobado function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* "ignorada" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de medicamento solicitado"."insert or update ignorada function"
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
          insert into "Desviación de medicamento solicitado"."ignorada state"
            (    "ignorada") values
            (new."ignorada")
          returning   "Desviación de medicamento solicitado"."ignorada state"."ignorada state"
          into        "new ignorada state"
          ;
        else
          select     "Desviación de medicamento solicitado"."ignorada proxy"."ignorada state"
          into       "new ignorada state"
          from       "Desviación de medicamento solicitado"."identity" natural join "Desviación de medicamento solicitado"."active" natural join "Desviación de medicamento solicitado"."journal"
          inner join "Desviación de medicamento solicitado"."succession" on ("Desviación de medicamento solicitado"."journal"."entry" = "Desviación de medicamento solicitado"."succession"."successor")
          inner join "Desviación de medicamento solicitado"."ignorada proxy" on ("Desviación de medicamento solicitado"."succession"."entry" = "Desviación de medicamento solicitado"."ignorada proxy"."entry")
          where      "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
          ;
        end if;

        insert into  "Desviación de medicamento solicitado"."ignorada proxy" ("entry", "ignorada state")
        select       "Desviación de medicamento solicitado"."active"."entry", "new ignorada state"
        from         "Desviación de medicamento solicitado"."identity" inner join "Desviación de medicamento solicitado"."active" using ("identity")
        where        "Desviación de medicamento solicitado"."identity"."identity" = new."identity"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update ignorada"
instead of insert or update on public."Desviación de medicamento solicitado"
for each row execute procedure "Desviación de medicamento solicitado"."insert or update ignorada function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Reference triggers */
/*}}}*//*}}}*//*}}}*//*}}}*/
