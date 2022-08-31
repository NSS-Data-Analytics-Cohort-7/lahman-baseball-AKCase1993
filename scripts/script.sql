Select Max(yearid), Min(yearid)
From appearances
-- Question 1: 1871-2016

--Question 2 Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

Select p.namegiven, t.name, a.g_all, p.height
From people AS p
Inner Join appearances AS a
USING (playerid)
Inner Join teams AS t
Using (teamid)
Group By p.namegiven, t.name, a.g_all, p.height
Order By p.height
Limit 1

-- Edward Carl, St. Louis Browns, 1 game played, 43 in tall

--Question 3 Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

Select
	Concat(Cast(p.namefirst AS text), ' ', Cast(p.namelast AS text)) AS full_name,
	s.schoolname,
	SUM(sa.salary) AS total_salary_earned
From people AS p
Join collegeplaying AS c
ON p.playerid = c.playerid
Join schools AS s
ON c.schoolid = s.schoolid
Join salaries AS sa
ON p.playerid = sa.playerid
Where s.schoolname = 'Vanderbilt University'
Group By full_name,
	s.schoolname
Order By total_salary_earned DESC 
-- David Price, $245,553,888.

-- Question 4 Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

Select
	Sum(po) AS total_putouts,
	Case When pos = 'OF' THEN 'Outfield'
		When pos = 'SS'
			OR pos = '1B'
			OR pos = '2B'
			OR pos = '3B' THEN 'Infield'
		ELSE 'Battery' END AS position
From fielding
Where yearid = '2016'
Group BY position

-- Battery= 41424, Infield= 58934, Outfield= 29560

-- Question 5 Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

Select 
    Case When (yearid/10)*10 = 2010 Then Concat((yearid/10)*10, '-', ((yearid/10)*10)+6)
        Else Concat((yearid/10)*10,'-',((yearid/10)*10)+9) End AS decade,
    Round(Cast(Sum(so) AS Decimal)/Cast(Sum(g)/2 AS Decimal), 2) AS avg_strikeouts,
    Round(Cast(Sum(hr) AS Decimal)/Cast(Sum(g)/2 AS Decimal), 2) AS avg_homeruns
From teams
Where yearid >= '1920'
Group by decade
Order By decade 


--Question 6 Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.


Select batting.playerid,
	namefirst,
	namelast,
	Sum(sb) AS successful_sb,
	Sum(sb + cs) AS total_attempts,
	Sum(sb)/Cast(Sum(sb +cs) AS decimal(10,2))*100 AS successful_attempts
From batting
Left Join people
ON batting.playerid = people.playerid
Where batting.yearid = '2016'
Group By batting.playerid,
	namefirst,
	namelast
Having Sum(sb + cs) >= 20
Order BY successful_attempts DESC

-- Question 7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT yearid,
	name, 
	MAX(w)
FROM teams
WHERE wswin = 'N'
	AND yearid BETWEEN 1970 AND 2016
GROUP BY yearid,
	name
ORDER BY MAX(w) DESC
    
-- Largest number of wins for team that lostwin World Series: 116, Seattle Mariners, 2001
Select yearid,
	name, 
	MIN(w)
From teams
Where wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
Group BY yearid,
	name
Order BY MIN(w);
-- Smallest number of wins for team that won the World Series: 83, St. Louis Cardinals, 2006

With top_scores AS
(SELECT DISTINCT a.yearid,
	a.name,
	a.w,
	a.wswin
FROM teams AS a
INNER JOIN (
	SELECT yearid,
			MAX(w) AS w
	FROM teams
	GROUP BY yearid
	ORDER BY yearid) AS b
ON a.yearid = b.yearid AND a.w = b.w
WHERE a.yearid BETWEEN 1970 AND 2016)
SELECT SUM(CASE WHEN wswin = 'Y' THEN 1
		   WHEN wswin = 'N' THEN 0 END) AS total
	FROM top_scores
-- Number of times team with most wins won World Series: 12 

