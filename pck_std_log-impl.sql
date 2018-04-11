CREATE OR REPLACE PACKAGE body pck_std_log
AS
/***************************************************************************\
Package Description:
	See package interface

Special logic:
	Program can have bugs. The purpose of logging is to help determine
	where the logic errors are. But if the logic involving in logging,
	be it on the application programmer's part, i.e., the users making
	use of the logging package, logging itself may present a kind
	of error, particularly when streaming of logging messages bogs the
	system and renders the application unusable. Therefore this package
	will maintain a per session counter for each level of logging.
	When the count exceeds a predefined maximum, the logging message
	will no longer be written to the database. However, it may be useful
	to get an idea how bad the "streaming" was, so a kind of heartbeat
	logging will still take place in case of streaming. This is achieved
	by checking the modulo of the message count againt a predefined value.

Dependencies:

Limitations:

\***************************************************************************/
--
/*******************************************************************
  Constant declaration
*******************************************************************/
--
gc_pkg_name      constant varchar2(30) := 'PCK_STD_LOG';
gc_nl      constant varchar2(1) := chr(10);
--
c_il_debug     constant log_table.info_level%type := 'D';
c_il_info      constant log_table.info_level%type := 'I';
c_il_error     constant log_table.info_level%type := 'E';
c_il_publish   constant log_table.info_level%type := 'P';
--
c_sess_max_debug     constant binary_integer := 1000;
c_sess_max_info      constant binary_integer := 10000;
c_sess_max_info_long      constant binary_integer := 1000;
c_sess_max_error     constant binary_integer := 100000;
c_sess_max_publish   constant binary_integer := 100;
--
c_heartbeat_modulo   constant binary_integer := 10000;
--
-- The following values for data length need to be adjusted
-- column size of the corresponding columns change
--
c_comp_max_len       binary_integer := 30;
c_subcomp_max_len    binary_integer := 30;
c_text_max_len       binary_integer := 1000;

g_cached_long_flag boolean;
g_cached_long_text clob ; 

/*******************************************************************
  Variable declaration
*******************************************************************/
g_sess_id integer;
g_last_db_check date;
g_debug_on boolean;
g_osuser log_table.osuser%type;
--
g_sess_cnt_debug     binary_integer := 0;
g_sess_cnt_info      binary_integer := 0;
g_sess_cnt_error     binary_integer := 0;
g_sess_cnt_publish   binary_integer := 0;
g_sess_cnt_info_long binary_integer := 0;
--
--
g_log_id       log_table.id%type;
v_errmsg       varchar2(2000);
/*******************************************************************
  Internal routines
*******************************************************************/

/***************************************************************************/
function bool2char ( p_flag boolean) return varchar2
/***************************************************************************/
as
begin return case when p_flag then 'True' when not p_flag then 'False' else null end;
end bool2char;

/***************************************************************************/
function debug_on
return boolean
/***************************************************************************/
as
	l_cnt integer;
begin
	dbms_output.put_line('last_db_check: '||to_char(g_last_db_check, 'dd.Mon.rr hh24:mi:ss') );
	dbms_output.put_line('debug_on: '||bool2char(g_debug_on));
	if g_debug_on then
		return g_debug_on;
	end if;
	if g_last_db_check is null 
	  or g_debug_on is null
		or sysdate-g_last_db_check > 10 / (24*60*60) -- last check more than 10 seconds ago
	then
		g_osuser := upper(sys_context('USERENV','OS_USER'));
		dbms_output.put_line('g_osuser : '||g_osuser);
		g_last_db_check := sysdate;
		select count(*) into l_cnt
		from debug_user
		where username = user
		  and (
                    -- osuser can NOT be determined
                    (g_osuser is null and osuser is null )
                    -- osuser can be determined
			or( upper(osuser) = g_osuser  or osuser is null )
			) and upper(debug_on) = 'Y'
			;
		g_debug_on := l_cnt > 0;
		dbms_output.put_line('ROWS  FOUND : '||l_cnt);
		dbms_output.put_line('last_db_check: '||g_last_db_check);
		dbms_output.put_line('debug_on: '
		||case when g_debug_on then 't' when not g_debug_on then 'f' else 'null' end);
	end if; -- check time db lookup time
	return g_debug_on;
end debug_on;

procedure p_insert (
	a_info_level   log_table.info_level%type,
	a_err_code     log_table.err_code%type default 0,
	a_comp     IN log_table.component%type,
	a_subcomp  IN log_table.subcomponent%type default null,
	a_text     IN log_table.text%type
) as
/***************************************************************************\
Procedure Description:
	The "single point of INSERT" to the log table
Parameters:

Dependencies:
Special logic:
	None
Change history
DDMMRR  Who   What
------  ---   ----------------------------------------------------------
140301  Lam   Created
\***************************************************************************/
	pragma autonomous_transaction;
begin
	/* if g_sess_id not yet set, then it is the first invocation
	of this logging package by a session
	*/
