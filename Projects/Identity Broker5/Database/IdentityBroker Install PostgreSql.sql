-- Table: public."StoredValueCollection"

-- DROP TABLE public."StoredValueCollection";

CREATE TABLE public."StoredValueCollection"
(
    "StoredValueCollectionId" uuid NOT NULL,
    "Values" jsonb NOT NULL,
    CONSTRAINT "StoredValueCollection_pkey" PRIMARY KEY ("StoredValueCollectionId")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."StoredValueCollection"
    OWNER to postgres;


-- Table: public."Entity"

-- DROP TABLE public."Entity";

CREATE SEQUENCE public."Entity_EntityKey_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public."Entity_EntityKey_seq"
    OWNER TO postgres;

CREATE TABLE public."Entity"
(
    "EntityKey" bigint NOT NULL DEFAULT nextval('"Entity_EntityKey_seq"'::regclass),
    "EntityId" uuid NOT NULL,
    "PartitionId" uuid NOT NULL,
    "CreatedTime" timestamp without time zone,
    "ModifiedTime" timestamp without time zone,
    "ContainerId" uuid,
    "DN" character varying(400) COLLATE pg_catalog."default",
    "ObjectClass" character varying(50) COLLATE pg_catalog."default",
    "EntityValues" jsonb NOT NULL,
    "EntityValueTypes" jsonb NOT NULL,
    CONSTRAINT "Entity_pkey" PRIMARY KEY ("EntityKey"),
    CONSTRAINT "Entity_EntityId_PartitionId_key" UNIQUE ("EntityId", "PartitionId")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."Entity"
    OWNER to postgres;

-- Table: public."Origin"

-- DROP TABLE public."Origin";

CREATE SEQUENCE public."Origin_OriginKey_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public."Origin_OriginKey_seq"
    OWNER TO postgres;

CREATE TABLE public."Origin"
(
    "OriginKey" bigint NOT NULL DEFAULT nextval('"Origin_OriginKey_seq"'::regclass),
    "EntityId" uuid NOT NULL,
    "PartitionId" uuid NOT NULL,
    "Field" text COLLATE pg_catalog."default" NOT NULL,
    "SourceEntityId" uuid,
    "SourcePartitionId" uuid,
    "SourceField" text COLLATE pg_catalog."default",
    CONSTRAINT "Origin_pkey" PRIMARY KEY ("OriginKey")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."Origin"
    OWNER to postgres;

-- Table: public."Container"

-- DROP TABLE public."Container";

CREATE TABLE public."Container"
(
    "ContainerId" uuid NOT NULL,
    "PartitionId" uuid NOT NULL,
    "CreatedTime" timestamp without time zone,
    "ModifiedTime" timestamp without time zone,
    "DN" character varying(400) COLLATE pg_catalog."default" NOT NULL,
    "Required" boolean NOT NULL,
    "Level" int NOT NULL,
    CONSTRAINT "Container_pkey" PRIMARY KEY ("ContainerId"),
    CONSTRAINT "container_dn_unique" UNIQUE ("DN")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."Container"
    OWNER to postgres;

-- Table: public."Changes"

-- DROP TABLE public."Changes";

CREATE SEQUENCE public."Changes_ChangesKey_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public."Changes_ChangesKey_seq"
    OWNER TO postgres;

CREATE TABLE public."Changes"
(
    "ChangesKey" bigint NOT NULL DEFAULT nextval('"Changes_ChangesKey_seq"'::regclass),
    "EntityId" uuid NOT NULL,
    "AdapterId" uuid NOT NULL,
    "ChangeTime" timestamp without time zone NOT NULL,
    CONSTRAINT "Changes_pkey" PRIMARY KEY ("ChangesKey")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."Changes"
    OWNER to postgres;

-- Table: public."ChangeLog"

-- DROP TABLE public."ChangeLog";

CREATE SEQUENCE public."ChangeLog_ChangeLogKey_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public."ChangeLog_ChangeLogKey_seq"
    OWNER TO postgres;

CREATE TABLE public."ChangeLog"
(
    "ChangeLogKey" bigint NOT NULL DEFAULT nextval('"ChangeLog_ChangeLogKey_seq"'::regclass),
    "AdapterId" uuid NOT NULL,
    "ChangeType" smallint NOT NULL,
    "ChangeTimestamp" timestamp without time zone NOT NULL,
    "TargetDN" character varying(400) COLLATE pg_catalog."default",
    "NewDN" character varying(400) COLLATE pg_catalog."default",
    "Changes" character varying,
    CONSTRAINT "ChangeLog_pkey" PRIMARY KEY ("ChangeLogKey")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public."ChangeLog"
    OWNER to postgres;

-- Type: OriginKey

-- DROP TYPE public."OriginKey";

CREATE TYPE public."OriginKey" AS
(
    "EntityId" uuid,
    "PartitionId" uuid,
    "Field" text
);

ALTER TYPE public."OriginKey"
    OWNER TO postgres;

-- Type: OriginEntityKey

-- DROP TYPE public."OriginEntityKey";

CREATE TYPE public."OriginEntityKey" AS
(
    "EntityId" uuid,
    "PartitionId" uuid
);

ALTER TYPE public."OriginEntityKey"
    OWNER TO postgres;

-- Type: Changes_row

-- DROP TYPE public."Changes_row";

CREATE TYPE public."Changes_row" AS
(
    "ChangesKey" bigint,
    "EntityId" uuid,
    "AdapterId" uuid,
    "ChangeTime" timestamp without time zone
);

ALTER TYPE public."Changes_row"
    OWNER TO postgres;

-- Type: Origin_row

-- DROP TYPE public."Origin_row";

CREATE TYPE public."Origin_row" AS
(
    "OriginKey" bigint,
    "EntityId" uuid,
    "PartitionId" uuid,
    "Field" text COLLATE pg_catalog."default",
    "SourceEntityId" uuid,
    "SourcePartitionId" uuid,
    "SourceField" text COLLATE pg_catalog."default"
);

ALTER TYPE public."Origin_row"
    OWNER TO postgres;

-- Type: Entity_row

-- DROP TYPE public."Entity_row";

CREATE TYPE public."Entity_row" AS
(
    "EntityKey" bigint,
    "EntityId" uuid,
    "PartitionId" uuid,
    "CreatedTime" timestamp without time zone,
    "ModifiedTime" timestamp without time zone,
    "ContainerId" uuid,
    "DN" character varying(400) COLLATE pg_catalog."default",
    "ObjectClass" character varying(50) COLLATE pg_catalog."default",
    "EntityValues" jsonb,
    "EntityValueTypes" jsonb
);

ALTER TYPE public."Entity_row"
    OWNER TO postgres;

-- FUNCTION: public.get_collection_by_collection_id(uuid)

-- DROP FUNCTION public.get_collection_by_collection_id(uuid);

CREATE OR REPLACE FUNCTION public.get_collection_by_collection_id(
    collection_id uuid)
    RETURNS SETOF "StoredValueCollection"
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "StoredValueCollection" WHERE "StoredValueCollectionId" = collection_id);
    END;

    
$BODY$;

-- FUNCTION: public.get_entity_count(uuid)

-- DROP FUNCTION public.get_entity_count(uuid);

CREATE OR REPLACE FUNCTION public.get_entity_count(
    partition_id uuid)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    
    BEGIN
        RETURN (SELECT COUNT(*) FROM "Entity" WHERE "PartitionId" = partition_id);
    END;
    
    
$BODY$;

ALTER FUNCTION public.get_entity_count(uuid)
    OWNER TO postgres;


-- FUNCTION: public.get_all_entities(uuid)

-- DROP FUNCTION public.get_all_entities(uuid);

CREATE OR REPLACE FUNCTION public.get_all_entities(
    partition_id uuid)
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id);
    END;

    
$BODY$;

ALTER FUNCTION public.get_all_entities(uuid)
    OWNER TO postgres;


-- FUNCTION: public.get_entity_by_entity_id_value(uuid, uuid)

-- DROP FUNCTION public.get_entity_by_entity_id_value(uuid, uuid);

CREATE OR REPLACE FUNCTION public.get_entity_by_entity_id_value(
    partition_id uuid,
    value uuid)
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id AND "EntityId" = value);
    END;

    
$BODY$;

ALTER FUNCTION public.get_entity_by_entity_id_value(uuid, uuid)
    OWNER TO postgres;


-- FUNCTION: public.get_entities_by_entity_id_values(uuid, uuid[])

-- DROP FUNCTION public.get_entities_by_entity_id_values(uuid, uuid[]);

CREATE OR REPLACE FUNCTION public.get_entities_by_entity_id_values(
    partition_id uuid,
    _values uuid[])
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id AND "EntityId" = ANY(_values));
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_by_entity_id_values(uuid, uuid[])
    OWNER TO postgres;


-- FUNCTION: public.get_entities_not_by_entity_id_values(uuid, uuid[])

-- DROP FUNCTION public.get_entities_not_by_entity_id_values(uuid, uuid[]);

CREATE OR REPLACE FUNCTION public.get_entities_not_by_entity_id_values(
    partition_id uuid,
    _values uuid[])
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        CREATE TEMP TABLE entity_select_not_by_entity_id_temp_table (entity_id uuid) ON COMMIT DELETE ROWS;
        INSERT INTO entity_select_not_by_entity_id_temp_table (entity_id) (SELECT unnest from unnest(_values));
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id AND "EntityId" NOT IN (SELECT entity_id FROM entity_select_not_by_entity_id_temp_table));
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_not_by_entity_id_values(uuid, uuid[])
    OWNER TO postgres;


-- FUNCTION: public.get_entity_by_dn_value(uuid, text)

-- DROP FUNCTION public.get_entity_by_dn_value(uuid, text);

CREATE OR REPLACE FUNCTION public.get_entity_by_dn_value(
    partition_id uuid,
    value text)
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id AND "DN" = value);
    END;

    