WITH top_scores AS
(SELECT DISTINCT a.yearid,
	a.w,
	a.wswin
FROM teams AS a
Inner Join (
		SELECT yearid,
				MAX(w) AS w
		FROM teams
		GROUP BY yearid
		ORDER BY yearid) AS b
ON a.yearid = b.yearid AND a.w = b.w
WHERE a.yearid BETWEEN 1970 AND 2016)
Select Cast(AVG(CASE WHEN wswin = 'Y' THEN 1.0
		   WHEN wswin = 'N' THEN 0.0 END)*100.0 AS DECIMAL(10,2)) AS avg
	FROM top_scores
-- Percent of times team with most wins won World Series: 25%

-- Question 8 Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT 
	p.park_name,
	t.name,
	(h.attendance / h.games) AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON h.park = p.park
INNER JOIN teams AS t
ON h.team = t.teamid
WHERE h.year = '2016' 
	AND t.yearid = '2016'
	AND h.games >= 10
GROUP BY
	p.park_name,
	t.name,
	h.attendance,
    h.games
ORDER BY avg_attendance DESC;
--TOP AVERAGE ATTENDANCE:
	/*Dodger Stadium, Los Angeles Dodgers, 45719
	Busch Stadium III, St. Louis Cardinals, 42524
	Rogers Centre, Toronto Blue Jays, 41877
	AT&T Park, San Francisco Giants, 41546
	Wrigley Field, Chicago Cubs, 39906*/
SELECT 
	p.park_name,
	t.name,
	(h.attendance / h.games) AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON h.park = p.park
INNER JOIN teams AS t
ON h.team = t.teamid
WHERE h.year = '2016' 
	AND t.yearid = '2016'
	AND h.games >= 10
GROUP BY
    p.park_name,
	t.name,
	h.attendance,
	h.games
ORDER BY avg_attendance

-- BOTTOM AVERAGE ATTENDANCE:
	/*Tropicana Field, Tampa Bay Rays, 15878
	Oakland-Alameda County Coliseum, Oakland Athletics, 18784
	Progressive Field, Cleveland Indians, 19650
	Marlins Park, Miami Marlins, 21405
	U.S. Cellular Field, Chicago White Sox, 21559*/

--Question 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award. 

SELECT * 
FROM awardsmanagers;
-- playerid
SELECT *
FROM people;
-- playerid
SELECT *
FROM teams;
-- teamid
SELECT *
FROM managers;


WITH a AS (
	SELECT namefirst as first,
	namelast as last,
	am.yearid,
	awardid,
	p.playerid,
	lgid
	FROM awardsmanagers as am
	FULL join people as p
	ON am.playerid = p.playerid
	WHERE lgid = 'AL'
	AND awardid = 'TSN Manager of the Year'
	order by namelast, yearid),
b AS (
	SELECT namefirst as first,
	namelast as last,
	am.yearid,
	awardid,
	p.playerid,
	lgid
	FROM awardsmanagers as am
	FULL join people as p
	ON am.playerid = p.playerid
	WHERE lgid = 'NL'
	AND awardid = 'TSN Manager of the Year'
	order by namelast, yearid)
-- c AS (SELECT *
-- 	  FROM teams AS T
-- 	 LEFT JOIN managers as M
-- 	 USING (teamid)
	
SELECT a.first,
	a.last,
	 a.yearid AS AL_year,
	 a.lgid AS AL_award,
	b.yearid AS NL_year,
	b.lgid AS NL_award,
	t.name
FROM a
INNER JOIN b 
ON a.playerid = b.playerid
LEFT JOIN managers as m
ON m.playerid = a.playerid
LEFT JOIN teams as t
ON t.teamid = m.teamid
ORDER BY nl_year

--Question 10 Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

With homers as(
Select playerid,
    Max(hr) as twentysixteenhr
From batting
Where yearid = 2016
Group by playerid)


Select b.playerid,
    Concat(p.namefirst, ' ', p.namelast) as namefull,
    Max(hr) AS actualmaxhomers,
    twentysixteenhr
From batting AS b
Left Join homers
ON b.playerid = homers.playerid
Inner Join people as p
    ON b.playerid = p.playerid
Where twentysixteenhr > 0
Group BY b.playerid, twentysixteenhr, namefull
Having Max(hr) = twentysixteenhr
    And Max(yearid) - min(yearid) >= 10
Order BY Max(b.hr) Desc

-- Question 11 Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.