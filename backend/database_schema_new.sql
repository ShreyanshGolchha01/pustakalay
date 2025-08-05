-- Pustakalaya Library Management System Database Schema
-- Updated version with new table structure

-- Create database
CREATE DATABASE IF NOT EXISTS pustakalaya;
USE pustakalaya;

-- Login table for librarians and admins
CREATE TABLE `login` (
  `l_id` int(11) NOT NULL AUTO_INCREMENT,
  `l_name` varchar(255) NOT NULL,
  `l_email` varchar(255) NOT NULL,
  `l_password` varchar(255) NOT NULL,
  `l_mobile` varchar(10) DEFAULT NULL,
  `l_role` enum('admin','librarian') NOT NULL,
  `l_createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `l_updatedAt` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`l_id`),
  UNIQUE KEY `unique_email` (`l_email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Donors table
CREATE TABLE `donors` (
  `u_id` int(11) NOT NULL AUTO_INCREMENT,
  `u_name` varchar(255) NOT NULL,
  `u_mobile` varchar(10) NOT NULL,
  `ul_id` int(11) NOT NULL,
  `u_createdat` timestamp NOT NULL DEFAULT current_timestamp(),
  `u_updatedat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`u_id`),
  UNIQUE KEY `unique_mobile` (`u_mobile`),
  KEY `fk_lib_1` (`ul_id`),
  CONSTRAINT `fk_lib_1` FOREIGN KEY (`ul_id`) REFERENCES `login` (`l_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Books table
CREATE TABLE `books` (
  `b_id` int(11) NOT NULL AUTO_INCREMENT,
  `b_title` varchar(255) NOT NULL,
  `b_author` varchar(255) NOT NULL,
  `b_genre` varchar(255) NOT NULL,
  `b_count` int(5) NOT NULL DEFAULT 1,
  `bl_id` int(11) NOT NULL,
  `b_createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `b_updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`b_id`),
  KEY `fk_lib_2` (`bl_id`),
  KEY `idx_title_author` (`b_title`, `b_author`),
  CONSTRAINT `fk_lib_2` FOREIGN KEY (`bl_id`) REFERENCES `login` (`l_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Donations table
CREATE TABLE `donations` (
  `d_id` int(11) NOT NULL AUTO_INCREMENT,
  `du_id` int(11) NOT NULL,
  `dl_id` int(11) NOT NULL,
  `db_id` int(11) NOT NULL,
  `d_count` int(11) NOT NULL,
  `d_createdat` timestamp NOT NULL DEFAULT current_timestamp(),
  `d_updatedat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`d_id`),
  KEY `fk_user_3` (`du_id`),
  KEY `fk_lib_4` (`dl_id`),
  KEY `fk_book_1` (`db_id`),
  CONSTRAINT `fk_book_1` FOREIGN KEY (`db_id`) REFERENCES `books` (`b_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lib_4` FOREIGN KEY (`dl_id`) REFERENCES `login` (`l_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_3` FOREIGN KEY (`du_id`) REFERENCES `donors` (`u_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Files table for certificate storage
CREATE TABLE `files` (
  `f_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_path` varchar(512) NOT NULL,
  `f_user_id` int(11) NOT NULL,
  `f_lib_id` int(11) NOT NULL,
  `f_createdat` timestamp NOT NULL DEFAULT current_timestamp(),
  `f_updatedat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`f_id`),
  KEY `fk_user_2` (`f_user_id`),
  KEY `fk_lib_3` (`f_lib_id`),
  CONSTRAINT `fk_lib_3` FOREIGN KEY (`f_lib_id`) REFERENCES `login` (`l_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_2` FOREIGN KEY (`f_user_id`) REFERENCES `donors` (`u_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data
-- Sample librarian account
INSERT INTO `login` (`l_name`, `l_email`, `l_password`, `l_mobile`, `l_role`) VALUES
('Test Librarian', 'librarian@library.gov.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '9876543210', 'librarian'),
('Admin User', 'admin@library.gov.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '9876543211', 'admin');

-- Sample books
INSERT INTO `books` (`b_title`, `b_author`, `b_genre`, `b_count`, `bl_id`) VALUES
('गीता', 'व्यास', 'धर्म', 5, 1),
('रामायण', 'वाल्मीकि', 'धर्म', 3, 1),
('हरी घास के ये दिन', 'फणीश्वरनाथ रेणु', 'साहित्य', 2, 1),
('गोदान', 'मुंशी प्रेमचंद', 'उपन्यास', 4, 1),
('कामायनी', 'जयशंकर प्रसाद', 'काव्य', 2, 1);

-- Sample donors
INSERT INTO `donors` (`u_name`, `u_mobile`, `ul_id`) VALUES
('राम शर्मा', '9876543210', 1),
('सीता देवी', '9876543211', 1),
('गीता पटेल', '9876543212', 1);

-- Sample donations
INSERT INTO `donations` (`du_id`, `dl_id`, `db_id`, `d_count`) VALUES
(1, 1, 1, 2),
(1, 1, 2, 1),
(2, 1, 3, 1),
(3, 1, 4, 2);
