/********************************************************************************************************/
/************* COMENTADO PORQUE PRIMERA VEZ FALLA, DESCOMENTAR LUEGO DE EJECUTADO UNA VEZ ***************/
/*
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
DROP TRIGGER LOGPROCEDURES_ID;
DROP SEQUENCE LOGPROCEDURES_ID_SEQ;
DROP TRIGGER VENTA_ID;
DROP SEQUENCE VENTA_ID_SEQ;

DROP TRIGGER ACTUALIZAR_PESO_CHIPEO;
DROP TRIGGER CONTROL_CALIDAD_CHIPEO;
DROP TRIGGER CONTROL_CAPATAZ_CHIPEO;
DROP TRIGGER CONTROL_PESO_COCCION;
DROP TRIGGER CONTROL_VENTA;
DROP TRIGGER CONTROL_STOCK;

DROP TABLE CONTROL_CALIDAD;
DROP TABLE MADERA_MALESTADO;
DROP TABLE INFO_VENTA;
DROP TABLE LOGPROCEDURES;
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
*/

/*****************************************************************************************************/
---------------------------------------------- TABLES ----------------------------------------------
/*****************************************************************************************************/

CREATE TABLE EMPLEADO
(
    CI NUMBER(10),
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
    CI_JEFE NUMBER(10) DEFAULT NULL,
    CONSTRAINT jefe_fk FOREIGN KEY(CI_JEFE) REFERENCES EMPLEADO(CI),
    CONSTRAINT empleado_pk PRIMARY KEY(CI)
);

CREATE TABLE LOGPROCEDURES
(
    ID NUMBER(10),
    FECHA DATE,
    CI_EMPLEADO NUMBER(10) NOT NULL REFERENCES EMPLEADO,
    RAZON VARCHAR2(20) NOT NULL,
    CONSTRAINT log_empleado_fk FOREIGN KEY(CI_EMPLEADO) REFERENCES EMPLEADO(CI),
    CONSTRAINT log_pk PRIMARY KEY(ID, CI_EMPLEADO)
);

CREATE SEQUENCE LOGPROCEDURES_ID_SEQ START WITH 1;

CREATE TABLE PROVEEDOR
(
    EMAIL VARCHAR2(50),
    NOMBRE VARCHAR2(50),
    TELEFONO VARCHAR2(10),
    RUT VARCHAR2(20)  DEFAULT NULL,
    CONSTRAINT proveedor_pk PRIMARY KEY(EMAIL)
);

CREATE TABLE LOTEMADERA
(
    ID NUMBER(10),
    CI_RESPONSABLE NUMBER(10) NOT NULL ,
    EMAIL_PROVEEDOR VARCHAR2(50) NOT NULL,
    PESOINICIAL NUMBER(10) CHECK(PESOINICIAL > 0),
    PESOACTUAL NUMBER(10) CHECK(PESOACTUAL >= 0),
    ESTADO VARCHAR2(1) CHECK (ESTADO IN ('S', 'N')),
    FECHA DATE NOT NULL,
    CONSTRAINT responsable_lote_pk FOREIGN KEY(CI_RESPONSABLE) REFERENCES EMPLEADO(CI),
    CONSTRAINT proveedor_lote_pk FOREIGN KEY(EMAIL_PROVEEDOR) REFERENCES PROVEEDOR(EMAIL),
    CONSTRAINT lotemadeta_pk PRIMARY KEY(ID)
);

CREATE SEQUENCE LOTEMADERA_ID_SEQ START WITH 1;

CREATE TABLE MADERACHIP 
(
    ID NUMBER(10),
    ID_LOTE NUMBER(10) NOT NULL,
    CI_EMPLEADO NUMBER(10) NOT NULL,
    PESOMADERALOTE NUMBER(10) CHECK(PESOMADERALOTE > 0),
    PESOCHIP NUMBER(10) CHECK(PESOCHIP > 0),
    FECHA DATE NOT NULL,
    CONSTRAINT lote_chip_fk FOREIGN KEY(ID_LOTE) REFERENCES LOTEMADERA(ID),
    CONSTRAINT empleado_chip_fk FOREIGN KEY(CI_EMPLEADO) REFERENCES EMPLEADO(CI),
    CONSTRAINT chip_pk PRIMARY KEY(ID)

);

