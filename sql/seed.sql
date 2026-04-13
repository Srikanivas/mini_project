-- Digital Library Audit System
-- Seed / Sample Data Script
-- Exercises all audit queries and DML operations

-- ============================================================
-- BOOKS (10 books across 4+ categories)
-- Some books have available_copies < total_copies (currently issued)
-- ============================================================
INSERT INTO Books (book_id, title, author, category, total_copies, available_copies) VALUES
-- Science Fiction (3 books)
(1,  'Dune',                          'Frank Herbert',      'Science Fiction', 3, 1),
(2,  'Neuromancer',                   'William Gibson',     'Science Fiction', 2, 1),
(3,  'The Left Hand of Darkness',     'Ursula K. Le Guin',  'Science Fiction', 2, 2),
-- History (2 books)
(4,  'Sapiens',                       'Yuval Noah Harari',  'History',         4, 3),
(5,  'The Guns of August',            'Barbara Tuchman',    'History',         2, 2),
-- Mathematics (2 books)
(6,  'Godel Escher Bach',             'Douglas Hofstadter', 'Mathematics',     2, 1),
(7,  'The Art of Problem Solving',    'Richard Rusczyk',    'Mathematics',     3, 3),
-- Literature (2 books)
(8,  'One Hundred Years of Solitude', 'Gabriel Garcia Marquez', 'Literature',  3, 2),
(9,  'Crime and Punishment',          'Fyodor Dostoevsky',  'Literature',      2, 2),
-- Technology (1 book)
(10, 'The Pragmatic Programmer',      'Andrew Hunt',        'Technology',      4, 4);

-- ============================================================
-- STUDENTS (8 students)
-- student_id 7: no borrow history at all
-- student_id 8: last borrow was > 3 years ago (inactive)
-- student_id 6: last borrow was > 3 years ago (inactive, has phone)
-- ============================================================
INSERT INTO Students (student_id, name, email, phone, enrolled_date) VALUES
(1, 'Alice Johnson',  'alice@university.edu',   '555-0101', '2021-09-01'),
(2, 'Bob Martinez',   'bob@university.edu',     '555-0102', '2021-09-01'),
(3, 'Carol White',    'carol@university.edu',   NULL,       '2022-01-15'),
(4, 'David Lee',      'david@university.edu',   '555-0104', '2020-09-01'),
(5, 'Eva Brown',      'eva@university.edu',     NULL,       '2022-09-01'),
(6, 'Frank Wilson',   'frank@university.edu',   '555-0106', '2019-09-01'),
(7, 'Grace Kim',      'grace@university.edu',   '555-0107', '2023-01-10'),  -- no borrow history
(8, 'Henry Adams',    'henry@university.edu',   NULL,       '2018-09-01');  -- last borrow > 3 years ago

-- ============================================================
-- ISSUED BOOKS (15+ rows)
-- Covers: active issues, returned issues, overdue issues, historical records
-- ============================================================
INSERT INTO IssuedBooks (issue_id, book_id, student_id, issue_date, return_date) VALUES

-- Active issues (return_date IS NULL, recent issue_date)
-- Exercises: active_issues.sql, return_book.sql
(1,  1,  1, CURRENT_DATE - INTERVAL '3 days',  NULL),   -- Alice has Dune (active, not overdue)
(2,  6,  2, CURRENT_DATE - INTERVAL '5 days',  NULL),   -- Bob has Godel Escher Bach (active, not overdue)
(3,  8,  3, CURRENT_DATE - INTERVAL '7 days',  NULL),   -- Carol has 100 Years of Solitude (active, not overdue)

-- Overdue issues (issue_date > 14 days ago, return_date IS NULL)
-- Exercises: overdue_books.sql
(4,  4,  4, CURRENT_DATE - INTERVAL '20 days', NULL),   -- David has Sapiens (overdue 20 days)
(5,  2,  5, CURRENT_DATE - INTERVAL '30 days', NULL),   -- Eva has Neuromancer (overdue 30 days)
(6,  1,  2, CURRENT_DATE - INTERVAL '45 days', NULL),   -- Bob also has Dune copy (overdue 45 days)

-- Returned issues (return_date IS NOT NULL)
-- Exercises: category_popularity.sql (borrow counts per category)
(7,  1,  1, '2024-01-10', '2024-01-20'),   -- Alice returned Dune (Science Fiction)
(8,  2,  3, '2024-02-01', '2024-02-10'),   -- Carol returned Neuromancer (Science Fiction)
(9,  3,  4, '2024-03-05', '2024-03-15'),   -- David returned Left Hand of Darkness (Science Fiction)
(10, 4,  1, '2024-04-01', '2024-04-12'),   -- Alice returned Sapiens (History)
(11, 5,  2, '2024-05-10', '2024-05-20'),   -- Bob returned Guns of August (History)
(12, 6,  3, '2024-06-01', '2024-06-14'),   -- Carol returned Godel Escher Bach (Mathematics)
(13, 8,  4, '2024-07-15', '2024-07-25'),   -- David returned 100 Years of Solitude (Literature)
(14, 9,  5, '2024-08-01', '2024-08-10'),   -- Eva returned Crime and Punishment (Literature)
(15, 10, 1, '2024-09-01', '2024-09-15'),   -- Alice returned Pragmatic Programmer (Technology)

-- Historical records for inactive student detection
-- student_id 8 (Henry): last borrow was in 2020, > 3 years ago
-- Exercises: inactive_students.sql, delete_inactive_students.sql
(16, 7,  8, '2020-03-10', '2020-03-25'),   -- Henry returned Art of Problem Solving (historical)
(17, 5,  8, '2020-06-15', '2020-06-28'),   -- Henry returned Guns of August (historical)

-- student_id 6 (Frank): last borrow was in 2021, > 3 years ago
(18, 9,  6, '2021-01-05', '2021-01-18'),   -- Frank returned Crime and Punishment (historical)
(19, 10, 6, '2021-04-20', '2021-05-02');   -- Frank returned Pragmatic Programmer (historical)

-- ============================================================
-- NOTES ON COVERAGE
--
-- overdue_books.sql    : issue_ids 4, 5, 6 (issue_date > 14 days ago, return_date NULL)
-- category_popularity  : all 5 categories have borrow events; Science Fiction leads
-- inactive_students    : student 7 (Grace) has no borrows; students 6 & 8 last borrowed > 3 yrs ago
-- active_issues.sql    : issue_ids 1-6 (return_date IS NULL)
-- issue_book.sql       : books 3, 5, 7, 9, 10 have available_copies > 0 and no active issues
-- return_book.sql      : issue_ids 1-6 are active and can be returned
-- delete_inactive_students : students 6, 7, 8 qualify as inactive
-- reconcile_availability   : operates on all books; verifies available_copies consistency
-- ============================================================