$BODY$;

ALTER FUNCTION public.get_entity_by_dn_value(uuid, text)
    OWNER TO postgres;


-- FUNCTION: public.get_entities_by_dn_values(uuid, text[])

-- DROP FUNCTION public.get_entities_by_dn_values(uuid, text[]);

CREATE OR REPLACE FUNCTION public.get_entities_by_dn_values(
    partition_id uuid,
    _values text[])
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id AND "DN" = ANY(_values));
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_by_dn_values(uuid, text[])
    OWNER TO postgres;


-- FUNCTION: public.get_entities_not_by_dn_values(uuid, text[])

-- DROP FUNCTION public.get_entities_not_by_dn_values(uuid, text[]);

CREATE OR REPLACE FUNCTION public.get_entities_not_by_dn_values(
    partition_id uuid,
    _values text[])
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id AND NOT("DN" = ANY(_values)));
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_not_by_dn_values(uuid, text[])
    OWNER TO postgres;

-- FUNCTION: public.get_entities_by_field_values(uuid, text, jsonb[])

-- DROP FUNCTION public.get_entities_by_field_values(uuid, text, jsonb[]);

CREATE OR REPLACE FUNCTION public.get_entities_by_field_values(
    partition_id uuid,
    field text,
    _values jsonb[])
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id AND "EntityValues"->field = ANY(_values));
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_by_field_values(uuid, text, jsonb[])
    OWNER TO postgres;