CREATE SEQUENCE MADERACHIP_ID_SEQ START WITH 1;

-- VISTA NECESARIA POR MUTATING TABLE AL EJECUTAR EL TRIGGER ACTUALIZAR_PESO_CHIPEO
CREATE VIEW VIEW_MADERACHIP AS
SELECT ID,ID_LOTE,CI_EMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA
FROM MADERACHIP;

CREATE TABLE COCCION
(
    ID NUMBER(10),
    ID_CHIP NUMBER(10) NOT NULL,
    PESO NUMBER(10) CHECK(PESO > 0),
    FECHA DATE NOT NULL,
    CONSTRAINT chip_coccion_fk FOREIGN KEY(ID_CHIP) REFERENCES MADERACHIP(ID),
    CONSTRAINT coccion_pk PRIMARY KEY(ID)
);

CREATE SEQUENCE COCCION_ID_SEQ START WITH 1;

CREATE TABLE ENERGIA 
(
	ID NUMBER(10) NOT NULL,
	FECHA DATE NOT NULL,
    KW NUMBER(10) NOT NULL,
    CONSTRAINT coccion_energia_fk FOREIGN KEY(ID) REFERENCES COCCION(ID),
    CONSTRAINT energia_pk PRIMARY KEY(ID)
);

CREATE TABLE PAPEL
(
    ID NUMBER(10) NOT NULL,
    PHIDRO NUMBER(10) CHECK (PHIDRO > 0),
    ACIDO NUMBER(10) CHECK (ACIDO > 0),
	PESO NUMBER(10) CHECK(PESO > 0),
    FECHA DATE NOT NULL,
	CONSTRAINT coccion_papel_fk FOREIGN KEY(ID) REFERENCES COCCION(ID),
	CONSTRAINT papel_pk PRIMARY KEY(ID)
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
    ID NUMBER(10),
    EMAIL_CLIENTE VARCHAR2(50) NOT NULL REFERENCES CLIENTE(EMAIL),
    CI_VENDEDOR NUMBER(10) NOT NULL REFERENCES EMPLEADO(CI),
    ID_PAPEL NUMBER(10) NOT NULL REFERENCES PAPEL(ID),
    PRECIO NUMBER(10) NOT NULL,
    FECHA DATE NOT NULL,
    CONSTRAINT venta_pk PRIMARY KEY(ID,EMAIL_CLIENTE,CI_VENDEDOR,ID_PAPEL)
);

CREATE SEQUENCE VENTA_ID_SEQ START WITH 1;

CREATE TABLE INFO_VENTA
(
    ID_VENTA NUMBER(10) NOT NULL,
    EMAIL_CLIENTE VARCHAR2(50) NOT NULL,
    CI_VENDEDOR NUMBER(10) NOT NULL,
    ID_PAPEL NUMBER(10) NOT NULL,
    PRECIO_FINAL NUMBER(10) NOT NULL,
	BONO_EMPLEADO  NUMBER(10),
	DESCUENTO_CLIENTE NUMBER(10),
    FECHA DATE NOT NULL,
	CONSTRAINT info_venta_bono_fk FOREIGN KEY(ID_VENTA,EMAIL_CLIENTE, CI_VENDEDOR, ID_PAPEL) REFERENCES VENTA(ID,EMAIL_CLIENTE,CI_VENDEDOR,ID_PAPEL),
    CONSTRAINT info_venta_pk PRIMARY KEY(ID_VENTA,EMAIL_CLIENTE,CI_VENDEDOR,ID_PAPEL)
);

CREATE TABLE STOCK
(
    ID NUMBER(10) PRIMARY KEY,
    CANTPHIDRO NUMBER(10) DEFAULT NULL,
    CANTACIDO NUMBER(10) DEFAULT NULL
);

