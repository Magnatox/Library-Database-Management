REM   Script: donem  projesi script
REM   VTY dersi kutuphane database management 

CREATE TABLE Authors ( 
  author_id NUMBER PRIMARY KEY, 
  author_name VARCHAR2(100) 
);

CREATE TABLE Genres ( 
  genre_id NUMBER PRIMARY KEY, 
  genre_name VARCHAR2(100) 
);

CREATE TABLE Publishers ( 
  publisher_id NUMBER PRIMARY KEY, 
  publisher_name VARCHAR2(100) 
);

CREATE TABLE Books ( 
  book_id NUMBER PRIMARY KEY, 
  title VARCHAR2(100), 
  author_id NUMBER, 
  publication_year NUMBER, 
  ISBN VARCHAR2(20), 
  available_copies NUMBER, 
  total_copies NUMBER, 
  genre_id NUMBER, 
  publisher_id NUMBER, 
  FOREIGN KEY (author_id) REFERENCES Authors(author_id), 
  FOREIGN KEY (genre_id) REFERENCES Genres(genre_id), 
  FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id) 
);

CREATE TABLE Students ( 
  student_id NUMBER PRIMARY KEY, 
  first_name VARCHAR2(50), 
  last_name VARCHAR2(50), 
  grade NUMBER, 
  date_of_birth DATE, 
  address VARCHAR2(100), 
  contact_number VARCHAR2(20), 
  email VARCHAR2(100), 
  current_book_id NUMBER, 
  FOREIGN KEY (current_book_id) REFERENCES Books(book_id) 
);

CREATE TABLE Reports ( 
  report_id NUMBER PRIMARY KEY, 
  student_id NUMBER, 
  title VARCHAR2(100), 
  description VARCHAR2(100), 
  date_generated DATE, 
  FOREIGN KEY (student_id) REFERENCES Students(student_id) 
);

CREATE TABLE Staff ( 
  staff_id NUMBER PRIMARY KEY, 
  name VARCHAR2(100), 
  email VARCHAR2(100), 
  genre_id NUMBER, 
  FOREIGN KEY (genre_id) REFERENCES Genres(genre_id) 
);

CREATE TABLE Authentication ( 
  user_id NUMBER PRIMARY KEY, 
  username VARCHAR2(100), 
  password_hash VARCHAR2(100), 
  role VARCHAR2(100), 
  staff_id NUMBER, 
  student_id NUMBER, 
  FOREIGN KEY (staff_id) REFERENCES Staff(staff_id), 
  FOREIGN KEY (student_id) REFERENCES Students(student_id) 
);

CREATE TABLE Library_Cards ( 
  card_number VARCHAR2(10) PRIMARY KEY, 
  student_id NUMBER, 
  issue_date DATE, 
  expiry_date DATE, 
  FOREIGN KEY (student_id) REFERENCES Students(student_id) 
);

CREATE TABLE Loans ( 
  loan_id NUMBER PRIMARY KEY, 
  card_number VARCHAR2(10), 
  student_id NUMBER, 
  book_id NUMBER, 
  loan_date DATE, 
  return_date DATE, 
  FOREIGN KEY (card_number) REFERENCES Library_Cards(card_number), 
  FOREIGN KEY (student_id) REFERENCES Students(student_id), 
  FOREIGN KEY (book_id) REFERENCES Books(book_id) 
);

CREATE OR REPLACE TRIGGER enforce_one_book 
BEFORE INSERT OR UPDATE ON Loans 
FOR EACH ROW 
DECLARE 
    student_current_books NUMBER; 
BEGIN 
    -- Check the number of books currently borrowed by the student 
    SELECT COUNT(*) INTO student_current_books 
    FROM Loans 
    WHERE student_id = :NEW.student_id 
      AND return_date IS NULL; 
 
    -- If the student already has a borrowed book, raise an exception 
    IF student_current_books >= 1 THEN 
        raise_application_error(-20001, 'Students are allowed to borrow only one book at a time.'); 
    END IF; 
END; 
/

CREATE OR REPLACE TRIGGER enforce_card_expiry 
BEFORE INSERT OR UPDATE ON Loans 
FOR EACH ROW 
DECLARE 
    card_expiry_date DATE; 
BEGIN 
    -- Retrieve the expiry date of the library card for the student 
    SELECT expiry_date INTO card_expiry_date 
    FROM Library_Cards 
    WHERE card_number = :NEW.card_number; 
 
    -- If the card has expired, raise an exception 
    IF card_expiry_date < SYSDATE THEN 
        raise_application_error(-20002, 'Cannot borrow books. Library card has expired.'); 
    END IF; 
END; 
/

CREATE OR REPLACE TRIGGER enforce_genre_count 
BEFORE INSERT OR UPDATE ON Staff 
FOR EACH ROW 
DECLARE 
    genre_count NUMBER; 
