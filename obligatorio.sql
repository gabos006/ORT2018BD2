DROP TRIGGER CONTROL_CALIDAD_ID;
DROP SEQUENCE CONTROL_CALIDAD_ID_SEQ;
DROP TRIGGER MADERA_MALESTADO_ID;
DROP SEQUENCE MADERA_MALESTADO_ID_SEQ;
DROP TRIGGER COCCION_ID;
DROP SEQUENCE COCCION_ID_SEQ;
DROP TRIGGER MADERACHIP_ID;
DROP SEQUENCE MADERACHIP_ID_SEQ;
DROP TRIGGER LOTEMADERA_ID;
DROP SEQUENCE LOTEMADERA_ID_SEQ;

DROP TRIGGER ACTUALIZAR_PESO_CHIPEO;
DROP TRIGGER CONTROL_CALIDAD_CHIPEO;
DROP TRIGGER CONTROL_CAPATAZ_CHIPEO;
DROP TRIGGER CONTROL_PESO_COCCION;

DROP TABLE CONTROL_CALIDAD;
DROP TABLE MADERA_MALESTADO;
DROP TABLE STOCK;
DROP TABLE VENTA;
DROP TABLE CLIENTE;
DROP TABLE PAPEL;
DROP TABLE ENERGIA;
DROP TABLE COCCION;
DROP VIEW VIEW_MADERACHIP;
DROP TABLE MADERACHIP;
DROP TABLE LOTEMADERA;
DROP TABLE PROVEEDOR;
DROP TABLE EMPLEADO;

CREATE TABLE EMPLEADO
(
    CI NUMBER(10) PRIMARY KEY,
    NOMBRECOMPLETO VARCHAR2(50),
    TELEFONO VARCHAR2(10),
    CELULAR VARCHAR2(10),
    DIRECCION VARCHAR2(50),
    ESTCIVIL VARCHAR2(1) CHECK (ESTCIVIL IN ('S','C')),
    SUELDONOM NUMBER(10),
    OFICIO VARCHAR2(10),
    SECTOR VARCHAR2(10),
    TIENEHIJOS VARCHAR2(1) CHECK (TIENEHIJOS IN ('S','N')),
    PUESTO VARCHAR2(10),
    CIJEFE NUMBER(10) DEFAULT NULL REFERENCES EMPLEADO
);

CREATE TABLE PROVEEDOR
(
    EMAIL VARCHAR2(50) PRIMARY KEY,
    NOMBRE VARCHAR2(50),
    TELEFONO VARCHAR2(10),
    RUT VARCHAR2(20)  DEFAULT NULL 
);

CREATE TABLE LOTEMADERA
(
    IDLOTE NUMBER(10) PRIMARY KEY,
    CIRESPONSABLE NUMBER(10) NOT NULL REFERENCES EMPLEADO,
    EMAILPROVEEDOR VARCHAR2(50) NOT NULL REFERENCES PROVEEDOR(EMAIL),
    PESOINICIAL NUMBER(10) CHECK(PESOINICIAL > 0),
    PESOACTUAL NUMBER(10) CHECK(PESOACTUAL >= 0),
    ESTADO VARCHAR2(1) CHECK (ESTADO IN ('S', 'N')),
    FECHA DATE NOT NULL
);

CREATE SEQUENCE LOTEMADERA_ID_SEQ START WITH 1;

CREATE TABLE MADERACHIP 
(
    ID NUMBER(10) PRIMARY KEY,
    LOTEID NUMBER(10) NOT NULL REFERENCES LOTEMADERA,
    CIEMPLEADO NUMBER(10) NOT NULL REFERENCES EMPLEADO,
    PESOMADERALOTE NUMBER(10) CHECK(PESOMADERALOTE > 0),
    PESOCHIP NUMBER(10) CHECK(PESOCHIP > 0),
    FECHA DATE NOT NULL
);

CREATE SEQUENCE MADERACHIP_ID_SEQ START WITH 1;

-- VISTA NECESARIA POR MUTATING TABLE AL EJECUTAR EL TRIGGER ACTUALIZAR_PESO_CHIPEO
CREATE VIEW VIEW_MADERACHIP AS
SELECT ID,LOTEID,CIEMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA
FROM MADERACHIP;

CREATE TABLE COCCION
(
    ID NUMBER(10) PRIMARY KEY,
    IDCHIP NUMBER(10) NOT NULL REFERENCES MADERACHIP,
    PESO NUMBER(10) CHECK(PESO > 0),
    FECHA DATE NOT NULL
);

CREATE SEQUENCE COCCION_ID_SEQ START WITH 1;

