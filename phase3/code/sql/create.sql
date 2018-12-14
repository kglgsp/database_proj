DROP TABLE IF EXISTS Customer CASCADE;--OK
DROP TABLE IF EXISTS Mechanic CASCADE;--OK
DROP TABLE IF EXISTS Car CASCADE;--OK
DROP TABLE IF EXISTS Owns CASCADE;--OK
DROP TABLE IF EXISTS Service_Request CASCADE;--OK
DROP TABLE IF EXISTS Closed_Request CASCADE;--OK

--CREATE SEQUENCE Mechanicseq START WITH 250;
--CREATE SEQUENCE Customerseq START WITH 500;
--CREATE SEQUENCE ServiceRequestseq START WITH 30001;




-------------
---DOMAINS---
-------------
CREATE DOMAIN us_postal_code AS TEXT CHECK(VALUE ~ '^\d{5}$' OR VALUE ~ '^\d{5}-\d{4}$');
CREATE DOMAIN _STATUS CHAR(1) CHECK (value IN ( 'W' , 'C', 'R' ) );
CREATE DOMAIN _GENDER CHAR(1) CHECK (value IN ( 'F' , 'M' ) );
CREATE DOMAIN _CODE CHAR(2) CHECK (value IN ( 'MJ' , 'MN', 'SV' ) ); --Major, Minimum, Service
CREATE DOMAIN _PINTEGER AS int4 CHECK(VALUE > 0);
CREATE DOMAIN _PZEROINTEGER AS int4 CHECK(VALUE >= 0);
CREATE DOMAIN _YEARS AS int4 CHECK(VALUE >= 0 AND VALUE < 100);
CREATE DOMAIN _YEAR AS int4 CHECK(VALUE >= 1970);

------------
---TABLES---
------------
CREATE TABLE Customer
(
	id INTEGER NOT NULL,
	fname CHAR(32) NOT NULL,
	lname CHAR(32) NOT NULL,
	phone CHAR(13) NOT NULL,
	address CHAR(256) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE Mechanic
(
	id INTEGER NOT NULL,
	fname CHAR(32) NOT NULL,
	lname CHAR(32) NOT NULL,
	experience _YEARS NOT NULL,
	PRIMARY KEY (id) 
);

CREATE TABLE Car
(
	vin VARCHAR(16) NOT NULL,
	make VARCHAR(32) NOT NULL,
	model VARCHAR(32) NOT NULL,
	year _YEAR NOT NULL,
	PRIMARY KEY (vin)
);
---------------
---RELATIONS---
---------------
CREATE TABLE Owns
(
	ownership_id INTEGER NOT NULL,
	customer_id INTEGER NOT NULL,
	car_vin VARCHAR(16) NOT NULL,
	PRIMARY KEY (ownership_id),
	FOREIGN KEY (customer_id) REFERENCES Customer(id),
	FOREIGN KEY (car_vin) REFERENCES Car(vin)
);

CREATE TABLE Service_Request
(
	rid INTEGER NOT NULL,
	customer_id INTEGER NOT NULL,
	car_vin VARCHAR(16) NOT NULL,
	date DATE NOT NULL,
	odometer _PINTEGER NOT NULL,
	complain TEXT,
	PRIMARY KEY (rid),
	FOREIGN KEY (customer_id) REFERENCES Customer(id),
	FOREIGN KEY (car_vin) REFERENCES Car(vin)
);

CREATE TABLE Closed_Request
(
	wid INTEGER NOT NULL,
	rid INTEGER NOT NULL,
	mid INTEGER NOT NULL,
	date DATE NOT NULL,
	comment TEXT,
	bill _PINTEGER NOT NULL,
	PRIMARY KEY (wid),
	FOREIGN KEY (rid) REFERENCES Service_Request(rid),
	FOREIGN KEY (mid) REFERENCES Mechanic(id)
);

----------------------------
-- INSERT DATA STATEMENTS --
----------------------------

COPY Customer (
	id,
	fname,
	lname,
	phone,
	address
)
FROM 'customer.csv'
WITH DELIMITER ',';

COPY Mechanic (
	id,
	fname,
	lname,
	experience
)
FROM 'mechanic.csv'
WITH DELIMITER ',';

COPY Car (
	vin,
	make,
	model,
	year
)
FROM 'car.csv'
WITH DELIMITER ',';

COPY Owns (
	ownership_id,
	customer_id,
	car_vin
)
FROM 'owns.csv'
WITH DELIMITER ',';

COPY Service_Request (
	rid,
	customer_id,
	car_vin,
	date,
	odometer,
	complain
)
FROM 'service_request.csv'
WITH DELIMITER ',';

COPY Closed_Request (
	wid,
	rid,
	mid,
	date,
	comment,
	bill
)
FROM 'closed_request.csv'
WITH DELIMITER ',';


----------------------------
-- CREATE TRIGGER --
----------------------------


DROP SEQUENCE IF EXISTS Mechanicseq;

CREATE SEQUENCE Mechanicseq START WITH 250;

CREATE OR REPLACE FUNCTION func_name()
  RETURNS "trigger" AS
  $BODY$
  BEGIN
   New.id := nextval('Mechanicseq');
   
   RETURN NEW;
  END
  $BODY$
  LANGUAGE plpgsql VOLATILE;
  
CREATE TRIGGER theTrigger
BEFORE INSERT or UPDATE
ON Mechanic
FOR EACH ROW
EXECUTE PROCEDURE func_name();


DROP SEQUENCE IF EXISTS Customerseq;

CREATE SEQUENCE Customerseq START WITH 500;

CREATE OR REPLACE FUNCTION new_customer_id()
  RETURNS "trigger" AS
  $BODY$
  BEGIN
   New.id := nextval('Customerseq');
   
   RETURN NEW;
  END
  $BODY$
  LANGUAGE plpgsql VOLATILE;
  
CREATE TRIGGER KatherineTrigger
BEFORE INSERT or UPDATE
ON Customer
FOR EACH ROW
EXECUTE PROCEDURE new_customer_id();



DROP SEQUENCE IF EXISTS Requestseq;

CREATE SEQUENCE Requestseq START WITH 30001;

CREATE OR REPLACE FUNCTION service_request_func()
  RETURNS "trigger" AS
  $BODY$
  BEGIN
   New.id := nextval('Requestseq');
   
   RETURN NEW;
  END
  $BODY$
  LANGUAGE plpgsql VOLATILE;
  
CREATE TRIGGER KevinTrigger
BEFORE INSERT or UPDATE
ON service_request
FOR EACH ROW
EXECUTE PROCEDURE service_request_func();