BEGIN 
    -- Check the number of genres managed by the staff member 
    SELECT COUNT(*) INTO genre_count 
    FROM Staff 
    WHERE staff_id = :NEW.staff_id; 
 
    -- If the staff member already manages three genres, raise an exception 
    IF genre_count >= 3 THEN 
        raise_application_error(-20003, 'A staff member can manage at most three genres.'); 
    END IF; 
END; 
/

INSERT INTO Authors (author_id, author_name) 
VALUES (1, 'Jane Austen');

INSERT INTO Authors (author_id, author_name) 
VALUES (2, 'Charles Dickens');

INSERT INTO Authors (author_id, author_name) 
VALUES (3, 'Mark Twain');

INSERT INTO Authors (author_id, author_name) 
VALUES (4, 'Emily Bronte');

INSERT INTO Authors (author_id, author_name) 
VALUES (5, 'Agatha Christie');

INSERT INTO Genres (genre_id, genre_name) 
VALUES (1, 'Romance');

INSERT INTO Genres (genre_id, genre_name) 
VALUES (2, 'Mystery');

INSERT INTO Genres (genre_id, genre_name) 
VALUES (3, 'Science Fiction');

INSERT INTO Genres (genre_id, genre_name) 
VALUES (4, 'Fantasy');

INSERT INTO Genres (genre_id, genre_name) 
VALUES (5, 'Thriller');

INSERT INTO Publishers (publisher_id, publisher_name) 
VALUES (1, 'Penguin Books');

INSERT INTO Publishers (publisher_id, publisher_name) 
VALUES (2, 'HarperCollins');

INSERT INTO Publishers (publisher_id, publisher_name) 
VALUES (3, 'Random House');

INSERT INTO Publishers (publisher_id, publisher_name) 
VALUES (4, 'Simon & Schuster');

INSERT INTO Publishers (publisher_id, publisher_name) 
VALUES (5, 'Macmillan Publishers');

INSERT INTO Books (book_id, title, author_id, publication_year, ISBN, available_copies, total_copies, genre_id, publisher_id) 
VALUES (1, 'Pride and Prejudice', 1, 1813, '9780141439518', 5, 10, 1, 1);

INSERT INTO Books (book_id, title, author_id, publication_year, ISBN, available_copies, total_copies, genre_id, publisher_id) 
VALUES (2, 'Great Expectations', 2, 1861, '9780141439563', 8, 12, 2, 2);

INSERT INTO Books (book_id, title, author_id, publication_year, ISBN, available_copies, total_copies, genre_id, publisher_id) 
VALUES (3, 'Adventures of Huckleberry Finn', 3, 1884, '9780199536559', 3, 7, 3, 3);

INSERT INTO Books (book_id, title, author_id, publication_year, ISBN, available_copies, total_copies, genre_id, publisher_id) 
VALUES (4, 'Wuthering Heights', 4, 1847, '9780141439556', 6, 10, 4, 4);

INSERT INTO Books (book_id, title, author_id, publication_year, ISBN, available_copies, total_copies, genre_id, publisher_id) 
VALUES (5, 'Murder on the Orient Express', 5, 1934, '9780062693662', 4, 6, 2, 5);

INSERT INTO Students (student_id, first_name, last_name, grade, date_of_birth, address, contact_number, email, current_book_id) 
VALUES (1, 'John', 'Doe', 10, TO_DATE('2005-05-15', 'YYYY-MM-DD'), '123 Main St', '123-456-7890', 'john.doe@example.com', NULL);

INSERT INTO Students (student_id, first_name, last_name, grade, date_of_birth, address, contact_number, email, current_book_id) 
VALUES (2, 'Jane', 'Smith', 11, TO_DATE('2004-08-22', 'YYYY-MM-DD'), '456 Elm St', '987-654-3210', 'jane.smith@example.com', 2);

INSERT INTO Students (student_id, first_name, last_name, grade, date_of_birth, address, contact_number, email, current_book_id) 
VALUES (3, 'Michael', 'Johnson', 9, TO_DATE('2006-03-10', 'YYYY-MM-DD'), '789 Oak St', '555-123-4567', 'michael.johnson@example.com', 3);

INSERT INTO Students (student_id, first_name, last_name, grade, date_of_birth, address, contact_number, email, current_book_id) 
VALUES (4, 'Sarah', 'Williams', 12, TO_DATE('2003-11-28', 'YYYY-MM-DD'), '321 Pine St', '555-987-6543', 'sarah.williams@example.com', 4);

INSERT INTO Students (student_id, first_name, last_name, grade, date_of_birth, address, contact_number, email, current_book_id) 
VALUES (5, 'David', 'Brown', 11, TO_DATE('2004-06-05', 'YYYY-MM-DD'), '567 Walnut St', '555-789-1234', 'david.brown@example.com', 1);

INSERT INTO Reports (report_id, student_id, title, description, date_generated) 
VALUES (1, 1, 'Late Book Return', 'The student returned the book after the due date.', SYSDATE);

INSERT INTO Reports (report_id, student_id, title, description, date_generated) 
VALUES (2, 2, 'Damaged Book', 'The book was returned with pages torn.', SYSDATE);

