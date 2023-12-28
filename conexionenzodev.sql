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
        dbms_output.put_line('SECCI�N: ' || VALOR.cod_secc);
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

select * from pedidos where val_mont_esti > 250