-- write here you answer to the percentiles question here
-- 
-- remember, it should one single SQL statement

/*
WITH num_votes_percentiles AS 
	(SELECT 
		unnest(percentile_cont(array[0, 0.25, 0.5, 0.75, 0.95, 0.99]) WITHIN GROUP (ORDER BY r.numvotes)) as perc
		FROM ratings AS r
	 	JOIN productions AS p ON p.id = r.id
		WHERE productiontype = 'movie')
	SELECT * 
	FROM productions AS p
	JOIN ratings AS r ON r.id = p.id
	JOIN num_votes_percentiles AS nvp ON nvp.perc >= r.numvotes
	LIMIT 20;

-- Working, but joining wrong
WITH percentiles AS 
	(SELECT UNNEST(percentile_cont(array[0, 0.25, 0.5, 0.75, 0.95, 0.99])
		WITHIN GROUP (ORDER BY r.numvotes)) AS num_in_perc, UNNEST(array[0,25,50,75,95,99]) AS percentile
	 	FROM ratings AS r)
	SELECT * FROM productions AS p
	JOIN ratings AS r on p.id = r.id
	JOIN percentiles AS perc ON r.numvotes <= perc.num_in_perc;


-- still not quite joining right
WITH percentiles AS 
	(SELECT percentile_cont(array[0, 0.25, 0.5, 0.75, 0.95, 0.99])
		WITHIN GROUP (ORDER BY r.numvotes) AS num_in_perc
	 FROM ratings AS r)
,
	joined AS
	(SELECT 
		p.*, r.*,
		CASE
			WHEN r.numvotes >= perc.num_in_perc[6] THEN 99
			WHEN r.numvotes >= perc.num_in_perc[5] THEN 95
			WHEN r.numvotes >= perc.num_in_perc[4] THEN 75
			WHEN r.numvotes >= perc.num_in_perc[3] THEN 50
			WHEN r.numvotes >= perc.num_in_perc[2] THEN 25
			WHEN r.numvotes >= perc.num_in_perc[1] THEN 0
		END AS percentile 
	FROM productions AS p
	JOIN ratings AS r on p.id = r.id, percentiles AS perc)
	SELECT percentile, COUNT(*) AS count
	FROM joined
	GROUP BY percentile
	ORDER BY percentile;

-- Works, but returns the counts as a row
WITH percentiles AS 
		(SELECT percentile_cont(array[0, 0.25, 0.5, 0.75, 0.95, 0.99])
			WITHIN GROUP (ORDER BY r.numvotes) AS num_in_perc
		 FROM ratings AS r
		JOIN productions AS p on p.id = r.id
		WHERE p.productiontype = 'movie'),
	perc_0 AS
		(SELECT 
			p.*, r.*
		FROM productions AS p
		JOIN ratings AS r on p.id = r.id, percentiles AS perc
		WHERE p.productiontype = 'movie'
		AND r.numvotes >= perc.num_in_perc[1]),
	perc_25 AS
		(SELECT 
			p.*, r.*
		FROM productions AS p
		JOIN ratings AS r on p.id = r.id, percentiles AS perc
		WHERE p.productiontype = 'movie'
		AND r.numvotes >= perc.num_in_perc[2]),
	perc_50 AS
		(SELECT 
			p.*, r.*
		FROM productions AS p
		JOIN ratings AS r on p.id = r.id, percentiles AS perc
		WHERE p.productiontype = 'movie'
		AND r.numvotes >= perc.num_in_perc[3]),
	perc_75 AS
		(SELECT 
			p.*, r.*
		FROM productions AS p
		JOIN ratings AS r on p.id = r.id, percentiles AS perc
		WHERE p.productiontype = 'movie'
		AND r.numvotes >= perc.num_in_perc[4]),
	perc_95 AS
		(SELECT 
			p.*, r.*
		FROM productions AS p
		JOIN ratings AS r on p.id = r.id, percentiles AS perc
		WHERE p.productiontype = 'movie'
		AND r.numvotes >= perc.num_in_perc[5]),
	perc_99 AS
		(SELECT 
			p.*, r.*
		FROM productions AS p
		JOIN ratings AS r on p.id = r.id, percentiles AS perc
		WHERE p.productiontype = 'movie'
		AND r.numvotes >= perc.num_in_perc[6])
	SELECT p0.Count, p25.Count, p50.Count, p75.Count, p95.Count, p99.Count
	FROM 
		(SELECT COUNT(*) AS Count FROM perc_0) as p0,
		(SELECT COUNT(*) AS Count FROM perc_25) as p25,
		(SELECT COUNT(*) AS Count FROM perc_50) as p50,
		(SELECT COUNT(*) AS Count FROM perc_75) as p75,
		(SELECT COUNT(*) AS Count FROM perc_95) as p95,
		(SELECT COUNT(*) AS Count FROM perc_99) as p99;



-- WORKING!!
WITH percentiles AS 
	(SELECT UNNEST(percentile_cont(array[0, 0.25, 0.5, 0.75, 0.95, 0.99])
		WITHIN GROUP (ORDER BY r.numvotes)) AS num_in_perc, UNNEST(array[0,25,50,75,95,99]) AS percentile
	 	FROM ratings AS r
		JOIN productions AS p ON p.id = r.id
		WHERE p.productiontype = 'movie')
	SELECT perc.percentile, 
		(SELECT COUNT(*) FROM productions AS p 
		 JOIN ratings AS r on p.id = r.id
		 WHERE r.numvotes >= perc.num_in_perc
			AND p.productiontype = 'movie')
	FROM percentiles AS perc;

*/
--- COMPLETE!!
WITH movies_w_ratings AS 
		(SELECT * FROM productions AS p 
		 JOIN ratings AS r on p.id = r.id
			AND p.productiontype = 'movie'),
	percentiles AS 
		(SELECT UNNEST(percentile_cont(array[0, 0.25, 0.5, 0.75, 0.95, 0.99])
			WITHIN GROUP (ORDER BY mwr.numvotes)) AS num_in_perc, UNNEST(array[0,25,50,75,95,99]) AS percentile
			FROM movies_w_ratings AS mwr)
	SELECT perc.percentile, 
		(SELECT COUNT(*) 
			 FROM movies_w_ratings as mwr
			 WHERE mwr.numvotes >= perc.num_in_perc) AS count,
		(SELECT MIN(mwr.numvotes)
			 FROM movies_w_ratings AS mwr
			 WHERE mwr.numvotes >= perc.num_in_perc) AS minimumvotes,
		(SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY mwr.numvotes) 
		 	FROM movies_w_ratings AS mwr
			WHERE mwr.numvotes >= perc.num_in_perc) AS medianvotes,
		(SELECT AVG(mwr.numvotes) 
			FROM movies_w_ratings AS mwr
			WHERE mwr.numvotes >= perc.num_in_perc) AS averagevotes,
		(SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY mwr.averagerating) 
		 	FROM movies_w_ratings AS mwr
			WHERE mwr.numvotes >= perc.num_in_perc) AS medianavgratings,
		(SELECT AVG(mwr.averagerating)
		 	FROM movies_w_ratings AS mwr
			WHERE mwr.numvotes >= perc.num_in_perc) AS averagerating,
		(SELECT corr("averagerating", "numvotes") 
		 	FROM movies_w_ratings AS mwr
			WHERE mwr.numvotes >= perc.num_in_perc) AS corr
	FROM percentiles AS perc;
