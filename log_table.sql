rem CREATE TABLE log_table_v2
rem (
rem 	id	NUMBER,
rem 	caller_position	VARCHAR2(100) NOT NULL,
rem 	log_user	VARCHAR2(30) not null,
rem 	caller_position	VARCHAR2(100),
rem 	timestamp	DATE NOT NULL,
rem 	info_level	CHAR(1) NOT NULL ,
rem 	err_code	number(10),
rem 	text	VARCHAR2(1000),
rem 	log_sess_id integer,
rem 	osuser varchar2(30)
rem 	, PRIMARY KEY (id )
rem  	, constraint log_table_k1 check (info_level in ('I', 'D', 'E', 'P') )
rem 	--using index tablespace users
rem )
rem --partition by range (timestamp) (
rem --	partition P_pre_2008 values less than (to_date('2008 01', 'yyyy mm')),
rem --)
rem --tablespace users
rem pctfree 0
rem ;

create table log_table_v2
( id NUMBER GENERATED ALWAYS AS IDENTITY
 ,caller_position VARCHAR2(100 CHAR)
 ,log_ts    TIMESTAMP default systimestamp  NOT NULL 
 ,info_level	CHAR(1) NOT NULL check (info_level in ('I', 'D', 'E', 'P', 'W') )
 ,err_code	number(10)
 ,text	VARCHAR2(1000)
 ,log_sess_id integer
  ,db_user varchar2(30)
  ,osuser varchar2(30)
  , part_key GENERATED ALWAYS AS ( EXTRACT( YEAR FROM log_ts) * 100 + EXTRACT( MONTH FROM log_ts) ) VIRTUAL
	, PRIMARY KEY (id )
 )
 ;
 --
 -- write statement to migrate data !!!
 --
 
rem add partition for the current and next year
set serverout out size 100000
declare l_next_year date;
	l_sql long;
begin
if 1=0 then -- not all shops have bought partitioning option!
	for i in 1 .. 2 loop
		l_next_year := trunc(add_months(sysdate,12*i), 'year');
		l_sql := 'alter table LOG_TABLE_v2 add partition P_PRE_'
			||to_char( l_next_year,'yyyy')
			||' values less than (to_date('
			||to_char(l_next_year,'yyyymmdd')
			||',''yyyymmdd'') )'
			;
		dbms_output.put_line('ddl: '||l_sql);
		execute immediate l_sql	;
	end loop;
end if; 	-- no op
end;
/
	
grant select on log_table_v2 to public;

COMMENT ON COLUMN log_table_v2.id IS 'can be referred with in other tables'
;
COMMENT ON COLUMN log_table_v2.caller_position IS 'e.g package name or standalone procedure name'
;
COMMENT ON COLUMN log_table_v2.caller_position IS 'e.g. name of procedure inside a package'
;
COMMENT ON COLUMN log_table_v2.log_ts IS 'when this entry is logged'
;
COMMENT ON COLUMN log_table_v2.info_level IS 'I for informational, D for debugging/development, E for error, P for publishable'
;

COMMENT ON COLUMN log_table_v2.err_code IS 'Should be Oracle''s error code' ;
