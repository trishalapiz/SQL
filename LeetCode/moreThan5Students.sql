/* https://leetcode.com/problems/classes-more-than-5-students/submissions/
Runtime: 1036 ms, faster than 95.86% of MS SQL Server online submissions for Classes More Than 5 Students.
Memory Usage: 0B, less than 100.00% of MS SQL Server online submissions for Classes More Than 5 Students.*/
SELECT class
FROM courses 
GROUP BY class
HAVING COUNT(DISTINCT student) >= 5;