-- FUNCTION: public.get_entities_by_field_contains_any(uuid, text, jsonb[])

-- DROP FUNCTION public.get_entities_by_field_contains_any(uuid, text, jsonb[]);

CREATE OR REPLACE FUNCTION public.get_entities_by_field_contains_any(
    partition_id uuid,
    field text,
    _values jsonb[])
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id AND "EntityValues"->field @> ANY(_values));
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_by_field_contains_any(uuid, text, jsonb[])
    OWNER TO postgres;

-- FUNCTION: public.remove_entity_field_values(uuid, text[])

-- DROP FUNCTION public.remove_entity_field_values(uuid, text[]);

CREATE OR REPLACE FUNCTION public.remove_entity_field_values(
    partition_id uuid,
    fields text[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        UPDATE "Entity" 
        SET 
            "EntityValues" = remove_jsonb_values("EntityValues", fields),
            "EntityValueTypes" = remove_jsonb_values("EntityValueTypes", fields)
        WHERE "PartitionId" = partition_id;
    END;   

$BODY$;

ALTER FUNCTION public.remove_entity_field_values(uuid, text[])
    OWNER TO postgres;
    
-- FUNCTION: public.remove_jsonb_values(_json, text[])

-- DROP FUNCTION public.remove_jsonb_values(_json, text[]);

CREATE OR REPLACE FUNCTION public.remove_jsonb_values(
    _json jsonb,
    fields text[])
    RETURNS jsonb
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
    
    DECLARE
        modJson jsonb := _json;
        item text;
    BEGIN
        FOREACH item IN ARRAY fields LOOP
            modJson = modJson - item;
        END LOOP;
        RETURN modJson;        
    END;   

$BODY$;

ALTER FUNCTION public.remove_jsonb_values(jsonb, text[])
    OWNER TO postgres;

-- FUNCTION: public.get_entities_ordered_ascending(uuid, text)

-- DROP FUNCTION public.get_entities_ordered_ascending(uuid, text);

CREATE OR REPLACE FUNCTION public.get_entities_ordered_ascending(
    partition_id uuid,
    field text)
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id ORDER BY "EntityValues"->field ASC);
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_ordered_ascending(uuid, text)
    OWNER TO postgres;


-- FUNCTION: public.get_entities_ordered_ascending_multikey(uuid, text[])

-- DROP FUNCTION public.get_entities_ordered_ascending_multikey(uuid, text[]);

CREATE OR REPLACE FUNCTION public.get_entities_ordered_ascending_multikey(
    partition_id uuid,
    fields text[])
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY EXECUTE 'SELECT * FROM "Entity" WHERE "PartitionId" = $1 ORDER BY "EntityValues"->''' || array_to_string(fields, ''' ASC, "EntityValues"->''') || ''' ASC' USING partition_id;
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_ordered_ascending_multikey(uuid, text[])
    OWNER TO postgres;

-- FUNCTION: public.get_entities_ordered_descending(uuid, text)

-- DROP FUNCTION public.get_entities_ordered_descending(uuid, text);

CREATE OR REPLACE FUNCTION public.get_entities_ordered_descending(
    partition_id uuid,
    field text)
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Entity" WHERE "PartitionId" = partition_id ORDER BY "EntityValues"->field DESC);
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_ordered_descending(uuid, text)
    OWNER TO postgres;

-- FUNCTION: public.get_entities_ordered_descending_multikey(uuid, text[])

-- DROP FUNCTION public.get_entities_ordered_descending_multikey(uuid, text[]);

CREATE OR REPLACE FUNCTION public.get_entities_ordered_descending_multikey(
    partition_id uuid,
    fields text[])
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY EXECUTE 'SELECT * FROM "Entity" WHERE "PartitionId" = $1 ORDER BY "EntityValues"->''' || array_to_string(fields, ''' DESC, "EntityValues"->''') || ''' DESC' USING partition_id;
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_ordered_descending_multikey(uuid, text[])
    OWNER TO postgres;


-- FUNCTION: public.get_entities_ordered_ascending_metadata(uuid, text)

-- DROP FUNCTION public.get_entities_ordered_ascending_metadata(uuid, text);

CREATE OR REPLACE FUNCTION public.get_entities_ordered_ascending_metadata(
    partition_id uuid,
    field text)
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY EXECUTE 'SELECT * FROM "Entity" WHERE "PartitionId" = $1 ORDER BY ' || quote_ident(field) || ' ASC' USING partition_id;
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_ordered_ascending_metadata(uuid, text)
    OWNER TO postgres;


-- FUNCTION: public.get_entities_ordered_descending_metadata(uuid, text)

-- DROP FUNCTION public.get_entities_ordered_descending_metadata(uuid, text);

CREATE OR REPLACE FUNCTION public.get_entities_ordered_descending_metadata(
    partition_id uuid,
    field text)
    RETURNS SETOF "Entity" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY EXECUTE 'SELECT * FROM "Entity" WHERE "PartitionId" = $1 ORDER BY ' || quote_ident(field) || ' DESC' USING partition_id;
    END;

    
$BODY$;

ALTER FUNCTION public.get_entities_ordered_descending_metadata(uuid, text)
    OWNER TO postgres;


-- FUNCTION: public.get_container_count()

-- DROP FUNCTION public.get_container_count();

CREATE OR REPLACE FUNCTION public.get_container_count()
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    
    BEGIN
        RETURN (SELECT COUNT(*) FROM "Container");
    END;
    
    
$BODY$;

ALTER FUNCTION public.get_container_count()
    OWNER TO postgres;


-- FUNCTION: public.get_container_by_container_id_value(uuid)

-- DROP FUNCTION public.get_container_by_container_id_value(uuid);

CREATE OR REPLACE FUNCTION public.get_container_by_container_id_value(
    value uuid)
    RETURNS SETOF "Container" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Container" WHERE "ContainerId" = value);
    END;

    
$BODY$;

ALTER FUNCTION public.get_container_by_container_id_value(uuid)
    OWNER TO postgres;


-- FUNCTION: public.get_containers_by_container_id_values(uuid[])

-- DROP FUNCTION public.get_containers_by_container_id_values(uuid[]);

CREATE OR REPLACE FUNCTION public.get_containers_by_container_id_values(
    _values uuid[])
    RETURNS SETOF "Container" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Container" WHERE "ContainerId" = ANY(_values));
    END;

    
$BODY$;

ALTER FUNCTION public.get_containers_by_container_id_values(uuid[])
    OWNER TO postgres;


-- FUNCTION: public.get_containers_not_by_container_id_values(uuid[])

-- DROP FUNCTION public.get_containers_not_by_container_id_values(uuid[]);

CREATE OR REPLACE FUNCTION public.get_containers_not_by_container_id_values(
    _values uuid[])
    RETURNS SETOF "Container" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Container" WHERE NOT("ContainerId" = ANY(_values)));
    END;

    
$BODY$;

ALTER FUNCTION public.get_containers_not_by_container_id_values(uuid[])
    OWNER TO postgres;


-- FUNCTION: public.get_container_by_dn_value(text)

-- DROP FUNCTION public.get_container_by_dn_value(text);

CREATE OR REPLACE FUNCTION public.get_container_by_dn_value(
    value text)
    RETURNS SETOF "Container" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Container" WHERE "DN" = value);
    END;

    
$BODY$;

ALTER FUNCTION public.get_container_by_dn_value(text)
    OWNER TO postgres;


-- FUNCTION: public.get_containers_by_dn_values(text[])

-- DROP FUNCTION public.get_containers_by_dn_values(text[]);

CREATE OR REPLACE FUNCTION public.get_containers_by_dn_values(
    _values text[])
    RETURNS SETOF "Container" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Container" WHERE "DN" = ANY(_values));
    END;

    
$BODY$;

ALTER FUNCTION public.get_containers_by_dn_values(text[])
    OWNER TO postgres;


-- FUNCTION: public.get_containers_not_by_dn_values(text[])

-- DROP FUNCTION public.get_containers_not_by_dn_values(text[]);

CREATE OR REPLACE FUNCTION public.get_containers_not_by_dn_values(
    _values text[])
    RETURNS SETOF "Container" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Container" WHERE NOT("DN" = ANY(_values)));
    END;

    
$BODY$;

ALTER FUNCTION public.get_containers_not_by_dn_values(text[])
    OWNER TO postgres;


-- FUNCTION: public.get_containers_one_level(text, int)

-- DROP FUNCTION public.get_containers_one_level(text, int);

CREATE OR REPLACE FUNCTION public.get_containers_one_level(
    value text,
    level int)
    RETURNS SETOF "Container" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Container" WHERE ("DN" = value) OR ("DN" LIKE ('%,' || value) AND "Level" = (level + 1)));
    END;

    
$BODY$;

ALTER FUNCTION public.get_containers_one_level(text, int)
    OWNER TO postgres;


-- FUNCTION: public.get_containers_subtree(text, int)

-- DROP FUNCTION public.get_containers_subtree(text, int);

CREATE OR REPLACE FUNCTION public.get_containers_subtree(
    value text,
    level int)
    RETURNS SETOF "Container" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Container" WHERE ("DN" = value) OR ("DN" LIKE ('%,' || value)));
    END;

    
$BODY$;

ALTER FUNCTION public.get_containers_subtree(text, int)
    OWNER TO postgres;


-- FUNCTION: public.delete_unused_containers()

-- DROP FUNCTION public.delete_unused_containers();

CREATE OR REPLACE FUNCTION public.delete_unused_containers()
    RETURNS VOID 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE FROM "Container" AS o
        WHERE (
            SELECT COUNT(*)
            FROM "Container" AS i
            WHERE i."Level" = o."Level" + 1
            AND i."DN" LIKE ('%,' || o."DN")
        ) = 0
        AND (
            SELECT COUNT(*)
            FROM "Entity" as e
            WHERE e."DN" LIKE ('%,' || o."DN")
        ) = 0
        AND "Required" = false;
    END;

    
$BODY$;

ALTER FUNCTION public.delete_unused_containers()
    OWNER TO postgres;

-- FUNCTION: public.bulk_insert_changes("Changes_row"[])

-- DROP FUNCTION public.bulk_insert_changes("Changes_row"[]);

CREATE OR REPLACE FUNCTION public.bulk_insert_changes(
    to_insert "Changes_row"[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
         INSERT INTO "Changes" ("EntityId", "AdapterId", "ChangeTime")
         SELECT "EntityId", "AdapterId", "ChangeTime" FROM unnest(to_insert);
    END;   

$BODY$;

ALTER FUNCTION public.bulk_insert_changes("Changes_row"[])
    OWNER TO postgres;

-- FUNCTION: public.get_pending_changes_count(uuid, timestamp without time zone)

-- DROP FUNCTION public.get_pending_changes_count(uuid, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.get_pending_changes_count(
    adapter_id uuid,
    process_time timestamp without time zone)
    RETURNS bigint 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        RETURN (SELECT COUNT(*) FROM "Changes" WHERE "AdapterId" = adapter_id AND "ChangeTime" <= process_time);
    END;

    
$BODY$;

ALTER FUNCTION public.get_pending_changes_count(uuid, timestamp without time zone)
    OWNER TO postgres;


-- FUNCTION: public.get_future_change_times(uuid, timestamp without time zone)

-- DROP FUNCTION public.get_future_change_times(uuid, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.get_future_change_times(
    adapter_id uuid,
    process_time timestamp without time zone)
    RETURNS SETOF timestamp without time zone 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT "ChangeTime" FROM "Changes" WHERE "AdapterId" = adapter_id AND "ChangeTime" > process_time);
    END;

    
$BODY$;

ALTER FUNCTION public.get_future_change_times(uuid, timestamp without time zone)
    OWNER TO postgres;


-- FUNCTION: public.get_changes_to_process(uuid, timestamp without time zone, bigint)

-- DROP FUNCTION public.get_changes_to_process(uuid, timestamp without time zone, bigint);

CREATE OR REPLACE FUNCTION public.get_changes_to_process(
    adapter_id uuid,
    process_time timestamp without time zone,
    count bigint)
    RETURNS SETOF "Changes" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "Changes" WHERE "AdapterId" = adapter_id AND "ChangeTime" <= process_time ORDER BY "ChangesKey" ASC LIMIT count);
    END;

    
$BODY$;

ALTER FUNCTION public.get_changes_to_process(uuid, timestamp without time zone, bigint)
    OWNER TO postgres;


-- FUNCTION: public.get_changes_by_change_values("Changes_row"[])

-- DROP FUNCTION public.get_changes_by_change_values("Changes_row"[]);

CREATE OR REPLACE FUNCTION public.get_changes_by_change_values(
    changes "Changes_row"[])
    RETURNS SETOF "Changes" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN       
        RETURN QUERY (
            SELECT * 
            FROM "Changes" 
            WHERE ("EntityId", "AdapterId", "ChangeTime") IN (
                SELECT "EntityId", "AdapterId", "ChangeTime"
                FROM unnest(changes)
            ));
    END;
    
$BODY$;

ALTER FUNCTION public.get_changes_by_change_values(changes "Changes_row"[])
    OWNER TO postgres;


-- FUNCTION: public.get_changes_not_by_change_values(uuid[], uuid[], timestamp without time zone[])

-- DROP FUNCTION public.get_changes_not_by_change_values(uuid[], uuid[], timestamp without time zone[]);

CREATE OR REPLACE FUNCTION public.get_changes_not_by_change_values(
    entity_ids uuid[],
    adapter_ids uuid[],
    change_times timestamp without time zone[])
    RETURNS SETOF "Changes" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (
            SELECT * 
            FROM "Changes" 
            WHERE NOT "EntityId" = ANY(entity_ids)
            OR NOT "AdapterId" = ANY(adapter_ids)
            OR NOT "ChangeTime" = ANY(change_times));
    END;

    
$BODY$;

ALTER FUNCTION public.get_changes_not_by_change_values(uuid[], uuid[], timestamp without time zone[])
    OWNER TO postgres;


-- FUNCTION: public.delete_changes_before_changetime(uuid, timestamp without time zone)

-- DROP FUNCTION public.delete_changes_before_changetime(uuid, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.delete_changes_before_changetime(
    adapter_id uuid,
    change_time timestamp without time zone)
    RETURNS VOID 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE
        FROM "Changes"
        WHERE "AdapterId" = adapter_id
        AND "ChangeTime" <= change_time;
    END;

    
$BODY$;

ALTER FUNCTION public.delete_changes_before_changetime(uuid, timestamp without time zone)
    OWNER TO postgres;


-- FUNCTION: public.delete_changes_between(uuid, bigint, bigint)

-- DROP FUNCTION public.delete_changes_between(uuid, bigint, bigint);

CREATE OR REPLACE FUNCTION public.delete_changes_between(
    adapter_id uuid,
    first_key bigint,
    last_key bigint)
    RETURNS VOID 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE
        FROM "Changes"
        WHERE "AdapterId" = adapter_id
        AND first_key <= "ChangesKey"
        AND "ChangesKey" <= last_key;
    END;

    
$BODY$;

ALTER FUNCTION public.delete_changes_between(uuid, bigint, bigint)
    OWNER TO postgres;


-- FUNCTION: public.delete_changes_before(uuid, bigint, timestamp without time zone)

-- DROP FUNCTION public.delete_changes_before(uuid, bigint, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.delete_changes_before(
    adapter_id uuid,
    last_key bigint,
    change_time timestamp without time zone)
    RETURNS VOID 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE
        FROM "Changes"
        WHERE "AdapterId" = adapter_id
        AND "ChangesKey" <= last_key
        AND "ChangeTime" <= change_time;
    END;

    
$BODY$;

ALTER FUNCTION public.delete_changes_before(uuid, bigint, timestamp without time zone)
    OWNER TO postgres;


-- FUNCTION: public.delete_changes(uuid)

-- DROP FUNCTION public.delete_changes(uuid);

CREATE OR REPLACE FUNCTION public.delete_changes(
    adapter_id uuid)
    RETURNS VOID 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE
        FROM "Changes"
        WHERE "AdapterId" = adapter_id;
    END;

    
$BODY$;

ALTER FUNCTION public.delete_changes(uuid)
    OWNER TO postgres;


-- FUNCTION: public.delete_changelogs(timestamp without time zone)

-- DROP FUNCTION public.delete_changelogs(timestamp without time zone);

CREATE OR REPLACE FUNCTION public.delete_changelogs(
    change_timestamp timestamp without time zone)
    RETURNS VOID 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE
        FROM "ChangeLog"
        WHERE "ChangeTimestamp" < change_timestamp;
    END;

    
$BODY$;

ALTER FUNCTION public.delete_changelogs(timestamp without time zone)
    OWNER TO postgres;

-- FUNCTION: public.delete_changelogs_by_adapter_ids(uuid[])

-- DROP FUNCTION public.delete_changelogs_by_adapter_ids(uuid[]);

CREATE OR REPLACE FUNCTION public.delete_changelogs_by_adapter_ids(
	adapter_ids uuid[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE FROM "ChangeLog" WHERE "AdapterId" = ANY(adapter_ids);
    END;    

$BODY$;

ALTER FUNCTION public.delete_changelogs_by_adapter_ids(uuid[])
    OWNER TO postgres;

-- FUNCTION: public.delete_partition_entities(uuid[])

-- DROP FUNCTION public.delete_partition_entities(uuid[]);

CREATE OR REPLACE FUNCTION public.delete_partition_entities(
    partition_ids uuid[])
    RETURNS VOID 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE FROM "Entity" WHERE "PartitionId" = ANY(partition_ids);
        DELETE FROM "ChangeLog" WHERE "AdapterId" = ANY(partition_ids);
    END;

    
$BODY$;

ALTER FUNCTION public.delete_partition_entities(uuid[])
    OWNER TO postgres;

-- FUNCTION: public.get_changelogs_after(bigint)

-- DROP FUNCTION public.get_changelogs_after(bigint);

CREATE OR REPLACE FUNCTION public.get_changelogs_after(
    last_change_number bigint)
    RETURNS SETOF "ChangeLog" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "ChangeLog" WHERE "ChangeLogKey" >= last_change_number ORDER BY "ChangeLogKey" ASC);
    END;

    
$BODY$;

ALTER FUNCTION public.get_changelogs_after(bigint)
    OWNER TO postgres;


-- FUNCTION: public.get_partition_changelogs_after(uuid, bigint)

-- DROP FUNCTION public.get_partition_changelogs_after(uuid, bigint);

CREATE OR REPLACE FUNCTION public.get_partition_changelogs_after(
    adapter_id uuid,
    last_change_number bigint)
    RETURNS SETOF "ChangeLog" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (SELECT * FROM "ChangeLog" WHERE "AdapterId" = adapter_id AND "ChangeLogKey" >= last_change_number ORDER BY "ChangeLogKey" ASC);
    END;

    
$BODY$;

ALTER FUNCTION public.get_partition_changelogs_after(uuid, bigint)
    OWNER TO postgres;


-- FUNCTION: public.get_last_change_number()

-- DROP FUNCTION public.get_last_change_number();

CREATE OR REPLACE FUNCTION public.get_last_change_number()
    RETURNS bigint 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        RETURN (SELECT "last_value" FROM "ChangeLog_ChangeLogKey_seq");
    END;

    
$BODY$;

ALTER FUNCTION public.get_last_change_number()
    OWNER TO postgres;


-- FUNCTION: public.get_last_change_time(uuid)

-- DROP FUNCTION public.get_last_change_time(uuid);

CREATE OR REPLACE FUNCTION public.get_last_change_time(
    adapter_id uuid)
    RETURNS timestamp without time zone 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        RETURN (SELECT MAX("ChangeTimestamp") FROM "ChangeLog");
    END;

    
$BODY$;

ALTER FUNCTION public.get_last_change_time(uuid)
    OWNER TO postgres;

-- FUNCTION: public.bulk_update_entities("Entity_row"[])

-- DROP FUNCTION public.bulk_update_entities("Entity_row"[]);

CREATE OR REPLACE FUNCTION public.bulk_update_entities(
    to_update "Entity_row"[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        UPDATE "Entity"
        SET "EntityValues" = "ue"."EntityValues", "EntityValueTypes" = "ue"."EntityValueTypes", "DN" = "ue"."DN", "ModifiedTime" = "ue"."ModifiedTime" 
        FROM unnest(to_update) as "ue"
        WHERE "Entity"."PartitionId" = "ue"."PartitionId"
        AND "Entity"."EntityId" = "ue"."EntityId";
    END;   

$BODY$;

ALTER FUNCTION public.bulk_update_entities("Entity_row"[])
    OWNER TO postgres;

-- FUNCTION: public.bulk_insert_entities("Entity_row"[])

-- DROP FUNCTION public.bulk_insert_entities("Entity_row"[]);

CREATE OR REPLACE FUNCTION public.bulk_insert_entities(
    to_insert "Entity_row"[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
         INSERT INTO "Entity" ("EntityId", "PartitionId", "CreatedTime", "ModifiedTime", "ContainerId", "DN", "ObjectClass", "EntityValues", "EntityValueTypes")
         SELECT "EntityId", "PartitionId", "CreatedTime", "ModifiedTime", "ContainerId", "DN", "ObjectClass", "EntityValues", "EntityValueTypes" FROM unnest(to_insert);
    END;   

$BODY$;

ALTER FUNCTION public.bulk_insert_entities("Entity_row"[])
    OWNER TO postgres;

-- FUNCTION: public.bulk_delete_entities(uuid, uuid[])

-- DROP FUNCTION public.bulk_delete_entities(uuid, uuid[]);

CREATE OR REPLACE FUNCTION public.bulk_delete_entities(
    partition_id uuid,
    entity_ids_to_delete uuid[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        CREATE TEMP TABLE entity_select_delete_by_entity_id_temp_table (entity_id uuid) ON COMMIT DELETE ROWS;
        INSERT INTO entity_select_delete_by_entity_id_temp_table (entity_id) (SELECT unnest FROM unnest(entity_ids_to_delete));
        DELETE FROM "Entity" WHERE "PartitionId" = partition_id AND "EntityId" IN (SELECT entity_id FROM entity_select_delete_by_entity_id_temp_table);
    END;   

$BODY$;

ALTER FUNCTION public.bulk_delete_entities(uuid, uuid[])
    OWNER TO postgres;

-- FUNCTION: public.get_origin("OriginKey")

-- DROP FUNCTION public.get_origin("OriginKey");

CREATE OR REPLACE FUNCTION public.get_origin(
    origin_key "OriginKey")
    RETURNS SETOF "Origin" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (
            SELECT * 
            FROM "Origin" 
            WHERE "EntityId" = origin_key."EntityId"
            AND "PartitionId" = origin_key."PartitionId"
            AND "Field" = origin_key."Field");
    END;   

$BODY$;

ALTER FUNCTION public.get_origin("OriginKey")
    OWNER TO postgres;


-- FUNCTION: public.get_origins("OriginKey"[])

-- DROP FUNCTION public.get_origins("OriginKey"[]);

CREATE OR REPLACE FUNCTION public.get_origins(
    origin_keys "OriginKey"[])
    RETURNS SETOF "Origin" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (
            SELECT * 
            FROM "Origin" 
            WHERE ("EntityId", "PartitionId", "Field") IN (
                SELECT "EntityId", "PartitionId", "Field"
                FROM unnest(origin_keys)
            ));
    END;   

$BODY$;

ALTER FUNCTION public.get_origins("OriginKey"[])
    OWNER TO postgres;

-- FUNCTION: public.get_entity_origins("OriginEntityKey"[])

-- DROP FUNCTION public.get_entity_origins("OriginEntityKey"[]);

CREATE OR REPLACE FUNCTION public.get_entity_origins(
    origin_entity_keys "OriginEntityKey"[])
    RETURNS SETOF "Origin" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (
            SELECT * 
            FROM "Origin" 
            WHERE ("EntityId", "PartitionId") IN (
                SELECT "EntityId", "PartitionId"
                FROM unnest(origin_entity_keys)
            ));
    END;   

$BODY$;

ALTER FUNCTION public.get_entity_origins("OriginEntityKey"[])
    OWNER TO postgres;

-- FUNCTION: public.get_entity_id_origins(uuid[])

-- DROP FUNCTION public.get_entity_id_origins(uuid[]);

CREATE OR REPLACE FUNCTION public.get_entity_id_origins(
    entity_ids uuid[])
    RETURNS SETOF "Origin" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (
            SELECT * 
            FROM "Origin" 
            WHERE "EntityId" = ANY(entity_ids));
    END;   

$BODY$;

ALTER FUNCTION public.get_entity_id_origins(uuid[])
    OWNER TO postgres;

-- FUNCTION: public.get_entity_id_field_origins(uuid, text)

-- DROP FUNCTION public.get_entity_id_field_origins(uuid, text);

CREATE OR REPLACE FUNCTION public.get_entity_id_field_origins(
    entity_id uuid,
    field text)
    RETURNS SETOF "Origin" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (
            SELECT * 
            FROM "Origin" 
            WHERE "EntityId" = entity_id
            AND "Field" = field);
    END;   

$BODY$;

ALTER FUNCTION public.get_entity_id_field_origins(uuid, text)
    OWNER TO postgres;

-- FUNCTION: public.get_where_origin("OriginKey")

-- DROP FUNCTION public.get_where_origin("OriginKey");

CREATE OR REPLACE FUNCTION public.get_where_origin(
    source_origin_key "OriginKey")
    RETURNS SETOF "Origin" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (
            SELECT * 
            FROM "Origin" 
            WHERE "SourceEntityId" = source_origin_key."EntityId"
            AND "SourcePartitionId" = source_origin_key."PartitionId"
            AND "SourceField" = source_origin_key."Field");
    END;   

$BODY$;

ALTER FUNCTION public.get_where_origin("OriginKey")
    OWNER TO postgres;

-- FUNCTION: public.get_where_origins(origin_keys "OriginKey"[])

-- DROP FUNCTION public.get_where_origins(origin_keys "OriginKey"[];

CREATE OR REPLACE FUNCTION public.get_where_origins(
    source_origin_keys "OriginKey"[])
    RETURNS SETOF "Origin" 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

    BEGIN
        RETURN QUERY (
            SELECT * 
            FROM "Origin" 
            WHERE ("SourceEntityId", "SourcePartitionId", "SourceField") IN (
                SELECT "EntityId", "PartitionId", "Field"
                FROM unnest(source_origin_keys)
            ));
    END;   

$BODY$;

ALTER FUNCTION public.get_where_origins(origin_keys "OriginKey"[])
    OWNER TO postgres;

-- FUNCTION: public.bulk_insert_origins("Origin_row"[])

-- DROP FUNCTION public.bulk_insert_origins("Origin_row"[]);

CREATE OR REPLACE FUNCTION public.bulk_insert_origins(
    to_insert "Origin_row"[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE
AS $BODY$

    BEGIN
         INSERT INTO "Origin" ("EntityId", "PartitionId", "Field", "SourceEntityId", "SourcePartitionId", "SourceField")
         SELECT "EntityId", "PartitionId", "Field", "SourceEntityId", "SourcePartitionId", "SourceField" FROM unnest(to_insert);
    END;   

$BODY$;

ALTER FUNCTION public.bulk_insert_origins("Origin_row"[])
    OWNER TO postgres;

-- FUNCTION: public.bulk_update_origins("Origin_row"[])

-- DROP FUNCTION public.bulk_update_origins("Origin_row"[]);

CREATE OR REPLACE FUNCTION public.bulk_update_origins(
    to_update "Origin_row"[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        UPDATE "Origin"
        SET "SourceEntityId" = "uo"."SourceEntityId", "SourcePartitionId" = "uo"."SourcePartitionId", "SourceField" = "uo"."SourceField"
        FROM unnest(to_update) as "uo"
        WHERE "Origin"."EntityId" = "uo"."EntityId"
        AND "Origin"."PartitionId" = "uo"."PartitionId"
        AND "Origin"."Field" = "uo"."Field";
    END;   

$BODY$;

ALTER FUNCTION public.bulk_update_origins("Origin_row"[])
    OWNER TO postgres;


-- FUNCTION: public.bulk_delete_origins("Origin_row"[])

-- DROP FUNCTION public.bulk_delete_origins("Origin_row"[]);

CREATE OR REPLACE FUNCTION public.bulk_delete_origins(
    to_delete "Origin_row"[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    BEGIN
        DELETE FROM "Origin"
        WHERE ("EntityId", "PartitionId", "Field") IN (SELECT "EntityId", "PartitionId", "Field" FROM unnest(to_delete))
        AND ("SourceEntityId" IN (SELECT "SourceEntityId" FROM unnest(to_delete)) 
             OR EXISTS(SELECT 1 from (SELECT "SourceEntityId" FROM unnest(to_delete)) as src_e_id where src_e_id is null))
        AND ("SourcePartitionId" IN (SELECT "SourcePartitionId" FROM unnest(to_delete)) 
             OR EXISTS(SELECT 1 from (SELECT "SourcePartitionId" FROM unnest(to_delete)) as src_p_id where src_p_id is null))
        AND ("SourceField" IN (SELECT "SourceField" FROM unnest(to_delete)) 
             OR EXISTS(SELECT 1 from (SELECT "SourceField" FROM unnest(to_delete)) as src_f where src_f is null));
    END;   

$BODY$;

ALTER FUNCTION public.bulk_delete_origins("Origin_row"[])
    OWNER TO postgres;

-- Index: entity_entity_id_index

-- DROP INDEX public.entity_entity_id_index;

CREATE INDEX entity_entity_id_index
    ON public."Entity" USING btree
    ("EntityId")
    TABLESPACE pg_default;

-- Index: entity_partition_id_index

-- DROP INDEX public.entity_partition_id_index;

CREATE INDEX entity_partition_id_index
    ON public."Entity" USING btree
    ("PartitionId")
    TABLESPACE pg_default;

-- Index: origin_fkey_index

-- DROP INDEX public.origin_fkey_index;

CREATE INDEX origin_fkey_index
    ON public."Origin" USING btree
    ("EntityId", "PartitionId")
    TABLESPACE pg_default;

-- Index: container_level_index

-- DROP INDEX public.container_level_index;

CREATE INDEX container_level_index
    ON public."Container" USING btree
    ("Level")
    TABLESPACE pg_default;
    
-- Index: container_dn_index

-- DROP INDEX public.container_dn_index;

CREATE INDEX container_dn_index
    ON public."Container" USING btree
    ("DN")
    TABLESPACE pg_default;

-- Index: changes_fkey_index

-- DROP INDEX public.changes_fkey_index;

CREATE INDEX changes_fkey_index
    ON public."Changes" USING btree
    ("EntityId", "AdapterId")
    TABLESPACE pg_default;