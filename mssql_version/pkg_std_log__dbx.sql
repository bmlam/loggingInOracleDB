use testdb1;
GO

IF OBJECT_ID ( 'pkg_std_log__dbx', 'P' ) IS NOT NULL
    DROP PROCEDURE pkg_std_log__dbx;
GO




CREATE PROCEDURE pkg_std_log__dbx
 @a_text    nvarchar(1000)
,@a_caller_position  varchar(100) = NULL 

AS

DECLARE   @v_dbx_cnt INT   ,@c_counter_key NVARCHAR(20)   ,@c_max_dbx_allowed INT;

BEGIN
   SET @c_counter_key = N'SESSION_DBX_COUNT';
   SET @c_max_dbx_allowed = 3;

   SELECT @v_dbx_cnt = CAST( SESSION_CONTEXT( @c_counter_key ) AS INT ); 
   IF @v_dbx_cnt IS NULL
   BEGIN
      EXEC sp_set_session_context @c_counter_key, 0;  
   END

   IF @v_dbx_cnt < @c_max_dbx_allowed
   BEGIN 
      EXEC pkg_std_log__insert_row @a_info_level = 'D', @a_text = @a_text, @a_caller_position = @a_caller_position    
      SET @v_dbx_cnt += 1;
      EXEC sp_set_session_context @c_counter_key, @v_dbx_cnt;  
      IF @v_dbx_cnt = @c_max_dbx_allowed
      BEGIN
         EXEC pkg_std_log__insert_row @a_info_level = 'W', @a_text = 'dbx quota reached. dbx messages will no longer be logged!', @a_caller_position = NULL    
      END
   END
END;
GO