-- mysteriously, after introduction of the procedure INFO_LONG,
-- the package variable V_LOG_SESSION seems to have dual values:
-- Text message start with 'LONG LONG TEXT' has a different LOG_SESS_ID!
-- So I work around by moving the assignment into the package initialization 
-- code.
-- 
-- 	if g_sess_id is null then
-- 		g_sess_id := g_log_id;
-- 	end if;
	insert into log_table (
		id,
		log_sess_id,
		component,
		subcomponent,
		log_user,   timestamp,        info_level,
		text,
		err_code
	) values (
--		g_log_id,
		log_table_seq.nextval,
		g_sess_id,
		nvl(substr(a_comp, 1, c_comp_max_len), 'NULL'),
		substr(a_subcomp, 1, c_subcomp_max_len),
		user,       sysdate,          a_info_level,
		substr(a_text, 1, c_text_max_len),
		a_err_code
	)
	returning id into g_log_id
	;
	if g_cached_long_flag then 
		insert into long_log (id, log_time, log_text)
		values(g_log_id , sysdate, g_cached_long_text);
	end if; -- check cached_long_flag 
	commit;
end p_insert;
/*******************************************************************
  Interface routines
*******************************************************************/
PROCEDURE publish (
	a_comp     IN log_table.component%type,
	a_subcomp  IN log_table.subcomponent%type default null,
	a_text     IN log_table.text%type
) as
/***************************************************************************\
Procedure Description:
	See interface description
Parameters:
	See interface description
Dependencies:
Special logic:
	See "special logic" section of the package

\***************************************************************************/
c_procname   constant varchar2(60) := 'PUBLISH';
begin
	if g_sess_cnt_publish <= c_sess_max_publish then
		p_insert(
			a_info_level=> c_il_publish
			, a_comp=> a_comp, a_subcomp => a_subcomp
			, a_text => a_text);
	else
		if mod(g_sess_cnt_publish, c_heartbeat_modulo) = 1 then
			p_insert(a_info_level=> c_il_info
				, a_comp=> gc_pkg_name, a_subcomp=> c_procname,
				a_text=> 'Value of g_sess_cnt_PUBLISH reaches ' || g_sess_cnt_publish ||
				'. Component: ' || a_comp ||
				'. Subcomponent: ' || a_subcomp
			);
		end if;
	end if;
	g_sess_cnt_publish := g_sess_cnt_publish + 1;
exception
	when others then
		v_errmsg := sqlerrm;
		raise_application_error(-20001, 'c_procname: ' || c_procname ||' v_errmsg: ' || v_errmsg);
end;
--
PROCEDURE info (
	a_comp     IN log_table.component%type,
	a_subcomp  IN log_table.subcomponent%type default null,
	a_text     IN log_table.text%type
) as
/***************************************************************************\
\***************************************************************************/
	c_procname   constant varchar2(60) := 'INFO';
begin
	if g_sess_cnt_info <= c_sess_max_info then
		p_insert( a_info_level=>c_il_info, a_comp=> a_comp, a_subcomp=> a_subcomp
		, a_text=> a_text);
	else
		if mod(g_sess_cnt_info, c_heartbeat_modulo) = 1 then
			p_insert( a_info_level=> c_il_info, a_comp=> gc_pkg_name, a_subcomp=> c_procname,
				a_text=> 'Value of g_sess_cnt_info reaches ' || g_sess_cnt_info ||
				'. Component: ' || a_comp ||
				'. Subcomponent: ' || a_subcomp
			);
		end if;
	end if;
	g_sess_cnt_info := g_sess_cnt_info + 1;
exception
	when others then
		v_errmsg := sqlerrm;
		dbms_output.put_line('c_procname: ' || c_procname ||' v_errmsg: ' || v_errmsg);
end;
--
PROCEDURE debug (
	a_comp     IN log_table.component%type,
	a_subcomp  IN log_table.subcomponent%type default null,
	a_text     IN log_table.text%type
) as
/***************************************************************************\
Procedure Description:
	See interface description
Parameters:
	See interface description
Dependencies:
Special logic:
	See "special logic" section of the package
Change history
DDMMRR  Who   What
------  ---   ----------------------------------------------------------
140301  Lam   Created
\***************************************************************************/
	c_procname   constant varchar2(60) := 'DEBUG';
begin
	if debug_on then
		if g_sess_cnt_debug <= c_sess_max_debug then
			p_insert( a_info_level=> c_il_debug
			, a_comp=> a_comp, a_subcomp=> a_subcomp, a_text=> a_text);
		else
			if mod(g_sess_cnt_debug, c_heartbeat_modulo) = 1 then
				p_insert( a_info_level=> c_il_info, a_comp=> gc_pkg_name
				, a_subcomp=> c_procname,
					a_text => 'Value of g_sess_cnt_debug reaches ' || g_sess_cnt_debug ||
					'. Component: ' || a_comp ||
					'. Subcomponent: ' || a_subcomp
				);
			end if;
		end if;
		g_sess_cnt_debug := g_sess_cnt_debug + 1;
	end if;
