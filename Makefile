HOST=localhost
USER=mitchellgritts
DBNAME=huntnv
# DATA=/Users/mitchellgritts/Documents/projects/ndow/_game/huntnv/database/data
DATA=./data

all: build load transform

init:
	createdb $(DBNAME)

build:
	psql $(DBNAME) -a -f scripts/01-build.sql

load:
	psql $(DBNAME) -c "\copy etl.hunts from '$(DATA)/db-hunt-config.csv' with csv header"
	psql $(DBNAME) -c "\copy etl.joiner from '$(DATA)/db-joiner.csv' with csv header"
	ogr2ogr \
		-f "PostgreSQL" \
		-lco SCHEMA=etl \
		-lco GEOMETRY_NAME=geom \
		-nln etl.hunt_units \
		--config PG_USE_COPY YES \
		"PG:host=$(HOST) user=$(USER) dbname=$(DBNAME)" \
		$(DATA)/nv-hunt-units.gpkg hunt_units

transform:
	psql $(DBNAME) -a -f scripts/02-transform.sql
	psql $(DBNAME) -c "DROP SCHEMA etl CASCADE;"

danger:
	dropdb $(DBNAME)

restart: danger init