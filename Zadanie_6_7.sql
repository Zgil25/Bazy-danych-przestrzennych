-- ładowanie rastra(dem) do pliku sql
-- "C:\Program Files\PostgreSQL\16\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 100x100 -I -C -M -d srtm_1arc_v3.tif rasters.dem > dem.sql

-- ładowanie rastra(landsat) do pliku sql
-- "C:\Program Files\PostgreSQL\16\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 128x128 -I -C -M -d Landsat8_L1TP_RGBN.tif rasters.landsat8 > landsat.sql

-------Tworzenie rastrów z istniejących rastrów i interakcja z wektorami-------

---Przykład 1 - ST_Intersects  Przecięcie rastra z wektorem
CREATE TABLE schema_gil.intersects AS
	SELECT 
		a.rast, 
		b.municipality
	FROM 
		rasters.dem AS a, 
		vectors.porto_parishes AS b
	WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

select * 
from schema_gil.intersects

--W przypadku tworzenia tabel zawierających dane rastrowe sugeruje się wykonanie poniższych kroków: 
--1. dodanie serial primary key:
alter table schema_gil.intersects
add column 
	rid SERIAL PRIMARY KEY;

--2. utworzenie indeksu przestrzennego:
CREATE INDEX idx_intersects_rast_gist ON schema_gil.intersects
USING gist (ST_ConvexHull(rast));

--3. dodanie raster constraints:
-- schema::name table_name::name raster_column::name
SELECT 
	AddRasterConstraints('schema_gil'::name, 'intersects'::name,'rast'::name); 



---Przykład 2 - ST_Clip Obcinanie rastra na podstawie wektora
CREATE TABLE schema_gil.clip AS
	SELECT 
		ST_Clip(a.rast, b.geom, true), 
		b.municipality
	FROM 
	rasters.dem AS a, 
	vectors.porto_parishes AS b
	WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

---Przykład 3 - ST_Union Połączenie wielu kafelków w jeden raster.
CREATE TABLE schema_gil.union AS
	SELECT 
		ST_Union(ST_Clip(a.rast, b.geom, true))
	FROM 
		rasters.dem AS a, 
		vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);


-------Tworzenie rastrów z wektorów (rastrowanie) -------

---Przykład 1 - ST_AsRaster
CREATE TABLE schema_gil.porto_parishes AS
	WITH r AS (
		SELECT rast FROM rasters.dem
		LIMIT 1
	)
	SELECT 
		ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
	FROM 
		vectors.porto_parishes AS a, 
		r
	WHERE a.municipality ilike 'porto';


---Przykład 2 - ST_Union
DROP TABLE schema_gil.porto_parishes; --> drop table porto_parishes first

CREATE TABLE schema_gil.porto_parishes AS
	WITH r AS (
		SELECT rast FROM rasters.dem
		LIMIT 1
	)
	SELECT 
		st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
	FROM 
		vectors.porto_parishes AS a, 
		r
	WHERE a.municipality ilike 'porto';

---Przykład 3 - ST_Tile
DROP TABLE schema_gil.porto_parishes; --> drop table porto_parishes first

CREATE TABLE schema_gil.porto_parishes AS
	WITH r AS (
		SELECT 
			rast FROM rasters.dem
		LIMIT 1 
	)
	SELECT 
		st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)),128,128,true,-32767) AS rast
	FROM 
		vectors.porto_parishes AS a, 
		r
	WHERE a.municipality ilike 'porto';


-------Konwertowanie rastrów na wektory (wektoryzowanie) -------

---Przykład 1 - ST_Intersection
create table schema_gil.intersection as
	SELECT
		a.rid,
		(ST_Intersection(b.geom,a.rast)).geom,
		(ST_Intersection(b.geom,a.rast)).val
	FROM 
		rasters.landsat8 AS a, 
		vectors.porto_parishes AS b
	WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

