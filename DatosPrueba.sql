ALTER SESSION 
SET NLS_DATE_FORMAT = 'DD-MM-YYYY'; 

/**************************************************************************
----------------------------- CLIENTES -------------------------------
**************************************************************************/
INSERT INTO CLIENTE(EMAIL,RUT,NOMBRE,TELEFONO) 
VALUES ('abc@gmail.com','213456740012','ABS S.R.L','25678903');

INSERT INTO CLIENTE(EMAIL,RUT,NOMBRE,TELEFONO) 
VALUES ('def@gmail.com','213454240965','DEF S.R.L','23126713');

INSERT INTO CLIENTE(EMAIL,RUT,NOMBRE,TELEFONO) 
VALUES ('ghi@gmail.com','217456239876','GHI S.R.L','24056908');

INSERT INTO CLIENTE(EMAIL,RUT,NOMBRE,TELEFONO) 
VALUES ('jkm@gmail.com','217465747856','JKM S.R.L','25475906');

INSERT INTO CLIENTE(EMAIL,RUT,NOMBRE,TELEFONO) 
VALUES ('nop@gmail.com','214489740812','NOP S.R.L','27876793');

/**************************************************************************
----------------------------- EMPLEADOS -------------------------------
**************************************************************************/
INSERT INTO EMPLEADO(CI,NOMBRECOMPLETO,DIRECCION,CELULAR,SECTOR,TELEFONO,OFICIO,PUESTO,CI_JEFE,ESTCIVIL,SUELDONOM,TIENEHIJOS) 
VALUES (12345678,'Rafael Rodriguez','Mercedes 2345','098756432','SECTOR1','23456789','OFICIO1','PUESTO1',NULL,'S',30000,'S');

INSERT INTO EMPLEADO(CI,NOMBRECOMPLETO,DIRECCION,CELULAR,SECTOR,TELEFONO,OFICIO,PUESTO,CI_JEFE,ESTCIVIL,SUELDONOM,TIENEHIJOS) 
VALUES (23456789,'Pedro Gimenez','Uruguay 2345','098673432','SECTOR1','23696789','OFICIO2','PUESTO2',12345678,'C',20000,'S');

INSERT INTO EMPLEADO(CI,NOMBRECOMPLETO,DIRECCION,CELULAR,SECTOR,TELEFONO,OFICIO,PUESTO,CI_JEFE,ESTCIVIL,SUELDONOM,TIENEHIJOS) 
VALUES (34567890,'Juan Perna','Paysandu 2345','098444432','SECTOR2','23454589','OFICIO3','PUESTO1',NULL,'S',25000,'N');

INSERT INTO EMPLEADO(CI,NOMBRECOMPLETO,DIRECCION,CELULAR,SECTOR,TELEFONO,OFICIO,PUESTO,CI_JEFE,ESTCIVIL,SUELDONOM,TIENEHIJOS) 
VALUES (45678901,'Jose Umpierrez','Fernandez Crespo 2345','098756555','SECTOR2','23216789','OFICIO4','PUESTO3',34567890,'S',15000,'N');

/**************************************************************************
----------------------------- PROVEEDORES -------------------------------
**************************************************************************/
INSERT INTO PROVEEDOR(EMAIL,NOMBRE,RUT,TELEFONO) 
VALUES ('prov1@gmail.com','PROV1','213456789014','23096745');

INSERT INTO PROVEEDOR(EMAIL,NOMBRE,RUT,TELEFONO) 
VALUES ('prov2@gmail.com','PROV2','213456959014','23246745');

INSERT INTO PROVEEDOR(EMAIL,NOMBRE,RUT,TELEFONO) 
VALUES ('prov3@gmail.com','PROV3','213456239014','23236745');

INSERT INTO PROVEEDOR(EMAIL,NOMBRE,RUT,TELEFONO) 
VALUES ('prov4@gmail.com','PROV4','213453459014','23483745');

/**************************************************************************
----------------------------- PAPEL -------------------------------
**************************************************************************/
INSERT INTO STOCK(ID,CANTPHIDRO,CANTACIDO)
VALUES(1,10000,10000);

/**************************************************************************
----------------------------- LOTESMADERA -------------------------------
**************************************************************************/
INSERT INTO LOTEMADERA(EMAIL_PROVEEDOR,PESOINICIAL,ESTADO,FECHA,PESOACTUAL,CI_RESPONSABLE) 
VALUES ('prov1@gmail.com',1000,'S','20/06/2018',1000,12345678);

