-- Create example table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample data
INSERT INTO users (username, email) VALUES 
    ('student1', 'student1@example.com'),
    ('student2', 'student2@example.com'),
    ('student3', 'student3@example.com');

-- Create another example table
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(100) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample posts
INSERT INTO posts (user_id, title, content) VALUES
    (1, 'First Post', 'This is my first post content.'),
    (1, 'PHP Basics', 'Learning about PHP variables and functions.'),
    (2, 'MySQL Tutorial', 'How to use MySQL with PHP.');

-- Grant permissions to the student user (already handled by environment variables, but included for completeness)
-- GRANT ALL PRIVILEGES ON studentdb.* TO 'student'@'%';
