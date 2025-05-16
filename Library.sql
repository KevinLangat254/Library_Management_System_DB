-- Create the database
CREATE DATABASE IF NOT EXISTS library_management_system;
USE library_management_system;

-- Members table (1-to-M with Loans)
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(200),
    membership_date DATE NOT NULL,
    membership_status ENUM('Active', 'Expired', 'Suspended') DEFAULT 'Active',
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%')
);

-- Authors table (M-to-M with Books)
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    birth_year YEAR,
    nationality VARCHAR(50)
);

-- Publishers table (1-to-M with Books)
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    country VARCHAR(50)
);

-- Genres table (M-to-M with Books)
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- Books table (Central entity with multiple relationships)
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    publisher_id INT NOT NULL,
    publication_year YEAR,
    edition INT DEFAULT 1,
    pages INT,
    shelf_location VARCHAR(20),
    available_copies INT DEFAULT 1,
    total_copies INT DEFAULT 1,
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) 
        REFERENCES publishers(publisher_id) ON UPDATE CASCADE,
    CONSTRAINT chk_isbn CHECK (LENGTH(isbn) = 13 OR LENGTH(isbn) = 17),
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies AND available_copies >= 0)
);

-- Book-Author junction table (M-to-M relationship)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id) 
        REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Book-Genre junction table (M-to-M relationship)
CREATE TABLE book_genres (
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (book_id, genre_id),
    CONSTRAINT fk_bg_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_bg_genre FOREIGN KEY (genre_id) 
        REFERENCES genres(genre_id) ON DELETE CASCADE
);

-- Loans table (M-to-1 with Members and Books)
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    CONSTRAINT fk_loan_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON UPDATE CASCADE,
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) ON UPDATE CASCADE,
    CONSTRAINT chk_due_date CHECK (due_date > loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- Fines table (1-to-1 with Loans)
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issue_date DATE NOT NULL,
    payment_date DATE,
    status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id) ON DELETE CASCADE,
    CONSTRAINT chk_amount CHECK (amount >= 0),
    CONSTRAINT chk_payment_date CHECK (payment_date IS NULL OR payment_date >= issue_date)
);

-- Staff table (for library employees)
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    CONSTRAINT chk_staff_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_salary CHECK (salary >= 0)
);

-- Reservations table (for book holds)
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    request_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Fulfilled', 'Cancelled') DEFAULT 'Pending',
    CONSTRAINT fk_reservation_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON UPDATE CASCADE,
    CONSTRAINT fk_reservation_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) ON UPDATE CASCADE
);

-- Create indexes for performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_members_name ON members(last_name, first_name);
CREATE INDEX idx_loans_dates ON loans(loan_date, due_date);
CREATE INDEX idx_fines_status ON fines(status);