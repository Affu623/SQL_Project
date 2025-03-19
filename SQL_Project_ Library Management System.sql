CREATE DATABASE LibraryDB;

USE LibraryDB;

CREATE TABLE Books (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(100) NOT NULL,
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Price DECIMAL(6,2),
    Stock INT DEFAULT 1
);

CREATE TABLE Members (
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    JoinDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE BorrowedBooks (
    BorrowID INT PRIMARY KEY AUTO_INCREMENT,
    MemberID INT,
    BookID INT,
    BorrowDate DATE DEFAULT (CURRENT_DATE),
    ReturnDate DATE,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);


INSERT INTO Books (Title, Author, Genre, Price, Stock) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', 10.99, 5),
('1984', 'George Orwell', 'Dystopian', 8.99, 3),
('To Kill a Mockingbird', 'Harper Lee', 'Classic', 12.50, 4);

INSERT INTO Members (FullName, Email, Phone) VALUES
('Alice Johnson', 'alice@example.com', '123-456-7890'),
('Bob Smith', 'bob@example.com', '987-654-3210');


INSERT INTO BorrowedBooks (MemberID, BookID, BorrowDate, ReturnDate)
VALUES (1, 2, '2025-03-10', '2025-03-20');


SELECT Members.FullName, Books.Title, BorrowedBooks.BorrowDate, BorrowedBooks.ReturnDate
FROM BorrowedBooks
JOIN Members ON BorrowedBooks.MemberID = Members.MemberID
JOIN Books ON BorrowedBooks.BookID = Books.BookID;


SELECT Members.FullName, COUNT(BorrowedBooks.BorrowID) AS BooksBorrowed
FROM Members
LEFT JOIN BorrowedBooks ON Members.MemberID = BorrowedBooks.MemberID
GROUP BY Members.FullName;

SELECT Title, Stock FROM Books WHERE Stock > 0;


DELIMITER //
CREATE TRIGGER ReduceStock AFTER INSERT ON BorrowedBooks
FOR EACH ROW
BEGIN
    UPDATE Books SET Stock = Stock - 1 WHERE BookID = NEW.BookID;
END //
DELIMITER ;





