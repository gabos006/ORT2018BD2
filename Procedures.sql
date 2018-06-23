DROP PROCEDURE MADERA_ALMACENADA;
DROP PROCEDURE MADERA_MAL_ESTADO;
DROP PROCEDURE GENERACION_ENERGIA;

-- REQUERIMIENTO MADERA ALMACENADA
CREATE OR REPLACE PROCEDURE MADERA_ALMACENADA AS
BEGIN
    DECLARE
        CURSOR MADERA IS
            SELECT L.IDLOTE, L.FECHA, L.PESOACTUAL, L.EMAILPROVEEDOR FROM LOTEMADERA L
            WHERE L.ESTADO = 'S'
            ORDER BY L.FECHA ASC;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID LOTE' || '     ' || 'FECHA LOTE' || '     ' || 'PESO ACTUAL' || '     ' || 'EMAIL PROV');
        FOR itemLote IN MADERA
        LOOP
            DBMS_OUTPUT.PUT_LINE(rpad(itemLote.IDLOTE,12) || rpad(itemLote.FECHA,15) || rpad(itemLote.PESOACTUAL,16) || rpad(itemLote.EMAILPROVEEDOR,20));
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
            SELECT L.IDLOTE, L.FECHA FROM LOTEMADERA L
            WHERE L.ESTADO = 'S';
    BEGIN
        FECHALIMITE := ADD_MONTHS(FECHA_ENTRADA,-6);
        SELECT NVL(MAX(LOTEID),0) INTO ULTREGISTRO FROM MADERA_MALESTADO;
        
        FOR itemLote IN MADERA
        LOOP
            UPDATE LOTEMADERA SET ESTADO = 'N' WHERE FECHA < FECHALIMITE AND IDLOTE >= ULTREGISTRO;
            INSERT INTO MADERA_MALESTADO(LOTEID) VALUES (itemLote.IDLOTE);
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

       /* -- AGRUPO POR FECHA
        CURSOR GRUPO IS
            SELECT E.FECHA AS FECHA,SUM(KW) AS KW,SUM(M.PESOMADERALOTE) AS PESOMADERA,SUM(M.PESOCHIP) AS PESOCHIP 
            FROM ENERGIA E, COCCION C, MADERACHIP M
            WHERE M.ID = C.IDCHIP AND C.ID = E.IDENERGIA
                  AND E.FECHA >= FECHA_DESDE AND E.FECHA <= FECHA_HASTA
                  AND C.FECHA >= FECHA_DESDE AND C.FECHA <= FECHA_HASTA
                  AND M.FECHA >= FECHA_DESDE AND M.FECHA <= FECHA_HASTA
            GROUP BY E.FECHA
            ORDER BY E.FECHA;
*/
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

-- TESTS
--EXECUTE MADERA_ALMACENADA();
--EXECUTE MADERA_MAL_ESTADO(CURRENT_DATE);
EXECUTE GENERACION_ENERGIA('18/06/2018','23/06/2018');
