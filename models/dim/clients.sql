
-- I specify where I want to write my data
-- I precise the schema because I have define a macro to create a custom schema if specify the "schema" field
-- alias is not more  after changing files name
{{ config(
    schema='client_data', 
    alias='clients'
)
}}
-- I firstly take the raw data 
WITH src_events AS (
    SELECT *
    FROM {{ source("raw_data", "raw_clients_events") }}
), 

-- Get unique elements and not null email
-- Take the last event with the same event_id depending on event_time and ingestion time

deduplicates_events AS (
     SELECT DISTINCT client_id, 
           email, 
           country, 
           ingested_at,
           event_type, 
           event_time, 
    FROM src_events
    WHERE event_time IS NOT NULL
        AND ingested_at IS NOT NULL
        AND event_id IS NOT NULL
        AND client_id IS NOT NULL
    QUALIFY ROW_NUMBER() OVER(PARTITION BY event_id ORDER BY event_time DESC, ingested_at DESC) = 1
), 

--get users creation 
users_creation AS (
    SELECT  client_id, 
            min(event_time) as created_at
    FROM deduplicates_events
    WHERE LOWER(event_type) LIKE 'client_created' 
    GROUP BY client_id
), 
-- Last non null email 

last_email AS (
    SELECT client_id, 
           array_agg(email ORDER BY event_time DESC LIMIT 1)[offset(0)] as email
    FROM deduplicates_events
    WHERE email IS NOT NULL 
         AND NOT REGEXP_CONTAINS(email, r'^\s+$')
    GROUP BY client_id
    ), 
-- get last country 

last_country AS (
    SELECT client_id, 
           array_agg(country ORDER BY event_time DESC LIMIT 1)[offset(0)] as country
    FROM deduplicates_events
    WHERE country IS NOT NULL 
         AND NOT REGEXP_CONTAINS(country, r'^\s+$')
    GROUP BY client_id
)

SELECT DISTINCT client_id, 
       uc.created_at AS created_at, 
       le.email AS email, 
       lc.country AS country
FROM deduplicates_events AS de
LEFT JOIN users_creation AS uc USING(client_id)
LEFT JOIN last_email AS le USING(client_id)
LEFT JOIN last_country AS lc USING(client_id)




