/*{{{*//*{{{*//* "Desviación de solicitud" schema */
/*}}}*/
/*{{{*/create schema "Desviación de solicitud";
/*}}}*/
/*{{{*//*{{{*//* Row versioning backend */
/*}}}*/
/*{{{*//*{{{*//* Row identification */
/*}}}*/
create table "Desviación de solicitud"."identity"
  ( "identity" bigserial not null primary key
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version journal */
/*}}}*/
create table "Desviación de solicitud"."journal"
  ( "entry"     bigserial                not null primary key
  , "identity"  bigint                   not null references "Desviación de solicitud"."identity"
  , "timestamp" timestamp with time zone not null default now()

  , unique ("entry", "timestamp")
  , unique ("entry", "identity" )
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version revocation */
/*}}}*/
create table "Desviación de solicitud"."revocation"
  ( "entry"           bigint                   not null primary key references "Desviación de solicitud"."journal"
  , "start timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity
  , "end timestamp"   timestamp with time zone not null default now()

  , check ("start timestamp" <= "end timestamp")
  , unique ("entry", "end timestamp")
  , foreign key ("entry", "start timestamp") references "Desviación de solicitud"."journal" ("entry", "timestamp")
  )
;/*}}}*/
/*{{{*//*{{{*//* Row version succession */
/*}}}*/
create table "Desviación de solicitud"."succession"
  ( "entry"     bigint                   not null primary key references "Desviación de solicitud"."revocation"
  , "successor" bigint                   not null unique      references "Desviación de solicitud"."journal"
  , "timestamp" timestamp with time zone not null -- redundant but required for time-efficient integrity

  -- succession timestamp equals successor journal entry timestamp
  , unique      ("successor", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("successor", "timestamp") references "Desviación de solicitud"."journal" ("entry", "timestamp")

  -- revocation end timestamp equals successor journal entry creation timestamp
  , unique      ("entry", "timestamp") -- implicit index may make foreign key checks more efficient
  , foreign key ("entry", "timestamp") references "Desviación de solicitud"."revocation" ("entry", "end timestamp")

  )
;/*}}}*/
/*{{{*//*{{{*//* Active row version tracking */
/*}}}*/
create table "Desviación de solicitud"."active"
  ( "identity" bigint not null primary key references "Desviación de solicitud"."identity"
  , "entry"    bigint not null unique      references "Desviación de solicitud"."journal"

  , unique      ("identity", "entry") -- implicit index may make foreign key checks more efficient
  , foreign key ("identity", "entry") references "Desviación de solicitud"."journal" ("identity", "entry")
  )
;/*}}}*//*}}}*/
/*{{{*//*{{{*//* Attributes */
/*}}}*/
/*{{{*//*{{{*//* "tipo de desviación" */
/*}}}*/
/*{{{*/create table "Desviación de solicitud"."tipo de desviación reference"
  ( "entry" bigint not null primary key references "Desviación de solicitud"."journal"
  , "tipo de desviación reference" bigint not null references "Tipo de desviación"."journal" ("entry") deferrable initially deferred
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "Request" */
/*}}}*/
/*{{{*/create table "Desviación de solicitud"."Request reference"
  ( "entry" bigint not null primary key references "Desviación de solicitud"."journal"
  , "Request reference" bigint not null references "Request"."journal" ("entry") deferrable initially deferred
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "monto total máximo aprobado" */
/*}}}*/
/*{{{*/create table "Desviación de solicitud"."monto total máximo aprobado state"
  ( "monto total máximo aprobado state" bigserial not null primary key
  , "monto total máximo aprobado" money not null
  )
;
/*}}}*/
/*{{{*/create table "Desviación de solicitud"."monto total máximo aprobado proxy"
  ( "entry" bigint not null primary key references "Desviación de solicitud"."journal"
  , "monto total máximo aprobado state" bigint not null references "Desviación de solicitud"."monto total máximo aprobado state"
  )
;
/*}}}*//*}}}*/
/*{{{*//*{{{*//* "ignorada" */
/*}}}*/
/*{{{*/create table "Desviación de solicitud"."ignorada state"
  ( "ignorada state" bigserial not null primary key
  , "ignorada" bool not null
  )
;
/*}}}*/
/*{{{*/create table "Desviación de solicitud"."ignorada proxy"
  ( "entry" bigint not null primary key references "Desviación de solicitud"."journal"
  , "ignorada state" bigint not null references "Desviación de solicitud"."ignorada state"
  )
;
/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Frontend */
/*}}}*/
/*{{{*//*{{{*//* Version view */
/*}}}*/
create view "Desviación de solicitud"."version" as
  select
    "Desviación de solicitud"."journal"."entry",
    "Desviación de solicitud"."journal"."timestamp" as "journal timestamp",
    "Desviación de solicitud"."revocation"."end timestamp",
    "Desviación de solicitud"."succession"."successor",
    "Desviación de solicitud"."identity"."identity",
    "Desviación de solicitud"."tipo de desviación reference"."tipo de desviación reference" as "tipo de desviación version",
    "tipo de desviación identity"."identity" as "tipo de desviación -> identity"
,
    "Desviación de solicitud"."Request reference"."Request reference" as "Request version",
    "Request identity"."identity" as "Request -> identity"
,
    "Desviación de solicitud"."monto total máximo aprobado state"."monto total máximo aprobado",
    "Desviación de solicitud"."ignorada state"."ignorada"
  from "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."journal"
  left outer join "Desviación de solicitud"."revocation" on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."revocation"."entry")
  left outer join "Desviación de solicitud"."succession" on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."succession"."entry")
  left outer join "Desviación de solicitud"."tipo de desviación reference"
    on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."tipo de desviación reference"."entry")
  left outer join "Tipo de desviación"."journal" as "tipo de desviación journal"
    on ("Desviación de solicitud"."tipo de desviación reference"."tipo de desviación reference" = "tipo de desviación journal"."entry")
  left outer join "Tipo de desviación"."identity" as "tipo de desviación identity"
    on ("tipo de desviación journal"."identity" = "tipo de desviación identity"."identity")

  left outer join "Desviación de solicitud"."Request reference"
    on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."Request reference"."entry")
  left outer join "Request"."journal" as "Request journal"
    on ("Desviación de solicitud"."Request reference"."Request reference" = "Request journal"."entry")
  left outer join "Request"."identity" as "Request identity"
    on ("Request journal"."identity" = "Request identity"."identity")

  left outer join "Desviación de solicitud"."monto total máximo aprobado proxy"
    on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."monto total máximo aprobado proxy"."entry")
  left outer join "Desviación de solicitud"."monto total máximo aprobado state"
    using ("monto total máximo aprobado state")

  left outer join "Desviación de solicitud"."ignorada proxy"
    on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."ignorada proxy"."entry")
  left outer join "Desviación de solicitud"."ignorada state"
    using ("ignorada state")

