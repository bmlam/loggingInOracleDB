use testdb1;

select db_name();

--DROP table log_table;

CREATE TABLE server.t_test
  (ID INT IDENTITY (1,1) PRIMARY KEY ,
	LOG_TS datetime  NOT NULL DEFAULT getdate(),
	INFO_LEVEL VARCHAR(1) NOT NULL  CHECK (info_level in ('I', 'D', 'E', 'P', 'W') ) ,
	ERR_CODE smallint,
	TEXT varchar(1000),
	LOG_SESS_ID VARCHAR(40),
	CALLER_POSITION varchar(100),
	OSUSER varchar(30),
	LOG_USER varchar(30),
   ) 
; 

