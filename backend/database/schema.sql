-- NEW: expense_tracker (normalized history version)
CREATE DATABASE IF NOT EXISTS expense_tracker;
USE expense_tracker;

-- (1) Reference tables (same as before)
CREATE TABLE IF NOT EXISTS departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS designations (
    designation_id INT AUTO_INCREMENT PRIMARY KEY,
    designation_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- (2) Employees
CREATE TABLE IF NOT EXISTS employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_code VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(255),
    email VARCHAR(255) NOT NULL UNIQUE,
    mobile_number VARCHAR(20),
    gender ENUM('Male', 'Female'),
    category ENUM('Staff', 'Worker'),
    birth_of_date DATE,
    date_of_joining DATE,
    designation_id INT,
    department_id INT,
    location_id INT,
    last_employment_date DATE,
    first_reporting_manager_emp_code VARCHAR(100),
    second_reporting_manager_emp_code VARCHAR(100),
    FOREIGN KEY (designation_id) REFERENCES designations(designation_id) ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE SET NULL,
    FOREIGN KEY (first_reporting_manager_emp_code) REFERENCES employees(emp_code) ON DELETE SET NULL,
    FOREIGN KEY (second_reporting_manager_emp_code) REFERENCES employees(emp_code) ON DELETE SET NULL
) ENGINE=InnoDB;

-- (3) Users
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'hr', 'accounts', 'user', 'coordinator') NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    inactive_reason ENUM('terminated', 'reassigned', 'deceased') DEFAULT NULL,
    tab_permissions TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- (4) Projects
CREATE TABLE IF NOT EXISTS projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    project_code VARCHAR(100) NOT NULL UNIQUE,
    project_name VARCHAR(255) NOT NULL,
    site_location VARCHAR(255),
    site_incharge_emp_code VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (site_incharge_emp_code) REFERENCES employees(emp_code) ON DELETE SET NULL
) ENGINE=InnoDB;

