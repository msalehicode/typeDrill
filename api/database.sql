CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,              -- Unique user ID
    username VARCHAR(255) NOT NULL UNIQUE,           -- Username (must be unique)
    password VARCHAR(255) NOT NULL,                  -- Hashed password
    email VARCHAR(255) NOT NULL UNIQUE,              -- User's email (must be unique)
    sessionKey VARCHAR(255) NULL,                    -- Session key (nullable)
    sessionExpireDate DATETIME NULL,                 -- Session expiration date (nullable)
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,    -- Date when the user was created
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Timestamp of last update
    verification_code VARCHAR(32) NOT NULL,
    is_verified BOOLEAN DEFAULT 0
);


CREATE TABLE files
(
    id INT AUTO_INCREMENT PRIMARY KEY,               -- Unique file ID
    user_id INT NOT NULL,                             -- User who uploaded the file (foreign key from `users`)
    filename VARCHAR(255) NOT NULL,                   -- File name (may include timestamps to handle duplicates)
    file_path VARCHAR(255) NOT NULL,                  -- File path in the server
    first_uploaded DATETIME DEFAULT CURRENT_TIMESTAMP, -- Timestamp of first upload
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Last update timestamp
    visibility ENUM('private', 'public') DEFAULT 'private', -- File visibility (public/private)
    FOREIGN KEY (user_id) REFERENCES users(id)       -- Foreign key linking to the `users` table
);
