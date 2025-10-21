--Utworzenie tabel
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(POLYGON),
    name VARCHAR(50)
);

CREATE TABLE roads (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(LINESTRING),
    name VARCHAR(50)
);

CREATE TABLE poi (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(POINT),
    name VARCHAR(50)
);

--Wprowadzenie wartości do tabel

INSERT INTO 
	buildings (geometry, name) 
VALUES
	(ST_GeomFromText('POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))'), 'BuildingA'),
	(ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))'), 'BuildingB'),
	(ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))'), 'BuildingC'),
	(ST_GeomFromText('POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))'), 'BuildingD'),
	(ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 'BuildingF');


INSERT INTO 
	roads (geometry, name) 
VALUES
	(ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'), 'RoadX'),
	(ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'), 'RoadY');


INSERT INTO 
	poi (geometry, name) 
VALUES
	(ST_GeomFromText('POINT(1 3.5)'), 'G'),
	(ST_GeomFromText('POINT(5.5 1.5)'), 'H'),
	(ST_GeomFromText('POINT(9.5 6)'), 'I'),
	(ST_GeomFromText('POINT(6 9.5)'), 'K');







--Całkowita długość dróg
SELECT SUM (ST_Length(geometry)) AS calkowita_dlugosc_drog
FROM roads;




--Geometria(WKT),pole powierzchni oraz obwód poligonu "BuildingA"
SELECT ST_AsText(geometry) AS geometria_WKT, ST_Area(geometry) AS pole_powierzchni, ST_Perimeter(geometry) AS obwod
FROM buildings
WHERE name = 'BuildingA';



--Nazwy i pola powierzchni wszystkich budynków (posortowane alfabetycznie)
SELECT name, ST_Area(geometry) AS pole_powierzchni
FROM buildings
ORDER BY name;





--Nazwy i obwody 2 budynków o największej powierzchni
SELECT name, ST_Perimeter(geometry) AS obwod
FROM buildings
ORDER BY ST_Area(geometry) DESC
LIMIT 2;




--Najkrótsza odległość między budynkiem "BuildingC" a punktem K
SELECT ST_Distance(b.geometry, p.geometry) AS najkrotsza_odleglosc
FROM buildings AS b, poi AS p
WHERE b.name = 'BuildingC' AND p.name = 'K';




--Pole powierzchni tej części budynku "BuildingC", która znajduje się w odległości większej niż 0.5 od budynku "BuildingB"
SELECT ST_Area(ST_Difference(  -- Budynek C - BudynekB + 0.5
	(SELECT geometry FROM buildings WHERE name = 'BuildingC'),
	(SELECT ST_Buffer(geometry, 0.5) FROM buildings WHERE name = 'BuildingB'))
) AS pole_powierzchni;




--Budynki, których centroid znajduje sie powyżej drogi "RoadX"
SELECT name
FROM buildings
WHERE ST_Y(ST_Centroid(geometry)) > (
	SELECT ST_Y(ST_StartPoint(geometry))
    FROM roads
    WHERE name = 'RoadX');




--Pole powierzchni tych częsci budynku "BuildingC" i poligonu o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch obiektów

--1 sposób
SELECT ST_Area( 
    ST_SymDifference( 
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))') 
    )
) AS pole_roznicy_sym;


--2 sposób
SELECT ST_Area(ST_Difference(
	ST_Union(
            (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
            ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')
        	),
    ST_Intersection(
		(SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')
    		)
)) AS pole_roznicy;




--3 sposób
SELECT 
    ST_Area(ST_Difference(
            (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
            ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')
        	)
    ) 
	+
    ST_Area(ST_Difference(
            ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'),
            (SELECT geometry FROM buildings WHERE name = 'BuildingC')
        	)
    )  AS pole;

