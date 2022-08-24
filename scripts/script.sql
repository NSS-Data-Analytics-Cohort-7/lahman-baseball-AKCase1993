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