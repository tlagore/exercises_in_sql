#!/bin/bash
pg_dump -U postgres db_022 -O -x > db_022.dump

scp db_022.dump tyronelagore@linux.csc.uvic.ca:/home/tyronelagore/csc502/csc502_asg1/part5/db_022.dump