CREATE TABLE ENERGIA 
(
	IDENERGIA NUMBER(10) REFERENCES COCCION(ID) PRIMARY KEY,
	FECHA DATE NOT NULL,
    KW NUMBER(10) NOT NULL
);

CREATE TABLE PAPEL
(
    IDPAPEL NUMBER(10) REFERENCES COCCION(ID) PRIMARY KEY,
    PHIDRO NUMBER(10) CHECK (PHIDRO > 0),
    ACIDO NUMBER(10) CHECK (ACIDO > 0),
	PESO NUMBER(10) CHECK(PESO > 0),
    FECHA DATE NOT NULL
);

CREATE TABLE CLIENTE
(
    EMAIL VARCHAR2(50) PRIMARY KEY,
    NOMBRE VARCHAR2(50),
    TELEFONO VARCHAR2(10),
    RUT VARCHAR2(20) DEFAULT NULL 
);

CREATE TABLE VENTA
(
    EMAILCLI VARCHAR2(50) REFERENCES CLIENTE(EMAIL),
    CIVENDEDOR NUMBER(10) REFERENCES EMPLEADO(CI),
    IDPAPEL NUMBER(10) REFERENCES PAPEL(IDPAPEL),
    PRECIO NUMBER(10) NOT NULL,
    PRIMARY KEY(EMAILCLI,CIVENDEDOR,IDPAPEL)
);

CREATE TABLE STOCK
(
    STOCKID NUMBER(10) PRIMARY KEY,
    CANTPHIDRO NUMBER(10) DEFAULT NULL,
    CANTACIDO NUMBER(10) DEFAULT NULL
);

-- Tabla auxiliar para porder retomar el proceso de madera en mal estado en el ultimo registro recorrido
CREATE TABLE MADERA_MALESTADO
(
    ID NUMBER(10) PRIMARY KEY,
    LOTEID NUMBER(10)
);
CREATE SEQUENCE MADERA_MALESTADO_ID_SEQ START WITH 1;

-- Tabla auxiliar para realizar el control de calidad de la madera
CREATE TABLE CONTROL_CALIDAD
(
    ID NUMBER(10) PRIMARY KEY,
    FECHA DATE,
    PORCENTAJE NUMBER(3)
);
CREATE SEQUENCE CONTROL_CALIDAD_ID_SEQ START WITH 1;
/*****************************************************************************************************/
---------------------------------------------- TRIGGERS ----------------------------------------------
/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER COCCION_ID BEFORE INSERT ON COCCION
FOR EACH ROW

BEGIN
    SELECT COCCION_ID_SEQ.NEXTVAL INTO :new.id FROM dual;
END;
/
ALTER TRIGGER COCCION_ID ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER MADERACHIP_ID BEFORE INSERT ON MADERACHIP
FOR EACH ROW

BEGIN
    SELECT MADERACHIP_ID_SEQ.NEXTVAL INTO :new.id FROM dual;
END;
/
ALTER TRIGGER MADERACHIP_ID ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER MADERA_MALESTADO_ID BEFORE INSERT ON MADERA_MALESTADO
FOR EACH ROW

BEGIN
    SELECT MADERA_MALESTADO_ID_SEQ.NEXTVAL INTO :new.id FROM dual;
END;
/
ALTER TRIGGER MADERA_MALESTADO_ID ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_CALIDAD_ID BEFORE INSERT ON CONTROL_CALIDAD
FOR EACH ROW

BEGIN
    SELECT CONTROL_CALIDAD_ID_SEQ.NEXTVAL INTO :new.id FROM dual;
END;
/
ALTER TRIGGER CONTROL_CALIDAD_ID ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER LOTEMADERA_ID BEFORE INSERT ON LOTEMADERA
FOR EACH ROW

BEGIN
    SELECT LOTEMADERA_ID_SEQ.NEXTVAL INTO :new.idLote FROM dual;
END;
/
ALTER TRIGGER LOTEMADERA_ID ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_CAPATAZ_CHIPEO BEFORE INSERT OR UPDATE ON MADERACHIP
FOR EACH ROW

DECLARE
	v_cijefe NUMBER(10);
BEGIN

    SELECT e.CIJEFE INTO v_cijefe FROM EMPLEADO e WHERE e.CI = :NEW.CIEMPLEADO;
    
    IF(v_cijefe != NULL) THEN
        Raise_Application_Error (-20003, 'Los chips deben ser llevados por capataces');
    END IF;

