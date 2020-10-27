--<20>-hw5-query.sql

--Team 20
--Eric Tram ewt6
--Robert Xu rox5
--Joeseph DAlesandro jrd105


--FUNCTIONS

--Task 2 getCancellationTime

--assuming must cancel 12 hours before flight_date of first leg of the trip
CREATE OR REPLACE FUNCTION getCancellationTime(reservation_number integer)
RETURNS timestamp
AS $$
DECLARE
    cancel_time timestamp;
    cancel_window interval = '12 hours';
BEGIN
    SELECT (flight_date - cancel_window) INTO cancel_time
    FROM RESERVATION_DETAIL
    WHERE RESERVATION_DETAIL.reservation_number = $1 AND leg = 1;

    RETURN cancel_time;
END;
$$ LANGUAGE plpgsql;

--TESTING
SELECT getCancellationTime(1);



--Task 3 isPlaneFull

CREATE OR REPLACE FUNCTION isPlaneFull(f_number integer)
RETURNS BOOLEAN
AS $$
DECLARE
    is_full BOOLEAN := false;
    res_count integer;
BEGIN
    SELECT count(flight_number) INTO res_count
    FROM RESERVATION_DETAIL rd
    WHERE rd.flight_number = $1;

    SELECT (a.flight_number = $1) INTO is_full
    FROM FLIGHT a left join PLANE p ON a.plane_type = p.plane_type
    WHERE a.flight_number = $1 AND p.plane_capacity <= res_count;

    if is_full IS NULL then
        is_full := false;
    end if;

    RETURN is_full;
END
$$ LANGUAGE plpgsql;

--TESTING
SELECT isPlaneFull(2);




--Task 4 makeReservation

CREATE OR REPLACE PROCEDURE makeReservation(res_num integer, flight_num integer, dep_date date, l integer)
LANGUAGE plpgsql
AS $$
DECLARE
    f_time varchar;
    hour integer;
    minute integer;
    final_time time;
    f_timedate timestamp;
BEGIN
    SELECT departure_time INTO f_time
    FROM FLIGHT
    WHERE flight_number = $2;

    SELECT SUBSTRING(f_time from 1 for 2) INTO hour;

    SELECT SUBSTRING(f_time from 3 for 2) INTO minute;

    SELECT make_time(hour,minute,0.0) INTO final_time;

    SELECT ($3 + final_time) INTO f_timedate;

    INSERT INTO RESERVATION_DETAIL(reservation_number, flight_number, flight_date, leg) VALUES ($1,$2,f_timedate,$4);
END;
$$;

--Test Inserts the reservation number 6 then updates and adds tuple into reservation_details table

INSERT INTO RESERVATION(reservation_number, cid, cost, credit_card_num, reservation_date, ticketed) VALUES(7,5,615,'2538244543760285','10-28-2020 15:50:15.000000',FALSE);

BEGIN;
SET CONSTRAINTS ALL DEFERRED;
CALL makeReservation(7, 3, TO_DATE('11-23-2020','MM-DD-YYYY'),1);
COMMIT;
