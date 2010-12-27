
--
-- The data that is lifted out of this window becomes

--
-- forpe
--

-- 1. Flat runs with constant iterations.
--
-- 2. Flat runs with scheduled rampup (runs for a fixed period after rampup).
--
-- 3. Rampup runs (two periods; one in which we are constantly addind users, two a short period of constat load).

--
-- 1. loadrunner.scheduled.data.run.type='untilcompletion';

--
-- 2. loadrunner.scheduled.data.run.type= forperiodafterrampup



create or replace view LR_SCHEDULE_V AS
	select  distinct
		to_number(hh) hours,
		to_number(mm) minutes,
		to_number(ss) seconds,
--		to_char(to_number(hh),'00') || ':' || to_char(to_number(mm),'00')  || ':' || to_char(to_number(ss),'00') time,
		(to_number(hh) * (60 * 60)) + (to_number(mm) * 60) + to_number(ss) total_seconds,
		h.task_id,
		fix.value LRA_Fixed_DBName
	from 	(
			select 	tag, 
				value hh,
				task_id
			from 	task_context 
			where 	tag =  'loadrunner.schedule.duration.run.for.hh'
			and 	source like '%override%'
		) h,
		(
			select 	tag, 
				value mm,
				task_id
			from 	task_context 
			where 	tag =  'loadrunner.schedule.duration.run.for.mm'
			and 	source like '%override%'
		) m,
		(
			select 	tag, 
				value ss,
				task_id
			from 	task_context 
			where 	tag =  'loadrunner.schedule.duration.run.for.ss'
			and 	source like '%override%'
		) s,
		(
			select 	task_id, 	
				value 	
			from 	task_context 
			where 	tag = 'LRA_Fixed_DBName'
		) fix
	where h.task_id = m.task_id
	and m.task_id = s.task_id
	and s.task_id = fix.task_id