END;
/
ALTER TRIGGER CONTROL_CAPATAZ_CHIPEO ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_CALIDAD_CHIPEO BEFORE INSERT OR UPDATE ON MADERACHIP
FOR EACH ROW
--FOLLOWS CONTROL_PESO_CHIPEO
DECLARE
	v_peso_chip NUMBER(10);
	v_peso_madera NUMBER(10);
	v_porcentaje NUMBER(10);
    v_control_id NUMBER(10);
    v_peso_lote NUMBER(10);
BEGIN

    -- CONTROLO EL PESO DEL LOTE
    SELECT l.PESOACTUAL INTO v_peso_lote FROM LOTEMADERA l WHERE :NEW.LOTEID = l.IDLOTE;

	IF UPDATING THEN 
	  v_peso_lote := v_peso_lote + :OLD.PESOMADERALOTE;
	END IF;  

	IF (v_peso_lote < :NEW.PESOMADERALOTE) THEN
		Raise_Application_Error (-20002, 'Fallo el control de peso');
	END IF;
    
    -- CONTROL DE CALIDAD DEL 95%
	SELECT NVL(SUM(m.PESOCHIP),0) INTO v_peso_chip  FROM MADERACHIP m WHERE TRUNC(m.FECHA) = TRUNC(CURRENT_DATE);
	SELECT NVL(SUM(m.PESOMADERALOTE),0) INTO v_peso_madera FROM MADERACHIP m WHERE TRUNC(m.FECHA) = TRUNC(CURRENT_DATE);
    
	IF UPDATING THEN 
		v_peso_chip := v_peso_chip - :OLD.PESOCHIP;
		v_peso_madera := v_peso_madera - :OLD.PESOMADERALOTE;
	END IF;  

	v_peso_chip := v_peso_chip + :NEW.PESOCHIP;
	v_peso_madera := v_peso_madera + :NEW.PESOMADERALOTE;
	v_porcentaje := v_peso_chip * 100 / v_peso_madera;

    -- SI ESTOY POR DEBAJO DEL CONTROL DE CALIDAD AGREGO REGISTRO O MODIFICO EXISTENTE, SINO ELIMINO EL EXISTENTE.
	IF  (v_porcentaje < 95) THEN
        
        -- BUSCO REGISTRO PARA SABER SI DAR DE ALTA O MODIFICAR
        SELECT  COUNT(*) INTO v_control_id FROM CONTROL_CALIDAD WHERE TRUNC(FECHA) = TRUNC(SYSDATE);
        
        IF v_control_id = 0 THEN
            INSERT INTO CONTROL_CALIDAD(FECHA,PORCENTAJE) VALUES (CURRENT_DATE,v_porcentaje);
        ELSE
            UPDATE CONTROL_CALIDAD SET PORCENTAJE = v_porcentaje WHERE TRUNC(FECHA) = TRUNC(SYSDATE);
        END IF;
    ELSE
        DELETE FROM CONTROL_CALIDAD WHERE TRUNC(FECHA) = TRUNC(SYSDATE);
	END IF;
END;
/
ALTER TRIGGER CONTROL_CALIDAD_CHIPEO ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_PESO_COCCION BEFORE INSERT OR UPDATE ON COCCION
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
ALTER TRIGGER CONTROL_PESO_COCCION ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER ACTUALIZAR_PESO_CHIPEO
INSTEAD OF INSERT OR UPDATE ON VIEW_MADERACHIP
FOR EACH ROW

DECLARE
	v_peso_suma NUMBER(10);
BEGIN

	IF INSERTING THEN
        INSERT INTO MADERACHIP(LOTEID,CIEMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA)
        VALUES(:NEW.LOTEID,:NEW.CIEMPLEADO,:NEW.PESOMADERALOTE,:NEW.PESOCHIP,:NEW.FECHA);
    ELSE
        UPDATE MADERACHIP SET LOTEID = :NEW.LOTEID,
                              CIEMPLEADO = :NEW.CIEMPLEADO,
                              PESOMADERALOTE = :NEW.PESOMADERALOTE,
                              PESOCHIP = :NEW.PESOCHIP,
                              FECHA = :NEW.FECHA
        WHERE ID = :NEW.ID;
    END IF;
    
    SELECT NVL(SUM(m.PESOMADERALOTE),0) INTO v_peso_suma FROM MADERACHIP m WHERE m.LOTEID = :NEW.LOTEID;
	UPDATE LOTEMADERA SET PESOACTUAL = PESOINICIAL - v_peso_suma WHERE IDLOTE = :NEW.LOTEID;
END;
/
ALTER TRIGGER ACTUALIZAR_PESO_CHIPEO ENABLE;

/*****************************************************************************************************/
--------------------------------------------- PROCEDURES ---------------------------------------------
/*****************************************************************************************************/

COMMIT;
