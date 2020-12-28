DROP TABLESPACE CTUSR_RUNTIME INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
DROP TABLESPACE CTUSR_RUNTIMELOG INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
DROP TABLESPACE CTUSR_DEVTIME INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
DROP TABLESPACE CTUSR_TEMP INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
CREATE TABLESPACE CTUSR_RUNTIME DATAFILE 'C:\ORACLE\ORACLEXE\ORADATA\XE\CTUSR_DATA01.DBF' SIZE 10M AUTOEXTEND ON NEXT 5M  MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;
CREATE TABLESPACE CTUSR_RUNTIMELOG DATAFILE 'C:\ORACLE\ORACLEXE\ORADATA\XE\CTUSR_DATA02.DBF' SIZE 10M AUTOEXTEND ON NEXT 5M  MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;
CREATE TABLESPACE CTUSR_DEVTIME DATAFILE 'C:\ORACLE\ORACLEXE\ORADATA\XE\CTUSR_DATA03.DBF' SIZE 10M AUTOEXTEND ON NEXT 5M  MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;
CREATE TEMPORARY TABLESPACE CTUSR_TEMP TEMPFILE 'C:\ORACLE\ORACLEXE\ORADATA\XE\CTUSR_TEMP01.DBF' SIZE 100K  AUTOEXTEND ON NEXT 100K  MAXSIZE 10M EXTENT MANAGEMENT LOCAL UNIFORM SIZE 50K;