;/*}}}*/
/*{{{*//*{{{*//* Transactional view */
/*}}}*/
/*{{{*/create view public."Desviación de solicitud" as
  select
    "Desviación de solicitud"."identity"."identity",
    "Desviación de solicitud"."tipo de desviación reference"."tipo de desviación reference" as "tipo de desviación version",
    "tipo de desviación identity"."identity" as "tipo de desviación -> identity"
,
    "Desviación de solicitud"."Request reference"."Request reference" as "Request version",
    "Request identity"."identity" as "Request -> identity"
,
    "Desviación de solicitud"."monto total máximo aprobado state"."monto total máximo aprobado",
    "Desviación de solicitud"."ignorada state"."ignorada"
  from "Desviación de solicitud"."active" natural join "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."journal"
  left outer join "Desviación de solicitud"."tipo de desviación reference"
    on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."tipo de desviación reference"."entry")
  left outer join "Tipo de desviación"."journal" as "tipo de desviación journal"
    on ("Desviación de solicitud"."tipo de desviación reference"."tipo de desviación reference" = "tipo de desviación journal"."entry")
  left outer join "Tipo de desviación"."identity" as "tipo de desviación identity"
    on ("tipo de desviación journal"."identity" = "tipo de desviación identity"."identity")

  left outer join "Desviación de solicitud"."Request reference"
    on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."Request reference"."entry")
  left outer join "Request"."journal" as "Request journal"
    on ("Desviación de solicitud"."Request reference"."Request reference" = "Request journal"."entry")
  left outer join "Request"."identity" as "Request identity"
    on ("Request journal"."identity" = "Request identity"."identity")

  left outer join "Desviación de solicitud"."monto total máximo aprobado proxy"
    on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."monto total máximo aprobado proxy"."entry")
  left outer join "Desviación de solicitud"."monto total máximo aprobado state"
    using ("monto total máximo aprobado state")

  left outer join "Desviación de solicitud"."ignorada proxy"
    on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."ignorada proxy"."entry")
  left outer join "Desviación de solicitud"."ignorada state"
    using ("ignorada state")

