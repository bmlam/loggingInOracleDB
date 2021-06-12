use testdb1;
GO

IF OBJECT_ID ( 'pkg_std_log__info', 'P' ) IS NOT NULL
    DROP PROCEDURE pkg_std_log__info;
GO




CREATE PROCEDURE pkg_std_log__info
 @a_text    varchar(1000)
,@a_caller_position  varchar(100) = NULL 

AS

BEGIN
   EXEC pkg_std_log__insert_row @a_info_level = 'I', @a_text = @a_text, @a_caller_position = @a_caller_position    
   ;
END;
GO

