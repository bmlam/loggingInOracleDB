# loggingInOracleDB
A PLSQL framework to write logging and debugging information into a database table. Notable features are:
* INSERT into the table is performed as autonomous transaction
* INSERT is counted per session and logging level (see explantion below) and when a maximum count is reached, INSERT is skipped. This spares the tablespace from running filling up.
* Various logging information levels are distinguished according to the significance if the information being logged. This is in analogy to the --verbose flag found in many command line programs.

The author advocates writing logging information into a database table rather than to files due to the involved complexity of file handling. The examination or usage of the content in the files is also a real pain.
