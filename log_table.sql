CREATE TABLE log_table
(
	id	NUMBER,
	component	VARCHAR2(100) NOT NULL,
	log_user	VARCHAR2(30) not null,
	subcomponent	VARCHAR2(100),
	timestamp	DATE NOT NULL,
	info_level	CHAR(1) NOT NULL ,
	err_code	number(10),
	text	VARCHAR2(1000),
	log_sess_id integer,
	osuser varchar2(30)
	, PRIMARY KEY (id )
 	, constraint log_table_k1 check (info_level in ('I', 'D', 'E', 'P') )
	--using index tablespace users
)
--partition by range (timestamp) (
--	partition P_pre_2008 values less than (to_date('2008 01', 'yyyy mm')),
--)
--tablespace users
pctfree 0
;
create table log_table_v2
( id NUMBER GENERATED ALWAYS AS IDENTITY
 ,caller_position VARCHAR2(100 CHAR)
 ,log_ts    TIMESTAMP default systimestamp  NOT NULL 
 ,info_level	CHAR(1) NOT NULL check (info_level in ('I', 'D', 'E', 'P', 'W') )
 ,err_code	number(10)
 ,text	VARCHAR2(1000)
 ,log_sess_id integer
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
		l_sql := 'alter table LOG_TABLE add partition P_PRE_'
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
	
grant select on log_table to public;

create sequence log_table_seq;

COMMENT ON COLUMN log_table.id IS 'can be referred with in other tables'
;
COMMENT ON COLUMN log_table.component IS 'e.g package name or standalone procedure name'
;
COMMENT ON COLUMN log_table.subcomponent IS 'e.g. name of procedure inside a package'
;
COMMENT ON COLUMN log_table.timestamp IS 'when this entry is logged'

COMMENT ON COLUMN log_table.info_level IS 'I for informational, D for debugging/development, E for error, P for publishable'
;

COMMENT ON COLUMN log_table.err_code IS 'Should be Oracle''s error code'
;
