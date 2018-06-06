--------------------------------------------------------
--  File created - Wednesday-June-06-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger CONTROL_PESO_CHIPEO
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "OBLIGATORIO"."CONTROL_PESO_CHIPEO" BEFORE INSERT OR UPDATE ON MADERACHIP
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
ALTER TRIGGER "OBLIGATORIO"."CONTROL_PESO_CHIPEO" ENABLE;
