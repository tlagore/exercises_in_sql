## Create tables

Run `create_tables.sql` to create tables.


## Populate tables

Since it was not possible to install 3rd party python libraries on school server (`psycopg2`), the database was populated locally using the script `load_data.py`, run with no arguments.

Then a dump of the tables was done, and copied to the school servers using `scp` by running `dump_and_copy.sh`

Once on the school server, the data was imported by 
 - connecting to the psql server (`psql -U user022 -h studentdb.csc.uvic.ca db_022`) 
 - schema created using `\i create_tables.sql`
 - data was imported by running `\i db_022.sql`