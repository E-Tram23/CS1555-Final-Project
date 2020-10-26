--<20>-hw5-db.sql
--Team 20
--Eric Tram ewt6
--Robert Xu rox5
--Joeseph DAlesandro jrd105

--Assumptions


---DROP ALL TABLES TO MAKE SURE THE SCHEMA IS CLEAR
DROP TABLE IF EXISTS AIRLINE CASCADE;
DROP TABLE IF EXISTS FLIGHT CASCADE;
DROP TABLE IF EXISTS PLANE CASCADE;
DROP TABLE IF EXISTS PRICE CASCADE;
DROP TABLE IF EXISTS CUSTOMER CASCADE;
DROP TABLE IF EXISTS RESERVATION CASCADE;
DROP TABLE IF EXISTS RESERVATION_DETAIL CASCADE;
DROP TABLE IF EXISTS OUT_TIME_INFO CASCADE;


---CREATING AIRLINE_INFO TABLE
CREATE TABLE AIRLINE(
airline_id   integer NOT NULL,
airline_name     varchar(50)    NOT NULL,
airline_abbreviation varchar(10)   NOT NULL,
year_founded integer,
CONSTRAINT AIRLINE_PK PRIMARY KEY(airline_id)
);

---CREATING FLIGHT SCHEDULE TABLE
CREATE TABLE FLIGHT(
flight_number integer NOT NULL,
airline_id integer NOT NULL,
plane_type char(4) NOT NULL,
departure_city char(3) NOT NULL,
arrival_city char(3) NOT NULL,
departure_time varchar(4) NOT NULL,
arrival_time varchar(4) NOT NULL,
weekly_schedule varchar(7),
CONSTRAINT FLIGHT_PK PRIMARY KEY(flight_number),
CONSTRAINT FLIGHT_FK FOREIGN KEY(plane_type,airline_id) REFERENCES PLANE(plane_type,owner_id),
CONSTRAINT FLIGHT_FK FOREIGN KEY(airline_id) REFERENCES AIRLINE(airline_id)
);

---CREATING PLANE INFO TABLE
CREATE TABLE PLANE(
plane_type char(4) NOT NULL,
manufacturer varchar(10) NOT NULL,
plane_capacity integer NOT NULL,
last_service date NOT NULL,
year integer NOT NULL,
owner_id integer NOT NULL,
CONSTRAINT PLANE_PK PRIMARY KEY(plane_type,owner_id),
CONSTRAINT PLANE_FK FOREIGN KEY(owner_id) REFERENCES AIRLINE(airline_id)
);

---CREATING FLIGHT PRICING TABLE
CREATE TABLE PRICE(
departure_city char(3) NOT NULL,
arrival_city char(3) NOT NULL,
airline_id   integer NOT NULL,
high_price integer NOT NULL,
low_price integer NOT NULL,
CONSTRAINT PRICE_PK PRIMARY KEY(departure_city,arrival_city),
CONSTRAINT PRICE_FK FOREIGN KEY(airline_id) REFERENCES AIRLINE(airline_id),
CONSTRAINT POSITIVE CHECK (high_price > 0),
CONSTRAINT POSITIVE CHECK (low_price > 0)
);

---CREATING CUSTOMER INFO TABLE
CREATE TABLE CUSTOMER(
cid integer NOT NULL,
salutation varchar(3) NOT NULL,
first_name varchar(30) NOT NULL,
last_name varchar(30) NOT NULL,
credit_card_num varchar(16) NOT NULL,
credit_card_expire date NOT NULL,
street varchar(30) NOT NULL,
city varchar(30) NOT NULL,
state varchar(10) NOT NULL,
phone varchar(10) NOT NULL,
email varchar(30) NOT NULL,
frequent_miles varchar(10) NOT NULL,
CONSTRAINT CUSTOMER_PK PRIMARY KEY(cid),
CONSTRAINT CUSTOMER_FK FOREIGN KEY(frequent_miles) REFERENCES AIRLINE(airline_abbreviation)
);


---CREATING RESERVATION INFO TABLE
CREATE TABLE RESERVATION(
reservation_number integer NOT NULL,
cid integer NOT NULL,
cost decimal NOT NULL,
credit_card_num varchar(16) NOT NULL,
reservation_date timestamp NOT NULL,
ticketed boolean NOT NULL,
CONSTRAINT RESERVATION_PK PRIMARY KEY(reservation_number),
CONSTRAINT RESERVATION_FK FOREIGN KEY(cid) REFERENCES CUSTOMER(cid),
CONSTRAINT RESERVATION_FK FOREIGN KEY(credit_card_num) REFERENCES CUSTOMER(credit_card_num),
CONSTRAINT POSITIVE CHECK (cost > 0)
);

---CREATING RESERVATION DETAIL TABLE

CREATE TABLE RESERVATION_DETAIL(
reservation_number integer NOT NULL,
flight_number integer NOT NULL,
flight_date timestamp NOT NULL,
leg integer NOT NULL,
CONSTRAINT RESERVATION_DETAIL_PK PRIMARY KEY(reservation_number, leg),
CONSTRAINT RESERVATION_DETAIL_FK FOREIGN KEY(reservation_number) REFERENCES RESERVATION(reservation_number),
CONSTRAINT RESERVATION_DETAIL_FK FOREIGN KEY(flight_number) REFERENCES FLIGHT(flight_number)
);

--AUXILLARY TABLE
---CREATING OUR TIME INFO TABLE

CREATE TABLE OURTIMESTAMP(
    c_timestamp timestamp,
    CONSTRAINT OURTIMESTAMP_PK PRIMARY KEY(c_timestamp)
);
