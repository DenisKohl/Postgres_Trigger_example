/*CREATE OR REPLACE FUNCTION random_range(z1 INTEGER, z2 INTEGER)
   RETURNS INTEGER
   
    AS $$
        SELECT (z1 + FLOOR((z2 - z1 + 1) * random() ))::INTEGER;
   $$ LANGUAGE SQL;

   select random_range(10,30);
*/
   --CREATE TABLE zufall (id serial PRIMARY KEY, str char(10), txt text, value numeric);
/*CREATE OR REPLACE FUNCTION random_text_simple(length INTEGER)
    RETURNS TEXT
    LANGUAGE PLPGSQL
    AS $$
    DECLARE
        possible_chars TEXT := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        output TEXT := '';
        i INT4;
        pos INT4;
    BEGIN

        FOR i IN 1..length LOOP
            pos := random_range(1, length(possible_chars));
            output := output || substr(possible_chars, pos, 1);
        END LOOP;

        RETURN output;
    END;
    $$;*/

   --insert into zufall (str,txt,value)values(random_text_simple(10), random_text_simple(random_range(100,1000)), random_range(1000,9999));
--select * from zufall;
/*create or REPLACE FUNCTION make_zufall() returns void as
$$
BEGIN
    FOR i IN 1..100 LOOP
        insert into zufall (str,txt,value)values(random_text_simple(10), random_text_simple(random_range(100,1000)), random_range(1000,9999));
    END LOOP;
END;
$$ LANGUAGE PLPGSQL;


select make_zufall();

select count(*) from zufall;



CREATE OR REPLACE FUNCTION waren_wert( p_ware varchar, p_land varchar ) returns money
as $HORST$
DECLARE 
	v_preis money := 0; 
	v_vol int := 0;
	v_wid int := 0;
	v_ergo money ;
BEGIN
	SELECT  id into v_wid from ware where ware.name = p_ware;
	SELECT  cur into v_vol from bestand where wid = v_wid;
	SELECT  preis into v_preis from preis where country = p_land and wid = v_wid;
	v_ergo := v_vol * v_preis;
	IF v_ergo = null THEN
		RAISE EXCEPTION 'LAND ODER WARE NICHT GEFUNDEN'
		USING HINT = 'BITTE LAND ÜBERPRÜFEN';
	END IF;
	RETURN v_ergo;
END;
$HORST$ LANGUAGE plpgsql;


select waren_wert('Klopapier','DE');
*/

select 'Jetzt verstehe ist: ' || coalesce(null,' ');


