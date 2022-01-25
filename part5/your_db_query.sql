-- write your query to answer your db question here

WITH 
	age_range_start AS (
		SELECT generate_series(1976, 2020, 4) AS from_interval
	), 
	age_range AS (
		SELECT from_interval, (from_interval + 3) AS to_interval FROM age_range_start
	),
	highest_party_per_year AS
	(
		SELECT ei.year, si.state_name, p.party_name, p.party_simplified, MAX(totalvotes)
		FROM electioninfo AS ei
		JOIN stateinfo AS si ON si.id = ei.stateid
		JOIN party AS p ON p.id = ei.partyid
		GROUP BY ei.year, si.state_name, p.party_name, p.party_simplified
	),
	party_wins AS 
	(
		SELECT year, party_name, COUNT(*) AS num_wins FROM highest_party_per_year
		GROUP BY year, party_name
	)
	SELECT from_interval, to_interval,
		(SELECT SUM(totalvotes) FROM electioninfo AS ei
			WHERE ei.year BETWEEN from_interval AND to_interval) AS total_votes,
		(SELECT MAX(totalvotes) FROM electioninfo AS ei
			WHERE ei.year BETWEEN from_interval AND to_interval) AS max_state_votes
	FROM age_range;


/*WITH 
	age_range_start AS (
		SELECT generate_series(1976, 2020, 4) AS from_interval
	), 
	age_range AS (
		SELECT from_interval, (from_interval + 3) AS to_interval FROM age_range_start
	),
	WITH max_candidate AS 
	(SELECT ei.year, ei.candidatename, MAX(candidatevotes) FROM electioninfo AS ei,
			WHERE ei.year  BETWEEN 1976 AND 1979
			GROUP BY ei.year, ei.candidatename)
	highest_party_per_year AS
	(
		SELECT ei.year, si.state_name, p.party_name, p.party_simplified, MAX(totalvotes)
		FROM electioninfo AS ei
		JOIN stateinfo AS si ON si.id = ei.stateid
		JOIN party AS p ON p.id = ei.partyid
		GROUP BY ei.year, si.state_name, p.party_name, p.party_simplified
	),
	party_wins AS 
	(
		SELECT year, party_name, COUNT(*) AS num_wins FROM highest_party_per_year
		GROUP BY year, party_name
	)
	SELECT from_interval, to_interval,
		(SELECT SUM(totalvotes) FROM electioninfo AS ei
			WHERE ei.year BETWEEN from_interval AND to_interval) AS total_votes,
		(SELECT MAX(totalvotes) FROM electioninfo AS ei
			WHERE ei.year BETWEEN from_interval AND to_interval) AS max_state_votes
		(SELECT state )
	FROM age_range;*/

/*
WITH 
	age_range_start AS (
		SELECT generate_series(1976, 2020, 4) AS from_interval
	), 
 	age_range AS (
		SELECT from_interval, (from_interval + 3) AS to_interval FROM age_range_start
	)
	SELECT 
		ar.from_interval,
		ar.to_interval,
		(SELECT state_name FROM 
		 	(SELECT si.state_name, MAX(totalvotes) FROM electioninfo AS ei
			JOIN stateinfo AS si ON si.id = ei.stateid
			WHERE ei.year  BETWEEN ar.from_interval AND ar.to_interval
			GROUP BY si.state_name) AS t
		)
	FROM age_range AS ar;
*/

WITH age_range_start AS (
		SELECT generate_series(1976, 2020, 4) AS from_interval
	), 
 	age_range AS (
		SELECT from_interval, (from_interval + 3) AS to_interval FROM age_range_start
	),
	max_by_year AS
	( SELECT from_interval, to_interval, max(totalvotes)
		FROM electioninfo AS ei, age_range
		WHERE ei.year BETWEEN from_interval AND to_interval
		GROUP by from_interval, to_interval
	),
	max_state_info AS (SELECT DISTINCT mby.from_interval, mby.to_interval, si.state_name as state_w_highest_votes, mby.max 
		FROM max_by_year AS mby
		JOIN electioninfo AS ei ON ei.totalvotes = mby.max
	 	JOIN stateinfo AS si ON si.id = ei.stateid)
	SELECT DISTINCT msi.from_interval, msi.to_interval, msi.state_w_highest_votes, msi.max,
			(SELECT SUM(totalvotes) FROM electioninfo AS ei
				WHERE ei.year BETWEEN from_interval AND to_interval) AS total_votes,
			(SELECT AVG(totalvotes) FROM electioninfo AS ei
				WHERE ei.year BETWEEN from_interval AND to_interval) AS avg_total_votes
		FROM max_state_info AS msi
		JOIN electioninfo AS ei ON ei.totalvotes = msi.max
		JOIN stateinfo AS si ON si.id = ei.stateid
		JOIN party AS p ON p.id = ei.partyid
		WHERE ei.year BETWEEN msi.from_interval AND msi.to_interval;
	
	
	/*
	SELECT DISTINCT ms.from_interval, ms.to_interval, ms.state_w_highest_votes, ms.max,
			(SELECT SUM(totalvotes) FROM electioninfo AS ei
				WHERE ei.year BETWEEN from_interval AND to_interval) AS total_votes,
			(SELECT AVG(totalvotes) FROM electioninfo AS ei
				WHERE ei.year BETWEEN from_interval AND to_interval) AS avg_total_votes
		FROM max_state AS ms
		JOIN electioninfo AS ei ON ei.totalvotes = mby.max
		JOIN stateinfo AS si ON si.id = ei.stateid
		JOIN party AS p ON p.id = ei.partyid
		WHERE ei.year BETWEEN mby.from_interval AND mby.to_interval;*/
	
	

	 
	/*
	SELECT state_name FROM
	 FROM electioninfo AS ei 
	 JOIN stateinfo AS si ON si.id = ei.stateid
	 JOIN max_year;
	 */
/*
SELECT ei.year, si.state_name, MAX(totalvotes) FROM electioninfo AS ei
		JOIN stateinfo AS si ON si.id = ei.stateid
		WHERE ei.year  BETWEEN 1976 AND 1979
		GROUP BY ei.year, si.state_name;
*/
/*
SELECT * FROM electioninfo AS ei
	JOIN stateinfo AS si ON si.id = ei.stateid
	WHERE year  BETWEEN 1976 AND 1979;
	*/