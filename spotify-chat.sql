-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 11, 2024 at 07:12 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `spotify-chat`
--

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` tinyint(1) NOT NULL DEFAULT 0,
  `message` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `user_id`, `type`, `message`, `created_at`, `deleted_at`) VALUES
(1, 9, 0, 'hi first message', '2024-05-10 08:11:13', NULL),
(2, 10, 0, 'hello whats up', '2024-05-10 08:11:30', NULL),
(3, 10, 1, '3GZD6HmiNUhxXYf8Gch723', '2024-05-10 08:11:39', NULL),
(4, 9, 0, 'ASDASDSADAS', '2024-05-10 08:13:32', NULL),
(5, 9, 1, '7F6PtLP6fJPVtA1FWVkl8K', '2024-05-10 08:13:35', NULL),
(10, 11, 0, 'on skibidi this song goated frr', '2024-05-10 08:19:34', NULL),
(11, 11, 1, '5GUYJTQap5F3RDQiCOJhrS', '2024-05-10 08:19:36', NULL),
(12, 9, 1, '736PP5LTtREkDgktNmX3Gu', '2024-05-11 07:48:48', NULL),
(13, 9, 0, 'AHAHAHAHAHA AHA AHAHAHAHAHAHA AHA AHAHAHAHAHAHA AHA AHAHAHAHAHAHA AHA AH', '2024-05-11 11:57:46', '2024-05-11 13:10:44'),
(16, 9, 1, '2LlOeW5rVcvl3QcPNPcDus', '2024-05-11 12:13:34', NULL),
(17, 12, 0, 'HAHAHA', '2024-05-11 12:31:31', NULL),
(18, 12, 1, '6QqrxJe1iQxwLY6he6FLFo', '2024-05-11 12:31:40', NULL),
(19, 13, 0, 'hii', '2024-05-11 12:34:20', NULL),
(22, 9, 0, 'heyyyy', '2024-05-11 13:06:41', '2024-05-11 13:09:32');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `username`, `password`) VALUES
(9, 'joren', 'joren', '$2b$10$/efcTvRCRewWPDLkntDM0eBwDZalVa2yCuma2jX3enyFXqOAxM.mW'),
(10, 'chaewon', 'chaewon', '$2b$10$dxfgA0qyW6q5q8iF4fMVQefFkzlf2EupWe01m1BPpQ9YHC4mspu7S'),
(11, 'Daniel Caesar', 'daniel97x', '$2b$10$itaZwqHoVjZGBJJPI3e3dO2kZHvhxnwl9xr3A2v23rOadZoQnCjra'),
(12, 'illit', 'illit', '$2b$10$xeg6fIdy7IwaS8fnS44nOuGp59OqrYTBwapCzo03CBwBRCcSnGQJO'),
(13, 'sir ken', 'ken', '$2b$10$o6Y7vCckdClP.lZk2MyNhOse0WFBD7ZFLA.3fT48AJfA15/D9IeCG');



/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
