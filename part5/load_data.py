import psycopg2
import sys
import os

LOCAL = False

if len(sys.argv) > 1 and sys.argv[1] == 'local':
    LOCAL = True

conn = psycopg2.connect(
    host = "localhost" if LOCAL else "studentdb.csc.uvic.ca",
    database = "db_022",
    user = "postgres" if LOCAL else "user022",
    password = os.environ.get("PSQL_DB_PASS")
)