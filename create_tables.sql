DROP TABLE IF EXISTS electioninfo;
DROP TABLE IF EXISTS stateinfo;
DROP TABLE IF EXISTS party;

CREATE TABLE stateinfo
(
    id SERIAL PRIMARY KEY,
    state_name varchar(64),
    state_po varchar(16),
    state_fips INT,
    state_cen INT,
    state_ic INT
);

CREATE TABLE party
(
    id SERIAL PRIMARY KEY,
    party_name VARCHAR(128),
    party_simplified VARCHAR(128)
);

CREATE TABLE electioninfo
(
    -- There are instances
    -- of "unknown" individuals running for the same party in the same state in the same year
    -- where the name is "NA", therefore we create an index instead of using those values as PK
    id SERIAL PRIMARY KEY,
    office VARCHAR(64),
    stage VARCHAR(16),
    year INT,
    special BOOLEAN,
    candidatename VARCHAR(128),
    partyid INT,
    stateid INT,
    district VARCHAR(64),
    mode VARCHAR(32),
    candidatevotes INT,
    totalvotes INT,
    unofficial BOOLEAN,
    CONSTRAINT state_fk FOREIGN KEY (stateid) 
        REFERENCES stateinfo(id),
    CONSTRAINT party_fk FOREIGN KEY (partyid)
        REFERENCES party(id)
);