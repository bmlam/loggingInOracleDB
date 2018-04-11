create or replace procedure debug (
        p_procname  IN VARCHAR2,
        p_text      IN VARCHAR2
) AS
        vcomp log_table.component%TYPE;
        vsubcomp log_table.subcomponent%TYPE;
        vdot_pos   PLS_INTEGER := INSTR( p_procname, '.');
BEGIN
        IF vdot_pos > 1 THEN
                vcomp := SUBSTR(p_procname, 1, vdot_pos-1);
                vsubcomp := SUBSTR(p_procname,  vdot_pos+1);
        ELSE
                vcomp := p_procname;
        END IF;
        Pck_std_Log.DEBUG(vcomp, vsubcomp, p_text);
END;
/

show errors

grant execute on debug to public;

create public synonym debug for debug; 

create or replace procedure loginfo (
        p_procname  IN VARCHAR2,
        p_text      IN VARCHAR2
) AS
        vcomp log_table.component%TYPE;
        vsubcomp log_table.subcomponent%TYPE;
        vdot_pos   PLS_INTEGER := INSTR( p_procname, '.');
BEGIN
        IF vdot_pos > 1 THEN
                vcomp := SUBSTR(p_procname, 1, vdot_pos-1);
                vsubcomp := SUBSTR(p_procname,  vdot_pos+1);
        ELSE
                vcomp := p_procname;
        END IF;
        Pck_std_Log.info(
                a_comp=> vcomp, a_subcomp=> vsubcomp, a_text=> p_text);
END;
/

show errors

grant execute on loginfo to public;

CREATE PUBLIC SYNONYM loginfo FOR loginfo;

create or replace procedure logerror (
        p_procname  IN VARCHAR2,
        p_err_code IN INTEGER,
        p_text      IN VARCHAR2
) AS
        vcomp log_table.component%TYPE;
        vsubcomp log_table.subcomponent%TYPE;
        vdot_pos   PLS_INTEGER := INSTR( p_procname, '.');
	vlog_id integer;
BEGIN
        IF vdot_pos > 1 THEN
                vcomp := SUBSTR(p_procname, 1, vdot_pos-1);
                vsubcomp := SUBSTR(p_procname,  vdot_pos+1);
        ELSE
                vcomp := p_procname;
        END IF;
        Pck_std_Log.error(a_err_code=> p_err_code,
                a_comp=> vcomp, a_subcomp=> vsubcomp, a_text=> p_text
		,a_log_id => vlog_id
		);
END;
/

show errors

grant execute on logerror to public;

CREATE PUBLIC SYNONYM logerror FOR logerror;
