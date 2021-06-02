BEGIN;

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SCHEMA etl;

CREATE TABLE etl.hunts (
  id text,
  species text,
  class text,
  weapon text,
  draw_type text,
  season_dates text,
  unit_group text,
  hunter_choice_number_ke text,
  quota text,
  season_start_date text,
  season_end_date text
);

CREATE TABLE etl.joiner (
  hunt_id text,
  unit text  
);

-- CREATE PUBLIC SCHEMA TABLES
CREATE TABLE public.hunts (
  id serial PRIMARY KEY,
  species text NOT NULL,
  class text,
  weapon text NOT NULL,
  draw_type text,
  season_dates text,
  unit_group text,
  hunter_choice_number_ke text,
  season_start_date date,
  season_end_date date,
  is_new boolean,
  created_at timestamp with time zone default now()
);

CREATE TABLE public.hunt_units (
  id serial PRIMARY KEY,
  is_open boolean default true,
  display_name text NOT NULL,
  geom geometry(Polygon, 4326) NOT NULL
);

CREATE TABLE public.hunt_units_hunts_joiner (
  id serial PRIMARY KEY,
  hunt_id int references public.hunts (id),
  hunt_unit_id int references public.hunt_units (id)
);

CREATE TABLE public.quotas (
  id serial PRIMARY KEY,
  hunt_id int references hunts (id),
  hunt_year int NOT NULL,
  quota int
);

COMMIT;