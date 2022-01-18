-- write here you answer. Use joins or cross-products


SELECT COUNT(*) FROM crew AS c
	JOIN roles AS r ON c.pid = r.pid AND c.id = r.id 
	WHERE c.crewtype = 'director'
	AND (r.roletype = 'actor' OR r.roletype = 'actress');