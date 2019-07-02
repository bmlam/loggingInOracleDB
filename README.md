# loggingInOracleDB
A PLSQL framework to write logging and debugging information into a database table. Notable features are:
* INSERT into the table is performed as autonomous transaction
* INSERT is counted per session and logging level (see explantion below) and when a maximum count is reached, INSERT is skipped. This spares the tablespace from filling up.
* Various logging information levels are distinguished according to the significance of the information being logged. This is in analogy to the --verbose flag found in many Unix command line programs.
* Since 2019 the framework is able to extract automatically from which stored procedure object and line the logging API call have been made and write the information into the column CALLER_POSITION of the logging table.
* Debug level logging can be turned on or off
* Turning on or off debugging level logging is controlled by PLSQL calls within the database session or based on logged on user or OS username
The author advocates writing logging information into a database table rather than to files due to the involved complexity of file handling. The examination or usage of the content in the files is also a real pain.
