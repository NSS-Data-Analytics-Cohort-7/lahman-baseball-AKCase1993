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
ROUND((ROUND(AVG(so),2) / (SUM(g) / 2)), 2) AS avg_so_pg,
	ROUND((ROUND(AVG(hr),2) / (SUM(g) / 2)), 2) AS avg_hr_pg,
        Case When yearid >= '1920' And yearid <= '1929' Then '1920s'
        When yearid >= '1930' And yearid <= '1939' Then '1930s'
		When yearid >= '1940' And yearid <= '1949' Then '1940s'
		When yearid >= '1950' And yearid <= '1959' Then '1950s'
		When yearid >= '1960' And yearid <= '1969' Then '1960s'
		When yearid >= '1970' And yearid <= '1979' Then '1970s'
		When yearid >= '1980' And yearid <= '1989' Then '1980s'
		When yearid >= '1990' And yearid <= '1999' Then '1990s'
		When yearid >= '2000' And yearid <= '2009' Then '2000s'
		When yearid >= '2010' And yearid <= '2019' Then '2010s'
		End AS decade
From teams
Where yearid >= '1920'
Group by decade
Order By decade DESC



--Question 6 Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
Select
	Distinct b.playerid,
	p.namefirst,
	p.namelast,
	Cast(b.sb AS numeric) AS bases_stolen,
	Cast(b.cs AS numeric) AS caught_stealing,
	Cast(b.sb AS numeric) + Cast(b.cs AS numeric) AS attempts,
	Round((Cast(b.sb AS numeric) / (Cast(b.sb AS numeric) + Cast(b.cs AS numeric))), 2) AS success
FROM batting AS b
JOIN people AS p
ON b.playerid = p.playerid
WHERE b.yearid = '2016'
GROUP BY
	b.playerid,
	p.namefirst,
	p.namelast,
	b.sb,
	b.cs
HAVING CAST(sb AS numeric) + CAST(cs AS numeric) >= 20
ORDER BY success DESC;