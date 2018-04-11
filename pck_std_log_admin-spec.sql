CREATE OR REPLACE PACKAGE pck_std_log_admin
AS
   /**
    *
    * $Id: pck_std_log_admin-spec.sql 998 2011-01-30 15:34:47Z bmlam $
    * $HeadURL: http://bmlam-svn.cvsdude.com/projects/ora/dbo/service/packages/pck_std_log_admin/pck_std_log_admin-spec.sql $
    */

/******************************************************/
   PROCEDURE deact_debug 
/******************************************************/
;

END pck_std_log_admin;
/

show errors

create public synonym pck_std_log_admin for pck_std_log_admin;

