/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name, membercost FROM `Facilities` WHERE membercost > 0
/*
name			membercost
Tennis Court 1	5.0
Tennis Court 2	5.0
Massage Room 1	9.9
Massage Room 2	9.9
Squash Court	3.5
*/


/* Q2: How many facilities do not charge a fee to members? */
--4
SELECT COUNT(facid) FROM `Facilities` WHERE membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
-- Set two constraints with AND.
SELECT facid, name, membercost, `monthlymaintenance` FROM `Facilities` 
WHERE membercost > 0 AND membercost < monthlymaintenance * 0.20
/*
facid	name			membercost	monthlymaintenance
0		Tennis Court 1	5.0			200
1		Tennis Court 2	5.0			200
4		Massage Room 1	9.9			3000
5		Massage Room 2	9.9			3000
6		Squash Court	3.5			80
*/

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
-- Use a list with IN instead of OR.
SELECT * FROM `Facilities` WHERE facid IN (1, 5)
/*
facid	name				membercost	guestcost	initialoutlay	monthlymaintenance
1		Tennis Court 2		5.0			25.0		8000			200
5		Massage Room 2		9.9			80.0		4000			3000
*/

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT `name`, `monthlymaintenance`, 
CASE WHEN monthlymaintenance > 100 THEN 'expensive' 
ELSE 'cheap' END AS label
FROM `Facilities`
/* This query creates a new column called label.  The CASE statement
works like an IF THEN ELSE statement, separating over 100 from under 100,
adding descriptive names for each result.
name			monthlymaintenance	label
Tennis Court 1	200					expensive
Tennis Court 2	200					expensive
Badminton Court	50					cheap
Table Tennis	10					cheap
Massage Room 1	3000				expensive
Massage Room 2	3000				expensive
Squash Court	80					cheap
Snooker Table	15					cheap
Pool Table		15					cheap
*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT t1.firstname, t1.surname FROM Members t1
WHERE t1.joindate = (select max(t2.joindate) from Members t2)
--Darren Smith
/* This query uses the Members table twice, first in a subquery as t2 to
identify the max/latest join date, then again to find that max join date
in Members as t1, pulling the related first and last name columns. */ 


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT(CONCAT(M.surname, ', ', M.firstname, ' ', F.name)) AS Tennis_Users
FROM Bookings B 
JOIN Facilities F ON B.facid = F.facid
JOIN Members M on B.memid = M.memid
WHERE F.name LIKE ('Tennis%')
ORDER BY M.surname, M.firstname, F.name
/* It requires all three tables, utilize the IDs within Bookings to get
the member's name and the facility's name.  I used CONCAT to combine the
names into one column, and DISTINCT to list those combinations each only once.

Tennis_Users
Bader, Florence Tennis Court 1
Bader, Florence Tennis Court 2
Baker, Anne Tennis Court 1
Baker, Anne Tennis Court 2
Baker, Timothy Tennis Court 1
Baker, Timothy Tennis Court 2
Boothe, Tim Tennis Court 1
Boothe, Tim Tennis Court 2
Butters, Gerald Tennis Court 1
Butters, Gerald Tennis Court 2
Coplin, Joan Tennis Court 1
Crumpet, Erica Tennis Court 1 
*/

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT bookid as booking, name AS facility, CONCAT( firstname, ' ', surname ) AS member, 
CASE WHEN B.memid =0 THEN slots * guestcost ELSE slots * membercost END AS cost
FROM Bookings B
JOIN Facilities F ON B.facid = F.facid
JOIN Members M ON B.memid = M.memid
WHERE starttime LIKE ('2012-09-14%')
HAVING cost >30
ORDER BY cost DESC
/*
booking	facility		member			cost
2946	Massage Room 2	GUEST GUEST		320.0
2942	Massage Room 1	GUEST GUEST		160.0
2937	Massage Room 1	GUEST GUEST		160.0
2940	Massage Room 1	GUEST GUEST		160.0
2926	Tennis Court 2	GUEST GUEST		150.0
2922	Tennis Court 2	GUEST GUEST		75.0
2925	Tennis Court 1	GUEST GUEST		75.0
2920	Tennis Court 1	GUEST GUEST		75.0
2948	Squash Court	GUEST GUEST		70.0
2941	Massage Room 1	Jemima Farrell	39.6
2951	Squash Court	GUEST GUEST		35.0
2949	Squash Court	GUEST GUEST		35.0

Because the bookings are datetime stamped, I used a wildcard % to seek the date part.
This query required a CASE statement to select between using a guest or member cost.
Because we needed to sort by a mathematical result, it was achieved with HAVING clause. */

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT SubQ.bookid as booking, SubQ.name AS facility, SubQ.Mname AS member, SubQ.cost AS total_cost
FROM (SELECT bookid, starttime, name, CONCAT(firstname, ' ', surname) as Mname, 
	  CASE WHEN B.memid =0 THEN slots * guestcost ELSE slots * membercost END AS cost
      FROM Bookings B
      JOIN Facilities F ON B.facid = F.facid
      JOIN Members M ON B.memid = M.memid) SubQ
WHERE SubQ.starttime like ('2012-09-14%') 
HAVING total_cost >30
ORDER BY total_cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT name AS facility_name, 
	SUM(CASE WHEN B.memid =0 THEN slots * guestcost 
        ELSE slots * membercost END) AS total_revenue
FROM Bookings B
JOIN Facilities F ON B.facid = F.facid
JOIN Members M ON B.memid = M.memid
GROUP BY facility_name
HAVING total_revenue < 1000
ORDER BY total_revenue DESC
/*
facility_name	total_revenue
Pool Table		270.0
Snooker Table	240.0
Table Tennis	180.0
To calculate revenue by facility, the revenue records calculated by guest or member
in a CASE statement were totaled within a SUM function, and added a GROUP BY
statement to roll up by the facility name. */