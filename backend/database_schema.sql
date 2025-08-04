-- Pustakalaya Database Schema
-- Create database first: CREATE DATABASE pustakalaya;

-- Login table for librarians
CREATE TABLE `login` (
  `l_id` int(11) NOT NULL AUTO_INCREMENT,
  `l_name` varchar(255) NOT NULL,
  `l_email` varchar(255) NOT NULL,
  `l_password` varchar(255) NOT NULL,
  `l_mobile` varchar(10) DEFAULT NULL,
  `l_role` enum('admin','librarian') NOT NULL,
  `l_createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `l_updatedAt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`l_id`),
  UNIQUE KEY `l_email` (`l_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample librarian for testing
INSERT INTO `login` (`l_name`, `l_email`, `l_password`, `l_mobile`, `l_role`) VALUES
('राम शर्मा', 'ram@library.gov.in', 'admin123', '9876543210', 'librarian'),
('श्याम गुप्ता', 'shyam@library.gov.in', 'lib123', '9876543211', 'librarian'),
('गीता वर्मा', 'geeta@library.gov.in', 'pass123', '9876543212', 'librarian');

-- Users table (donors/library members)
CREATE TABLE `users` (
  `u_id` int(11) NOT NULL AUTO_INCREMENT,
  `u_name` varchar(255) NOT NULL,
  `u_mobile` varchar(10) NOT NULL,
  `u_email` varchar(255) DEFAULT NULL,
  `u_address` text DEFAULT NULL,
  `u_createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `u_updatedAt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`u_id`),
  UNIQUE KEY `u_mobile` (`u_mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Books table
CREATE TABLE `books` (
  `b_id` int(11) NOT NULL AUTO_INCREMENT,
  `b_title` varchar(500) NOT NULL,
  `b_author` varchar(255) NOT NULL,
  `b_isbn` varchar(13) NOT NULL,
  `b_genre` varchar(100) NOT NULL,
  `b_language` varchar(50) NOT NULL,
  `b_publication_year` int(4) DEFAULT NULL,
  `b_pages` int(11) DEFAULT NULL,
  `b_createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `b_updatedAt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`b_id`),
  UNIQUE KEY `b_isbn` (`b_isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Donations table
CREATE TABLE `donations` (
  `d_id` int(11) NOT NULL AUTO_INCREMENT,
  `d_user_id` int(11) NOT NULL,
  `d_librarian_id` int(11) NOT NULL,
  `d_books_count` int(11) NOT NULL DEFAULT 1,
  `d_certificate_path` varchar(500) DEFAULT NULL,
  `d_notes` text DEFAULT NULL,
  `d_createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `d_updatedAt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`d_id`),
  KEY `fk_donation_user` (`d_user_id`),
  KEY `fk_donation_librarian` (`d_librarian_id`),
  CONSTRAINT `fk_donation_user` FOREIGN KEY (`d_user_id`) REFERENCES `users` (`u_id`),
  CONSTRAINT `fk_donation_librarian` FOREIGN KEY (`d_librarian_id`) REFERENCES `login` (`l_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Donation books (many-to-many relationship)
CREATE TABLE `donation_books` (
  `db_id` int(11) NOT NULL AUTO_INCREMENT,
  `db_donation_id` int(11) NOT NULL,
  `db_book_id` int(11) NOT NULL,
  `db_createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`db_id`),
  KEY `fk_donation_books_donation` (`db_donation_id`),
  KEY `fk_donation_books_book` (`db_book_id`),
  CONSTRAINT `fk_donation_books_donation` FOREIGN KEY (`db_donation_id`) REFERENCES `donations` (`d_id`),
  CONSTRAINT `fk_donation_books_book` FOREIGN KEY (`db_book_id`) REFERENCES `books` (`b_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
