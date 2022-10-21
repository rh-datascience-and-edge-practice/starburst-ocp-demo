
CREATE TABLE IF NOT EXISTS customer (
	id 		INTEGER NOT NULL PRIMARY KEY,
	customerName	VARCHAR(255) NOT NULL,
	customerAddr	VARCHAR(255) NOT NULL,
	effectiveDate	DATE,
	mktSegment	INTEGER,
	status		INTEGER NOT NULL );
