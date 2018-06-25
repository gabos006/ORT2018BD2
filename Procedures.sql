DROP PROCEDURE MADERA_ALMACENADA;
DROP PROCEDURE MADERA_MAL_ESTADO;
DROP PROCEDURE GENERACION_ENERGIA;
DROP PROCEDURE RESUMEN_VENTAS;
DROP PROCEDURE RESUMEN_CLIENTES;

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

            DBMS_OUTPUT.PUT_LINE(rpad(v_clientes_rec.NOMBRE,12));
            DBMS_OUTPUT.PUT_LINE(rpad('Total Compras',12) || rpad('Descuentos',12));
            FOR mes IN (EXTRACT(MONTH from FECHA_DESDE))..(EXTRACT(MONTH from FECHA_HASTA)) LOOP
                v_mes_actual := mes;
                DBMS_OUTPUT.PUT_LINE (v_mes_actual);
                OPEN INFO;
                LOOP
                    FETCH INFO into v_info_rec;
                    DBMS_OUTPUT.PUT_LINE(rpad(v_info_rec.COMPRAS,12) || rpad(v_info_rec.DESCUENTOS,12));

                    EXIT WHEN INFO%NOTFOUND;
                END LOOP;
                CLOSE INFO;
            END LOOP;
        EXIT WHEN CLIENTES%NOTFOUND;
        END LOOP;
        CLOSE CLIENTES;

        /***********Crear Log**********/

        INSERT INTO LOGPROCEDURES(FECHA, CI_EMPLEADO, RAZON) VALUES(SYSDATE, CI_EMPLEADO, 'RESUMEN_CLIENTES');
        COMMIT;
    END;
END;