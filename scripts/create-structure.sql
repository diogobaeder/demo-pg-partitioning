CREATE TABLE IF NOT EXISTS data (
    uuid UUID NOT NULL DEFAULT gen_random_uuid(),
    country_code VARCHAR(3) NOT NULL,
    date DATE NOT NULL,
    description TEXT,
    PRIMARY KEY (uuid, country_code, date)
) PARTITION BY LIST (country_code);

CREATE OR REPLACE FUNCTION data_add_partition(
    date DATE, country_code VARCHAR(3)
) RETURNS VOID LANGUAGE plpgsql AS $$
    DECLARE
        year INTEGER := EXTRACT(YEAR FROM date);
        from_date DATE := FORMAT('%s-01-01', year);
        to_date DATE := FORMAT('%s-01-01', year + 1);
    BEGIN
        -- Create the country code partition
        EXECUTE FORMAT(
            'CREATE TABLE IF NOT EXISTS data_%s '
            'PARTITION OF data FOR VALUES IN (''%s'') '
            'PARTITION BY RANGE (date);',
            country_code, country_code
        );
        -- Create the year partition
        EXECUTE FORMAT(
            'CREATE TABLE IF NOT EXISTS data_%s_%s '
            'PARTITION OF data_%s FOR VALUES FROM (''%s'') TO (''%s'')',
            country_code, year, country_code, from_date, to_date
        );
    END;
$$;

CREATE OR REPLACE FUNCTION data_insert(
    date DATE, country_code VARCHAR(3), description TEXT
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    PERFORM data_add_partition(date, country_code);
    INSERT INTO data (country_code, date, description)
        VALUES (country_code, date, description);
END;
$$;
