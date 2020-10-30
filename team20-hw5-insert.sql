--<20>-hw5-insert.sql

--Team 20
--Eric Tram ewt6
--Robert Xu rox5
--Joeseph DAlesandro jrd105


--INSERT FOR TEST DATA
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded) VALUES(1, 'Alaska Airlines', 'ASA', 1932);
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded) VALUES(2, 'Allegiant Airlines', 'AAY', 1997);
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded) VALUES(3, 'American Airlines', 'AAL', 1926);
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded) VALUES(4, 'Delta Airlines', 'DAL', 1924);
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded) VALUES(5, 'United Airlines', 'UAL', 1926);

INSERT INTO PLANE(plane_type, manufacturer, plane_capacity, last_service, year, owner_id) VALUES('A320', 'Airbus',186,TO_DATE('11-03-2020','MM-DD-YYYY'),1988,1);
INSERT INTO PLANE(plane_type, manufacturer, plane_capacity, last_service, year, owner_id) VALUES('E175', 'Emraer',76,TO_DATE('10-22-2020','MM-DD-YYYY'),2004,2);
INSERT INTO PLANE(plane_type, manufacturer, plane_capacity, last_service, year, owner_id) VALUES('B737', 'Boeing',125,TO_DATE('09-09-2020','MM-DD-YYYY'),2006,3);
INSERT INTO PLANE(plane_type, manufacturer, plane_capacity, last_service, year, owner_id) VALUES('E145', 'Embraer',50,TO_DATE('06-15-2020','MM-DD-YYYY'),2018,4);
INSERT INTO PLANE(plane_type, manufacturer, plane_capacity, last_service, year, owner_id) VALUES('B777', 'Boeing',368,TO_DATE('09-16-2020','MM-DD-YYYY'),1995,5);
INSERT INTO PLANE(plane_type, manufacturer, plane_capacity, last_service, year, owner_id) VALUES('SMAL', 'Boeing',20,TO_DATE('09-16-2020','MM-DD-YYYY'),1995,3);

INSERT INTO FLIGHT(FLIGHT_NUMBER, AIRLINE_ID, PLANE_TYPE, DEPARTURE_CITY, ARRIVAL_CITY, DEPARTURE_TIME, ARRIVAL_TIME, WEEKLY_SCHEDULE) VALUES(1,1,'A320','PIT','JFK','1355','1730','SMTWTFS');
INSERT INTO FLIGHT(FLIGHT_NUMBER, AIRLINE_ID, PLANE_TYPE, DEPARTURE_CITY, ARRIVAL_CITY, DEPARTURE_TIME, ARRIVAL_TIME, WEEKLY_SCHEDULE) VALUES(2,2,'E175','JFK','LAX','0825','1845','-MTWTFS');
INSERT INTO FLIGHT(FLIGHT_NUMBER, AIRLINE_ID, PLANE_TYPE, DEPARTURE_CITY, ARRIVAL_CITY, DEPARTURE_TIME, ARRIVAL_TIME, WEEKLY_SCHEDULE) VALUES(3,3,'B737','PIT','JFK','1355','1730','SMT-TFS');
INSERT INTO FLIGHT(FLIGHT_NUMBER, AIRLINE_ID, PLANE_TYPE, DEPARTURE_CITY, ARRIVAL_CITY, DEPARTURE_TIME, ARRIVAL_TIME, WEEKLY_SCHEDULE) VALUES(4,4,'E145','SEA','IAH','1OO5','2035','SMTW--S');
INSERT INTO FLIGHT(FLIGHT_NUMBER, AIRLINE_ID, PLANE_TYPE, DEPARTURE_CITY, ARRIVAL_CITY, DEPARTURE_TIME, ARRIVAL_TIME, WEEKLY_SCHEDULE) VALUES(5,5,'B777','IAH','PIT','0630','1620','-MTW--S');

INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('PIT','JFK',1,300,165);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('JFK','LAX',2,480,345);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('LAX','SEA',3,380,270);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('SEA','IAH',4,515,365);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('IAH','PIT',5,435,255);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('JFK','PIT',1,440,315);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('LAX','PIT',2,605,420);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('SEA','LAX',3,245,150);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('IAH','SEA',4,395,260);
INSERT INTO PRICE(departure_city, arrival_city, airline_id, high_price, low_price) VALUES('PIT','IAH',5,505,350);

INSERT INTO CUSTOMER(cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state, phone, email, frequent_miles) VALUES(1,'Mr','Jon','Smith','6859941825383380',TO_DATE('04-13-2022','MM-DD-YYYY'),'Bigelow Boulevard','Pittsburgh','PA','412222222','jsmith@gmail.com','ASA');
INSERT INTO CUSTOMER(cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state, phone, email, frequent_miles) VALUES(2,'Mrs','Latanya','Wood','7212080255339668',TO_DATE('07-05-2023','MM-DD-YYYY'),'Houston Street','New York','NY','7187181717','lw@aol.com','AAY');
INSERT INTO CUSTOMER(cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state, phone, email, frequent_miles) VALUES(3,'Ms','Gabriella','Rojas','4120892825130802',TO_DATE('09-22-2024','MM-DD-YYYY'),'Melrose Avenue','Los Angelas','CA','2133234567','gar@yahoo.com','AAL');
INSERT INTO CUSTOMER(cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state, phone, email, frequent_miles) VALUES(4,'Mr','Abbas','Malouf','4259758505178751 ',TO_DATE('10-17-2021','MM-DD-YYYY'),'Pine Street','Seattle','WA','2066170345','malouf.a@outlook.com ','DAL');
INSERT INTO CUSTOMER(cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state, phone, email, frequent_miles) VALUES(5,'Ms','Amy','Liu','2538244543760285',TO_DATE('03-24-2022','MM-DD-YYYY'),'HAmber Drive','Houston','TX','2818880102','amyliu45@icloud.com ','UAL');

INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(1,1,1160,'6859941825383380','11-02-2020 19:45:25.000000',TRUE);
INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(2,2,620,'7212080255339668','11-22-2020 20:00:30.000000',TRUE);
INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(3,3,380,'4120892825130802','11-05-2020 09:30:05.000000',FALSE);
INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(4,4,255,'4259758505178751','12-01-2020 13:15:10.000000',TRUE);
INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(5,5,615,'2538244543760285','10-28-2020 15:50:15.000000',FALSE);

INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(1,1,'11-02-2020',1);
INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(1,2,'11-04-2020',2);
INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(1,3,'11-05-2020',3);
INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(2,4,'12-14-2020',1);
INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(2,5,'12-15-2020',2);
INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(3,3,'11-05-2020',1);
INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(4,5,'12-15-2020',1);
INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(5,2,'11-04-2020',1);
INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES(5,3,'11-05-2020',2);
