-- -*-sql-*- --
-----------------------------------------------------------------
-- Package:		P_TASK_CONTEXT
--
-- Date:		
--
-- Description:		

-- The only procedure that should be public is ARCHIVE_TABLE.

-- This is the first rev at what it takes to manually partition
-- an oracle table. Much hardcode with the expectation that this
-- will be refactored and abstracted, simplified and templated.

-- It is also HAPPY PATH.

-- That said...

-- The task_context table contains data whose date is really tied
-- to the task.updated_dt table. That table is self-referential, 
-- which means that all date based queries on the task_context table
-- actually include a nested hierarchical sub-query on the task table.
-- The data that ends up in a particular task_context dated table
-- may not actually be within the date range of the table itself. This
-- is expected - since the date information is tied to task, which is 
-- then tied to task_context.

-- Given a date (today) figure out a date that is about 1 month
-- earlier. (date minus the number of days in the month that date
-- occurs in). This value is the "pivot date". For each month 
-- prior to the month that pivot date occurs in, create a new 
-- task_context table named for the date_year that it represents. 
-- All the remaining data (pivot date to date) put into a temporary task_context table.

-- Make sure that the indexes and triggers are correct.

-- Move the current task_context table to one named for the
-- day_month_year and move the temporary task_context table to "task_context".

-- After running this code, you will want to run a mos patch
-- to rebuild the TASK_CONTEXT_V. That view union alls the task_context
-- table with all the dated task_context tables.

-- All tools should continue to work correctly against the
-- task_context table. But - things like smtop and dumpc
-- will only show data if it occurs within the window of data
-- that is in the current task_context table. (By default that data
-- is somewhere between 28 and 60 days).

--
-- FUNCTIONS
--

-- PIVOT_DAY:
-- given a date, calculate the "pivot date".

-- CREATE_DATED_PARTITION_TABLE:
-- given a month and a year, build a "context_table_p_month_year"
-- table that contains just the relevant data for that time period.

-- CREATE_DATED_PARTITION_TABLES:
-- loop through the month and years prior to the pivot date and
-- call CREATE_DATED_PARTITION_TABLE.

-- CREATE_CURRENT_PARTITION_TABLE:
-- create the task_context_new table with data from the pivot date
-- through sysdate.

-- DROP_INDICIES:
-- drop all indicies in the database on the task_context_p_% tables.
-- This isn't actually needed or called.

-- DROP_TRIGGERS:
-- drop all triggers in the database on the task_context_p_% tables.
-- This isn't actually needed or called.

-- ARCHIVE_TABLE:
-- Said public interface to this package.

-- REVERT:
-- development function to drop all dated and temporary tables.

--
-----------------------------------------------------------------
--
PROMPT Creating PACKAGE BODY P_TASK_CONTEXT.
CREATE OR REPLACE PACKAGE BODY P_TASK_CONTEXT AS

        no_of_days      number(3);

--
-- NAME: PIVOT_DAY
-- ARGS: base_date <date>
--       window <number>
-- RETURN: <date>
-- DESC: given base_date, window, return the date that is the first day of the month
--       where the month is determined from base_date - window
--
FUNCTION        PIVOT_DAY
(
        base_date        date
)
RETURN date
IS
        day             date;
BEGIN

IF no_of_days is null THEN
        select to_number(to_char(last_day(base_date), 'DD')) + 1 
        into no_of_days 
        from dual;
END IF;

-- dbms_output.put_line( 'PIVOT_DAY: no_of_days is ' || no_of_days );

select to_date(to_char((base_date - no_of_days), 'Mon-YY'), 'Mon-YY')
into day
from dual;

-- dbms_output.put_line( 'PIVOT_DAY: internal calculation day is ' || day );
RETURN day;

END;



PROCEDURE     	CREATE_DATED_PARTITION_TABLE
(
	month		varchar2,
	year            varchar2
)
IS
	start_date      varchar2(10);
        end_date        varchar2(10);
        sql_stmt        varchar2(5000);
        table_name      varchar2(50)    := 'TASK_CONTEXT_P_';
