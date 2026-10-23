-- Vehicle availability by category.
SELECT v.vehicle_id, v.brand, v.available,
       CASE WHEN c.vehicle_id IS NOT NULL THEN 'Car'
            WHEN m.vehicle_id IS NOT NULL THEN 'Motorcycle'
            WHEN b.vehicle_id IS NOT NULL THEN 'Bicycle'
            WHEN e.vehicle_id IS NOT NULL THEN 'Electric scooter' END AS category
FROM Vehicle v
LEFT JOIN Car c ON c.vehicle_id = v.vehicle_id
LEFT JOIN Motorcycle m ON m.vehicle_id = v.vehicle_id
LEFT JOIN Bicycle b ON b.vehicle_id = v.vehicle_id
LEFT JOIN Electric_Scooter e ON e.vehicle_id = v.vehicle_id
ORDER BY v.vehicle_id;

-- Rentals in a selected period, with customer and vehicle details.
SELECT r.rental_id, v.vehicle_id, v.brand, c.first_name, c.last_name,
       r.rental_date, r.duration, r.cost
FROM Rental r
JOIN Vehicle v ON v.vehicle_id = r.vehicle_id
JOIN Customer c ON c.customer_id = r.customer_id
WHERE r.rental_date >= '2024-01-01' AND r.rental_date < '2025-01-01'
ORDER BY r.rental_id;

-- Duration statistics per rented vehicle. The active schema stores duration as integer days.
SELECT vehicle_id, MIN(duration) AS min_days, MAX(duration) AS max_days,
       AVG(duration) AS avg_days
FROM Rental
GROUP BY vehicle_id
ORDER BY vehicle_id;

-- Rental revenue per vehicle in the selected period, including zero-revenue vehicles.
SELECT v.vehicle_id, COALESCE(SUM(r.cost), 0) AS revenue
FROM Vehicle v
LEFT JOIN Rental r ON r.vehicle_id = v.vehicle_id
 AND r.rental_date >= '2024-01-01' AND r.rental_date < '2025-01-01'
GROUP BY v.vehicle_id
ORDER BY v.vehicle_id;

-- Repair expenditure in the selected period.
SELECT COALESCE(SUM(repair_cost), 0) AS total_repair_cost
FROM Report
WHERE report_date >= '2024-01-01' AND report_date < '2025-01-01';
