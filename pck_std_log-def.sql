CREATE OR REPLACE PACKAGE pck_std_log
AS
/***************************************************************************\
Package Description:

	This package provides a way for logging and debugging from PL/SQL
	programs. It is also suitable for publishing milestone information
	for example when major load procedure have been completed successfully.
	Four levels of information are distinguished by this package:
		PUBLISHABLE
		ERROR
		INFORMATIONAL
		DEBUGGING
	See the pertaining procedure for more details.

General description of common input parameters

	A_COMPONENT
		The name of the caller_position. A possible candidate would be the
		Package name if the caller is part of a package.
		It may be the name of the calling procedure or function if it is
		stand-alone.
		Will be truncated if exceeds the length of the corresponding column

	A_SUBCOMP
		The name of the caller_position. A possible candidate would be the
		procedure name if the calling procedure is part of a package.
		It should be left blank if the calling procedure or function is
		stand-alone.
		Will be truncated if exceeds the length of the corresponding column

	A_TEXT
		Whatever is appropiately informative.
		Will be truncated if exceeds the length of the corresponding column

\***************************************************************************/
--
PROCEDURE publish (
	a_comp     IN log_table_v2.caller_position%type,
	a_subcomp  IN log_table_v2.caller_position%type default null,
	a_text     IN log_table_v2.text%type
);
/***************************************************************************\
Procedure Description:
	Log important information, like final result of a batch job, to the
	database log table. Information logged by this procedure is supposed
	to be visible by the public, for example, on the intranet.
	Bear this in mind when phrasing the text for the input text parameters.
Input parameters:
	A_COMPONENT
		See remarks on common input parameters in the package description section.
		Having pointed you to that information, it should be said that
		since this procedure is supposed to bring information to
		an audience who may be not technical at all, something more
		descriptive than package names may be used.
	A_SUBCOMP
		See remarks on common input parameters in the package description section.
		The same remarks on A_COMPONENT above applies here.
	A_TEXT
		See remarks on common input parameters in the package description section.
Output parameters:
\***************************************************************************/
--
PROCEDURE info (
	a_comp     IN log_table_v2.caller_position%type,
	a_subcomp  IN log_table_v2.caller_position%type default null,
	a_text     IN log_table_v2.text%type
);
/***************************************************************************\
Procedure Description:
	Log important information, e.g. major events in a batch process,
	to the database log table
Input parameters:
	A_COMPONENT
		See remarks on common input parameters in the package description section.
	A_SUBCOMP
		See remarks on common input parameters in the package description section.
	A_TEXT
		See remarks on common input parameters in the package description section.
Output parameters:
\***************************************************************************/
--
PROCEDURE debug (
	a_comp     IN log_table_v2.caller_position%type,
	a_subcomp  IN log_table_v2.caller_position%type default null,
	a_text     IN log_table_v2.text%type
);
/***************************************************************************\
Procedure Description:
	Log debugging information to the database log table
Input parameters:
	A_COMPONENT
		See remarks on common input parameters in the package description section.
	A_SUBCOMP
		See remarks on common input parameters in the package description section.
	A_TEXT
		See remarks on common input parameters in the package description section.
Output parameters:
\***************************************************************************/
PROCEDURE error (
	a_err_code IN log_table_v2.err_code%type,
	a_comp     IN log_table_v2.caller_position%type,
	a_subcomp  IN log_table_v2.caller_position%type default null,
	a_text     IN log_table_v2.text%type,
	a_log_id  OUT   log_table_v2.id%type
);

/***************************************************************************\
Procedure Description:
	Overload the procedure which requires an output parameter with a signature
	without output parm.
\***************************************************************************/
PROCEDURE error (
	a_err_code IN log_table_v2.err_code%type,
	a_comp     IN log_table_v2.caller_position%type,
	a_subcomp  IN log_table_v2.caller_position%type default null,
	a_text     IN log_table_v2.text%type
);

/***************************************************************************\
Procedure Description:
	Log error information to the database log table.
Input parameters:
	A_ERR_CODE
		It is recommended to use the Oracle error number when the error
		is associated with an Oracle server error. If not, the caller (or
		the programmer) should make sure it does not fall into the range
		reserved for Oracle server errors. This parameter takes a number of
		up to 10 digits. The highest Oracle server error number is 30999
		as of version 8.1.7.
	A_COMPONENT
		See remarks on common input parameters in the package description section.
	A_SUBCOMP
		See remarks on common input parameters in the package description section.
	A_TEXT
		See remarks on common input parameters in the package description section.
Output parameters:
	A_LOG_ID
		The unique id of the the log table entry where the supplied error
		information is logged. For loader tables, it can be useful to store
		this Id as a pointer to more detailed error description when load
		error are encountered.
\***************************************************************************/
--
PROCEDURE info_long (
	a_comp     IN log_table_v2.caller_position%type,
	a_subcomp  IN log_table_v2.caller_position%type default null,
	a_text     IN clob
)
;

PROCEDURE switch_debug (
	a_on       boolean default FALSE
);
/***************************************************************************\
Procedure Description:
	Set a package internal flag to controls whether calls to this
	procedure will be honoured with entries inserted into the log table.
	Bear in mind that debugging is useful only during development phase
	and ought not waste resources in a production environment.
	So only turn on this flag when you are debugging in a test environment.
Input parameters:
	A_ON
		TRUE or FALSE
Output parameters:
\***************************************************************************/

PROCEDURE dbx (
	a_text     IN log_table_v2.text%type
);

PROCEDURE inf (
	a_text     IN log_table_v2.text%type
);

PROCEDURE warn (
	a_text     IN log_table_v2.text%type
);

PROCEDURE err (
	a_text     IN log_table_v2.text%type
 ,a_errno    IN NUMBER DEFAULT NULL 
);

PROCEDURE pub (
	a_text     IN log_table_v2.text%type
);

FUNCTION count_of
( a_info_level VARCHAR2)
RETURN NUMBER
;
END; -- package 

/

show errors

GRANT EXECUTE ON PCK_STD_LOG TO PUBLIC;