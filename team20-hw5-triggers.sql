--<20>-hw5-triggers.sql

--Team 20
--Eric Tram ewt6
--Robert Xu rox5
--Joeseph DAlesandro jrd105

--Task 5 planeUpgrade

CREATE OR REPLACE FUNCTION planeUpgradeFunc() RETURNS trigger AS
$$
DECLARE
    capacity_order bigint;
BEGIN
    IF (TG_OP = 'INSERT') THEN

        SELECT row_number INTO capacity_order FROM
            (SELECT plane_type, plane_capacity, row_number() over (ORDER BY plane_capacity DESC) AS row_number
            FROM PLANE
            RIGHT JOIN
            (SELECT airline_id FROM FLIGHT WHERE FLIGHT.flight_number = NEW.flight_number) AS A
            ON owner_id = A.airline_id)
        AS O
        RIGHT JOIN FLIGHT
        ON FLIGHT.plane_type = O.plane_type
        WHERE FLIGHT.flight_number = NEW.flight_number;

        --raise notice / rollback
        IF capacity_order = 1 THEN
            RAISE EXCEPTION 'ERROR: There is no available plane under this airline with a higher capacity.';
        ELSE

            UPDATE FLIGHT
            SET plane_type =
                (SELECT plane_type FROM
                    (SELECT plane_type, plane_capacity, row_number() over (ORDER BY plane_capacity DESC) AS row_number
                    FROM PLANE
                    RIGHT JOIN
                    (SELECT airline_id FROM FLIGHT WHERE FLIGHT.flight_number = NEW.flight_number) AS A
                    ON owner_id = A.airline_id) AS O
                WHERE O.row_number = capacity_order - 1)
            WHERE FLIGHT.flight_number = NEW.flight_number;

        END IF;
    END IF;
    RETURN NULL;
END
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER planeUpgrade
    BEFORE INSERT
    ON RESERVATION_DETAIL
    FOR EACH ROW
    WHEN (NEW.flight_number IS NOT NULL AND isPlaneFull(NEW.flight_number))
    EXECUTE FUNCTION planeUpgradeFunc();

--Test triggering planeUpgrade
--making smaller plane and flight to easier reach max cap
INSERT INTO PLANE(plane_type, manufacturer, plane_capacity, last_service, year, owner_id) VALUES('AAAA', 'Boeing',1,TO_DATE('09-16-2020','MM-DD-YYYY'),1995,5);
INSERT INTO FLIGHT(FLIGHT_NUMBER, AIRLINE_ID, PLANE_TYPE, DEPARTURE_CITY, ARRIVAL_CITY, DEPARTURE_TIME, ARRIVAL_TIME, WEEKLY_SCHEDULE) VALUES(6,5,'AAAA','IAH','PIT','0630','1620','-MTW--S');

--placing first reservation on flight with plane with cap of 1
INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(8,5,615,'2538244543760285','10-28-2020 15:50:15.000000',FALSE);

BEGIN;
SET CONSTRAINTS ALL DEFERRED;
CALL makeReservation(8, 6, TO_DATE('11-23-2020','MM-DD-YYYY'),1);
COMMIT;

--placing second reservation on flight with plane with cap of 1
INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(9,5,615,'2538244543760285','10-28-2020 15:50:15.000000',FALSE);

BEGIN;
SET CONSTRAINTS ALL DEFERRED;
CALL makeReservation(9, 6, TO_DATE('11-23-2020','MM-DD-YYYY'),1);
COMMIT;

--placing first reservation on flight with plane with cap of 1
--on new airline with only one plane
INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded) VALUES(6, 'heyo', 'h', 1926);
INSERT INTO PLANE(plane_type, manufacturer, plane_capacity, last_service, year, owner_id) VALUES('BBBB', 'Boeing',1,TO_DATE('09-16-2020','MM-DD-YYYY'),1995,6);
INSERT INTO FLIGHT(FLIGHT_NUMBER, AIRLINE_ID, PLANE_TYPE, DEPARTURE_CITY, ARRIVAL_CITY, DEPARTURE_TIME, ARRIVAL_TIME, WEEKLY_SCHEDULE) VALUES(7,6,'BBBB','IAH','PIT','0630','1620','-MTW--S');

