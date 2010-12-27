-- local objects -*-perl-*-
--
--
-- createM80[]StandardTable
-- Arg1 => tablename
-- Arg2 => custom columns In a list
-- Arg3 => List of reference tables
-- Arg4 => a List of check constraints
-- (checkConstraint1 [, .... checkConstraint1n])
-- where each check constraint is of form
-- (field, nullflag, (list of values))
--
-- some useful tokens:
-- varcharType
-- INSTANTIATION_TABLE
-- datetime
-- bigNumber
--
--
-- if nullflag is blank, nulls are not allowed
-- Arg5 => list of arguments of form (flag1,flag2=value2,flag3

createM80StandardTable(ETLManager,
                       (
			last_update DATE,
			num_errors number(5) default 0, m4_dnl when trying to update; if we fail we can record this here
                       ),
                       (),
                       (),
		       )m4_dnl;

                       


                       
