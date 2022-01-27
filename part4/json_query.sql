-- your answer to the JSON query goes here

-- Working, turned back into a json and ordered by year
WITH 
	winners AS 
		(SELECT 
		 	tuple->>'category' AS category, 
		 	tuple->>'year' AS year,
		 	json_array_elements(tuple->'laureates') AS persons
		FROM prizes
		WHERE tuple->>'laureates' IS NOT NULL),
	relational AS 
		(SELECT 
		 	category, year, 
		 	persons->>'firstname' AS firstname, 
		 	CASE 
		 		WHEN persons::jsonb ? 'surname' THEN persons->>'surname'
		 		ELSE NULL
		 	END AS surname 
		FROM winners AS w),
	multi_winners AS 
		(SELECT firstname, surname, COUNT(*)
		FROM relational
		GROUP BY firstname, surname
		HAVING COUNT(*) > 1),
	json_awards AS
		(SELECT 
			r.firstname, r.surname,
			(SELECT row_to_json(_) FROM (SELECT year, category) AS _) AS awards
		FROM relational AS r
		JOIN multi_winners AS mw
		ON (mw.firstname = r.firstname and (mw.surname IS NULL OR mw.surname = r.surname))
	 	WHERE mw.surname IS NOT NULL
		ORDER BY firstname, year)
	SELECT 
		(SELECT row_to_json(_) FROM (SELECT firstname, surname, json_agg(awards) AS awards) AS _) AS r 
	FROM json_awards
	GROUP BY firstname, surname;