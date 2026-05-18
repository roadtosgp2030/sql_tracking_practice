select *
from users
order by created_at
limit 5;

select dayname(created_at) as day, count(*) as total
from users
group by day
order by total desc
limit 1;

select username
from users
         left join photos on users.id = photos.user_id
where photos.id is NULL;

select username, image_url, count(*) as total_like
from users
         join photos on users.id = photos.user_id
         join likes on photos.id = likes.photo_id
group by username, image_url
order by count(*) desc
limit 1;

select (
    (select count(*) from photos) / (select count(*) from users)
) as avg;

select tag_name, count(*)
from tags
         join photo_tags on tags.id = photo_tags.tag_id
group by tag_name
order by count(*) desc
limit 5;

select tag_id, count(*)
from photo_tags
group by tag_id
order by count(*) desc;

select username
from likes
         join users on likes.user_id = users.id
group by user_id
having count(*) = (select count(*) from photos);