BEGIN

IF length(month) = 1 THEN
        table_name := table_name || '0' || month;
else
        table_name := table_name || month;
END IF;
table_name := table_name || '_';

IF length(year) = 1 THEN
        table_name := table_name || '0' || year;
else
        table_name := table_name || year;
END IF;

select to_char(to_date(month || '-' || year, 'MM-YY'), 'DD-Mon-YY') into start_date from dual;
select to_char(last_day(to_date(month || '-' || year, 'MM-YY')), 'DD-Mon-YY') into end_date from dual;

dbms_output.put_line('CREATE_DATED_PARTITION_TABLE: start_date -> ' || start_date || '  end_date -> ' || end_date );
dbms_output.put_line('CREATE_DATED_PARTITION_TABLE: creating table ' || table_name  );

execute immediate 'create table ' || table_name || ' as 
                        select *
                        from task_context
                        where task_id in (
                                select  task_id
                                from task
                                start with task_id in (
                                                        select  t.task_id
                                                        from task t
                                                        where t.parent_task_id is null
                                                        and t.updated_dt >= to_date(''' || start_date || ' 00:00:00'', ''DD-Mon-YY hh24:mi:ss'') 
                                                        and t.updated_dt <= to_date(''' || end_date   || ' 23:59:59'', ''DD-Mon-YY hh24:mi:ss'')
                                                     )
                                connect by prior task_id = parent_task_id
                        )
               ';       
END;


PROCEDURE       CREATE_DATED_PARTITION_TABLES
(
        pivot_date_in date
)
IS
        cursor task_context_dates is
                select distinct to_number(to_char(updated_dt, 'MM')) month, 
                                to_number(to_char(updated_dt, 'YYYY')) year 
                from    task 
                where   updated_dt < PIVOT_DAY(pivot_date_in)
                and     updated_dt >= (select min(updated_dt) from task_context)
                order by year, month;

        task_context_rec        task_context_dates%rowtype;
        month   number(2);
        year    number(4);

BEGIN

        for task_context_rec in task_context_dates loop
--                DBMS_OUTPUT.PUT_LINE( 'CREATE_DATED_PARTITION_TABLES: month -> ' || task_context_rec.month || '  year -> ' || task_context_rec.year );
                DBMS_OUTPUT.PUT_LINE( 'CREATE_DATED_PARTITION_TABLE( to_char( ' || task_context_rec.month || ' ), to_char( ' || task_context_rec.year || ' ) ); ' );
                CREATE_DATED_PARTITION_TABLE( to_char( task_context_rec.month  ), to_char( task_context_rec.year ) );
        end loop;
END;


PROCEDURE       CREATE_CURRENT_PARTITION_TABLE
(
        some_day        date
)
IS
BEGIN
        dbms_output.put_line('CREATE_CURRENT_PARTITION_TABLE: creating task_context_new');
        execute immediate '
                CREATE TABLE TASK_CONTEXT_NEW AS
                SELECT *
                FROM task_context
                WHERE task_id in (
                        SELECT task_id
                        FROM task
                        START WITH task_id in (
                                SELECT task_id
                                FROM task
                                WHERE updated_dt >= P_TASK_CONTEXT.PIVOT_DAY(''' || to_char(some_day, 'DD-Mon-YY') || ''')
                                and parent_task_id is null
                        )
                        CONNECT BY PRIOR task_id = parent_task_id
                )
        ';
        dbms_output.put_line('CREATE_CURRENT_PARTITION_TABLE: create the m80 task_context_pk index');
        -- all m80 derived tables have this
        execute immediate 'alter table task_context_new 
                                add constraint task_context_new_PK 
                                primary key (task_context_ID)';

        dbms_output.put_line('CREATE_CURRENT_PARTITION_TABLE: creating the task_id index on task_context_new');
        -- this is hardcoded in a patch
        execute immediate 'create index task_context_new_task_id on task_context_new(task_id)';

        dbms_output.put_line('CREATE_CURRENT_PARTITION_TABLE: creating the insert trigger on task_context_new');
        -- m80 generated triggers on the inserted_dt and updated_dt fields                
        execute immediate '
create or replace trigger task_context_new_INSERT
before insert on task_context_new
for each row
declare
begin
   if DBMS_REPUTIL.FROM_REMOTE = FALSE THEN

     IF :old.task_context_id IS NULL THEN
         SELECT task_context_S.NEXTVAL INTO :new.task_context_id FROM DUAL; 
     END IF;
     :new.inserted_dt := SYSDATE;
   end if;
end;
';
        dbms_output.put_line('CREATE_CURRENT_PARTITION_TABLE: creating the update trigger on task_context_new');
        execute immediate '
create or replace trigger task_context_new_UPDATE
before update on task_context_new
for each row
declare
begin
   if DBMS_REPUTIL.FROM_REMOTE = FALSE THEN
     :new.updated_dt := SYSDATE;
   end if;
end;
';

END;


PROCEDURE       DROP_INDICIES
IS
        cursor task_context_indexes is
                select  index_name,
                        table_name
                from    user_indexes
                where   table_name = 'TASK_CONTEXT'
                and     index_name not like '%PK';
        index_name              user_indexes.index_name%type;
        index_table_name        user_indexes.table_name%type;
BEGIN
        --
        -- drop and fix the indexes.
        --
        OPEN task_context_indexes;
        LOOP FETCH task_context_indexes into index_name, index_table_name;
                EXIT WHEN task_context_indexes%NOTFOUND;
                dbms_output.put_line('DROP_INDICIES: dropping ' || index_name);
                execute immediate 'drop index ' || index_name;
        END LOOP;
END;


PROCEDURE       DROP_TRIGGERS
IS

        cursor task_context_triggers is
                select  trigger_name,
                        table_name
                from    user_triggers
                where   table_name = 'TASK_CONTEXT';
        trigger_name            user_triggers.trigger_name%type;
        trigger_table_name      user_triggers.table_name%type;
BEGIN
        --
        -- drop and fix the triggers.
        --
        OPEN task_context_triggers;
        LOOP FETCH task_context_triggers into trigger_name, trigger_table_name;
                EXIT WHEN task_context_triggers%NOTFOUND;
                dbms_output.put_line('DROP_TRIGGERS: dropping ' || trigger_name);
                execute immediate 'drop trigger ' || trigger_name;
        END LOOP;
END;


PROCEDURE       ARCHIVE_TABLE
IS
        day   number(2);
        month   number(2);
        year    number(4);
BEGIN
        lock table task_context in exclusive mode;
        -- build the partition tables
        P_TASK_CONTEXT.CREATE_DATED_PARTITION_TABLES(sysdate);
        P_TASK_CONTEXT.CREATE_CURRENT_PARTITION_TABLE(sysdate);
--        P_TASK_CONTEXT.DROP_INDICIES;
--        P_TASK_CONTEXT.DROP_TRIGGERS;

        select distinct to_number(to_char(sysdate, 'DD')) day, 
                        to_number(to_char(sysdate, 'MM')) month, 
                        to_number(to_char(sysdate, 'YYYY')) year 
        into day, month, year
        from dual;

        execute immediate ' alter table task_context rename to task_context_old_' || day || '_' || month || '_' || year;
        execute immediate ' alter table task_context_new rename to task_context';

        commit;
END;


PROCEDURE       REVERT
IS
        cursor task_context_table is
                select table_name from user_tables where table_name like 'TASK_CONTEXT_P_%';
        task_context_rec        task_context_table%rowtype;
BEGIN
        for task_context_rec in task_context_table loop
                dbms_output.put_line('DROP_TABLE: dropping ' || task_context_rec.table_name);
                execute immediate 'drop table ' || task_context_rec.table_name;
        end loop;
        dbms_output.put_line('DROP_TABLE: dropping task_context_new');
        execute immediate 'drop table task_context_new';
        
END;
                
END;
