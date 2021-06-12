use testdb1;
GO

IF OBJECT_ID ( 'pkg_std_log__insert_row', 'P' ) IS NOT NULL
    DROP PROCEDURE pkg_std_log__insert_row;
GO




CREATE PROCEDURE pkg_std_log__insert_row
 @a_info_level   varchar(1)
,@a_text    varchar(1000)
,@a_err_code     smallint = NULL 
,@a_caller_position  varchar(100) = NULL 

AS
DECLARE 
   @v_log_sess_id varchar(40),
   @v_db_name_prefix_max_len int,
   @v_login_time_str varchar(15),
   @v_os_user  varchar(30),
   @v_log_user varchar(30)
   ;
BEGIN
   -- WRap as inner transaction ! 
   SELECT @v_login_time_str = format ( login_time, 'yyyyMMdd_HHmmss')
      , @v_os_user = substring( nt_user_name, 1, 30 )
      , @v_log_user = substring( login_name, 1, 30 )
   FROM sys.dm_exec_sessions    where session_id = @@spid
   ;
   SET @v_db_name_prefix_max_len = 40 - 1 /*separator*/- 5 /*spid*/ - 1 /*separator*/ - 15 /*login time*/  
   ;
   SET @v_log_sess_id = substring( db_name(), 1, @v_db_name_prefix_max_len );
   SET @v_log_sess_id += ':' +  CAST( @@spid as varchar(5) );
   SET @v_log_sess_id += ':' +  @v_login_time_str;

   INSERT INTO testdb1.dbo.LOG_TABLE ( 
      text, err_code, info_level 
      ,log_sess_id,   caller_position,   osuser,   log_user
   ) VALUES (
      @a_text, @a_err_code, @a_info_level
      ,@v_log_sess_id, @a_caller_position, @v_os_user, @v_log_user
   );
   COMMIT;
END;
GO

