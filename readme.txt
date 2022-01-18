Every query should be placed in its corresponding .sql file. This query should run
in our DBMS without any modification.

You can test you query in two ways:

1. using the shell.

Assume your query is in file query.sql and your username is user000

    cat query.sql | psql -h studentdb.csc.uvic.ca -U user000 imdb


2. inside psql.

The file query.sql should be in the current directory. Run psql and from inside it type:

\i query.sql








