-- Active schema exported from the Java JDBC table builders.
-- Apply to an empty, selected database.

CREATE TABLE Registration (
    registration_id INTEGER not null AUTO_INCREMENT,
    customer_id INTEGER not null,
    username VARCHAR(20) not null unique,
    pass VARCHAR(20) not null,
    registration_date DATE,
    PRIMARY KEY(registration_id));

CREATE TABLE Customer (
    customer_id INTEGER not NULL ,
    registration_id INTEGER not NULL,
    first_name VARCHAR(20) not NULL,
    last_name VARCHAR(20),
    street VARCHAR(20),
    date_of_birth INTEGER,
    drivers_licence_number INTEGER not NULL unique,
    credit_card_number VARCHAR(20) not NULL unique,
    expiration_date VARCHAR(20) not NULL,
    security_code INTEGER not NULL,
    city VARCHAR(20),
    region VARCHAR(20),
    zip_code INTEGER,
    age INTEGER,
    PRIMARY KEY (customer_id),
    FOREIGN KEY(registration_id) REFERENCES Registration(registration_id));

CREATE TABLE Vehicle (
    vehicle_id INTEGER not null unique,
    color VARCHAR(20),
    brand VARCHAR(20),
    autonomy INTEGER,
    daily_rental_cost INTEGER,
    daily_insurance_cost INTEGER,
    available VARCHAR(20),
    PRIMARY KEY (vehicle_id));

CREATE TABLE Report (
    report_id INTEGER not null unique,
    customer_id INTEGER not null,
    vehicle_id INTEGER not null,
    malfunction_description VARCHAR(100),
    report_date DATE,
    insurance_paid VARCHAR(20),
    repair_cost DOUBLE,
    PRIMARY KEY(report_id),
    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY(vehicle_id) REFERENCES Vehicle(vehicle_id));

CREATE TABLE Rental (
    rental_id INTEGER not null,
    customer_id INTEGER not null,
    vehicle_id INTEGER not null,
    first_name VARCHAR(20) not null,
    last_name VARCHAR(20) not null,
    rental_date DATE,
    duration INTEGER,
    cost INTEGER,
    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY(vehicle_id) REFERENCES Vehicle(vehicle_id),
    PRIMARY KEY(rental_id));

CREATE TABLE Car (
    vehicle_id INTEGER not null unique,
    registration_number INTEGER not null,
    type VARCHAR(20),
    number_of_passengers INTEGER,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id));

CREATE TABLE Motorcycle (
    Vehicle_id INTEGER not null UNIQUE,
    registration_number INTEGER,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id));

CREATE TABLE Electric_Scooter (
    special_number INTEGER not null unique,vehicle_id INTEGER not null,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id));

CREATE TABLE Bicycle (
    Vehicle_id INTEGER not null,
    Special_number INTEGER not null unique,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id));
