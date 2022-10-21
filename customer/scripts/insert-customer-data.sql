COPY customer(id, customerName, customerAddr, effectiveDate, mktSegment, status)
FROM '/tmp/fake-data.csv'
DELIMITER ','
CSV HEADER;
