--------------------------------------------------------
--  File created - Sunday-June-03-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger CONTROL_PESO
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "OBLIGATORIO"."CONTROL_PESO" BEFORE INSERT OR UPDATE ON MADERACHIP
For Each Row

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
ALTER TRIGGER "OBLIGATORIO"."CONTROL_PESO" ENABLE;
