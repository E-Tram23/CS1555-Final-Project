--<20>-hw5-query.sql

--Team 20
--Eric Tram ewt6
--Robert Xu rox5
--Joeseph DAlesandro jrd105


--FUNCTIONS

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
