show tables;

delimiter $$
create procedure showusers()
begin
    select * from users;
end $$
delimiter ;

call showusers()