create database trigger_demo;

use trigger_demo;

create table users (
    username varchar(50),
    age int
);

insert into users(username, age) values("testy", 22);
insert into users(username, age) values("tuna", 16);

select * from users;

create trigger adult_constraint
before insert on users
for each row
begin
    if NEW.age < 18 then
        signal sqlstate '45000'
        set message_text = 'User must be at least 18 years old';
    end if;
end;

show triggers;