;
/*}}}*/
/*{{{*//*{{{*//* Row version tracking triggers */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."view insert"
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
        raise exception 'insertions into % view must not specify surrogate key value', 'Desviación de solicitud';
      end if;
      select     "Desviación de solicitud"."identity"."identity"
      into       "new identity"
      from       "Desviación de solicitud"."identity"
      where      "Desviación de solicitud"."identity"."identity" = new."identity"
      ;

      if not found then
        insert into "Desviación de solicitud"."identity"
          ("identity") values
          (default   )
        returning "Desviación de solicitud"."identity"."identity"
        into "new identity"
        ;
        new."identity" := "new identity";
      end if;

      insert into "Desviación de solicitud"."journal"
        (    "identity") values
        ("new identity")
      returning "Desviación de solicitud"."journal"."entry" into "new entry"
      ;

      insert into "Desviación de solicitud"."active"
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
instead of insert on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."view insert"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Delete from view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."delete function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      insert into  "Desviación de solicitud"."revocation" ("entry", "start timestamp")
      select       "Desviación de solicitud"."journal"."entry", "Desviación de solicitud"."journal"."timestamp"
      from         "Desviación de solicitud"."active"
      natural join "Desviación de solicitud"."identity"
      natural join "Desviación de solicitud"."journal"
      where        "Desviación de solicitud"."identity"."identity" = old."identity"
      ;

      delete from "Desviación de solicitud"."active"
      using       "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."journal"
      where       "Desviación de solicitud"."active"."entry" = "Desviación de solicitud"."journal"."entry"
      and         "Desviación de solicitud"."identity"."identity" = old."identity"
      ;

      return old;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 delete"
instead of delete on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."delete function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."update function"
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
        raise exception 'updates to % view must not set surrogate key value', 'Desviación de solicitud';
      end if;

      select "Desviación de solicitud"."active"."entry"
      into   "old entry"
      from   "Desviación de solicitud"."active" natural join "Desviación de solicitud"."identity"
      where  "Desviación de solicitud"."identity"."identity" = old."identity"
      ;

      delete from public."Desviación de solicitud"
      where       public."Desviación de solicitud"."identity" = old."identity"
      ;

      select "Desviación de solicitud"."identity"."identity"
      into   "new identity"
      from   "Desviación de solicitud"."identity"
      where  "Desviación de solicitud"."identity"."identity" = new."identity"
      ;
      if not found then
        insert into "Desviación de solicitud"."identity"
          ("identity") values
          (default   )
        returning "Desviación de solicitud"."identity"."identity"
        into "new identity"
        ;
      end if;

      insert into "Desviación de solicitud"."journal"
        (    "identity") values
        ("new identity")
      returning "Desviación de solicitud"."journal"."entry"
      into "new entry"
      ;

      insert into "Desviación de solicitud"."active"
        (    "identity",     "entry") values
        ("new identity", "new entry")
      ;

      insert into "Desviación de solicitud"."succession" ("entry", "successor", "timestamp")
      select      "old entry", "new entry", "Desviación de solicitud"."revocation"."end timestamp"
      from        "Desviación de solicitud"."revocation"
      where       "Desviación de solicitud"."revocation"."entry" = "old entry"
      ;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "00 update"
instead of update on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."update function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* Column triggers */
/*}}}*/
/*{{{*//*{{{*//* "tipo de desviación" */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."insert tipo de desviación function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if new."tipo de desviación version" is not null
      then
        raise exception 'insertions into % view must not specify % version', 'Desviación de solicitud', 'tipo de desviación';
      end if;

      if new."tipo de desviación -> identity" is not null then
        insert into "Desviación de solicitud"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de solicitud"."active"."entry", "Tipo de desviación"."active"."entry"
        from        "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."active",
                    "Tipo de desviación"."identity" natural join "Tipo de desviación"."active"
        where       "Desviación de solicitud"."identity"."identity" = new."identity"
      and         "Tipo de desviación"."identity"."identity" = new."tipo de desviación -> identity"
        ;
        if not found then
          raise exception 'no active % row matches insert into % table % reference', 'Tipo de desviación', 'Desviación de solicitud', 'tipo de desviación';
        end if;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert tipo de desviación"
