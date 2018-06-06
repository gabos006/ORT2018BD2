--------------------------------------------------------
--  File created - Wednesday-June-06-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger ACTUALIZAR_PESO_CHIPEO
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "OBLIGATORIO"."ACTUALIZAR_PESO_CHIPEO" AFTER INSERT OR UPDATE ON MADERACHIP
FOR EACH ROW

DECLARE
	v_peso_suma NUMBER(10);
BEGIN

	SELECT SUM(m.PESOMADERALOTE) INTO v_peso_suma FROM MADERACHIP m WHERE m.LOTE = :NEW.LOTE;
	UPDATE LOTEMADERA SET PESOACTUAL = v_peso_suma WHERE IDLOTE = :NEW.LOTE;

END;

/
ALTER TRIGGER "OBLIGATORIO"."ACTUALIZAR_PESO_CHIPEO" ENABLE;
