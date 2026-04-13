-- Digital Library Audit System
-- Schema DDL: Tables, Constraints, and Indexes

-- Books master catalog
CREATE TABLE Books (
    book_id          INT           NOT NULL,
    title            VARCHAR(255)  NOT NULL,
    author           VARCHAR(255)  NOT NULL,
    category         VARCHAR(100)  NOT NULL,
    total_copies     INT           NOT NULL CHECK (total_copies >= 1),
    available_copies INT           NOT NULL CHECK (available_copies >= 0),
    CONSTRAINT pk_books  PRIMARY KEY (book_id),
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies)
);

-- Students registry
CREATE TABLE Students (
    student_id    INT          NOT NULL,
    name          VARCHAR(255) NOT NULL,
    email         VARCHAR(255) NOT NULL,
    phone         VARCHAR(20),
    enrolled_date DATE         NOT NULL,
    CONSTRAINT pk_students  PRIMARY KEY (student_id),
    CONSTRAINT uq_email     UNIQUE (email),
    CONSTRAINT chk_enrolled CHECK (enrolled_date <= CURRENT_DATE)
);

-- Issued books transaction log
CREATE TABLE IssuedBooks (
    issue_id    INT  NOT NULL,
    book_id     INT  NOT NULL,
    student_id  INT  NOT NULL,
    issue_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    return_date DATE NULL,
    CONSTRAINT pk_issued         PRIMARY KEY (issue_id),
    CONSTRAINT fk_issued_book    FOREIGN KEY (book_id)    REFERENCES Books(book_id),
    CONSTRAINT fk_issued_student FOREIGN KEY (student_id) REFERENCES Students(student_id),
    CONSTRAINT chk_return_date   CHECK (return_date IS NULL OR return_date >= issue_date)
);

-- Indexes

-- Speed up overdue lookups (filter on return_date and issue_date)
CREATE INDEX idx_issued_return  ON IssuedBooks (return_date, issue_date);

-- Speed up student activity lookups
CREATE INDEX idx_issued_student ON IssuedBooks (student_id, issue_date);

-- Speed up category analysis joins
CREATE INDEX idx_books_category ON Books (category);

-- Prevent a student from having two active issues of the same book simultaneously
CREATE UNIQUE INDEX uq_active_issue ON IssuedBooks (book_id, student_id) WHERE return_date IS NULL;