instead of insert on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."insert tipo de desviación function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."update tipo de desviación function"
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
        raise exception 'updates to % view must not set % version to non-null values', 'Desviación de solicitud', 'tipo de desviación';

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
        insert into "Desviación de solicitud"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de solicitud"."active"."entry", "Tipo de desviación"."active"."entry"
        from        "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."active",
                    "Tipo de desviación"."identity" natural join "Tipo de desviación"."active"
        where       "Desviación de solicitud"."identity"."identity" = new."identity"
        and         "Tipo de desviación"."identity"."identity" = new."tipo de desviación -> identity"
        ;
        if not found then
          raise exception 'no active % row matches update to % table % reference', 'Tipo de desviación', 'Desviación de solicitud', 'tipo de desviación';
        end if;

      -- If the reference was unchanged in this update, and a reference actually existed (it was not null), then the new referrer version should refer to the same referred version as the old version.  This works just like regular attributes: the proxy pointer is copied in the new version if it exists.
      elsif
        old."tipo de desviación version" is not null and new."tipo de desviación version" is not null
        and old."tipo de desviación version" = new."tipo de desviación version"
        and new."tipo de desviación -> identity" is not null
        and old."tipo de desviación -> identity" = new."tipo de desviación -> identity"
      then
        insert into "Desviación de solicitud"."tipo de desviación reference" ("entry", "tipo de desviación reference")
        select      "Desviación de solicitud"."active"."entry", new."tipo de desviación version"
        from        "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."active"
        where       "Desviación de solicitud"."identity"."identity" = new."identity"
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
instead of update on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."update tipo de desviación function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* "Request" */
/*}}}*/
/*{{{*//*{{{*//* Insert into view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."insert Request function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if new."Request version" is not null
      then
        raise exception 'insertions into % view must not specify % version', 'Desviación de solicitud', 'Request';
      end if;

      if new."Request -> identity" is not null then
        insert into "Desviación de solicitud"."Request reference" ("entry", "Request reference")
        select      "Desviación de solicitud"."active"."entry", "Request"."active"."entry"
        from        "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."active",
                    "Request"."identity" natural join "Request"."active"
        where       "Desviación de solicitud"."identity"."identity" = new."identity"
      and         "Request"."identity"."identity" = new."Request -> identity"
        ;
        if not found then
          raise exception 'no active % row matches insert into % table % reference', 'Request', 'Desviación de solicitud', 'Request';
        end if;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert Request"
instead of insert on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."insert Request function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* Update view */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."update Request function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    begin
      if
        new."Request version" is not null
        and (
          not (old."Request version" is not null)
          or old."Request version" <> new."Request version"
        )
      then
        raise exception 'updates to % view must not set % version to non-null values', 'Desviación de solicitud', 'Request';

      elsif (
        -- If the referred identity did not change, and the referred version was set to null, the user requested updating the reference to the currently active version of the same row (“same” by identity).
        old."Request version" is not null
        and not (new."Request version" is not null)
        and new."Request -> identity" is not null and old."Request -> identity" = new."Request -> identity"

        -- If the referred version did not change, but the referred identity did, the user requested making the reference point to the currently active version of another row (“another” by identity).
      ) or (new."Request -> identity" is not null
        and (
          not (old."Request -> identity" is not null) or old."Request -> identity" <> new."Request -> identity"
        )
      ) then
        -- In either case, find the currently active version of the requested row and establish the reference.
        insert into "Desviación de solicitud"."Request reference" ("entry", "Request reference")
        select      "Desviación de solicitud"."active"."entry", "Request"."active"."entry"
        from        "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."active",
                    "Request"."identity" natural join "Request"."active"
        where       "Desviación de solicitud"."identity"."identity" = new."identity"
        and         "Request"."identity"."identity" = new."Request -> identity"
        ;
        if not found then
          raise exception 'no active % row matches update to % table % reference', 'Request', 'Desviación de solicitud', 'Request';
        end if;

      -- If the reference was unchanged in this update, and a reference actually existed (it was not null), then the new referrer version should refer to the same referred version as the old version.  This works just like regular attributes: the proxy pointer is copied in the new version if it exists.
      elsif
        old."Request version" is not null and new."Request version" is not null
        and old."Request version" = new."Request version"
        and new."Request -> identity" is not null
        and old."Request -> identity" = new."Request -> identity"
      then
        insert into "Desviación de solicitud"."Request reference" ("entry", "Request reference")
        select      "Desviación de solicitud"."active"."entry", new."Request version"
        from        "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."active"
        where       "Desviación de solicitud"."identity"."identity" = new."identity"
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
create trigger "10 update Request"
instead of update on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."update Request function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//*{{{*//* "monto total máximo aprobado" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."insert or update monto total máximo aprobado function"
  ()
