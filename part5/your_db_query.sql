-- write your query to answer your db question here
-- Question:
/*
	As US senate elections happen every 2 years, grouping by 2 year intervals determine:
		- Which state had the most votes? 
		- Which candidate had the most votes?
		- Which party did this candidate belong to?
		- Which state did the candidate with the most votes win in?
		- what was the amount of votes won by this candidate?
		- What were the total election votes for this 2 year period?
		- What were the average number of total votes?
		- What was the party that had the most state wins?
		- How many states were won by this party?

*/

WITH age_range_start AS (
		SELECT generate_series(1976, 2020, 2) AS from_interval
	), 
 	age_range AS (
		SELECT from_interval, (from_interval + 1) AS to_interval FROM age_range_start
	),
	winning_state_by_year AS (
		SELECT year, state_name, MAX(candidatevotes) 
		FROM electioninfo AS ei 
		JOIN stateinfo AS si ON si.id = ei.stateid
		GROUP BY year, state_name
	),
	with_party AS (
		SELECT wsby.year, state_name, max, party_simplified
		FROM winning_state_by_year AS wsby
		JOIN electioninfo AS ei ON wsby.max = ei.candidatevotes
		JOIN party AS p ON p.id = ei.partyid
	),
	party_count_by_year AS (
		SELECT year, party_simplified, COUNT(*)
		FROM with_party
		GROUP BY year, party_simplified
	),
	most_party_wins AS (
		SELECT year, MAX(count)
		FROM party_count_by_year
		GROUP BY year
	),
	most_party_wins_w_party AS(
		SELECT DISTINCT pcby.year, pcby.party_simplified, pcby.count
		FROM most_party_wins AS mpw
		JOIN party_count_by_year AS pcby ON mpw.max = pcby.count AND pcby.year = mpw.year
	),
	overall_winning_party AS (
		SELECT DISTINCT from_interval, to_interval,
			(
				CASE 
					WHEN (SELECT COUNT(*) FROM most_party_wins_w_party AS t WHERE mpwwp.year = t.year GROUP BY year ) > 1 THEN 'TIE'
					ELSE party_simplified
				END
			) AS party_with_most_state_wins,
			count
		FROM most_party_wins_w_party AS mpwwp
		JOIN age_range AS ar
			ON mpwwp.year BETWEEN ar.from_interval AND ar.to_interval
	),
	max_statevotes_by_year AS
	( SELECT from_interval, to_interval, max(totalvotes)
		FROM electioninfo AS ei, age_range
		WHERE ei.year BETWEEN from_interval AND to_interval
		GROUP by from_interval, to_interval
	),
	max_candidatevotes_by_year AS
	( SELECT from_interval, to_interval, max(candidatevotes)
		FROM electioninfo AS ei, age_range
		WHERE ei.year BETWEEN from_interval AND to_interval
		GROUP by from_interval, to_interval
	),
	candidate_winner AS
	(
		SELECT 
			mcby.from_interval,
			mcby.to_interval,
			(
				SELECT ei.candidatename
				FROM electioninfo AS ei 
				WHERE ei.year BETWEEN mcby.from_interval AND mcby.to_interval
				AND ei.candidatevotes = mcby.max
			) AS candidate_most_votes,
			(
				SELECT si.state_name
				FROM electioninfo AS ei 
				JOIN stateinfo AS si ON si.id = ei.stateid
				WHERE ei.year BETWEEN mcby.from_interval AND mcby.to_interval
				AND ei.candidatevotes = mcby.max
			) AS state_of_candidate,
			(
				SELECT p.party_name
				FROM electioninfo AS ei 
				JOIN party AS p on p.id = ei.partyid
				WHERE ei.year BETWEEN mcby.from_interval AND mcby.to_interval
				AND ei.candidatevotes = mcby.max
			) AS candidate_party_most_votes,
			mcby.max
		FROM max_candidatevotes_by_year AS mcby
	),
	max_state_info AS
	(
		SELECT 
			msby.from_interval,
			msby.to_interval,
			(
				SELECT DISTINCT si.state_name
				FROM electioninfo AS ei 
				JOIN stateinfo AS si ON ei.stateid = si.id
				WHERE ei.year BETWEEN msby.from_interval AND msby.to_interval
				AND ei.totalvotes = msby.max
			) AS state_most_votes
		FROM max_statevotes_by_year AS msby
	)
	SELECT
		cw.from_interval,
		cw.to_interval,
		msi.state_most_votes,
		cw.candidate_most_votes,
		cw.candidate_party_most_votes,
		cw.state_of_candidate,
		cw.max AS max_candidate_votes,
		(SELECT ROUND(AVG(candidatevotes),2) FROM electioninfo AS ei
			WHERE ei.year BETWEEN cw.from_interval AND cw.to_interval) AS avg_candidate_votes,
		(SELECT SUM(totalvotes) FROM 
		 	(SELECT DISTINCT totalvotes FROM electioninfo AS ei
				WHERE ei.year BETWEEN cw.from_interval AND cw.to_interval) AS T
		 )  AS total_election_votes,
		(SELECT ROUND(AVG(totalvotes),2) FROM 
		 	(SELECT DISTINCT totalvotes FROM electioninfo AS ei
				WHERE ei.year BETWEEN cw.from_interval AND cw.to_interval) AS T
		 ) AS avg_total_votes,
		 owp.party_with_most_state_wins,
		 owp.count AS party_win_state_count
	FROM max_state_info AS msi
	JOIN candidate_winner AS cw 
		ON msi.from_interval = cw.from_interval AND msi.to_interval = cw.to_interval
	JOIN overall_winning_party AS owp ON owp.from_interval = cw.from_interval AND owp.to_interval = cw.to_interval
	ORDER BY cw.from_interval;