DECLARE	
   no_such_object exception;
   PRAGMA EXCEPTION_INIT(no_such_object, -04043);
BEGIN
   execute immediate 'drop FUNCTION CONTEXT';
EXCEPTION
   WHEN no_such_object THEN
     NULL;
END;
/

