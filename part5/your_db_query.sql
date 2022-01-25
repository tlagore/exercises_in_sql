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
