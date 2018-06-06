--------------------------------------------------------
--  File created - Wednesday-June-06-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger CONTROL_CAPATAZ_CHIPEO
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "OBLIGATORIO"."CONTROL_CAPATAZ_CHIPEO" BEFORE INSERT OR UPDATE ON MADERACHIP
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
ALTER TRIGGER "OBLIGATORIO"."CONTROL_CAPATAZ_CHIPEO" ENABLE;