INSERT INTO Reports (report_id, student_id, title, description, date_generated) 
VALUES (3, 3, 'Lost Book', 'The student lost the borrowed book.', SYSDATE);

INSERT INTO Reports (report_id, student_id, title, description, date_generated) 
VALUES (4, 4, 'Late Book Return', 'The student returned the book after the due date.', SYSDATE);

INSERT INTO Reports (report_id, student_id, title, description, date_generated) 
VALUES (5, 5, 'Late Book Return', 'The student returned the book after the due date.', SYSDATE);

INSERT INTO Staff (staff_id, name, email, genre_id) 
VALUES (1, 'Mary Smith', 'mary.smith@example.com', 1);

INSERT INTO Staff (staff_id, name, email, genre_id) 
VALUES (2, 'John Johnson', 'john.johnson@example.com', 2);

INSERT INTO Staff (staff_id, name, email, genre_id) 
VALUES (3, 'Emily Davis', 'emily.davis@example.com', 3);

INSERT INTO Staff (staff_id, name, email, genre_id) 
VALUES (4, 'Daniel Wilson', 'daniel.wilson@example.com', 4);

INSERT INTO Staff (staff_id, name, email, genre_id) 
VALUES (5, 'Laura Thompson', 'laura.thompson@example.com', 5);

INSERT INTO Authentication (user_id, username, password_hash, role, staff_id, student_id) 
VALUES (1, 'mary_smith', 'password123', 'staff', 1, NULL);

INSERT INTO Authentication (user_id, username, password_hash, role, staff_id, student_id) 
VALUES (2, 'john_johnson', 'password456', 'staff', 2, NULL);

INSERT INTO Authentication (user_id, username, password_hash, role, staff_id, student_id) 
VALUES (3, 'emily_davis', 'password789', 'staff', 3, NULL);

INSERT INTO Authentication (user_id, username, password_hash, role, staff_id, student_id) 
VALUES (4, 'daniel_wilson', 'password987', 'staff', 4, NULL);

INSERT INTO Authentication (user_id, username, password_hash, role, staff_id, student_id) 
VALUES (5, 'laura_thompson', 'password321', 'staff', 5, NULL);

INSERT INTO Library_Cards (card_number, student_id, issue_date, expiry_date) 
VALUES ('LC001', 1, SYSDATE, TO_DATE('2024-06-15', 'YYYY-MM-DD'));

INSERT INTO Library_Cards (card_number, student_id, issue_date, expiry_date) 
VALUES ('LC002', 2, SYSDATE, TO_DATE('2024-06-15', 'YYYY-MM-DD'));

INSERT INTO Library_Cards (card_number, student_id, issue_date, expiry_date) 
VALUES ('LC003', 3, SYSDATE, TO_DATE('2024-06-15', 'YYYY-MM-DD'));

INSERT INTO Library_Cards (card_number, student_id, issue_date, expiry_date) 
VALUES ('LC004', 4, SYSDATE, TO_DATE('2024-06-15', 'YYYY-MM-DD'));

INSERT INTO Library_Cards (card_number, student_id, issue_date, expiry_date) 
VALUES ('LC005', 5, SYSDATE, TO_DATE('2024-06-15', 'YYYY-MM-DD'));

INSERT INTO Loans (loan_id, card_number, student_id, book_id, loan_date, return_date) 
VALUES (1, 'LC001', 1, 1, SYSDATE, NULL);

INSERT INTO Loans (loan_id, card_number, student_id, book_id, loan_date, return_date) 
VALUES (2, 'LC002', 2, 2, SYSDATE, SYSDATE + 90);

INSERT INTO Loans (loan_id, card_number, student_id, book_id, loan_date, return_date) 
VALUES (3, 'LC003', 3, 3, SYSDATE, SYSDATE + 90);

INSERT INTO Loans (loan_id, card_number, student_id, book_id, loan_date, return_date) 
VALUES (4, 'LC004', 4, 4, SYSDATE, NULL);

INSERT INTO Loans (loan_id, card_number, student_id, book_id, loan_date, return_date) 
VALUES (5, 'LC005', 5, 5, SYSDATE, NULL);

SELECT * FROM Books;

SELECT * FROM Books WHERE available_copies > 0;

SELECT * FROM Books WHERE publication_year = 1884;

SELECT * FROM Books WHERE genre_id = 2;

SELECT * FROM Books 
JOIN Loans ON Books.book_id = Loans.book_id 
WHERE Loans.student_id = 5;

SELECT * FROM Students 
JOIN Loans ON Students.student_id = Loans.student_id 
WHERE Loans.return_date IS NULL;

SELECT available_copies FROM Books WHERE book_id = 3;

SELECT COUNT(*) FROM Loans WHERE student_id = 5;

SELECT COUNT(*) FROM Loans WHERE loan_date BETWEEN TO_DATE('1882-06-15', 'YYYY-MM-DD')AND TO_DATE('2024-06-15', 'YYYY-MM-DD');

SELECT * FROM Reports WHERE student_id = 3;

SELECT * FROM Staff WHERE genre_id = 4;

