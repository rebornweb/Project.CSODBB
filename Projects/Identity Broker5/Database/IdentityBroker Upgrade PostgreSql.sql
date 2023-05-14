-- Added entity value type column in v5.3.1 
ALTER TABLE "Entity" ADD COLUMN "EntityValueTypes" jsonb;
UPDATE "Entity" SET "EntityValueTypes" = '{}';
ALTER TABLE "Entity" ALTER COLUMN "EntityValueTypes" SET NOT NULL;

-- Added in v5.3.1 for use with updated get_origin, get_origins, get_where_origin, get_where_origins functions
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'OriginKey') THEN
    CREATE TYPE public."OriginKey" AS
    (
        "EntityId" uuid,
        "PartitionId" uuid,
        "Field" text
    );
END IF;

-- Added in v5.3.1 for use with updated get_entity_origins function
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'OriginEntityKey') THEN
    CREATE TYPE public."OriginEntityKey" AS
    (
        "EntityId" uuid,
        "PartitionId" uuid
    );
END IF;

-- Modified for NPGSQL v4 as mapping to table type no longer works.
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'Changes_row') THEN
    CREATE TYPE public."Changes_row" AS
    (
        "ChangesKey" bigint,
        "EntityId" uuid,
        "AdapterId" uuid,
        "ChangeTime" timestamp without time zone
    );
END IF;

-- Modified for NPGSQL v4 as mapping to table type no longer works.
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'Origin_row') THEN
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
END IF;

-- Modified for NPGSQL v4 as mapping to table type no longer works.
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'Entity_row') THEN
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
END IF;

-- Modifed in v5.3.1 to match origin key against selected record.
DROP FUNCTION IF EXISTS public.get_origin(uuid, uuid, text);
CREATE FUNCTION public.get_origin(
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

-- Modifed in v5.3.1 to match origin keys against selected record.
DROP FUNCTION IF EXISTS public.get_origins(uuid[], uuid[], text[]);
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
                FROM unnest(origin_key)
            ));
    END;   

$BODY$;

-- Modifed in v5.3.1 to match origin key against selected record.
DROP FUNCTION IF EXISTS public.get_where_origin(uuid, uuid, text);
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

-- Modifed in v5.3.1 to match origin keys against selected record.
DROP FUNCTION IF EXISTS public.get_where_origins(uuid[], uuid[], text[]);
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
                FROM unnest(origin_key)
            ));
    END;   

$BODY$;

-- Modifed in v5.3.1 to match origin entity keys against selected record.
DROP FUNCTION IF EXISTS public.get_entity_origins(uuid[], uuid[]);
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

-- Added entity value type column in v5.3.1 
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

-- Added in v5.3.1 for get_changes_by_change_values performance
CREATE INDEX changes_fkey_index
    ON public."Changes" USING btree
    ("EntityId", "AdapterId")
    TABLESPACE pg_default;

-- Modified for NPGSQL v4 as mapping to table type no longer works.
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

-- Modified for NPGSQL v4 as mapping to table type no longer works.
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

-- Modified for NPGSQL v4 as mapping to table type no longer works.
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

-- Modified for NPGSQL v4 as mapping to table type no longer works.
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

-- Modified for NPGSQL v4 as mapping to table type no longer works.
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

-- Modified for NPGSQL v4 as mapping to table type no longer works.
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

-- Modified for NPGSQL v4 as mapping to table type no longer works.
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