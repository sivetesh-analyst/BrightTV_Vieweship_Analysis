WITH 
user_profiles AS (
SELECT UserID,

     CASE
         WHEN Province =' 'THEN 'Uncategorized'
         WHEN Province = 'None'THEN 'Uncategorized'
     ELSE Province
     END AS Region,

     age,
     CASE
        WHEN age= 0 THEN 'Infants'
        WHEN age BETWEEN 1 AND 12 THEN 'Kids'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenagers'
        WHEN age BETWEEN 20 AND 35 THEN 'Youth'
        WHEN age BETWEEN 36 AND 50 THEN 'Adults'
        WHEN age BETWEEN 51 AND 65 THEN 'Elders'
        WHEN age >65 THEN 'Pensioners'
        ELSE 'Unknown'
     END AS age_groups,

     CASE 
        WHEN (email IS NOT NULL) OR (email=' ') OR (email NOT IN ('None')) THEN 1
     ELSE 0
     END AS email_flag,

     CASE 
        WHEN `Social Media Handle` IS NOT NULL OR (`Social Media Handle`!=' ') OR (`Social Media Handle` NOT IN ('None')) THEN 1
          ELSE 0
      END AS sm_flag,

     CASE
         WHEN Race ilike ('%other%') THEN 'None'
         WHEN Race =' ' THEN 'None'
         ELSE Race
      END AS Ethnic_Groups,

    CASE
        WHEN gender IS NULL THEN 'Unknown'
        WHEN gender =' ' THEN 'None'
        ELSE gender
     END AS Gender

FROM `brighttv`.`brighttvschema`.`user_profiles`

),
viewership AS(
SELECT (COALESCE(UserID0,userid4,0)) AS userid, 

---Dates
    TO_DATE(RecordDate2) AS watch_date,---TO_CHAR(RecordDate2,'DD') AS day_of_week,To extract the date from the timestamp in our table 
    TO_CHAR(RecordDate2,'yyyyMM') AS month_id,--TO_CHAR:Converts a data into a string and TO_DATE: Converts a string into a date
    MONTHNAME(RecordDate2) AS month_name,
    DAYNAME(TO_DATE(RecordDate2)) AS day_name,

    CASE
        WHEN day_name IN('Sat', 'Sun') THEN 'weekend'
        ELSE 'weekday'
        END AS day_classification,

--TIME
    DATE_FORMAT(RecordDate2,'HH:mm:ss') AS watch_time,
    HOUR(RecordDate2) AS hour_of_day,

 CASE
     WHEN watch_time BETWEEN '00:00:00' AND '04:59:59' THEN 'Midnight'
     WHEN watch_time BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
     WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
     WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN 'Evening'
 END AS time_of_day,

 DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,

 CASE
    WHEN duration BETWEEN '00:00:00' AND '00:00:59' THEN 'Browsing'
    WHEN duration BETWEEN '00:01:00' AND '00:04:59'THEN 'Sampling'
    WHEN duration BETWEEN '00:05:00' AND '00:14:59'THEN 'Engaging'
    WHEN duration BETWEEN '00:15:00' AND '00:29:59'THEN 'Highly Engaging'
    WHEN duration BETWEEN '00:30:00' AND '00:59:59'THEN 'Immersed'
    ELSE 'Binge Watchhing'
END AS interaction,

CASE
    WHEN duration <= '00:05:00' THEN 'Low_Engagement'
    ELSE 'High_Engagement'
END AS engagement_flag,

CASE
    WHEN Channel2 IN ('Sawsee','SawSee') THEN 'SawSee'
    When Channel2 IN ('SuperSport Live Events','Live on SuperSport','Supersport Live Events','DStv Events 1') THEN 'Live Events'
    ELSE Channel2
    END AS Tv_channel

FROM brighttv.brighttvschema.viewership

)
SELECT COUNT(B.userid) AS sub_id,
watch_date,
month_id,
month_name,
day_name,
day_classification,
watch_time,
hour_of_day,
time_of_day,
duration,
interaction,
engagement_flag,
Tv_channel,
Region,
age_groups,
email_flag,
sm_flag,
Ethnic_Groups,
Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
ON A.userid=B.userid
GROUP BY ALL;