---Przykład 2 - ST_DumpAsPolygons
CREATE TABLE schema_gil.dumppolygons AS
	SELECT
		a.rid,
		(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,
		(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
	FROM 
		rasters.landsat8 AS a, 
		vectors.porto_parishes AS b
	WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);


-------Analiza rastrów-------

---Przykład 1 - ST_Band  Funkcja ST_Band służy do wyodrębniania pasm z rastra
CREATE TABLE schema_gil.landsat_nir AS
	SELECT 
		rid, 
		ST_Band(rast,4) AS rast
	FROM rasters.landsat8;

---Przykład 2 - ST_Clip  ST_Clip może być użyty do wycięcia rastra z innego rastra.
CREATE TABLE schema_gil.paranhos_dem AS
	SELECT 
		a.rid,ST_Clip(a.rast, b.geom,true) as rast
	FROM 
		rasters.dem AS a, 
		vectors.porto_parishes AS b
	WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

---Przykład 3 - ST_Slope
CREATE TABLE schema_gil.paranhos_slope AS
	SELECT 
		a.rid,
		ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
	FROM schema_gil.paranhos_dem AS a;

---Przykład 4 - ST_Reclass
CREATE TABLE schema_gil.paranhos_slope_reclass AS
	SELECT 
		a.rid,
		ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3','32BF',0)
	FROM schema_gil.paranhos_slope AS a;

---Przykład 5 - ST_SummaryStats
SELECT 
	st_summarystats(a.rast) AS stats
FROM 
	schema_gil.paranhos_dem AS a;


---Przykład 6 - ST_SummaryStats oraz Union
SELECT 
	st_summarystats(ST_Union(a.rast))
FROM 
	schema_gil.paranhos_dem AS a;

---Przykład 7 - ST_SummaryStats z lepszą kontrolą złożonego typu danych
WITH t AS (
SELECT 
	st_summarystats(ST_Union(a.rast)) AS stats
FROM 
	schema_gil.paranhos_dem AS a
)
SELECT 
	(stats).min,
	(stats).max,
	(stats).mean FROM t;

---Przykład 8 - ST_SummaryStats w połączeniu z GROUP BY
WITH t AS (
	SELECT 
		b.parish AS parish, 
		st_summarystats(ST_Union(ST_Clip(a.rast,b.geom,true))) AS stats
	FROM 
		rasters.dem AS a, 
		vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	group by b.parish
)
SELECT 
	parish,
	(stats).min,
	(stats).max,
	(stats).mean FROM t;


---Przykład 9 - ST_Value
SELECT 
	b.name,
	st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
	rasters.dem a, 
	vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

---Przykład 10 - ST_TPI
create table schema_gil.tpi30 as
select 
	ST_TPI(a.rast,1) as rast
from 
	rasters.dem a;
--Poniższa kwerenda utworzy indeks przestrzenny:
CREATE INDEX idx_tpi30_rast_gist ON schema_gil.tpi30
USING gist (ST_ConvexHull(rast));
--Dodanie constraintów:
SELECT 
	AddRasterConstraints('schema_gil'::name,'tpi30'::name,'rast'::name);


-----PROBLEM DO SAMODZIELEGO ROZWIAZANIA-----
create table schema_gil.tpi30_porto as
	SELECT 
		ST_TPI(a.rast,1) as rast
	FROM 
		rasters.dem AS a, 
		vectors.porto_parishes AS b
	WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';
	
CREATE INDEX idx_tpi30_porto_rast_gist ON schema_gil.tpi30_porto
USING gist (ST_ConvexHull(rast));


SELECT AddRasterConstraints('schema_gil'::name,'tpi30_porto'::name,'rast'::name);


-------Algebra map-------

---Przykład 1 - Wyrażenie Algebry Map
CREATE TABLE schema_gil.porto_ndvi AS
	WITH r AS (
		SELECT 
			a.rid,
			ST_Clip(a.rast, b.geom,true) AS rast
		FROM 
			rasters.landsat8 AS a, 
			vectors.porto_parishes AS b
		WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	)
SELECT
	r.rid,
	ST_MapAlgebra(
		r.rast, 1,
		r.rast, 4,
		'([rast2.val] - [rast1.val]) / ([rast2.val] +
		[rast1.val])::float','32BF'
		) AS rast
FROM r;
--Poniższe zapytanie utworzy indeks przestrzenny na wcześniej stworzonej tabeli:
CREATE INDEX idx_porto_ndvi_rast_gist ON schema_gil.porto_ndvi
USING gist (ST_ConvexHull(rast));
--Dodanie constraintów:
SELECT 
	AddRasterConstraints('schema_gil'::name, 'porto_ndvi'::name,'rast'::name);


---Przykład 2 – Funkcja zwrotna
create or replace function schema_gil.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
		--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
	RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;
--W kwerendzie algebry map należy można wywołać zdefiniowaną wcześniej funkcję:
CREATE TABLE schema_gil.porto_ndvi2 AS
	WITH r AS (
		SELECT 
			a.rid,
			ST_Clip(a.rast, b.geom,true) AS rast
		FROM 
			rasters.landsat8 AS a, 
			vectors.porto_parishes AS b
		WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	)
SELECT
	r.rid,
	ST_MapAlgebra(
		r.rast, ARRAY[1,4],
		'schema_gil.ndvi(double precision[],
		integer[],text[])'::regprocedure, --> This is the function!
		'32BF'::text
		) AS rast
FROM r;
--Dodanie indeksu przestrzennego:
CREATE INDEX idx_porto_ndvi2_rast_gist ON schema_gil.porto_ndvi2
USING gist (ST_ConvexHull(rast));
--Dodanie constraintów:
SELECT 
	AddRasterConstraints('schema_gil'::name,'porto_ndvi2'::name,'rast'::name);


---Przykład 3 - Funkcje TPI

-------Eksport danych-------

---Przykład 1 - ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast))
FROM schema_gil.porto_ndvi;

---Przykład 2 - ST_AsGDALRaster
SELECT 
	ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE','PREDICTOR=2', 'PZLEVEL=9'])
FROM schema_gil.porto_ndvi;
--Aby wyświetlić listę formatów obsługiwanych przez bibliotekę uruchom:
	SELECT ST_GDALDrivers();


--!!!!!-Przykład 3 - Zapisywanie danych na dysku za pomocą dużego obiektu (large object, lo)
CREATE TABLE tmp_out AS
	SELECT 
		lo_from_bytea(0,
			 ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
			'PREDICTOR=2', 'PZLEVEL=9'])
			 ) AS loid
FROM schema_gil.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'G:\myraster.tiff') --> Save the file in a place where the user postgres have access. In windows a flash drive usualy works fine.
 FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
 FROM tmp_out; --> Delete the large object.

---Przykład 4 - Użycie Gdal
--gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9
--PG:"host=localhost port=5432 dbname=postgis_raster user=postgres
--password=postgis schema=schema_name table=porto_ndvi mode=2"
--porto_ndvi.tiff