-- Tabla auxiliar para porder retomar el proceso de madera en mal estado en el ultimo registro recorrido
CREATE TABLE MADERA_MALESTADO
(
    ID NUMBER(10) PRIMARY KEY,
    ID_LOTE NUMBER(10)
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

CREATE OR REPLACE TRIGGER VENTA_ID BEFORE INSERT ON VENTA
FOR EACH ROW

BEGIN
    SELECT VENTA_ID_SEQ.NEXTVAL INTO :new.id FROM dual;
END;
/
ALTER TRIGGER VENTA_ID ENABLE;


/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER MADERACHIP_ID BEFORE INSERT ON MADERACHIP
FOR EACH ROW

BEGIN
    SELECT MADERACHIP_ID_SEQ.NEXTVAL INTO :new.id FROM dual;
END;
/
ALTER TRIGGER MADERACHIP_ID ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER LOGPROCEDURES_ID BEFORE INSERT ON LOGPROCEDURES
FOR EACH ROW

BEGIN
    SELECT LOGPROCEDURES_ID_SEQ.NEXTVAL INTO :new.id FROM dual;
END;
/
ALTER TRIGGER LOGPROCEDURES_ID ENABLE;

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
    SELECT LOTEMADERA_ID_SEQ.NEXTVAL INTO :new.ID FROM dual;
END;
/
ALTER TRIGGER LOTEMADERA_ID ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_CAPATAZ_CHIPEO BEFORE INSERT OR UPDATE ON MADERACHIP
FOR EACH ROW

DECLARE
	v_CI_JEFE NUMBER(10);
BEGIN

    SELECT e.CI_JEFE INTO v_CI_JEFE FROM EMPLEADO e WHERE e.CI = :NEW.CI_EMPLEADO;
    
    IF NOT(v_CI_JEFE IS NULL) THEN
        Raise_Application_Error (-20003, 'Los chips deben ser llevados por capataces');
    END IF;

END;
/
ALTER TRIGGER CONTROL_CAPATAZ_CHIPEO ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_CALIDAD_CHIPEO BEFORE INSERT OR UPDATE ON MADERACHIP
FOR EACH ROW
DECLARE
	v_peso_chip NUMBER(10);
	v_peso_madera NUMBER(10);
	v_porcentaje NUMBER(10);
    v_control_id NUMBER(10);
    v_peso_lote NUMBER(10);
BEGIN

    -- CONTROLO EL PESO DEL LOTE
    SELECT l.PESOACTUAL INTO v_peso_lote FROM LOTEMADERA l WHERE :NEW.ID_LOTE = l.ID;

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

CREATE OR REPLACE TRIGGER ACTUALIZAR_PESO_CHIPEO
INSTEAD OF INSERT OR UPDATE ON VIEW_MADERACHIP
FOR EACH ROW

DECLARE
	v_peso_suma NUMBER(10);
BEGIN

	IF INSERTING THEN
        INSERT INTO MADERACHIP(ID_LOTE,CI_EMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA)
        VALUES(:NEW.ID_LOTE,:NEW.CI_EMPLEADO,:NEW.PESOMADERALOTE,:NEW.PESOCHIP,:NEW.FECHA);
    ELSE
        UPDATE MADERACHIP SET ID_LOTE = :NEW.ID_LOTE,
                              CI_EMPLEADO = :NEW.CI_EMPLEADO,
                              PESOMADERALOTE = :NEW.PESOMADERALOTE,
                              PESOCHIP = :NEW.PESOCHIP,
                              FECHA = :NEW.FECHA
        WHERE ID = :NEW.ID;
    END IF;
    
    SELECT NVL(SUM(m.PESOMADERALOTE),0) INTO v_peso_suma FROM MADERACHIP m WHERE m.ID_LOTE = :NEW.ID_LOTE;
	UPDATE LOTEMADERA SET PESOACTUAL = PESOINICIAL - v_peso_suma WHERE ID = :NEW.ID_LOTE;
END;
/
ALTER TRIGGER ACTUALIZAR_PESO_CHIPEO ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_PESO_COCCION BEFORE INSERT OR UPDATE ON COCCION
For Each Row

DECLARE
	v_peso_chip NUMBER(10);
BEGIN

    SELECT m.PESOCHIP INTO v_peso_chip FROM MADERACHIP m WHERE m.ID = :NEW.ID_CHIP;
    
    IF(:NEW.PESO > v_peso_chip) THEN
        Raise_Application_Error (-20002, 'Fallo el control de peso');
    END IF;

END;
/
ALTER TRIGGER CONTROL_PESO_COCCION ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_STOCK BEFORE INSERT ON PAPEL
FOR EACH ROW
DECLARE
    v_cant_phidro NUMBER(10);
    v_cant_acido NUMBER(10);
BEGIN
    SELECT CANTPHIDRO INTO v_cant_phidro
    FROM STOCK WHERE ID = 1;
    
    SELECT CANTACIDO INTO v_cant_acido
    FROM STOCK WHERE ID = 1;
    
    IF (:NEW.PHIDRO > v_cant_phidro) THEN
        RAISE_APPLICATION_ERROR(-20002,'Stock de hidrogengo insuficiente');
    END IF;
    
    IF :NEW.ACIDO > v_cant_acido THEN
        RAISE_APPLICATION_ERROR(-20003,'Stock de acido insuficiente');
    END IF;
    
    -- ACTUALIZO EL STOCK
    UPDATE STOCK SET CANTPHIDRO = CANTPHIDRO - :NEW.PHIDRO, CANTACIDO = CANTACIDO - :NEW.ACIDO WHERE ID = 1;
END;
/
ALTER TRIGGER CONTROL_STOCK ENABLE;

/*****************************************************************************************************/

CREATE OR REPLACE TRIGGER CONTROL_VENTA AFTER INSERT OR UPDATE ON VENTA
FOR EACH ROW

DECLARE
    v_suma_precios NUMBER(10);
    v_precio_descuento NUMBER(10);
    v_descuentos_cliente NUMBER(10);
    v_bonos_empleado NUMBER(10);
BEGIN
	v_precio_descuento := :NEW.PRECIO;
	v_descuentos_cliente := 0;
    v_bonos_empleado := 0;
    
    IF(:NEW.PRECIO >= 1000) THEN
        v_precio_descuento := v_precio_descuento - (:NEW.PRECIO * 0.08);
		v_descuentos_cliente := v_descuentos_cliente  + (:NEW.PRECIO * 0.08);
        v_bonos_empleado := v_bonos_empleado + (:NEW.PRECIO * 0.02);
    END IF;

    SELECT NVL(SUM(v.PRECIO_FINAL),0) INTO v_suma_precios FROM INFO_VENTA v 
    WHERE EXTRACT(MONTH FROM v.FECHA)= EXTRACT(MONTH FROM :new.FECHA) 
    AND EXTRACT(YEAR FROM v.FECHA)= EXTRACT(YEAR FROM :new.FECHA)
    AND v.EMAIL_CLIENTE = :NEW.EMAIL_CLIENTE;
    
    IF(v_suma_precios >= 10000) THEN
        v_precio_descuento := v_precio_descuento - (:NEW.PRECIO * 0.05);
		v_descuentos_cliente := v_descuentos_cliente  + (:NEW.PRECIO * 0.05);
    END IF;
    
    IF INSERTING THEN
        INSERT INTO INFO_VENTA(ID_VENTA,EMAIL_CLIENTE,CI_VENDEDOR,ID_PAPEL,PRECIO_FINAL,BONO_EMPLEADO,DESCUENTO_CLIENTE,FECHA)
        VALUES(:NEW.ID, :NEW.EMAIL_CLIENTE,:NEW.CI_VENDEDOR, :NEW.ID_PAPEL,v_precio_descuento, v_bonos_empleado, v_descuentos_cliente,:NEW.FECHA);
    END IF;
    
    IF UPDATING THEN
        UPDATE INFO_VENTA SET
        EMAIL_CLIENTE = :NEW.EMAIL_CLIENTE,
        CI_VENDEDOR = :NEW.CI_VENDEDOR,
        ID_PAPEL = :NEW.ID_PAPEL,
        PRECIO_FINAL = v_precio_descuento,
        BONO_EMPLEADO = v_bonos_empleado,
        DESCUENTO_CLIENTE = v_descuentos_cliente,
        FECHA = :NEW.FECHA
        WHERE ID_VENTA = :OLD.ID;
    END IF;
    
END;
/
ALTER TRIGGER CONTROL_VENTA ENABLE;

/*****************************************************************************************************/

COMMIT;

/*****************************************************************************************************/
---------------------------------------------- PROCEDURES ----------------------------------------------
/*****************************************************************************************************/

/*******************************************************************************/
/************* SI SE DESEA ELIMINAR A LOS PROCEDURES DESCOMENTAR ***************/
/*
DROP PROCEDURE MADERA_ALMACENADA;
DROP PROCEDURE MADERA_MAL_ESTADO;
DROP PROCEDURE GENERACION_ENERGIA;
DROP PROCEDURE RESUMEN_VENTAS;
DROP PROCEDURE RESUMEN_CLIENTES;
*/

-- REQUERIMIENTO MADERA ALMACENADA
CREATE OR REPLACE PROCEDURE MADERA_ALMACENADA AS
BEGIN
    DECLARE
        CURSOR MADERA IS
            SELECT L.ID, L.FECHA, L.PESOACTUAL, L.EMAIL_PROVEEDOR FROM LOTEMADERA L
            WHERE L.ESTADO = 'S'
            ORDER BY L.FECHA ASC;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID LOTE' || '     ' || 'FECHA LOTE' || '     ' || 'PESO ACTUAL' || '     ' || 'EMAIL PROV');
        FOR itemLote IN MADERA
        LOOP
            DBMS_OUTPUT.PUT_LINE(rpad(itemLote.ID,12) || rpad(itemLote.FECHA,15) || rpad(itemLote.PESOACTUAL,16) || rpad(itemLote.EMAIL_PROVEEDOR,20));
        END LOOP;
    END;
END;

-- Funciona como DELIMITER
/

-- REQUERIMIENTO MADERA EN MAL ESTADO
CREATE OR REPLACE PROCEDURE MADERA_MAL_ESTADO(FECHA_ENTRADA IN DATE) AS
BEGIN
    DECLARE
        ULTREGISTRO NUMBER(10);
        FECHALIMITE DATE;
        
        -- ME GUARDO TODOS LOS LOTES QUE ESTAN EN BUEN ESTADO
        CURSOR MADERA IS
            SELECT L.ID, L.FECHA FROM LOTEMADERA L
            WHERE L.ESTADO = 'S';
    BEGIN
        FECHALIMITE := ADD_MONTHS(FECHA_ENTRADA,-6);
        SELECT NVL(MAX(ID_LOTE),0) INTO ULTREGISTRO FROM MADERA_MALESTADO;
        
        FOR itemLote IN MADERA
        LOOP
            UPDATE LOTEMADERA SET ESTADO = 'N' WHERE FECHA < FECHALIMITE AND ID >= ULTREGISTRO;
            INSERT INTO MADERA_MALESTADO(ID_LOTE) VALUES (itemLote.ID);
        END LOOP;
        
        EXECUTE IMMEDIATE 'TRUNCATE TABLE MADERA_MALESTADO';
        COMMIT;
    END;
END;

-- Funciona como DELIMITER
/

-- REQUERIMIENTO GENERACION DE ENERGIA
CREATE OR REPLACE PROCEDURE GENERACION_ENERGIA(FECHA_DESDE IN DATE, FECHA_HASTA IN DATE) AS
BEGIN
    DECLARE       
        cant_madera_lote NUMBER(10);
        cant_madera_chip NUMBER(10);
        
        -- AGRUPO POR FECHA
        CURSOR ENERGIA IS
            SELECT E.FECHA AS FECHA,SUM(KW) AS KW
            FROM ENERGIA E
            WHERE E.FECHA >= FECHA_DESDE AND E.FECHA <= FECHA_HASTA
            GROUP BY E.FECHA
            ORDER BY E.FECHA;         
    BEGIN
        DBMS_OUTPUT.PUT_LINE('FECHA' || '     ' || 'CANT. KW' || '     ' || 'PESO LOTE' || '     ' || 'PESO CHIP');
        
        FOR itemEnergia IN ENERGIA
        LOOP
            SELECT SUM(M.PESOMADERALOTE) INTO cant_madera_lote
            FROM MADERACHIP M
            WHERE M.FECHA = itemEnergia.FECHA;
        
            SELECT SUM(C.PESO) INTO cant_madera_chip
            FROM COCCION C
            WHERE C.FECHA = itemEnergia.FECHA;
            
            DBMS_OUTPUT.PUT_LINE(rpad(itemEnergia.FECHA,12) || rpad(itemEnergia.KW,12) || rpad(cant_madera_lote,16) || rpad(cant_madera_chip,12));        
        END LOOP;  
    END;
END;

-- Funciona como DELIMITER
/

CREATE OR REPLACE PROCEDURE PRODUCCION_PAPEL(FECHA_DESDE IN DATE, FECHA_HASTA IN DATE) AS
BEGIN
    DECLARE
        v_fecha DATE;
        v_sum_mchip NUMBER(10);
        v_sum_lmadera NUMBER(10);
        -- AGRUPO POR FECHA
        CURSOR GRUPO IS
            SELECT SUM(p.PESO) AS SUMA, p.FECHA as FECHA FROM PAPEL p WHERE p.FECHA >= FECHA_DESDE AND p.FECHA <= FECHA_HASTA
            GROUP BY p.FECHA
            ORDER BY p.FECHA;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('FECHA' || '     ' || 'PESO PAPEL' || '     ' || 'PESO CHIPS' || '     ' || 'PESO LOTE');
        

        FOR itemGrupo IN GRUPO
        LOOP
                SELECT NVL(SUM(m.PESOCHIP),0) into v_sum_mchip FROM MADERACHIP m WHERE m.FECHA = itemGrupo.FECHA;
                SELECT NVL(SUM(l.PESOINICIAL),0) into v_sum_lmadera FROM LOTEMADERA l WHERE l.FECHA = itemGrupo.FECHA;
                DBMS_OUTPUT.PUT_LINE(rpad(itemGrupo.FECHA,12) || rpad(itemGrupo.SUMA,14) || rpad(v_sum_mchip,14) || rpad(v_sum_lmadera,12)); 
        END LOOP;
    END;
END;

-- Funciona como DELIMITER
/

create or replace PROCEDURE RESUMEN_VENTAS(CI_EMPLEADO IN NUMBER, MES IN NUMBER DEFAULT 0) AS
BEGIN
    DECLARE
        v_fecha DATE;
        v_mes_actual NUMBER;

        CURSOR VENDEDORES IS
            SELECT e.CI, e.NOMBRECOMPLETO  FROM (SELECT DISTINCT v.CI_VENDEDOR FROM VENTA v) lista, EMPLEADO e, VENTA v
            WHERE e.CI = lista.CI_VENDEDOR 
            AND e.CI = v.CI_VENDEDOR 
            AND EXTRACT(MONTH from v_fecha) = EXTRACT(MONTH from v.FECHA)
            AND EXTRACT(YEAR from v_fecha) = EXTRACT(YEAR from v.FECHA)
            ;

        v_vendedores_rec VENDEDORES%ROWTYPE;

        CURSOR INFO IS
            SELECT * FROM INFO_VENTA iv WHERE iv.CI_VENDEDOR = v_VENDEDORES_rec.CI
            AND EXTRACT(MONTH from IV.FECHA) = EXTRACT(MONTH from v_fecha);

    BEGIN

        if(MES = 0) THEN
            SELECT  ADD_MONTHS(SYSDATE,-1) into v_fecha FROM dual;
        ELSE
            SELECT  ADD_MONTHS(SYSDATE, (MES - EXTRACT(MONTH from SYSDATE))) into v_fecha FROM dual;
        END IF;

        /***********Crear Log**********/

        INSERT INTO LOGPROCEDURES(FECHA, CI_EMPLEADO, RAZON) VALUES(SYSDATE, CI_EMPLEADO, 'RESUMEN_VENTAS');

        OPEN  VENDEDORES;

        LOOP
            FETCH VENDEDORES into v_vendedores_rec;
            EXIT WHEN VENDEDORES%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE('Empleado: ' || rpad(v_vendedores_rec.NOMBRECOMPLETO,50));
            DBMS_OUTPUT.PUT_LINE('EMAIL CLIENTE' || '            ' || 'PRECIO FINAL' || '     ' || 'BONOS OBTENIDOS');

            FOR info_venta IN INFO
            LOOP
                DBMS_OUTPUT.PUT_LINE(rpad(info_venta.EMAIL_CLIENTE,25) || rpad(info_venta.PRECIO_FINAL,17) || rpad(info_venta.BONO_EMPLEADO,12));
            END LOOP;
            
            DBMS_OUTPUT.PUT_LINE('   ');
        END LOOP;
        CLOSE VENDEDORES;

    END;
END;

-- Funciona como DELIMITER
/

CREATE OR REPLACE PROCEDURE RESUMEN_CLIENTES
(
CI_EMPLEADO IN NUMBER,
FECHA_DESDE IN DATE DEFAULT TRUNC (SYSDATE , 'YEAR'),
FECHA_HASTA IN DATE DEFAULT TRUNC(ADD_MONTHS(SYSDATE,-1))
) AS
BEGIN

    DECLARE

    v_mes_actual NUMBER;
    CURSOR CLIENTES IS
        SELECT C.Email, c.Nombre  FROM 
            (
                SELECT v.EMAIL_CLIENTE FROM VENTA v, CLIENTE c
                WHERE v.EMAIL_CLIENTE = c.EMAIL 
                AND EXTRACT(MONTH from v.FECHA) >= EXTRACT(MONTH from FECHA_DESDE)
                AND EXTRACT(MONTH from v.FECHA) <= EXTRACT(MONTH from FECHA_HASTA)
                AND EXTRACT(YEAR from v.FECHA) >= EXTRACT(YEAR from FECHA_DESDE)
                AND EXTRACT(YEAR from v.FECHA) <= EXTRACT(YEAR from FECHA_HASTA)
                GROUP BY v.EMAIL_CLIENTE
                ORDER BY SUM(v.PRECIO) DESC
            ) lista, CLIENTE c
        WHERE Lista.Email_Cliente = C.Email
        AND ROWNUM <=10;
        
    v_clientes_rec CLIENTES%ROWTYPE;
        
    CURSOR INFO IS
        SELECT SUM(i.PRECIO_FINAL) AS COMPRAS, SUM(i.DESCUENTO_CLIENTE) as DESCUENTOS FROM INFO_VENTA i
        WHERE i.EMAIL_CLIENTE = v_clientes_rec.Email AND (EXTRACT(MONTH from i.FECHA)) = v_mes_actual ;
        
    v_info_rec INFO%ROWTYPE;
    BEGIN

        OPEN  CLIENTES;

        LOOP
            FETCH CLIENTES into v_clientes_rec;
            EXIT WHEN CLIENTES%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE('Cliente: ' || rpad(v_clientes_rec.NOMBRE,50));
            FOR mes IN (EXTRACT(MONTH from FECHA_DESDE))..(EXTRACT(MONTH from FECHA_HASTA)) LOOP
                v_mes_actual := mes;
                DBMS_OUTPUT.PUT_LINE('MES: ' || TO_CHAR(TO_DATE(v_mes_actual, 'MM'), 'MONTH'));
                DBMS_OUTPUT.PUT_LINE('TOTAL COMPRAS' || '     ' || 'DESCUENTOS');
                OPEN INFO;
                LOOP
                    FETCH INFO into v_info_rec;
                    EXIT WHEN INFO%NOTFOUND;
                    
                    DBMS_OUTPUT.PUT_LINE(rpad(v_info_rec.COMPRAS,18) || rpad(v_info_rec.DESCUENTOS,12));
                    DBMS_OUTPUT.PUT_LINE('   ');
                END LOOP;
                CLOSE INFO;
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------');
        END LOOP;
        CLOSE CLIENTES;

        /***********Crear Log**********/

        INSERT INTO LOGPROCEDURES(FECHA, CI_EMPLEADO, RAZON) VALUES(SYSDATE, CI_EMPLEADO, 'RESUMEN_CLIENTES');
        COMMIT;
    END;
END;
