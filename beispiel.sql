create table ware(id serial primary key, name varchar(30)); 

insert into ware(name)values('Kolpapier');
insert into ware(name)values('Stühle');

create table bestand(id serial primary key, wid int references ware(id), min int, cur int);

create table preis(id serial primary key, wid int references ware(id), country char(2), preis money);

create table bestellung(id serial primary key, wid int, datum date, active char(1) check(active in('Y','N')) default 'N', vol int); 
ALTER TABLE bestellung ADD CONSTRAINT ware_bestellung FOREIGN KEY (wid) REFERENCES ware (id);


CREATE OR REPLACE FUNCTION waren_entnahme() RETURNS trigger as 
	$BODY$
	DECLARE 
	v_bestand int;
	v_vol int;
	v_auftrag int := 0;
	BEGIN
	IF new.cur < old.min THEN
		select count(*) into v_auftrag from bestellung where OLD.wid = wid and active != 'N';
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
		
		
CREATE OR REPLACE FUNCTION waren_wert( varchar, varchar ) returns money
as $$
DECLARE 
	v_preis money := 0; 
	v_vol int := 0;
	v_wid int := 0;
BEGIN
	SELECT  id into v_wid from ware where ware.name = $1;
	SELECT  cur into v_vol from bestand where wid = v_wid;
	SELECT  preis into v_preis from preis where country = $2 and wid = v_wid;
	RETURN v_vol * v_preis;
END;
 $$LANGUAGE plpgsql;