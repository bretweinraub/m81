CREATE OR REPLACE FUNCTION DECIMAL_TO_DATE (
	num	number
) RETURN VARCHAR2
IS 
	retval 	varchar2(32);
BEGIN
	select replace (trunc (num) || ':' || to_char (trunc (((num - trunc (num)) * 60)), '09'), ' ', '') into retval from dual;

	return retval;
END;
