--------------------------------------------------------
--  File created - Wednesday-June-06-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger CONTROL_PESO_COCCION
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "OBLIGATORIO"."CONTROL_PESO_COCCION" BEFORE INSERT OR UPDATE ON COCCION
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
ALTER TRIGGER "OBLIGATORIO"."CONTROL_PESO_COCCION" ENABLE;
