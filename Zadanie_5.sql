
--Utworzenie tabeli obiekty
CREATE TABLE obiekty (
    id SERIAL PRIMARY KEY,
	name VARCHAR(50),
    geom GEOMETRY
);



--Obiekt 1
INSERT INTO obiekty (name, geom) VALUES
(
  'obiekt1',
  ST_GeomFromEWKT(
    'COMPOUNDCURVE(
        (0 1, 1 1),                        
        CIRCULARSTRING(1 1, 2 0, 3 1),     
        CIRCULARSTRING(3 1, 4 2, 5 1),    
        (5 1, 6 1)                       
    )'
  )
);




--Obiekt2
INSERT INTO obiekty (name, geom) VALUES
(
  'obiekt2',
  ST_GeomFromEWKT(
    'CURVEPOLYGON(
		COMPOUNDCURVE(
	        (10 6, 14 6),                       
	        CIRCULARSTRING(14 6, 16 4, 14 2),     
	        CIRCULARSTRING(14 2, 12 0, 10 2),    
	        (10 2, 10 6)  
		),

		CIRCULARSTRING(11 2, 12 3, 13 2, 12 1, 11 2)
	
    )'
  )
);



--Obiekt 3
INSERT INTO obiekty (name, geom) VALUES
(
  'obiekt3',
  ST_GeomFromEWKT(
    'POLYGON(                    
		(7 15, 10 17, 12 13, 7 15)

    )'
  )
);


/*INSERT INTO obiekty (name, geom) VALUES
(
  'obiekt4',
  ST_GeomFromEWKT(
    'COMPOUNDCURVE(
        (20 20, 25 25),   
        (25 25, 27 24),
		(27 24, 25 22),
		(25 22, 26 21),
		(26 21, 22 19),
		(22 19, 20.5 19.5)
    )'
  )
);
*/


--Obiekt 4
INSERT INTO obiekty (name, geom) VALUES
(
  'obiekt4',
  ST_GeomFromEWKT(
    'LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)'
  )
);




--Obiekt 5
INSERT INTO obiekty (name, geom) VALUES
(
  'obiekt5',
  ST_GeomFromEWKT(
  	'MULTIPOINT (
  		(30 30 59), 
	  	(38 32 234)
	  )'
  )
);




--Obiekt 6
INSERT INTO obiekty (name, geom) VALUES
(
  'obiekt6',
  ST_GeomFromEWKT(
    'GEOMETRYCOLLECTION(
        LINESTRING(1 1, 3 2),                        
        POINT(4 2)          
    )'
  )
);


--2. Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej obiekt 3 i 4

SELECT 
	ST_Area(
		ST_Buffer(
			ST_ShortestLine(
				(SELECT geom FROM obiekty WHERE name = 'obiekt3'),
	            (SELECT geom FROM obiekty WHERE name = 'obiekt4')
			),
	        5
	    )
) AS pole_bufora;




--3. Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te warunki.
 --geometria musi być zamknieta (musimy dodac punkt koncowy do geometri (ktory jest punktem startu aby ją zamknąć))

UPDATE obiekty
SET geom = ST_MakePolygon(
			ST_AddPoint(
				geom,
				ST_StartPoint(geom)
			)
		   )
WHERE name = 'obiekt4'


--4. W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.

INSERT INTO obiekty (name, geom)
SELECT
  'obiekt7',     
  ST_Collect(geom)   
FROM obiekty
WHERE name IN ('obiekt3', 'obiekt4');


--5. Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów nie zawierających łuków

SELECT 
	SUM(ST_Area(ST_Buffer(geom, 5)))  AS pole_bufora
FROM obiekty
WHERE NOT ST_HasArc(geom);




