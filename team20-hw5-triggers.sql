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

-- Attempt 2, task 6 --
/*DROP TRIGGER IF EXISTS cancelReservation ON reservation;

CREATE TRIGGER cancelReservation
AFTER INSERT OR UPDATE
ON reservation
EXECUTE PROCEDURE cancelAndDowngrade();*/

--Trigger 6 -- attempt 3 --
CREATE OR REPLACE FUNCTION cancelReservationFunc() RETURNS trigger AS
$$
DECLARE
BEGIN
    --delete passengers
    DROP MATERIALIZED VIEW IF EXISTS reservationsToCancel;
    create MATERIALIZED view reservationsToCancel AS
    select reservation_number
    from reservation
    where ticketed = false AND getCancellationTime(reservation_number) < getTimestamp();

    begin
    DELETE FROM reservation_detail WHERE reservation_number IN (SELECT * FROM reservationstocancel);
    -- delete from reservation
    -- where reservation.reservation_number exists in reservationsToCancel.reservation_number

    DELETE FROM reservation WHERE reservation_number IN (SELECT * FROM reservationstocancel);
    -- delete from reservation_detail
    -- where reservation_detail.reservation_number exists in reservationsToCancel.reservation_number
    end;
    RETURN NULL;
END
$$ LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION downgradePlaneFunc() RETURNS trigger AS
$$
DECLARE
    airID integer;
    planeType char(4);
BEGIN
    --get flight_number from old
    --get flight with flight_number
    --raise exception 'planetype null';

    --get airline_id from flight
    SELECT airline_id INTO airID
    FROM flight
    WHERE flight.flight_number = OLD.flight_number;

    --get all plane_type, plane_capacity with that airline_id and plane_capacity >= pass_count
    --get plane_type with min(capacity)

    SELECT plane.plane_type INTO planeType
    FROM
    (SELECT min(p.plane_capacity) as min_plane_capacity
    FROM (SELECT plane_capacity, owner_id
    FROM plane p
    JOIN (SELECT count(flight_number) as pass_count FROM RESERVATION_DETAIL rd
    WHERE rd.flight_number = OLD.flight_number) as pc
    ON pc.pass_count <= p.plane_capacity) as p
    WHERE p.owner_id = airID) as c
    LEFT JOIN plane ON plane.plane_capacity = c.min_plane_capacity;

    if planeType is not null then
        UPDATE flight SET plane_type = planeType WHERE flight.flight_number = OLD.flight_number;
    end if;



    RETURN NULL;
END $$ LANGUAGE PLPGSQL;

-- triggers

DROP TRIGGER IF EXISTS downgradePlane ON reservation_detail;
CREATE TRIGGER downgradePlane
    AFTER DELETE
    ON reservation_detail
    FOR EACH ROW
    EXECUTE FUNCTION downgradePlaneFunc();

DROP TRIGGER IF EXISTS cancelReservation ON ourtimestamp;
CREATE TRIGGER cancelReservation
    AFTER INSERT OR UPDATE
    ON OURTIMESTAMP
    FOR EACH ROW
    EXECUTE FUNCTION cancelReservationFunc();
-- for triggers
DELETE FROM ourtimestamp WHERE c_timestamp is not NULL;
INSERT INTO ourtimestamp(c_timestamp) VALUES('2020-12-04 20:30:38.000000');