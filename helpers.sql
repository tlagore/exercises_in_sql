-- Finds specificity for a value that is not in the 
-- MCF's list in pg_stats

-- sum most common frequencies for table/attr
-- count distinct values of table/attr
-- count values of most common frequencies
-- calculate specificity
WITH mcfs AS 
	(SELECT UNNEST(most_common_freqs::text::float[]) as mcfs
	FROM pg_stats WHERE tablename = 'productions' AND attname = 'year'),
mcf_sum AS
	(SELECT SUM(mcfs.mcfs) AS sum
	FROM mcfs),
mcfs_count AS 
	(SELECT ARRAY_LENGTH(most_common_freqs::text::float[], 1) as lngth
	FROM pg_stats WHERE tablename = 'productions' AND attname = 'year'),
distinct_vals AS
	(SELECT DISTINCT year FROM productions),
distinct_sum AS
	(SELECT count(*) as distinct_sum FROM distinct_vals)
SELECT (1-mcf_sum.sum) / (distinct_sum.distinct_sum - mcfs_count.lngth) AS specificity
-- mcf_sum.sum, distinct_sum.distinct_sum, mcfs_count.lngth
FROM mcf_sum, distinct_sum, mcfs_count;