INSERT INTO LOTEMADERA(EMAIL_PROVEEDOR,PESOINICIAL,ESTADO,FECHA,PESOACTUAL,CI_RESPONSABLE) 
VALUES ('prov2@gmail.com',10000,'S','30/06/2017',10000,34567890);

INSERT INTO LOTEMADERA(EMAIL_PROVEEDOR,PESOINICIAL,ESTADO,FECHA,PESOACTUAL,CI_RESPONSABLE) 
VALUES ('prov3@gmail.com',2000,'S','24/04/2018',2000,12345678);

INSERT INTO LOTEMADERA(EMAIL_PROVEEDOR,PESOINICIAL,ESTADO,FECHA,PESOACTUAL,CI_RESPONSABLE) 
VALUES ('prov4@gmail.com',5000,'S','17/03/2017',5000,34567890);

INSERT INTO LOTEMADERA(EMAIL_PROVEEDOR,PESOINICIAL,ESTADO,FECHA,PESOACTUAL,CI_RESPONSABLE) 
VALUES ('prov1@gmail.com',2500,'S','08/10/2017',2500,12345678);

/**************************************************************************
----------------------------- MADERACHIP -------------------------------
**************************************************************************/
INSERT INTO VIEW_MADERACHIP(ID_LOTE,CI_EMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA)
VALUES(1,12345678,650,630,'20/06/2018');

INSERT INTO VIEW_MADERACHIP(ID_LOTE,CI_EMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA)
VALUES(1,12345678,350,200,'20/06/2018');

INSERT INTO VIEW_MADERACHIP(ID_LOTE,CI_EMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA)
VALUES(2,34567890,5000,4995,'21/06/2018');

INSERT INTO VIEW_MADERACHIP(ID_LOTE,CI_EMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA)
VALUES(3,12345678,1900,1890,'21/06/2018');

INSERT INTO VIEW_MADERACHIP(ID_LOTE,CI_EMPLEADO,PESOMADERALOTE,PESOCHIP,FECHA)
VALUES(4,34567890,3000,2200,'22/06/2018');

/**************************************************************************
----------------------------- COCCION -------------------------------
**************************************************************************/
INSERT INTO COCCION(ID_CHIP,FECHA,PESO)
VALUES(1,'20/06/2018',630);

INSERT INTO COCCION(ID_CHIP,FECHA,PESO)
VALUES(2,'20/06/2018',200);

INSERT INTO COCCION(ID_CHIP,FECHA,PESO)
VALUES(3,'21/06/2018',4995);

INSERT INTO COCCION(ID_CHIP,FECHA,PESO)
VALUES(4,'21/06/2018',1890);

INSERT INTO COCCION(ID_CHIP,FECHA,PESO)
VALUES(5,'22/06/2018',2200);

/**************************************************************************
----------------------------- ENERGIA -------------------------------
**************************************************************************/
INSERT INTO ENERGIA(ID,FECHA,KW)
VALUES(1,'20/06/2018',1260);

INSERT INTO ENERGIA(ID,FECHA,KW)
VALUES(2,'20/06/2018',400);

INSERT INTO ENERGIA(ID,FECHA,KW)
VALUES(3,'21/06/2018',9990);

INSERT INTO ENERGIA(ID,FECHA,KW)
VALUES(4,'21/06/2018',3780);

INSERT INTO ENERGIA(ID,FECHA,KW)
VALUES(5,'22/06/2018',4400);

/**************************************************************************
----------------------------- PAPEL -------------------------------
**************************************************************************/
INSERT INTO PAPEL(ID,PHIDRO,ACIDO,PESO,FECHA)
VALUES(1,100,100,315,'20/06/2018');

INSERT INTO PAPEL(ID,PHIDRO,ACIDO,PESO,FECHA)
VALUES(2,60,60,100,'20/06/2018');

INSERT INTO PAPEL(ID,PHIDRO,ACIDO,PESO,FECHA)
VALUES(3,500,500,2500,'21/06/2018');

INSERT INTO PAPEL(ID,PHIDRO,ACIDO,PESO,FECHA)
VALUES(4,300,300,990,'21/06/2018');

INSERT INTO PAPEL(ID,PHIDRO,ACIDO,PESO,FECHA)
VALUES(5,350,350,1100,'22/06/2018');

/**************************************************************************
----------------------------- VENTA -------------------------------
**************************************************************************/
INSERT INTO VIEW_VENTA(EMAIL_CLIENTE,CI_VENDEDOR,ID_PAPEL,PRECIO,FECHA)
VALUES('abc@gmail.com',23456789,1,1500,'20/06/2018');

COMMIT;