exception
	when others then
		v_errmsg := sqlerrm;
		dbms_output.put_line('c_procname: ' || c_procname ||' v_errmsg: ' || v_errmsg);
end;
--
PROCEDURE error (
	a_err_code IN log_table.err_code%type,
	a_comp     IN log_table.component%type,
	a_subcomp  IN log_table.subcomponent%type default null,
	a_text     IN log_table.text%type,
	a_log_id  OUT   log_table.id%type
) as
/***************************************************************************\
Procedure Description:
	See interface description
Parameters:
	See interface description
Special logic:
	See "special logic" section of the package
Dependencies:
Change history
DDMMRR  Who   What
------  ---   ----------------------------------------------------------
140301  Lam   Created
\***************************************************************************/
	c_procname   constant varchar2(60) := 'ERROR';
begin
	a_log_id := null;
	if g_sess_cnt_error <= c_sess_max_error then
		p_insert(
			a_info_level=> c_il_error, a_err_code=> a_err_code
			, a_comp=> a_comp, a_subcomp=> a_subcomp
			, a_text=> a_text);
		a_log_id := g_log_id;
	else
		if mod(g_sess_cnt_error, c_heartbeat_modulo) = 1 then
			p_insert( a_info_level=> c_il_info
			, a_comp=> gc_pkg_name, a_subcomp=> c_procname,
				a_text=> 'Value of g_sess_cnt_error reaches ' || g_sess_cnt_error ||
				'. Component: ' || a_comp ||
				'. Subcomponent: ' || a_subcomp
			);
		end if;
	end if;
	g_sess_cnt_error := g_sess_cnt_error + 1;
exception
	when others then
		v_errmsg := sqlerrm;
		dbms_output.put_line('c_procname: ' || c_procname ||' v_errmsg: ' || v_errmsg);
end ERROR;
--
PROCEDURE switch_debug (
	a_on       boolean default FALSE
) as
/***************************************************************************\
Procedure Description:
	See interface description
Parameters:
	See interface description
Dependencies:
Special logic:
	None
Change history
DDMMRR  Who   What
------  ---   ----------------------------------------------------------
140301  Lam   Created
\***************************************************************************/
begin
	if nvl(g_debug_on , false) <> nvl( a_on, false ) 
	then
		info (
			a_comp     => gc_pkg_name,
			a_subcomp  => 'switch_debug',
			a_text     => 'switch flag to new value: '||bool2char(a_on)
				||gc_nl
				||'Call stack: '||dbms_utility.format_call_stack
			);
	end if; -- check change of flag 
	g_debug_on := a_on;
end switch_debug;

PROCEDURE info_long (
	a_comp     IN log_table.component%type,
	a_subcomp  IN log_table.subcomponent%type default null,
	a_text     IN clob
) as
/***************************************************************************\
Procedure Description:
	See interface description
Parameters:
	See interface description
Dependencies:
Special logic:
	None
\***************************************************************************/
	c_procname   constant varchar2(60) := 'INFO_LONG';
	l_text_len   integer := dbms_lob.getlength(a_text);
begin
	if l_text_len <= 1000 then 
		info(a_comp, a_subcomp, a_text); -- redirect to normal info-procedure 

		return; -- done! 
	end if; -- check text length 
	if g_sess_cnt_info_long <= c_sess_max_info_long then
		g_cached_long_flag := true;
		g_cached_long_text := a_text;
		p_insert(
			a_info_level=> c_il_info, a_comp=> a_comp, a_subcomp=> a_subcomp
		, a_text=> 'Long log text! First and last 60 chars are:('
		||dbms_lob.substr(a_text, 60,1)
		||'...'||dbms_lob.substr(a_text, 60, l_text_len-60 )
		||'). See long_log for details');
		g_cached_long_flag := false;
	else
		if mod(g_sess_cnt_info_long, c_heartbeat_modulo) = 1 then
			p_insert( a_info_level=> c_il_info, 
				a_comp=> gc_pkg_name, a_subcomp=> c_procname, 
				a_text => 
				'Value of g_sess_cnt_info_long reaches ' || g_sess_cnt_info_long ||
				'. Component: ' || a_comp ||
				'. Subcomponent: ' || a_subcomp
			);
		end if;
	end if; -- check sess_cnt_info_long 

	g_sess_cnt_info_long := g_sess_cnt_info_long + 1;
end INFO_LONG;

/***************************************************************************\
\***************************************************************************/
PROCEDURE error (
	a_err_code IN log_table.err_code%type,
	a_comp     IN log_table.component%type,
	a_subcomp  IN log_table.subcomponent%type default null,
	a_text     IN log_table.text%type
) as
	l_log_id integer;
begin
	error (
	a_err_code => a_err_code
	,a_comp     => a_comp    
	,a_subcomp  => a_subcomp 
	,a_text     => a_text    
      , a_log_id => l_log_id);          
end error;


begin -- Package init stuff 
	g_sess_id := sys_context('USERENV','SESSIONID');
end;
/

show errors

