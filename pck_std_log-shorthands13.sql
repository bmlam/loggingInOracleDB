create or replace procedure debugv13 (
        p_comp  IN VARCHAR2,
        p_subcomp  IN VARCHAR2 default null,
        p_line  IN NUMBER default null,
        p_text      IN VARCHAR2
) AS
BEGIN
        Pck_std_Log.debug(
                a_comp=> p_comp, a_subcomp=> p_subcomp
				, a_text=> CASE when p_line is not null then 'Line '||p_line||':' end || p_text
				);
END;
/


show errors

grant execute on debugv13 to public;

create public synonym debugv13 for debugv13; 

create or replace procedure loginfov13 (
        p_comp  IN VARCHAR2,
        p_subcomp  IN VARCHAR2 default null,
        p_line  IN NUMBER default null,
        p_text      IN VARCHAR2
) AS
BEGIN
        Pck_std_Log.info(
                a_comp=> p_comp, a_subcomp=> p_subcomp
				, a_text=> CASE when p_line is not null then 'Line '||p_line||':' end || p_text
				);
END;
/

show errors

grant execute on loginfov13 to public;

CREATE PUBLIC SYNONYM loginfov13 FOR loginfov13;

create or replace procedure logerrorv13 (
        p_comp  IN VARCHAR2,
        p_subcomp  IN VARCHAR2 default null,
        p_line  IN NUMBER default null,
        p_text      IN VARCHAR2
) AS
BEGIN
        Pck_std_Log.error(
                a_comp=> p_comp, a_subcomp=> p_subcomp
				, a_text=> CASE when p_line is not null then 'Line '||p_line||':' end || p_text
				, a_err_CODE => 0
				);
END;
/

show errors

grant execute on logerrorv13 to public;

CREATE PUBLIC SYNONYM logerrorv13 FOR logerrorv13;
