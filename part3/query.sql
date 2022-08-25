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
