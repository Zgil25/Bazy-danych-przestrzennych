
CREATE TABLE "Final_Raster" AS
SELECT 
	ST_Union(rast) as rast
FROM "Exports";
