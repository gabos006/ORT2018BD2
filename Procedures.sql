DROP PROCEDURE MADERA_ALMACENADA;
DROP PROCEDURE MADERA_MAL_ESTADO;
DROP PROCEDURE GENERACION_ENERGIA;
DROP PROCEDURE RESUMEN_VENTAS;

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

/

create or replace PROCEDURE RESUMEN_VENTAS(EMPLEADO IN NUMBER, MES IN NUMBER DEFAULT 0) AS
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
            SELECT * FROM INFO_VENTA iv WHERE iv.CI_VENDEDOR = v_VENDEDORES_rec.CI;
            
            
    BEGIN
 
        if(MES = 0) THEN
            SELECT  ADD_MONTHS(SYSDATE,-1) into v_fecha FROM dual;
        ELSE
            SELECT  ADD_MONTHS(SYSDATE, (MES - v_mes_actual)) into v_fecha FROM dual;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Empleado:');
        
        OPEN  VENDEDORES;
        
        LOOP
            FETCH VENDEDORES into v_vendedores_rec;
            
            DBMS_OUTPUT.PUT_LINE(rpad(v_vendedores_rec.NOMBRECOMPLETO,12));
            
            DBMS_OUTPUT.PUT_LINE(rpad('Email Cliente',12) || rpad('Precio Final',12) || rpad('Bonos Obtenidos',12));

            FOR info_venta IN INFO
            LOOP
                DBMS_OUTPUT.PUT_LINE(rpad(info_venta.EMAIL_CLIENTE,12) || rpad(info_venta.PRECIO_FINAL,12) || rpad(NVL(info_venta.BONO_EMPLEADO,0),12));
            END LOOP;
            
            EXIT WHEN VENDEDORES%NOTFOUND;
        END LOOP;
        CLOSE VENDEDORES;
        
    END;
END;
