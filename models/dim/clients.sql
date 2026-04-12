
-- I specify where I want to write my data
-- I precise the schema because I have define a macro to create a custom schema if specify the "schema" field
-- alias is no more necessary after changing files name
{{ config(
    schema='client_data', 
    alias='clients'
)
}}
-- I firstly take the raw data 
WITH src_events as (
    SELECT *
    FROM {{ source("raw_data", "raw_clients_events") }}
), 

-- Get unique elements and not null email
-- Take the last event with the same event_id depending on event_time and ingestion time

not_null_email as (
    SELECT distinct client_id, 
           email, 
           country, 
           ingested_at,
           event_type, 
           event_time, 
    FROM src_events
    WHERE email is not null 
        AND event_time is not null
        AND ingested_at is not null
    QUALIFY ROW_NUMBER() OVER(partition by event_id ORDER BY event_time desc, ingested_at desc) = 1
),

--get users creation 
users_creation as (
    SELECT  client_id, 
            min(event_time) as created_at
    FROM not_null_email
    WHERE LOWER(event_type) LIKE 'client_created' or LOWER(event_type) LIKE 'client_updated'
    GROUP BY client_id
)

SELECT client_id,  
        array_agg(nne.email order by nne.event_time desc limit 1)[offset(0)] as email, -- get latest email
        array_agg(nne.country order by nne.event_time desc limit 1)[offset(0)] as country, -- latest country
        min(uc.created_at) as created_at
FROM not_null_email as nne 
    INNER JOIN users_creation as uc  USING(client_id)
GROUP BY client_id



