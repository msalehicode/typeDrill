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
