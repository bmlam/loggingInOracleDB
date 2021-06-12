use testdb1;

select db_name();

CREATE TABLE LOG_TABLE
  (ID INT NOT NULL ,
	CALLER_POSITION varchar(100),
	LOG_TS datetime  NOT NULL DEFAULT getdate(),
	INFO_LEVEL VARCHAR(1) NOT NULL  CHECK (info_level in ('I', 'D', 'E', 'P', 'W') ) ,
	ERR_CODE smallint,
	TEXT varchar(1000),
	LOG_SESS_ID bigint,
	OSUSER varchar(30),
	LOG_USER varchar(30),
   ) 
; 

