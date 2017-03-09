create table ware(id serial primary key, name varchar(30)); 

insert into ware(name)values('Klopapier');
insert into ware(name)values('Stühle');

create table bestand(id serial primary key, wid int references ware(id), min int, cur int);

create table preis(id serial primary key, wid int references ware(id), country char(2), preis money);

create table bestellung(id serial primary key, wid int, datum date, active char(1) check(active in('Y','N')) default 'N', vol int); 
ALTER TABLE bestellung ADD CONSTRAINT ware_bestellung FOREIGN KEY (wid) REFERENCES ware (id);

insert into bestand(wid,min,cur)values(1,100,121); 
insert into bestand(wid,min,cur)values(2,10,9);


insert into preis(wid,country, preis)values(1,'DE',1,23); # muss ein punkt im preis sein
insert into preis(wid,country, preis)values(1,'GB',0.89);
insert into preis(wid,country, preis)values(1,'AT', 2.10);  
insert into preis(wid,country, preis)values(2,'AT', 245.10);  
insert into preis(wid,country, preis)values(2,'EN', 300.00);
insert into preis(wid,country, preis)values(2,'DE', 310.00); 
	
CREATE OR REPLACE FUNCTION waren_entnahme() RETURNS trigger as 
	$BODY$
	DECLARE 
	v_bestand int;
	v_vol int;
	v_auftrag int := 0;
	BEGIN
	IF new.cur < old.min THEN
		select count(*) into v_auftrag from bestellung where OLD.wid = wid and active != 'Y';
		IF v_auftrag < 1 THEN
		SELECT min into v_vol from bestand where wid = OLD.wid ;
		INSERT INTO bestellung (wid, datum, vol )values(OLD.wid, current_date, v_vol);
		END IF;
	END IF;
	RETURN NEW;	
	END;
	
$BODY$ LANGUAGE plpgsql;
	
	CREATE TRIGGER auto_bestellung
	AFTER UPDATE on bestand
	FOR EACH ROW
	EXECUTE PROCEDURE waren_entnahme();
		
		
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
	IF v_ergo is null THEN
		RAISE EXCEPTION 'LAND ODER WARE NICHT GEFUNDEN'
		USING HINT = 'BITTE LAND ÜBERPRÜFEN';
	END IF;
	RETURN v_ergo;
END;
$HORST$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_select(p_wid int) returns varchar
as $$
DECLARE
	v_name varchar;
	v_num varchar;
BEGIN
	select id,name into v_num,v_name from ware where id = p_wid;
	return v_num || ' ' ||v_name;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION sum_by_country( varchar) returns money
as $$
DECLARE 
	v_num numeric := 0;
BEGIN
	select sum(p.preis * b.cur ) into v_num from preis p inner join  bestand b on p.wid = b.wid where p.country = $1;
	return v_num::numeric::money;
END;
$$ LANGUAGE plpgsql;


create view v_sum_by_country as select sum(p.preis * b.cur )  as summe , country from preis p inner join  bestand b 
on p.wid = b.wid group by country;

CREATE OR REPLACE FUNCTION sum_by_sql( varchar) returns money
as $$
	select sum(p.preis * b.cur ) anzahl from preis p inner join  bestand b on p.wid = b.wid where p.country = $1;
$$ LANGUAGE sql;

create type c_preis as
( preis  numeric,
  country  char(2) 
);


CREATE OR REPLACE FUNCTION get_c_type( land varchar ) returns c_preis
as $$
	DECLARE
		ergo c_preis;
	BEGIN
		select preis, country into ergo.preis, ergo.country from preis where country = land;
		RETURN ergo;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_anzahl() returns numeric
as $$
	DECLARE
		c_abfrage CURSOR FOR SELECT * FROM bestand;
		v_zeile bestand%ROWTYPE;
		v_ergo numeric := 0;
	BEGIN
		OPEN c_abfrage;
		LOOP
			
			FETCH c_abfrage INTO v_zeile;
			
			-- raise notice 'Trap %', v_zeile.cur ;
			v_ergo := v_ergo + coalesce(v_zeile.cur,1000);
			EXIT WHEN NOT FOUND;
			
		END LOOP;
		close c_abfrage;
		RETURN v_ergo;
	END;
$$ LANGUAGE plpgsql;















