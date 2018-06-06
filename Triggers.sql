CREATE OR REPLACE TRIGGER control_peso BEFORE INSERT OR UPDATE ON MADERACHIP
FOR EACH ROW

DECLARE
	v_peso_lote NUMBER(10);
BEGIN

    SELECT l.PESOACTUAL INTO v_peso_lote FROM LOTEMADERA l WHERE :NEW.LOTE = l.IDLOTE;
    
    IF UPDATING THEN 
      v_peso_lote := v_peso_lote + :OLD.PESOMADERALOTE;
    END IF;  
    
    IF  (v_peso_lote < :NEW.PESOMADERALOTE) THEN
        Raise_Application_Error (-20002, 'Fallo el control de peso');
    END IF;

END;
/
ALTER TRIGGER control_peso ENABLE;

/****************************************************************************************************************/

CREATE OR REPLACE TRIGGER control_calidad  BEFORE INSERT OR UPDATE ON MADERACHIP
FOR EACH ROW
 follows control_peso
DECLARE
	v_peso_chip NUMBER(10);
	v_peso_madera NUMBER(10);
	v_porcentaje NUMBER(10);

BEGIN

	SELECT SUM(m.PESOCHIP) INTO v_peso_chip  FROM MADERACHIP m WHERE TRUNC(sysdate) = TRUNC(m.FECHA);
	SELECT SUM(m.PESOMADERALOTE) INTO v_peso_madera FROM MADERACHIP m WHERE TRUNC(sysdate) = TRUNC(m.FECHA);

	IF UPDATING THEN 
		v_peso_chip := v_peso_chip - :OLD.PESOCHIP;
		v_peso_madera := v_peso_madera - :OLD.PESOMADERALOTE;
	END IF;  

	v_peso_chip := v_peso_chip + :NEW.PESOCHIP;
	v_peso_madera := v_peso_madera + :NEW.PESOMADERALOTE;
	v_porcentaje := v_peso_chip *  v_peso_madera / 100;

	IF  (v_porcentaje < 95) THEN
		Raise_Application_Error (-20001, 'Fallo el control de calidad');
	END IF;

END;
/
ALTER TRIGGER control_calidad ENABLE;

/****************************************************************************************************************/

CREATE OR REPLACE TRIGGER actualizar_peso AFTER INSERT OR UPDATE ON MADERACHIP
FOR EACH ROW

DECLARE
	v_peso_suma NUMBER(10);
BEGIN

    SELECT SUM(m.PESOMADERALOTE) INTO v_peso_suma FROM MADERACHIP m WHERE m.LOTE = :NEW.LOTE;
    UPDATE LOTEMADERA SET PESOACTUAL = v_peso_suma WHERE IDLOTE = :NEW.LOTE;

END;
/
ALTER TRIGGER actualizar_peso ENABLE;

/****************************************************************************************************************/
create or replace TRIGGER control_capataz_chipeo BEFORE INSERT OR UPDATE ON MADERACHIP
For Each Row

DECLARE
	v_cijefe NUMBER(10);
BEGIN

SELECT e.CIJEFE INTO v_cijefe FROM EMPLEADO e WHERE e.CI = :NEW.EMPLEADO;

IF(v_cijefe = NULL) THEN
    Raise_Application_Error (-20003, 'Los chips deben ser llevados por capataces');
END IF;

END;
/
ALTER TRIGGER control_capataz_chipeo ENABLE;

/****************************************************************************************************************/

create or replace TRIGGER control_peso_coccion BEFORE INSERT OR UPDATE ON COCCION
For Each Row

DECLARE
	v_peso_chip NUMBER(10);
BEGIN

SELECT m.PESOCHIP INTO v_peso_chip FROM MADERACHIP m WHERE m.ID = :NEW.IDCHIP;

IF(:NEW.PESO > v_peso_chip) THEN
	Raise_Application_Error (-20002, 'Fallo el control de peso');
END IF;

END;
/
ALTER TRIGGER control_peso_coccion ENABLE;