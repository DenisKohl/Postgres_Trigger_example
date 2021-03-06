CREATE OR REPLACE FUNCTION random_text_simple(length INTEGER)
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
    $$;
	
CREATE OR REPLACE FUNCTION random_range(INTEGER, INTEGER)
   RETURNS INTEGER
   
    AS $$
        SELECT ($1 + FLOOR(($2 - $1 + 1) * random() ))::INTEGER;
   $$ LANGUAGE SQL;
   
create table bs(id serial primary key, text varchar(100), str varchar(10), value int);
	
CREATE OR REPLACE FUNCTION  gen_data(count integer) 
returns void LANGUAGE PLPGSQL as $$
BEGIN
	FOR i in 1..count LOOP
		insert into bs(text,str,value)values(random_text_simple(100),random_text_simple(10),FLOOR(random() * 100));
	END LOOP; 
END;
$$;
