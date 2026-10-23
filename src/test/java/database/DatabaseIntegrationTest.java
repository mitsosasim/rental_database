package database;

import database.init.InitDatabase;
import database.tables.EditBicycleTable;
import database.tables.EditCarTable;
import database.tables.EditElectricScooterTable;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.*;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

class DatabaseIntegrationTest {
    private static Connection connection;

    private static List<String> statements(String path) throws Exception {
        String sql = new String(Files.readAllBytes(Paths.get(path)), StandardCharsets.UTF_8)
                .replaceAll("(?m)--.*$", "");
        List<String> result = new ArrayList<>();
        for (String part : sql.split(";")) if (!part.trim().isEmpty()) result.add(part.trim());
        return result;
    }

    private static void apply(Connection db, String path) throws Exception {
        try (Statement statement = db.createStatement()) {
            for (String sql : statements(path)) statement.execute(sql);
        }
    }

    @BeforeAll
    static void initialize() throws Exception {
        Class.forName("org.h2.Driver");
        System.setProperty("DB_URL", "jdbc:h2:mem:course;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1");
        System.setProperty("DB_USER", "sa");
        System.setProperty("DB_PASSWORD", "");
        connection = DB_Connection.getConnection();
        new InitDatabase().initTables();
        apply(connection, "sql/demo-data.sql");
    }

    @Test
    void exportedSchemaAcceptsSameFixturesAndEnforcesReferences() throws Exception {
        try (Connection exported = DriverManager.getConnection(
                "jdbc:h2:mem:exported;MODE=MySQL;DATABASE_TO_LOWER=TRUE", "sa", "")) {
            apply(exported, "sql/schema.sql");
            apply(exported, "sql/demo-data.sql");
            try (ResultSet tables = exported.getMetaData().getTables(null, "public", "%", new String[]{"TABLE"})) {
                int count = 0;
                while (tables.next()) count++;
                assertEquals(9, count);
            }
            try (Statement statement = exported.createStatement()) {
                assertThrows(SQLException.class, () -> statement.executeUpdate(
                    "INSERT INTO Rental VALUES (999,999,1,'Demo','Customer','2024-01-01',1,50)"));
                assertThrows(SQLException.class, () -> statement.executeUpdate(
                    "INSERT INTO Registration VALUES (99,99,'demo1','demo-only','2024-01-01')"));
            }
        }
    }

    @Test
    void availabilityHelpersFilterUnavailableVehicles() throws Exception {
        assertEquals(1, new EditCarTable().getAvailableCars().size());
        assertEquals(1, new EditCarTable().getAvailableCars().get(0).getVehicle_id());
        assertEquals(4, new EditBicycleTable().getAvailableBicycle().get(0).getVehicle_id());
        assertEquals(1, new EditElectricScooterTable().getAvailableElectricScooters().size());
        assertEquals(6, new EditElectricScooterTable().getAvailableElectricScooters().get(0).getVehicle_id());
    }

    @Test
    void inventoryJoinsAllFourCategories() throws Exception {
        Set<String> categories = new HashSet<>();
        int rows = 0, available = 0;
        try (Statement s = connection.createStatement(); ResultSet r = s.executeQuery(statements("sql/reports.sql").get(0))) {
            while (r.next()) {
                rows++;
                categories.add(r.getString("category"));
                if ("yes".equals(r.getString("available"))) available++;
            }
        }
        assertEquals(6, rows);
        assertEquals(4, available);
        assertEquals(new HashSet<>(Arrays.asList("Car", "Motorcycle", "Bicycle", "Electric scooter")), categories);
    }

    @Test
    void periodRentalsExcludePriorYear() throws Exception {
        List<Integer> ids = new ArrayList<>();
        int cost = 0;
        try (Statement s = connection.createStatement(); ResultSet r = s.executeQuery(statements("sql/reports.sql").get(1))) {
            while (r.next()) { ids.add(r.getInt("rental_id")); cost += r.getInt("cost"); }
        }
        assertEquals(Arrays.asList(101,102,103,105), ids);
        assertEquals(410, cost);
    }

    @Test
    void durationAggregatesIncludeRepeatedRentals() throws Exception {
        try (Statement s = connection.createStatement(); ResultSet r = s.executeQuery(statements("sql/reports.sql").get(2))) {
            assertTrue(r.next());
            assertEquals(1, r.getInt("vehicle_id"));
            assertEquals(2, r.getInt("min_days"));
            assertEquals(3, r.getInt("max_days"));
            assertEquals(2.5, r.getDouble("avg_days"), 0.0001);
            int rows = 1;
            while (r.next()) rows++;
            assertEquals(4, rows);
        }
    }

    @Test
    void revenueIncludesVehiclesWithoutPeriodRentals() throws Exception {
        List<Integer> totals = new ArrayList<>();
        try (Statement s = connection.createStatement(); ResultSet r = s.executeQuery(statements("sql/reports.sql").get(3))) {
            while (r.next()) totals.add(r.getInt("revenue"));
        }
        assertEquals(Arrays.asList(250,0,120,0,40,0), totals);
    }

    @Test
    void repairExpenditureRespectsPeriod() throws Exception {
        try (Statement s = connection.createStatement(); ResultSet r = s.executeQuery(statements("sql/reports.sql").get(4))) {
            assertTrue(r.next());
            assertEquals(100.0, r.getDouble("total_repair_cost"), 0.0001);
            assertFalse(r.next());
        }
    }
}
