CREATE TABLE long_log
(
	id	NUMBER not null
	,log_time date not null
	,log_text clob not null
)
pctfree 0
;

	
grant select on long_log to public;
