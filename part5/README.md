## Create tables

Run `create_tables.sql` to create tables.

## Populate tables

### Locally: 
Since it was not possible to install 3rd party python libraries on school server (`psycopg2`), the database was populated locally then copied over to the school server with the following steps
 - connected to the local server with `psql`
 - `\i create_tables.sql` 
 - The python script was run `python3 load_data.py`

### Remote:
A dump of the tables was done on the local database, and copied to the school servers using `scp` by running `dump_and_copy.sh`

Once on the school server, the data was imported by 
 - connecting to the psql server (`psql -U user022 -h studentdb.csc.uvic.ca db_022`) 
 - schema created using `\i create_tables.sql`
 - data was imported by running `\i db_022.sql`

### Note:
A copy of the dump has been kept within this folder, so it is unecessary to do the `scp` command.