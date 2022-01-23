from enum import unique
from operator import ge
from re import I
import psycopg2
from psycopg2.extras import execute_batch
import re
import csv
import sys
import os
import traceback

import getpass

from sshtunnel import SSHTunnelForwarder

REMOTE = False

if len(sys.argv) > 1 and sys.argv[1] == 'remote':
    REMOTE = True

class DBConnection(object):
    def __init__(self, db_details):
        self.db_details = db_details

    def __enter__(self):
        try:
            self.conn = psycopg2.connect("dbname='{0}' user='{1}' host='{2}' password='{3}'".format(
                self.db_details['database'],
                self.db_details['user'],
                self.db_details['host'],
                self.db_details['password']
            ))

        except Exception as e:
            print(f"Unable to connect to the database: {e}")
            raise e
    
        return self.conn

    def __exit__(self, exception_type, exception_value, trace):
        if exception_type is not None:
            traceback.print_exc(exception_type, exception_value, traceback)
        
        if self.conn is not None:
            print("disposing")
            self.conn.close()

        return True
        

db_details = {
    'host': "studentdb.csc.uvic.ca" if REMOTE else "localhost" ,
    'database': "db_022",
    'user': "user022" if REMOTE else "postgres" ,
    'password': os.environ.get("PSQL_DB_PASS")
}

if REMOTE:
    password = getpass.getpass("Enter password for remote DB: ")
    db_details['password'] = password


state_query = """
    INSERT INTO stateinfo (state_name, state_po, state_fips, state_cen, state_ic) 
        VALUES (%s, %s, %s, %s, %s)
        RETURNING id;
"""

party_query = """
    INSERT INTO party (party_name, party_simplified) 
        VALUES (%s, %s)
        RETURNING id;
"""

election_query = """
    INSERT INTO electioninfo 
        (
            office, stage, year, special, candidatename, partyid, stateid,
            district, mode, candidatevotes, totalvotes, unofficial
        ) 
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
"""

def get_state_info(row, col_idx):
    """
        [state_name, state_po, state_fips, state_cen, state_ic]
    """
    state = row[col_idx['state']]
    state_po = row[col_idx['state_po']]
    state_fips = row[col_idx['state_fips']]
    state_cen = row[col_idx['state_cen']]
    state_ic = row[col_idx['state_ic']]

    return [state, state_po, state_fips, state_cen, state_ic]

def get_party_info(row, col_idx):
    """
        [party_name, party_simplified]
    """

    party = row[col_idx['party_detailed']]

    party = party if party != '' else 'NULL'

    party_simplified = row[col_idx['party_simplified']]

    return [party, party_simplified]

def get_election_info(row, col_idx, party_id, state_id):
    """
        [
            office, stage, year, special, candidate, partyid, stateid,
            district, mode, candidatevotes, totalvotes, unofficial
        ]
    """
    office = row[col_idx['office']]
    stage = row[col_idx['stage']]
    year = row[col_idx['year']]
    special = row[col_idx['special']]
    candidate = row[col_idx['candidate']]

    candidate = candidate if (candidate != 'NA' and candidate != '') else 'NULL'

    district = row[col_idx['district']]
    mode = row[col_idx['mode']]
    candidatevotes = row[col_idx['candidatevotes']]
    totalvotes = row[col_idx['totalvotes']]
    unofficial = row[col_idx['unofficial']]

    return [office, stage, year, special, candidate, party_id, state_id, district, mode, candidatevotes, totalvotes, unofficial]


# keep a cache lookup of our party/state id
unique_parties = {}
unique_states = {}

data_loc = "data/1976-2020-senate.csv"
num_rows = 0

with DBConnection(db_details) as conn:
    with conn.cursor() as curs:
        with open(data_loc, "r") as cur_file:
            csv_reader = csv.reader(cur_file)

            for row in csv_reader:
                print(f"row={num_rows}\r", end='')
                if num_rows == 0:
                    # first row is headers, get their index for later lookup
                    col_idx = {col_name: idx for idx, col_name in enumerate(row)}
                    print(col_idx)
                    num_rows += 1
                    continue

                state_info = get_state_info(row, col_idx)    

                if state_info[0] not in unique_states:
                    # sq = state_query.format(*state_info)

                    curs.execute(state_query, state_info)
                    returned_id = curs.fetchone()[0]
                    conn.commit()

                    unique_states[state_info[0]] = returned_id
                    print(f"New state: '{state_info[0]}' with id '{returned_id}'")
                
                party_info = get_party_info(row, col_idx)

                if party_info[0] not in unique_parties:
                    # sq = party_query.format(*party_info)

                    curs.execute(party_query, party_info)
                    returned_id = curs.fetchone()[0]
                    conn.commit()

                    unique_parties[party_info[0]] = returned_id

                state_id = unique_states[state_info[0]]
                party_id = unique_parties[party_info[0]]

                election_info = get_election_info(row, col_idx, party_id, state_id)
                curs.execute(election_query, election_info)

                num_rows+=1

print(num_rows)