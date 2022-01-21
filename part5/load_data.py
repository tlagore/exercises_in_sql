import psycopg2
import csv
import sys
import os
import traceback

REMOTE = False

if len(sys.argv) > 1 and sys.argv[1] == 'remote':
    REMOTE = True

class DBConnection(object):
    def __init__(self, db_details):
        self.db_details = db_details

    def __enter__(self):
        try:
            self.conn = psycopg2.connect("dbname='{0}' user='{1}' host='{2}' password='{3}'".format(
                db_details['database'],
                db_details['user'],
                db_details['host'],
                db_details['password']
            ))
        except Exception as e:
            print(f"Unable to connect to the database: {e}")
            raise e
    
        return self.conn

    def __exit__(self, exception_type, exception_value, traceback):
        if exception_type is not None:
            traceback.print_exception(exception_type, exception_value, traceback)
        
        if self.conn is not None:
            print("disposing")
            self.conn.close()

        return True
        

db_details = {
    'host': "studentdb.csc.uvic.ca" if REMOTE else "localhost" ,
    'database': "db_022",
    'user': "user022" if REMOTE else "tyrone" ,
    'password': os.environ.get("PSQL_DB_PASS")
}

with DBConnection(db_details) as conn:
    with conn.cursor() as curs:
        print("got here!")