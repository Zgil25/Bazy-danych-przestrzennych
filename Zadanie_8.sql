

--1./2.
--"C:\Program Files\PostgreSQL\16\bin\raster2pgsql.exe" -s 27700 -N 0 -t 100x100 -I -C -M *.tif public.uk_250k | "C:\Program Files\PostgreSQL\16\bin\psql.exe" -d "8_Bazy" -U postgres

--3.

CREATE TABLE tmp_out_mosaic AS
SELECT 
    lo_from_bytea(0,
         ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
         ) AS loid
FROM public.uk_250k;


SELECT lo_export(loid, 'C:\Users\Public\uk_mosaic.tif') 
	FROM tmp_out_mosaic;


SELECT lo_unlink(loid) 
	FROM tmp_out_mosaic;
	
DROP TABLE tmp_out_mosaic;

--4./5. 
--Tabela została załadowana do bazy przez QGISA.

--6.

--łączymy park z jego nazwą
CREATE TABLE lake_district_with_name AS
SELECT 
    g.geom,
    n.name1 
FROM 
    national_parks AS g,
    names AS n
WHERE  
    ST_Intersects(g.geom, n.geom) 
    AND 
	n.name1 ILIKE 'Lake District%';

	
CREATE INDEX idx_lake_district_with_name 
	ON 
		public.lake_district_with_name
	USING 
		gist (geom);


--przycinanie rastra do parku
CREATE TABLE uk_lake_district AS
SELECT 
    ST_Clip(uk.rast, park.geom, true) AS rast
FROM 
    uk_250k AS uk, 
    lake_district_with_name AS park
WHERE 
    ST_Intersects(uk.rast, park.geom);

--7.

CREATE TABLE tmp_out_lake AS
SELECT 
    lo_from_bytea(0,
       ST_AsGDALRaster(
           ST_Union(rast),
           'GTiff',
           ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9']
       )
    ) AS loid
FROM 
	public.uk_lake_district;


SELECT lo_export(loid, 'C:\Users\Public\lake_district.tif') 
	FROM tmp_out_lake;

SELECT lo_unlink(loid) 
	FROM tmp_out_lake;

DROP TABLE tmp_out_lake;


--8./9. import B03 i B08

--"C:\Program Files\PostgreSQL\16\bin\raster2pgsql.exe" -s 32630 -N 0 -t 100x100 -I -C -M -d *B03*.jp2 public.sentinel_green | "C:\Program Files\PostgreSQL\16\bin\psql.exe" -d "8_Bazy" -U postgres
--"C:\Program Files\PostgreSQL\16\bin\raster2pgsql.exe" -s 32630 -N 0 -t 100x100 -I -C -M -d *B08*.jp2 public.sentinel_nir | "C:\Program Files\PostgreSQL\16\bin\psql.exe" -d "8_Bazy" -U postgres


--10. indeks NDWI

CREATE TABLE public.lake_district_ndwi AS
	WITH 
		green_mosaic AS (
		    SELECT ST_Union(g.rast) AS rast
		    FROM public.sentinel_green g, public.lake_district_with_name l
		    WHERE ST_Intersects(ST_Transform(l.geom, 32630), g.rast)
		),

		nir_mosaic AS (
		    SELECT ST_Union(n.rast) AS rast
		    FROM public.sentinel_nir n, public.lake_district_with_name l
		    WHERE ST_Intersects(ST_Transform(l.geom, 32630), n.rast)
		)

	SELECT
	    ST_Clip(
	        ST_MapAlgebra(
	            g.rast, 1,
	            n.rast, 1,
	            '([rast1.val] - [rast2.val]) / ([rast1.val] + [rast2.val])::float','32BF'
	        	),
	        ST_Transform(l.geom, 32630),
	        true
	    ) AS rast
	FROM 
	    green_mosaic g, 
	    nir_mosaic n,
	    public.lake_district_with_name l; 


ALTER TABLE public.lake_district_ndwi ADD COLUMN rid SERIAL PRIMARY KEY;


CREATE INDEX idx_lake_district_ndwi ON public.lake_district_ndwi
	USING gist (ST_ConvexHull(rast));


SELECT AddRasterConstraints('public'::name, 'lake_district_ndwi'::name, 'rast'::name);


--11.

CREATE TABLE tmp_out_ndwi AS
SELECT 
    lo_from_bytea(0,
       ST_AsGDALRaster(
           ST_Union(rast), 
           'GTiff', 
           ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9']
       )
    ) AS loid
FROM 
	public.lake_district_ndwi;


SELECT lo_export(loid, 'C:\Users\Public\lake_district_ndwi.tif') 
	FROM tmp_out_ndwi;

SELECT lo_unlink(loid) 
	FROM tmp_out_ndwi;
	
DROP TABLE tmp_out_ndwi;


