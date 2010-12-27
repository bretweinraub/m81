
alter table action add (actionmapper varchar(4000))
/

update action set actionmapper = mapper;

commit;

alter table action drop column mapper;
