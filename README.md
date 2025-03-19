# SQL_Project

**Library Management System**

**Overview**

The Library Management System is a simple SQL-based project designed to manage books, members, and borrowed books efficiently. This project includes database creation, table structures, data insertion, queries, and a trigger to update book stock when borrowed.

**Features**

Book Management: Store and manage books with details like title, author, genre, price, and stock.

Member Management: Store library members' details.

Borrowing System: Keep track of borrowed books and return dates.

Stock Update: Automatically update book stock when a book is borrowed.

**Database Schema**

--Tables:

---Books

BookID (Primary Key, Auto Increment)

Title (VARCHAR, Not Null)

Author (VARCHAR)

Genre (VARCHAR)

Price (DECIMAL)

Stock (INT, Default 1)

---Members

MemberID (Primary Key, Auto Increment)

FullName (VARCHAR, Not Null)

Email (VARCHAR, Unique, Not Null)

Phone (VARCHAR)

JoinDate (TIMESTAMP, Default Current Timestamp)

---BorrowedBooks

BorrowID (Primary Key, Auto Increment)

MemberID (Foreign Key -> Members)

BookID (Foreign Key -> Books)

BorrowDate (DATE, Default Current Date)

ReturnDate (DATE)

**SQL Queries**

1. Retrieve all borrowed books with member details:

SELECT Members.FullName, Books.Title, BorrowedBooks.BorrowDate, BorrowedBooks.ReturnDate
FROM BorrowedBooks
JOIN Members ON BorrowedBooks.MemberID = Members.MemberID
JOIN Books ON BorrowedBooks.BookID = Books.BookID;

2. Count total books borrowed by each member:

SELECT Members.FullName, COUNT(BorrowedBooks.BorrowID) AS BooksBorrowed
FROM Members
LEFT JOIN BorrowedBooks ON Members.MemberID = BorrowedBooks.MemberID
GROUP BY Members.FullName;

3. List available books in stock:

SELECT Title, Stock FROM Books WHERE Stock > 0;

Triggers

Auto-update stock when a book is borrowed:

DELIMITER //
CREATE TRIGGER ReduceStock AFTER INSERT ON BorrowedBooks
FOR EACH ROW
BEGIN
    UPDATE Books SET Stock = Stock - 1 WHERE BookID = NEW.BookID;
END //
DELIMITER ;

Installation & Setup

Create the Database:

CREATE DATABASE LibraryDB;
USE LibraryDB;

Create Tables: Execute the SQL commands to create tables.

Insert Sample Data: Add initial book and member records.

Run Queries: Perform SELECT queries to retrieve data.

Enable Triggers: Ensure the trigger works for stock updates.

Conclusion

This project demonstrates a basic library management system using SQL, helping to track books, members, and borrowed transactions efficiently. It can be extended further with advanced features like fines for late returns and book reservations.
