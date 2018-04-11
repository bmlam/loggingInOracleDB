CREATE OR REPLACE PACKAGE BODY pck_std_log_admin
AS
gc_pkg_name constant varchar2(30) := 'pck_std_log_admin';

/******************************************************/
function i$add_pkg_prefix( p_procname varchar2) 
return varchar2 
/******************************************************/
as 
begin
	return upper(gc_pkg_name||'.'||p_procname); 
end  i$add_pkg_prefix;
/******************************************************/
   PROCEDURE test 
/******************************************************/
AS
	lc_proc constant varchar2(100) := i$add_pkg_prefix('test');
BEGIN
	null;
exception
	when others then 
		logerror( lc_proc, p_err_code=> sqlcode, p_text=> sqlerrm);
end test;

/******************************************************/
   PROCEDURE deact_debug 
/******************************************************/

AS
	lc_proc constant varchar2(100) := i$add_pkg_prefix('deact_debug');
	l_rowcount integer;
BEGIN
	-- 
	update debug_user
	set last_updated = systimestamp
	where  last_updated is null and debug_on = 'Y'
	;
	loginfo(lc_proc, 'Rows updated due to unknown LAST_UPDATED: '||l_rowcount);
	update debug_user
	set debug_on = 'N'
	, last_updated = systimestamp
	where debug_on = 'Y'
		and last_updated > sysdate - 8/24
	;
	l_rowcount:= sql%rowcount;
	commit;
	loginfo(lc_proc, 'Rows deactivated: '||l_rowcount);
exception
	when others then 
		logerror( lc_proc, p_err_code=> sqlcode, p_text=> sqlerrm);
		rollback;
end deact_debug;
END; -- package
/

show errors
