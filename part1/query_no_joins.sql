-- write here you answer. Do not use joins or cross-products

WITH directors AS 
	(SELECT c.id, c.pid FROM crew AS c
	 WHERE crewtype = 'director'),
 main_roles AS 
	 (SELECT r.id, r.pid FROM roles AS r 
	  WHERE roletype = 'actor' OR roletype = 'actress')
 SELECT count(*) FROM main_roles AS mr
 WHERE EXISTS 
 	(SELECT id, pid FROM directors AS d
		WHERE d.pid = mr.pid AND d.id = mr.id
	);