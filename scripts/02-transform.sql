BEGIN;

-- 1. hunts
INSERT INTO public.hunts (
  id,
  species,
  class,
  weapon,
  draw_type,
  season_dates,
  unit_group,
  hunter_choice_number_ke,
  season_start_date,
  season_end_date,
  is_new
)
SELECT
  id::int,
  lower(species) AS species,
  lower(class) AS class,
  lower(weapon) AS weapon,
  lower(draw_type) AS draw_type,
  lower(season_dates) AS season_dates,
  lower(unit_group) AS unit_group,
  hunter_choice_number_ke,
  season_start_date::date AS season_start_date,
  season_end_date::date AS season_end_date,
  'true'::boolean AS is_new
FROM etl.hunts;

-- 2. hunt units
ALTER TABLE etl.hunt_units
  ADD COLUMN is_open boolean default True;

UPDATE etl.hunt_units
  SET is_open = False 
  WHERE name IN ('Sheldon National Wildlife Refuge', 'Death Valley National Park', 'Nellis Air Force Range/Nevada Test Site', 'Great Basin National Park', 'Indian Springs Air Force Auxiliary Field');

INSERT INTO  hunt_units (id, is_open, display_name, geom)
SELECT
  fid AS id,
  is_open,
  name AS display_name,
  geom
FROM etl.hunt_units;

-- 3. hunt unit to hunts joiner
INSERT INTO hunt_units_hunts_joiner (hunt_id, hunt_unit_id)
SELECT
  joiner.hunt_id::int,
  hunt_units.id AS hunt_unit_id
FROM hunt_units
RIGHT JOIN etl.joiner ON hunt_units.display_name = joiner.unit;

-- 4. quotas table
INSERT INTO quotas (hunt_id, hunt_year, quota)
SELECT
  id::int AS hunt_id,
  2021 AS hunt_year,
  quota::int AS quota 
FROM etl.hunts;

COMMIT;