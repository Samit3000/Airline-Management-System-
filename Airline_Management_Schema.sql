-- ============================================
-- DATABASE SETUP
-- ============================================

CREATE DATABASE IF NOT EXISTS airline_mgmt;
USE airline_mgmt;

-- ============================================
-- AIRPORTS
-- ============================================

CREATE TABLE airports (
    airport_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    iata_code VARCHAR(10) UNIQUE NOT NULL
);

-- ============================================
-- AIRCRAFT
-- ============================================

CREATE TABLE aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    CHECK (capacity > 0)
);

-- ============================================
-- FLIGHTS
-- ============================================

CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(20) NOT NULL,

    origin_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,

    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,

    aircraft_id INT NOT NULL,

    status ENUM('scheduled', 'delayed', 'cancelled') DEFAULT 'scheduled',

    UNIQUE (flight_number, departure_time),

    FOREIGN KEY (origin_airport_id) 
        REFERENCES airports(airport_id),

    FOREIGN KEY (destination_airport_id) 
        REFERENCES airports(airport_id),

    FOREIGN KEY (aircraft_id) 
        REFERENCES aircraft(aircraft_id),

    CHECK (origin_airport_id <> destination_airport_id),
    CHECK (arrival_time > departure_time)
);

-- ============================================
-- PASSENGERS
-- ============================================

CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    frequent_flyer_points INT DEFAULT 0,
    CHECK (frequent_flyer_points >= 0)
);

-- ============================================
-- BOOKINGS
-- ============================================

CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,

    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,

    seat_number VARCHAR(10) NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    status ENUM('confirmed', 'cancelled') DEFAULT 'confirmed',

    FOREIGN KEY (passenger_id) 
        REFERENCES passengers(passenger_id)
        ON DELETE CASCADE,

    FOREIGN KEY (flight_id) 
        REFERENCES flights(flight_id)
        ON DELETE CASCADE,

    UNIQUE (flight_id, seat_number),

    CHECK (ticket_price > 0)
);

-- ============================================
-- CREW
-- ============================================

CREATE TABLE crew (
    crew_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role ENUM('pilot', 'co-pilot', 'attendant') NOT NULL,
    experience_years INT NOT NULL,
    CHECK (experience_years >= 0)
);

-- ============================================
-- CREW ASSIGNMENTS
-- ============================================

CREATE TABLE crew_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    crew_id INT NOT NULL,
    flight_id INT NOT NULL,
    role_on_flight VARCHAR(50),

    FOREIGN KEY (crew_id) 
        REFERENCES crew(crew_id)
        ON DELETE CASCADE,

    FOREIGN KEY (flight_id) 
        REFERENCES flights(flight_id)
        ON DELETE CASCADE,

    UNIQUE (crew_id, flight_id)
);

-- ============================================
-- FLIGHT DELAYS
-- ============================================

CREATE TABLE flight_delays (
    delay_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    delay_duration INT NOT NULL,
    reason VARCHAR(255) DEFAULT 'Operational Delay',
    reported_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (flight_id) 
        REFERENCES flights(flight_id)
        ON DELETE CASCADE,

    CHECK (delay_duration > 0)
);

-- ============================================
-- INDEXES (PERFORMANCE)
-- ============================================

CREATE INDEX idx_flight_id ON bookings(flight_id);
CREATE INDEX idx_passenger_id ON bookings(passenger_id);
CREATE INDEX idx_flight_passenger ON bookings(flight_id, passenger_id);
CREATE INDEX idx_delay_flight ON flight_delays(flight_id);

-- ============================================
-- SAMPLE DATA (FOR TESTING)
-- ============================================

-- Airports
INSERT INTO airports (name, city, country, iata_code) VALUES
('Indira Gandhi Intl Airport', 'Delhi', 'India', 'DEL'),
('Chhatrapati Shivaji Intl', 'Mumbai', 'India', 'BOM'),
('Kempegowda Intl Airport', 'Bangalore', 'India', 'BLR');

-- Aircraft
INSERT INTO aircraft (model, capacity, manufacturer) VALUES
('A320', 180, 'Airbus'),
('B737', 160, 'Boeing');

-- Flights
INSERT INTO flights (
    flight_number, origin_airport_id, destination_airport_id,
    departure_time, arrival_time, aircraft_id
) VALUES
('AI101', 1, 2, '2026-04-15 10:00:00', '2026-04-15 12:30:00', 1),
('AI202', 2, 3, '2026-04-16 14:00:00', '2026-04-16 16:00:00', 2);

-- Passengers
INSERT INTO passengers (first_name, last_name, email, phone) VALUES
('Samit', 'Shandilya', 'samit@example.com', '9999999999'),
('Apoorv', 'Sharma', 'apoorv@example.com', '8888888888');

-- Bookings
INSERT INTO bookings (passenger_id, flight_id, seat_number, ticket_price) VALUES
(1, 1, '12A', 5000.00),
(2, 1, '12B', 5200.00);

-- Crew
INSERT INTO crew (name, role, experience_years) VALUES
('Captain Raj', 'pilot', 15),
('Ankit Verma', 'co-pilot', 8),
('Neha Singh', 'attendant', 5);

-- Crew Assignments
INSERT INTO crew_assignments (crew_id, flight_id, role_on_flight) VALUES
(1, 1, 'Captain'),
(2, 1, 'First Officer'),
(3, 1, 'Cabin Crew');

-- Flight Delays
INSERT INTO flight_delays (flight_id, delay_duration, reason) VALUES
(1, 30, 'Weather Conditions'),
(1, 15, 'Technical Check');