-- (5) Expense form (live data)
CREATE TABLE IF NOT EXISTS expense_form (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    project_id INT NOT NULL,
    travel_receipt_path VARCHAR(255),
    special_approval_path VARCHAR(255),
    claim_amount DECIMAL(10,2) DEFAULT 0,
    status ENUM(
        'pending',
        'coordinator_approved',
        'coordinator_rejected',
        'hr_approved',
        'hr_rejected',
        'accounts_approved',
        'accounts_rejected'
    ) DEFAULT 'pending',
    coordinator_comment TEXT,
    hr_comment TEXT,
    accounts_comment TEXT,
    coordinator_reviewed_by INT,
    hr_reviewed_by INT,
    accounts_reviewed_by INT,
    coordinator_reviewed_at TIMESTAMP NULL,
    hr_reviewed_at TIMESTAMP NULL,
    accounts_reviewed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hotel_receipt_path VARCHAR(255),
    food_receipt_path VARCHAR(255),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- (6) Travel table (unchanged)
CREATE TABLE IF NOT EXISTS travel_data (
    travel_id INT AUTO_INCREMENT PRIMARY KEY,
    expense_id INT NOT NULL,
    emp_id INT NOT NULL,
    travel_date DATE NOT NULL,
    from_location VARCHAR(255) NOT NULL,
    to_location VARCHAR(255) NOT NULL,
    mode_of_transport VARCHAR(100) NOT NULL,
    fare_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (expense_id) REFERENCES expense_form(expense_id) ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- (7) Allowances & expenses (live tables)
CREATE TABLE IF NOT EXISTS journey_allowance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    expense_id INT NOT NULL,
    emp_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    scope ENUM('Daily Allowance Metro', 'Daily Allowance Non-Metro', 'Site Allowance') NOT NULL,
    no_of_days INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (expense_id) REFERENCES expense_form(expense_id) ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS return_allowance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    expense_id INT NOT NULL,
    emp_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    scope ENUM('Daily Allowance Metro', 'Daily Allowance Non-Metro', 'Site Allowance') NOT NULL,
    no_of_days INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (expense_id) REFERENCES expense_form(expense_id) ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS stay_allowance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    expense_id INT NOT NULL,
    emp_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    scope ENUM('Daily Allowance Metro', 'Daily Allowance Non-Metro', 'Site Allowance') NOT NULL,
    no_of_days INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (expense_id) REFERENCES expense_form(expense_id) ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS hotel_expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    expense_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    sharing ENUM('Single', 'Double', 'Triple') NOT NULL,
    location VARCHAR(255) NOT NULL,
    bill_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (expense_id) REFERENCES expense_form(expense_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS food_expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    expense_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    sharing INT NOT NULL,
    location VARCHAR(255) NOT NULL,
    bill_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (expense_id) REFERENCES expense_form(expense_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- (8) Allowance rates
CREATE TABLE IF NOT EXISTS allowance_rates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    designation_id INT NOT NULL,
    scope ENUM('Daily Allowance Metro','Daily Allowance Non-Metro','Site Allowance') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (designation_id) REFERENCES designations(designation_id) ON DELETE CASCADE,
    UNIQUE KEY unique_designation_scope (designation_id, scope)
) ENGINE=InnoDB;

-- ---------- Normalized History Tables ----------
-- Main history (top-level fields)
CREATE TABLE IF NOT EXISTS expense_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    expense_id INT NOT NULL,
    emp_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,         -- e.g., 'resubmitted', 'coordinator_approved'
    previous_status VARCHAR(50),
    new_status VARCHAR(50),
    claim_amount DECIMAL(10,2),
    travel_receipt_path VARCHAR(255),
    hotel_receipt_path VARCHAR(255),
    food_receipt_path VARCHAR(255),
    special_approval_path VARCHAR(255),
    coordinator_comment TEXT,
    hr_comment TEXT,
    accounts_comment TEXT,
    site_location VARCHAR(255),
    site_incharge_emp_code VARCHAR(100),
    comment TEXT,
    action_by INT,
    action_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (expense_id) REFERENCES expense_form(expense_id) ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (action_by) REFERENCES employees(emp_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Child history tables (normalized)
CREATE TABLE IF NOT EXISTS expense_history_journey (
    id INT AUTO_INCREMENT PRIMARY KEY,
    history_id INT NOT NULL,
    from_date DATE,
    to_date DATE,
    scope VARCHAR(100),
    no_of_days INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (history_id) REFERENCES expense_history(history_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS expense_history_return (
    id INT AUTO_INCREMENT PRIMARY KEY,
    history_id INT NOT NULL,
    from_date DATE,
    to_date DATE,
    scope VARCHAR(100),
    no_of_days INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (history_id) REFERENCES expense_history(history_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS expense_history_stay (
    id INT AUTO_INCREMENT PRIMARY KEY,
    history_id INT NOT NULL,
    from_date DATE,
    to_date DATE,
    scope VARCHAR(100),
    no_of_days INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (history_id) REFERENCES expense_history(history_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS expense_history_hotel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    history_id INT NOT NULL,
    from_date DATE,
    to_date DATE,
    sharing VARCHAR(50),
    location VARCHAR(255),
    bill_amount DECIMAL(10,2),
    FOREIGN KEY (history_id) REFERENCES expense_history(history_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS expense_history_food (
    id INT AUTO_INCREMENT PRIMARY KEY,
    history_id INT NOT NULL,
    from_date DATE,
    to_date DATE,
    sharing VARCHAR(50),
    location VARCHAR(255),
    bill_amount DECIMAL(10,2),
    FOREIGN KEY (history_id) REFERENCES expense_history(history_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_emp_id ON expense_form(emp_id);
CREATE INDEX IF NOT EXISTS idx_project_id ON expense_form(project_id);
CREATE INDEX IF NOT EXISTS idx_status ON expense_form(status);

-- ---------- Trigger: normalized history insertion ----------
DELIMITER //

CREATE TRIGGER before_expense_update_normalized
BEFORE UPDATE ON expense_form
FOR EACH ROW
BEGIN
    -- declare variables first
    DECLARE v_site_location VARCHAR(255) DEFAULT '';
    DECLARE v_site_incharge_emp_code VARCHAR(100) DEFAULT '';
    DECLARE v_history_id INT DEFAULT 0;
    DECLARE v_action_by INT DEFAULT NULL;

    -- only if status changed (you can expand condition later)
    IF OLD.status <> NEW.status THEN

        -- fetch project info (if any)
        SELECT COALESCE(ep.site_location, ''), COALESCE(ep.site_incharge_emp_code, '')
        INTO v_site_location, v_site_incharge_emp_code
        FROM expense_projects ep
        WHERE ep.expense_id = OLD.expense_id
        LIMIT 1;

        -- determine action_by (prefer reviewer fields if present)
        SET v_action_by = COALESCE(NEW.coordinator_reviewed_by, NEW.hr_reviewed_by, NEW.accounts_reviewed_by, OLD.emp_id);

        -- Insert into main expense_history
        INSERT INTO expense_history (
            expense_id, emp_id, action,
            previous_status, new_status,
            claim_amount, travel_receipt_path, hotel_receipt_path, food_receipt_path, special_approval_path,
            coordinator_comment, hr_comment, accounts_comment,
            site_location, site_incharge_emp_code,
            comment, action_by, action_at
        )
        VALUES (
            OLD.expense_id,
            OLD.emp_id,
            NEW.status,            -- action recorded as new status
            OLD.status,
            NEW.status,
            OLD.claim_amount,
            OLD.travel_receipt_path,
            OLD.hotel_receipt_path,
            OLD.food_receipt_path,
            OLD.special_approval_path,
            OLD.coordinator_comment,
            OLD.hr_comment,
            OLD.accounts_comment,
            v_site_location,
            v_site_incharge_emp_code,
            CONCAT('Status changed from ', OLD.status, ' to ', NEW.status),
            v_action_by,
            NOW()
        );

        -- capture inserted history_id
        SET v_history_id = LAST_INSERT_ID();

        -- Insert child rows (journey)
        INSERT INTO expense_history_journey (history_id, from_date, to_date, scope, no_of_days, amount)
        SELECT v_history_id, ja.from_date, ja.to_date, ja.scope, ja.no_of_days, ja.amount
        FROM journey_allowance ja
        WHERE ja.expense_id = OLD.expense_id;

        -- return allowance
        INSERT INTO expense_history_return (history_id, from_date, to_date, scope, no_of_days, amount)
        SELECT v_history_id, ra.from_date, ra.to_date, ra.scope, ra.no_of_days, ra.amount
        FROM return_allowance ra
        WHERE ra.expense_id = OLD.expense_id;

        -- stay allowance
        INSERT INTO expense_history_stay (history_id, from_date, to_date, scope, no_of_days, amount)
        SELECT v_history_id, sa.from_date, sa.to_date, sa.scope, sa.no_of_days, sa.amount
        FROM stay_allowance sa
        WHERE sa.expense_id = OLD.expense_id;

        -- hotel
        INSERT INTO expense_history_hotel (history_id, from_date, to_date, sharing, location, bill_amount)
        SELECT v_history_id, he.from_date, he.to_date, he.sharing, he.location, he.bill_amount
        FROM hotel_expenses he
        WHERE he.expense_id = OLD.expense_id;

        -- food
        INSERT INTO expense_history_food (history_id, from_date, to_date, sharing, location, bill_amount)
        SELECT v_history_id, fe.from_date, fe.to_date, fe.sharing, fe.location, fe.bill_amount
        FROM food_expenses fe
        WHERE fe.expense_id = OLD.expense_id;

    END IF;
END//

DELIMITER ;




SHOW TRIGGERS FROM expense_tracker;



ALTER TABLE employees
ADD COLUMN profile_image_path VARCHAR(255) AFTER mobile_number;









-- 11. Expense Projects (multiple project links to one expense)
CREATE TABLE expense_projects (
    expense_project_id INT AUTO_INCREMENT PRIMARY KEY,
    expense_id INT NOT NULL,
    project_id INT NOT NULL,
    site_location VARCHAR(255),
    site_incharge_emp_code VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (expense_id) REFERENCES expense_form(expense_id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (site_incharge_emp_code) REFERENCES employees(emp_code) ON DELETE SET NULL
) ENGINE=InnoDB;



CREATE TABLE coordinator_departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coordinator_emp_id INT NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (coordinator_emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE,
    UNIQUE KEY unique_coordinator_department (coordinator_emp_id, department_id)
) ENGINE=InnoDB;


-- 9. User Activation Tokens
CREATE TABLE user_activation_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
) ENGINE=InnoDB;













INSERT INTO departments (department_name) VALUES
('Projects'),
('IT'),
('HR'),
('Accounts'),
('Biofuels');

-- Insert dummy data for designations (example)
INSERT INTO designations (designation_name) VALUES
('Management'),
('Head'),
('Team Leader'),
('Section Leader'),
('Officer'),
('Associate'),
('DET'),
('GET'),
('MT'),
('Trainee'),
('Workers');

-- Insert dummy data for locations
INSERT INTO locations (location_name) VALUES
('Mohali'),
('Baddi');

-- Insert one employee record
INSERT INTO employees (emp_code, username, first_name, last_name, email, mobile_number, designation_id, department_id, location_id, last_employment_date)
VALUES
('EMP001', 'johndoe', 'John', 'Doe', 'johndoe@example.com', '123-456-7890', 1, 1, 1, NULL);

-- Insert corresponding user record
INSERT INTO users (emp_id, username, email, password, role, status)
VALUES
(1, 'johndoe', 'johndoe@example.com', '$2b$10$blEseyNCAc77FY2x2xAMHOkYV7Fmjupe04ANj8t4nGRp4bSnRV.sG', 'admin', 'active');



