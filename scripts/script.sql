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



