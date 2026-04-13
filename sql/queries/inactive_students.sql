-- Inactive Students: no borrowing activity in the past 3 years
-- Returns students whose last issue_date predates 3 years ago, or who have never borrowed.
-- Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5
SELECT
    s.student_id,
    s.name,
    s.email,
    s.enrolled_date,
    MAX(ib.issue_date) AS last_activity_date
FROM Students s
LEFT JOIN IssuedBooks ib ON s.student_id = ib.student_id
GROUP BY s.student_id, s.name, s.email, s.enrolled_date
HAVING MAX(ib.issue_date) < CURRENT_DATE - INTERVAL '3 years'
    OR MAX(ib.issue_date) IS NULL
ORDER BY last_activity_date ASC NULLS FIRST;