--placing first reservation on flight with plane with cap of 1
INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(10,5,615,'2538244543760285','10-28-2020 15:50:15.000000',FALSE);

BEGIN;
SET CONSTRAINTS ALL DEFERRED;
CALL makeReservation(10, 7, TO_DATE('11-23-2020','MM-DD-YYYY'),1);
COMMIT;

--placing second reservation on flight with plane with cap of 1
INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(11,5,615,'2538244543760285','10-28-2020 15:50:15.000000',FALSE);

BEGIN;
SET CONSTRAINTS ALL DEFERRED;
CALL makeReservation(11, 7, TO_DATE('11-23-2020','MM-DD-YYYY'),1);
COMMIT;
     
                                                        
                                                        
 --Trigger 6 *NOT FULLY WORKING YET **
 --The Trigger Number 6



CREATE OR REPLACE FUNCTION cancelReservationFunc() RETURNS trigger AS
$$
DECLARE
    ticketbool boolean;
    capacity_order integer;
BEGIN

    SELECT ticketed into ticketbool
    FROM RESERVATION
         INNER JOIN RESERVATION_DETAIL RD on RESERVATION.reservation_number = RD.reservation_number
         INNER JOIN FLIGHT F on RD.flight_number = F.flight_number;

    IF(ticketbool = false) THEN

        DELETE FROM RESERVATION
        WHERE reservation_number = tg_argv;

        DELETE FROM RESERVATION_DETAIL
        WHERE reservation_number = tg_argv;

    end if;

END
$$
LANGUAGE PLPGSQL;

                                                      

--Grab timestamp helper function
CREATE OR REPLACE FUNCTION getTimestamp() RETURNS timestamp AS
$$
DECLARE
    ts timestamp;
BEGIN
    SELECT c_timestamp from OURTIMESTAMP into ts;
    RETURN ts;
end;
$$
LANGUAGE PLPGSQL;

--Trigger 6
 CREATE TRIGGER cancelReservation
    BEFORE UPDATE
    ON OURTIMESTAMP
    EXECUTE FUNCTION cancelReservationFunc();                                                       


-- Attempt 2, task 6 --
DROP TRIGGER IF EXISTS cancelReservation ON reservation;

CREATE TRIGGER cancelReservation
AFTER INSERT OR UPDATE
ON reservation
EXECUTE PROCEDURE cancelAndDowngrade();

CREATE OR REPLACE PROCEDURE cancelAndDowngrade()
LANGUAGE plpgsql
AS $$
DECLARE
    curr_time timestamp := NOW();
    var RECORD;
    var2 RECORD;
BEGIN;
    --remove reservations that are not ticketed at or after cancellation time has past
    begin;
    DELETE
    FROM reservation r
    USING reservation_detail rd
    WHERE r.reservation_number = rd.reservation_number
    AND r.ticketed = FALSE
    AND curr_time >= getcancellationtime(r.reservation_number);
    end;


--for each flight number/flight, downgrade flight if passanger count can fit into smaller plane
FOR var IN
        SELECT flight_number, count(*) as passenger_count
        FROM reservation_detail
        GROUP BY flight_number
        loop
            for var2 IN
                SELECT *
                FROM plane p
                ORDER BY plane_capacity
            loop
                if var.passenger_count <= var2.plane_capacity then
                    UPDATE flight as f SET plane_type = var2.plane_type WHERE f.flight_number = var.flight_number;
                    Exit;
                end if;
            end loop;
        end loop;
END
$$ LANGUAGE plpgsql;

                                                        
