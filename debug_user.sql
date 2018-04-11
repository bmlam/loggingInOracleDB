CREATE TABLE debug_user
(
	username	VARCHAR2(30) NOT NULL
	,osuser	varchar2(30)
	,module varchar2(30)
	,debug_on char(1) check (debug_on in ('Y','N') )
	,last_updated timestamp
)
tablespace users
;

grant select on debug_user to public;


COMMENT ON table debug_user IS 
'Use to turn on debugging for users dynamically'
;
