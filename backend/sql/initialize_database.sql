DROP SCHEMA IF EXISTS CMS;

CREATE SCHEMA CMS;

USE CMS;

CREATE TABLE IF NOT EXISTS Providers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = latin1;

CREATE TABLE IF NOT EXISTS Categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = latin1;

CREATE TABLE IF NOT EXISTS Courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    progress INT CHECK (
        progress BETWEEN 0
        AND 100
    ) NOT NULL,
    course_profile_image_link VARCHAR(255),
    notes VARCHAR(255),
    is_finished BOOLEAN GENERATED ALWAYS AS (progress = 100) VIRTUAL,
    provider_id INT NOT NULL,
    description VARCHAR(1023),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES Providers(id) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = latin1;

CREATE TABLE IF NOT EXISTS Course_Categories (
    course_id INT,
    category_id INT,
    PRIMARY KEY (course_id, category_id),
    FOREIGN KEY (course_id) REFERENCES Courses(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE CASCADE
);

INSERT INTO
    Providers (name)
VALUES
    ('Udemy'),
    ('ACloudGuru'),
    ('Coursera');

SET
    @x := (
        select
            count(*)
        from
            INFORMATION_SCHEMA.STATISTICS
        where
            TABLE_NAME = 'Courses'
            and INDEX_NAME = 'Idx_Courses_Provider_Id'
            and TABLE_SCHEMA = DATABASE()
    );

SET
    @sql := if(
        @x > 0,
        'SELECT ''Index exists.''',
        'ALTER TABLE Courses ADD INDEX Idx_Courses_Provider_Id (provider_id);'
    );

PREPARE stmt
FROM
    @sql;

EXECUTE stmt;

SET
    @x := (
        select
            count(*)
        from
            INFORMATION_SCHEMA.STATISTICS
        where
            TABLE_NAME = 'Courses'
            and INDEX_NAME = 'Idx_Courses_Progress'
            and TABLE_SCHEMA = DATABASE()
    );

SET
    @sql := if(
        @x > 0,
        'SELECT ''Index exists.''',
        'ALTER TABLE Courses ADD INDEX Idx_Courses_Progress (progress);'
    );

PREPARE stmt
FROM
    @sql;

EXECUTE stmt;

CREATE USER 'lenguyen' @'localhost' IDENTIFIED BY 'lenguyen';

GRANT ALL PRIVILEGES ON CMS.* TO 'lenguyen' @'localhost';

FLUSH PRIVILEGES;
