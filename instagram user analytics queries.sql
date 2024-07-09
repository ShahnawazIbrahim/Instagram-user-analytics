-- CHECKING TABLES
select * FROM users;
select * FROM photos;
select * FROM tags;
select * FROM photo_tags;
select * FROM likes;
select * FROM follows;
select * FROM comments;

-- A) Marketing Analysis:
-- 1. Loyal User Reward: The marketing team wants to reward the most loyal users, i.e., those who have been using the platform for the longest time.
-- Your Task: Identify the five oldest users on Instagram from the provided database.
SELECT username, created_at
FROM users 
ORDER BY created_at
LIMIT 5;

-- 2. Inactive User Engagement: The team wants to encourage inactive users to start posting by sending them promotional emails.
-- Your Task: Identify users who have never posted a single photo on Instagram.

SELECT u.id, u.username
FROM users u
LEFT JOIN photos p ON u.id = p.user_id 
WHERE p.user_id IS NULL;

-- 3. Contest Winner Declaration: The team has organized a contest where the user with the most likes on a single photo wins.
-- Your Task: Determine the winner of the contest and provide their details to the team.

with MostLikedPhoto as (SELECT 
    photo_id, COUNT(user_id) as total_likes
FROM
    likes
GROUP BY photo_id
ORDER BY COUNT(user_id) DESC
LIMIT 1)
select u.username, u.id, p.id as photo_id, MostLikedPhoto.total_likes from MostLikedPhoto
join photos p on MostLikedPhoto.photo_id = p.id
join users u on p.user_id = u.id; 

-- 4. Hashtag Research: A partner brand wants to know the most popular hashtags to use in their posts to reach the most people.
-- Your Task: Identify and suggest the top five most commonly used hashtags on the platform.

with top_tags as
(select tag_id from photo_tags 
group by tag_id
order by count(tag_id) desc 
limit 5)
select t.tag_name from top_tags
join tags t on top_tags.tag_id = t.id;

-- 5. Ad Campaign Launch: The team wants to know the best day of the week to launch ads.
-- Your Task: Determine the day of the week when most users register on Instagram. Provide insights on when to schedule an ad campaign.

select dayname(created_at) as days_of_week,
	   count(*) as num_of_users_resisters
from users
group by dayname(created_at)
order by num_of_users_resisters desc; 


-- B) Investor Metrics:

-- User Engagement: Investors want to know if users are still active and posting on Instagram or if they are making fewer posts.
-- Your Task: Calculate the average number of posts per user on Instagram. Also, provide the total number of photos on Instagram divided by the total number of users.

-- total number of users on instagram
SELECT COUNT(DISTINCT id) AS total_users_on_instagram FROM users;


-- total number of photos on instagram
SELECT COUNT(*) AS total_photos_on_instagram
FROM photos;


-- the total number of photos on Instagram divided by the total number of users

SELECT (SELECT Count(*) 
        FROM   photos) / (SELECT Count(*) 
                          FROM   users) AS avg; 
                          
--  Calculate the average number of posts per user on Instagram post count by user


select user_id, count(*)  as posts_count from photos
group by user_id
order by posts_count desc;


-- average_post per user

SELECT AVG(posts_count) as avg_posts_per_user
FROM (
select user_id, count(*)  as posts_count from photos
group by user_id
order by posts_count desc) as user_posts;



-- 2. Bots & Fake Accounts: Investors want to know if the platform is crowded with fake and dummy accounts.
-- Your Task: Identify users (potential bots) who have liked every single photo on the site, as this is not typically possible for a normal user.

select username, count(*) as num_likes
from users u 
join likes l
on u.id = l.user_id
group by l.user_id
having num_likes = (select count(*) from photos);