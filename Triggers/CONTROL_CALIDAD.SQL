--------------------------------------------------------
--  File created - Sunday-June-03-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger CONTROL_CALIDAD
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "OBLIGATORIO"."CONTROL_CALIDAD" BEFORE INSERT OR UPDATE ON MADERACHIP
For Each Row
 follows CONTROL_PESO
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
ALTER TRIGGER "OBLIGATORIO"."CONTROL_CALIDAD" ENABLE;
