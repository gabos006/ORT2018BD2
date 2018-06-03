DROP TABLE STOCK;
DROP TABLE VENTA;
DROP TABLE CLIENTE;
DROP TABLE PAPEL;
DROP TABLE PASTA;
DROP TABLE LICORNEGRO;
DROP TABLE PRODUCTOCOCCION;
DROP TABLE CHIPEA;
DROP TABLE COCCION;
DROP TABLE MADERACHIP;
DROP TABLE LOTEMADERA;
DROP TABLE PROVEEDOR;
DROP TABLE EMPLEADO;

CREATE TABLE EMPLEADO
(
    CI NUMBER(10) PRIMARY KEY,
    NOMBRECOMPLETO VARCHAR2(50),
    TELEFONO NUMBER(10),
    CELULAR NUMBER(10),
    DIRECCION VARCHAR2(50),
    ESTCIVIL VARCHAR2(1),
    SUELDONOM NUMBER(10),
    OFICIO VARCHAR2(10),
    SECTOR VARCHAR2(10),
    TINEHIJOS NUMBER(1),
    PUESTO VARCHAR2(10),
    CIJEFE NUMBER(8) DEFAULT NULL REFERENCES EMPLEADO
);

CREATE TABLE PROVEEDOR
(
    EMAIL VARCHAR2(50) PRIMARY KEY,
    NOMBRE VARCHAR2(50),
    TELEFONO NUMBER(10),
    RUT VARCHAR2(20)  DEFAULT NULL 
);

CREATE TABLE LOTEMADERA
(
    IDLOTE NUMBER(10) PRIMARY KEY,
    CIRESPONSABLE NUMBER(10) NOT NULL REFERENCES EMPLEADO,
    EMAILPROOVEDOR VARCHAR2(50) NOT NULL REFERENCES PROVEEDOR,
    PESOINICIAL NUMBER(10) CHECK(PESOINICIAL > 0),
    PESOACTUAL NUMBER(10) CHECK(PESOACTUAL >= 0),
    FECHA DATE NOT NULL
);

CREATE TABLE MADERACHIP 
(
    ID NUMBER(10) PRIMARY KEY,
    LOTE NUMBER(10) NOT NULL REFERENCES LOTEMADERA,
    EMPLEADO NUMBER(10) NOT NULL REFERENCES EMPLEADO,
    PESOMADERALOTE NUMBER(10) CHECK(PESO > 0),
    PESOCHIP NUMBER(10) CHECK(PESO > 0),
    FECHA DATE NOT NULL
);

/*
CREATE TABLE CHIPEA
(
    LOTE NUMBER(10) NOT NULL REFERENCES LOTEMADERA,
    EMPLEADO NUMBER(10) NOT NULL REFERENCES EMPLEADO,
    CHIP NUMBER(10) NOT NULL REFERENCES MADERACHIP
);
*/

CREATE TABLE COCCION
(
    ID NUMBER(10) PRIMARY KEY,
    IDCHIP NUMBER(10) NOT NULL REFERENCES MADERACHIP,
    PESO NUMBER(10) CHECK(PESO > 0),
    FECHA DATE NOT NULL
);

CREATE TABLE PRODUCTOCOCCION
(
    ID NUMBER(10) PRIMARY KEY,
    -- IDCHIP NUMBER(10) NOT NULL REFERENCES COCCION(IDCHIP),
    IDCOC NUMBER(10) NOT NULL REFERENCES COCCION(ID),
    PESO NUMBER(10) CHECK(PESO > 0),
    FECHA DATE NOT NULL
);

CREATE TABLE LICORNEGRO 
(
    IDLIC NUMBER(10) REFERENCES PRODUCTOCOCCION(ID) PRIMARY KEY,
    KW NUMBER(10) NOT NULL
);

CREATE TABLE PASTA 
(
    IDPASTA NUMBER(10) REFERENCES PRODUCTOCOCCION(ID) PRIMARY KEY,
    PHIDRO NUMBER(10) CHECK (PHIDRO > 0),
    ACIDO NUMBER(10) CHECK (ACIDO > 0)
);

CREATE TABLE PAPEL
(
    IDPAPEL NUMBER(10) PRIMARY KEY,
    IDPASTA NUMBER(10) REFERENCES PASTA(IDPASTA),
    PESO NUMBER(10) CHECK(PESO > 0),
    FECHA DATE NOT NULL
);

CREATE TABLE CLIENTE
(
    EMAIL VARCHAR2(50) PRIMARY KEY,
    NOMBRE VARCHAR2(50),
    TELEFONO NUMBER(10),
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