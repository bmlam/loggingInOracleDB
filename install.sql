--drop table debug_user;
--drop package pck_std_log;

sta /Users/bmlam/Dropbox/github-bmlam/loggingInOracleDB/log_table.sql
sta /Users/bmlam/Dropbox/github-bmlam/loggingInOracleDB/long_log.sql
sta /Users/bmlam/Dropbox/github-bmlam/loggingInOracleDB/debug_user.sql


sta /Users/bmlam/Dropbox/github-bmlam/loggingInOracleDB/pck_std_log-def.sql
sta /Users/bmlam/Dropbox/github-bmlam/loggingInOracleDB/pck_std_log-impl.sql

create or replace public synonym pck_std_log for pck_std_log;
