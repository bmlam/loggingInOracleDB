begin
	pck_std_log.switch_debug(true);
	for i in 1 .. 9999 loop
		pck_std_log.debug('TEST', 'MEAN GUY', 'Msg ' || i);
		pck_std_log.dbx( 'MEAN GUY flooding i:' || i);
	end loop;
end;
/
