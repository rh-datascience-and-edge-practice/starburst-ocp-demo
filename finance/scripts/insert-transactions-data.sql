COPY transactions(id, customerId, transDate, amount)
FROM '/tmp/fake-data.csv'
DELIMITER ','
CSV HEADER;
