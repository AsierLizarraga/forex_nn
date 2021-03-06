
DROP TABLE TN_EURUSD5;

SELECT 

       CONVERT(datetime,SUBSTRING(FECHA,1 ,4) + '-' + SUBSTRING(FECHA ,6 ,2) + '-' + SUBSTRING(FECHA ,9 ,2) + ' ' + SUBSTRING(HORA,1,2) + ':' + SUBSTRING(HORA,4,2) + ':00') AS FECHA
      ,convert(float,APERTURA) as APERTURA
      ,convert(float,[ALTO]) as ALTO
      ,convert(float,[BAJO]) as BAJO
      ,convert(float,[CERRAR]) as CIERRE
      ,convert(float,[VOLUMEN]) as VOLUMEN
     
      INTO TN_EURUSD5
  FROM [BOLSA].[dbo].[TB_EURUSD5]
  
  
  -- '2007-05-08 12:35:29.123'
  

DROP TABLE TN_EURUSD1;

SELECT 

       CONVERT(datetime,SUBSTRING(FECHA,1 ,4) + '-' + SUBSTRING(FECHA ,6 ,2) + '-' + SUBSTRING(FECHA ,9 ,2) + ' ' + SUBSTRING(HORA,1,2) + ':' + SUBSTRING(HORA,4,2) + ':00') AS FECHA
      ,convert(float,APERTURA) as APERTURA
      ,convert(float,[ALTO]) as ALTO
      ,convert(float,[BAJO]) as BAJO
      ,convert(float,[CERRAR]) as CIERRE
      ,convert(float,[VOLUMEN]) as VOLUMEN
     
      INTO TN_EURUSD1
  FROM [BOLSA].[dbo].[TB_EURUSD1]
  
