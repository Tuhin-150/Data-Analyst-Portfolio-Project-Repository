-- 1. How many olympics games have been held?

select count(distinct games) as total_olympic_games
    from olympics_history;
    
-- 2. List down all Olympics games held so far. (Data issue at 1956-"Summer"-"Stockholm")

    select distinct oh.year,oh.season,oh.city
    from olympics_history oh
    order by year;

-- 3. Mention the total no of nations who participated in each olympics game?

    with all_countries as
        (select games, nr.region
        from olympics_history oh
        join olympics_history_noc_regions nr ON nr.noc = oh.noc
        group by games, nr.region)
    select games, count(1) as total_countries
    from all_countries
    group by games
    order by games;
    
    -- 4. Which year saw the highest and lowest no of countries participating in olympics

      with all_countries as
              (select games, nr.region
              from olympics_history oh
              join olympics_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;
      
      -- 5. Which nation has participated in all of the olympic games
      with tot_games as
              (select count(distinct games) as total_games
              from olympics_history),
          countries as
              (select games, nr.region as country
              from olympics_history oh
              join olympics_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;
      
      -- 6. Identify the sport which was played in all summer olympics.
      with t1 as
          	(select count(distinct games) as total_summer_games
          	from olympics_history where season = 'Summer'),
          t2 as
          	(select distinct games, sport
          	from olympics_history where season = 'Summer'),
          t3 as
          	(select sport, count(1) as no_of_games
          	from t2
          	group by sport)
      select *
      from t3
      join t1 on t1.total_summer_games = t3.no_of_games;

-- 7. Which Sports were just played only once in the olympics.
      with t1 as
          	(select distinct games, sport
          	from olympics_history),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
      select t2.*, t1.games
      from t2
      join t1 on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport;

-- 8. Fetch the total no of sports played in each olympic games.
      with t1 as
      	(select distinct games, sport
      	from olympics_history),
        t2 as
      	(select games, count(1) as no_of_sports
      	from t1
      	group by games)
      select * from t2
      order by no_of_sports desc;
      
-- 9. Fetch oldest athletes to win a gold medal
    with temp as
            (select name,sex,cast(case when age = 'NA' then '0' else age end as unsigned) as age
              ,team,games,city,sport, event, medal
            from olympics_history),
        ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;

-- 10. Find the Ratio of male and female athletes participated in all olympic games.

WITH 
    t1 AS (
        SELECT sex, COUNT(*) AS cnt
        FROM olympics_history
        GROUP BY sex
    ),
    male_cnt AS (
        SELECT cnt
        FROM t1
        WHERE sex = 'M'
    ),
    female_cnt AS (
        SELECT cnt
        FROM t1
        WHERE sex = 'F'
    )
SELECT CONCAT('Male : Female = ', ROUND((SELECT cnt FROM male_cnt) / (SELECT cnt FROM female_cnt), 2)) AS ratio;

-- 11. Top 5 athletes who have won the most gold medals.
   
   with t1 as
            (select name, team, count(1) as total_gold_medals
            from olympics_history
            where medal = 'Gold'
            group by name, team
            order by total_gold_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_gold_medals desc) as rnk
            from t1)
    select * -- name, team, total_gold_medals
    from t2
	where rnk <= 5;
    
    -- 12. Top 5 athletes who have won the most medals (gold/silver/bronze).
   
   with t1 as
            (select name, team, count(1) as total_medals
            from olympics_history
            where medal in ('Gold', 'Silver', 'Bronze')
            group by name, team
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_medals desc) as rnk
            from t1)
    select * -- name, team, total_medals
    from t2
    where rnk <= 5;
    
    -- 13. Top 5 most successful countries in olympics. Success is defined by no of medals won.
    
    with t1 as
            (select nr.region, count(1) as total_medals
            from olympics_history oh
            join olympics_history_noc_regions nr on nr.noc = oh.noc
            where medal <> 'NA'
            group by nr.region
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over(order by total_medals desc) as rnk
            from t1)
    select *
    from t2
    where rnk <= 5;
    
    -- 14. List down total gold, silver and broze medals won by each country.

SELECT nr.region as country
    			, medal
    			, count(1) as total_medals
    			FROM olympics_history oh
    			JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
    			where medal <> 'NA'
    			GROUP BY nr.region,medal
    			order BY nr.region,medal;

    SELECT 
    country,
    COALESCE(SUM(CASE WHEN medal = 'Gold' THEN total_medals END), 0) AS gold,
    COALESCE(SUM(CASE WHEN medal = 'Silver' THEN total_medals END), 0) AS silver,
    COALESCE(SUM(CASE WHEN medal = 'Bronze' THEN total_medals END), 0) AS bronze
FROM (
    SELECT 
        nr.region AS country,
        medal,
        COUNT(1) AS total_medals
    FROM 
        olympics_history oh
    JOIN 
        olympics_history_noc_regions nr ON nr.noc = oh.noc
    WHERE 
        medal <> 'NA'
    GROUP BY 
        nr.region, medal
) AS medal_counts
GROUP BY 
    country
ORDER BY 
    gold DESC, silver DESC, bronze DESC;

-- 15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.

    SELECT 
    SUBSTRING_INDEX(games, ' - ', 1) AS games,
    SUBSTRING_INDEX(games, ' - ', -1) AS country,
    COALESCE(SUM(CASE WHEN medal = 'Gold' THEN total_medals END), 0) AS gold,
    COALESCE(SUM(CASE WHEN medal = 'Silver' THEN total_medals END), 0) AS silver,
    COALESCE(SUM(CASE WHEN medal = 'Bronze' THEN total_medals END), 0) AS bronze
FROM (
    SELECT 
        CONCAT(oh.games, ' - ', nr.region) AS games,
        medal,
        COUNT(1) AS total_medals
    FROM 
        olympics_history oh
    JOIN 
        olympics_history_noc_regions nr ON nr.noc = oh.noc
    WHERE 
        medal <> 'NA'
    GROUP BY 
        games, nr.region, medal
    ORDER BY 
        games, medal
) AS medal_counts
GROUP BY 
    games, country
ORDER BY 
    games;



