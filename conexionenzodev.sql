--DROP TABLE CLIENTES

CREATE TABLE CLIENTES(
    COD_CLIENTE VARCHAR(7) NOT NULL PRIMARY KEY,
    VAL_APE1 VARCHAR(100)  NULL,
    VAL_APE2 VARCHAR(100)  NULL,
    VAL_NOM1 VARCHAR(100)  NULL,
    VAL_NOM2 VARCHAR(100)  NULL,
    COD_SEXO CHAR(1)  NULL,
    FEC_CREA DATE  NULL,
    SAL_DEUD_ANTE NUMBER  NULL,
    FEC_NACI DATE  NULL
);

COMMIT;
CREATE TABLE PEDIDOS(
    FEC_SOLI DATE NULL,
    COD_PERI VARCHAR(10) NULL,
    VAL_NUME_SOLI NUMBER NULL,
    FEC_FACT DATE NULL,
    VAL_ORIG VARCHAR(30),
    COD_CLIE VARCHAR(7),
    COD_REGI VARCHAR(5),
    COD_ZONA VARCHAR(4),
    COD_SECC CHAR(1),
    SAL_DEUD_ANTE NUMBER NULL,
    VAL_MONT_ESTI NUMBER NULL,
    VAL_MONT_SOLI NUMBER NULL,
    VAL_ESTA_PEDI VARCHAR(100) NULL,
    MOT_RECH VARCHAR(100) NULL,
    VAL_MONT_FLET NUMBER NULL,
    VAL_UNID_LBEL NUMBER NULL,
    VAL_UNID_CYZO NUMBER NULL,
    VAL_UNID_ESIK NUMBER NULL
);
COMMIT;

--INSERCION DE DATA A TRAVES DE CSV

/*PREGUNTA 3*/
SET SERVEROUTPUT ON;
DECLARE

BEGIN
    
    FOR VALOR IN (SELECT 
        COD_ZONA ,
        SUM(val_unid_lbel) + SUM(val_unid_cyzo) + SUM(val_unid_esik) || ' unidades' AS UNIDADES, 
        'S/ ' || SUM(val_mont_esti) AS MONTO_ESTIMADO 
        FROM PEDIDOS 
        WHERE val_esta_pedi = 'FACTURADO' 
        GROUP BY COD_ZONA)
    LOOP
        dbms_output.put_line('COD ZONA: ' || VALOR.COD_ZONA);
        dbms_output.put_line('UNIDADES: ' || VALOR.UNIDADES);
        dbms_output.put_line('---------------------------');
    END LOOP;
    
END;

/*PREGUNTA 4*/
DECLARE

BEGIN
    
    FOR VALOR IN (SELECT 
        cod_secc ,
        val_mont_esti
        FROM (SELECT * FROM PEDIDOS WHERE val_esta_pedi = 'FACTURADO' ORDER BY val_mont_esti Desc) 
        WHERE
        ROWNUM <= 20)
    LOOP
        dbms_output.put_line('SECCIÓN: ' || VALOR.cod_secc);
        dbms_output.put_line('MONTO ESTIMADO: ' || VALOR.val_mont_esti);
        dbms_output.put_line('---------------------------');
    END LOOP;
    
END;






/*PREGUNTA 5*/
DECLARE 
BEGIN
    
    dbms_output.put_line('/*****************PEDIDOS ALTO VALOR***************/');
    
    for valor in (select COD_ZONA ,SUM(val_unid_lbel) + SUM(val_unid_cyzo) + SUM(val_unid_esik) AS NROPEDIDOS from (select * from pedidos where val_mont_esti > 250) group by COD_ZONA) LOOP
        dbms_output.put_line('ZONA: ' || valor.COD_ZONA);
        dbms_output.put_line('NRO PEDIDOS: ' || valor.NROPEDIDOS);
        dbms_output.put_line('---------------------------');
    end loop;
    
    dbms_output.put_line('/*****************PEDIDOS BAJO VALOR***************/');
    
    for valor in (select COD_ZONA ,SUM(val_unid_lbel) + SUM(val_unid_cyzo) + SUM(val_unid_esik) AS NROPEDIDOS from (select * from pedidos where val_mont_esti < 250) group by COD_ZONA) LOOP
        dbms_output.put_line('ZONA: ' || valor.COD_ZONA);
        dbms_output.put_line('NRO PEDIDOS: ' || valor.NROPEDIDOS);
        dbms_output.put_line('---------------------------');
    end loop;

END;



///////RETO 2

ALTER TABLE CLIENTES 
ADD NOMBRE_CORTO VARCHAR(100) NULL;

COMMIT;

--select * from clientes;
--UPDATE CLIENTES SET NOMBRE_CORTO = NULL;
CREATE OR REPLACE PROCEDURE insertar_nombre_corto 
is
BEGIN
    UPDATE CLIENTES SET NOMBRE_CORTO = (val_nom1 || ' ' || val_ape1) WHERE NOMBRE_CORTO IS NULL;
END;

DECLARE

BEGIN
    insertar_nombre_corto();
END;


ALTER TABLE CLIENTES
ADD EDAD NUMBER NULL;
COMMIT;



DECLARE

BEGIN
    
    UPDATE CLIENTES SET EDAD = EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM fec_naci);
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE TOTAL_MONTO_SOLICITADO_RECHAZADO (P_ZONA VARCHAR2, P_SECCION VARCHAR2, P_MENSAJE OUT VARCHAR2) 
IS
var_total_monto_solicitado NUMBER;
BEGIN
    SELECT SUM(VAL_MONT_SOLI) AS TOTAL_MONTOS INTO var_total_monto_solicitado FROM PEDIDOS WHERE val_esta_pedi = 'RECHAZADO' AND COD_ZONA = P_ZONA
    AND COD_SECC = P_SECCION;
    
    P_MENSAJE := 'El monto total para la zona ' || P_ZONA || ' y sección ' || P_SECCION || ' es: ' || var_total_monto_solicitado;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        P_MENSAJE := 'No se encontraron registros para la zona ' || P_ZONA || ' y sección ' || P_SECCION;
END;

DECLARE
p_mensaje varchar(300);
BEGIN
    
    TOTAL_MONTO_SOLICITADO_RECHAZADO('2017', 'D', p_mensaje);
    dbms_output.put_line(p_mensaje);
END;

//////RETO 3

---1
CREATE VIEW VISTA_PEDIDO_NO_FACTURADO AS
SELECT c.nombre_corto FROM PEDIDOS P
INNER JOIN CLIENTES C
ON p.cod_clie = c.cod_cliente
WHERE val_esta_pedi != 'FACTURADO';

---2
DECLARE 


BEGIN
    UPDATE CLIENTES SET val_ape1 = REPLACE(val_ape1, 'Ñ', 'N')
    WHERE INSTR(val_ape1, 'Ñ') > 0;
    
    UPDATE CLIENTES SET val_ape2 = REPLACE(val_ape2, 'Ñ', 'N')
    WHERE INSTR(val_ape2, 'Ñ') > 0;
    COMMIT;
END;

---3
CREATE OR REPLACE FUNCTION calcular_monto_deuda_x_zona(p_zona varchar)
return number is

v_deuda_total number;
begin

    select SUM(VAL_MONT_SOLI) into v_deuda_total from pedidos
    where MOT_RECH = 'DEUDA' AND COD_ZONA = p_zona
    group by COD_ZONA;
    return v_deuda_total;
end;

select calcular_monto_deuda_x_zona('2013') from dual;