returns trigger
  language 'plpgsql'
  security definer
as
  $body$
    declare
      "new monto total máximo aprobado state" bigint;
    begin
      if
        new."monto total máximo aprobado" is not null
      then
        if
          tg_op = 'INSERT'
          or not (old."monto total máximo aprobado" is not null and old."monto total máximo aprobado" = new."monto total máximo aprobado")
        then
          insert into "Desviación de solicitud"."monto total máximo aprobado state"
            (    "monto total máximo aprobado") values
            (new."monto total máximo aprobado")
          returning   "Desviación de solicitud"."monto total máximo aprobado state"."monto total máximo aprobado state"
          into        "new monto total máximo aprobado state"
          ;
        else
          select     "Desviación de solicitud"."monto total máximo aprobado proxy"."monto total máximo aprobado state"
          into       "new monto total máximo aprobado state"
          from       "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."active" natural join "Desviación de solicitud"."journal"
          inner join "Desviación de solicitud"."succession" on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."succession"."successor")
          inner join "Desviación de solicitud"."monto total máximo aprobado proxy" on ("Desviación de solicitud"."succession"."entry" = "Desviación de solicitud"."monto total máximo aprobado proxy"."entry")
          where      "Desviación de solicitud"."identity"."identity" = new."identity"
          ;
        end if;

        insert into  "Desviación de solicitud"."monto total máximo aprobado proxy" ("entry", "monto total máximo aprobado state")
        select       "Desviación de solicitud"."active"."entry", "new monto total máximo aprobado state"
        from         "Desviación de solicitud"."identity" inner join "Desviación de solicitud"."active" using ("identity")
        where        "Desviación de solicitud"."identity"."identity" = new."identity"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update monto total máximo aprobado"
instead of insert or update on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."insert or update monto total máximo aprobado function"();/*}}}*//*}}}*/
/*{{{*//*{{{*//* "ignorada" */
/*}}}*/
/*{{{*//*{{{*//* Function */
/*}}}*/
create function "Desviación de solicitud"."insert or update ignorada function"
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
          insert into "Desviación de solicitud"."ignorada state"
            (    "ignorada") values
            (new."ignorada")
          returning   "Desviación de solicitud"."ignorada state"."ignorada state"
          into        "new ignorada state"
          ;
        else
          select     "Desviación de solicitud"."ignorada proxy"."ignorada state"
          into       "new ignorada state"
          from       "Desviación de solicitud"."identity" natural join "Desviación de solicitud"."active" natural join "Desviación de solicitud"."journal"
          inner join "Desviación de solicitud"."succession" on ("Desviación de solicitud"."journal"."entry" = "Desviación de solicitud"."succession"."successor")
          inner join "Desviación de solicitud"."ignorada proxy" on ("Desviación de solicitud"."succession"."entry" = "Desviación de solicitud"."ignorada proxy"."entry")
          where      "Desviación de solicitud"."identity"."identity" = new."identity"
          ;
        end if;

        insert into  "Desviación de solicitud"."ignorada proxy" ("entry", "ignorada state")
        select       "Desviación de solicitud"."active"."entry", "new ignorada state"
        from         "Desviación de solicitud"."identity" inner join "Desviación de solicitud"."active" using ("identity")
        where        "Desviación de solicitud"."identity"."identity" = new."identity"
        ;
      end if;

      return new;
    end;
  $body$
;/*}}}*/
/*{{{*//*{{{*//* Trigger */
/*}}}*/
create trigger "10 insert or update ignorada"
instead of insert or update on public."Desviación de solicitud"
for each row execute procedure "Desviación de solicitud"."insert or update ignorada function"();/*}}}*//*}}}*//*}}}*/
/*{{{*//* Reference triggers */
/*}}}*//*}}}*//*}}}*//*}}}*/
