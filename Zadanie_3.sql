
--1. Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana pomiędzy 2018 a 2019).

SELECT t19.*
FROM t2019_kar_buildings AS t19
LEFT JOIN t2018_kar_buildings AS t18 ON ST_Equals(t19.geom,t18.geom)
WHERE t18.geom IS NULL



--select *
--from t2019_kar_buildings





--2. Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.

WITH
	budynki_nowe AS (
		SELECT t19.*
		FROM t2019_kar_buildings AS t19
		LEFT JOIN t2018_kar_buildings AS t18 ON ST_Equals(t19.geom,t18.geom)
		WHERE t18.geom IS NULL),

	nowe_punkty AS (
		SELECT t19.*
		FROM t2019_kar_poi_table AS t19
		LEFT JOIN t2018_kar_poi_table AS t18 ON ST_Equals(t19.geom,t18.geom)
		WHERE t18.geom IS NULL)

SELECT p.type, COUNT(DISTINCT p.poi_id) AS ilosc 
FROM nowe_punkty AS p, budynki_nowe AS b
WHERE ST_DWithin(p.geom::geography, b.geom::geography, 500)
GROUP BY p.type;



--sprawdzenie
SELECT p.type, COUNT(DISTINCT p.poi_id) AS ilosc 
FROM nowe_punkty AS p, budynki_nowe AS b
WHERE ST_DWithin(ST_Transform(p.geom, 3068), ST_Transform(b.geom, 3068),500)
GROUP BY p.type;








--3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.

CREATE TABLE streets_reprojected AS
	SELECT *, ST_Transform(geom, 3068) AS geom_new
	FROM t2019_kar_streets;






--4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.

CREATE TABLE input_points (
    id SERIAL PRIMARY KEY,
    geom GEOMETRY(POINT, 4326)
);


INSERT INTO input_points(geom)
VALUES
	(ST_GeomFromText('POINT(8.36093 49.03174)', 4326)),
	(ST_GeomFromText('POINT(8.39876 49.00644)', 4326));





--5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych DHDN.Berlin/Cassini.

ALTER TABLE input_points
ALTER COLUMN geom TYPE GEOMETRY(POINT, 3068)
USING ST_Transform(geom, 3068);

--select ST_Srid(geom)
--from input_points








--6. Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj reprojekcji geometrii, aby była zgodna z resztą tabel.

WITH 
	linia AS (
		SELECT ST_MakeLine(geom) AS geom_lini
		FROM input_points
		)
		
SELECT s.*
FROM t2019_kar_street_node AS s, linia AS l
WHERE ST_DWithin( ST_Transform(s.geom, 3068),l.geom_lini,200);






--7. Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się w odległości 300 m od parków (LAND_USE_A).

--bez zmiany ukladu
SELECT COUNT(DISTINCT poi.poi_id) AS ilosc
FROM t2019_kar_poi_table AS poi, t2019_kar_land_use_a AS use 
WHERE poi.type = 'Sporting Goods Store' AND use.type like '%Park %'
AND ST_DWithin( poi.geom::geography,use.geom::geography,300); 




--sprawdzam bo jednostką układu DHDN.Berlin/Cassini są metry.
SELECT COUNT(DISTINCT poi.poi_id) AS ilosc
FROM t2019_kar_poi_table AS poi, t2019_kar_land_use_a AS use 
WHERE poi.type = 'Sporting Goods Store' AND use.type like '%Park %'
AND ST_DWithin( ST_Transform(poi.geom, 3068), ST_Transform(use.geom, 3068),300);







  
--8. Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.


CREATE TABLE T2019_KAR_BRIDGES AS
	SELECT ST_Intersection(r.geom,w.geom) AS punkty_przeciecia
	FROM t2019_kar_railways AS r, t2019_kar_water_lines AS w
	WHERE ST_Intersects(r.geom, w.geom);
	
