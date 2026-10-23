# Setup and implementation notes

## Build and verify

Use JDK 17 and Maven 3.9 or newer:

```sh
mvn verify
```

The WAR targets the `javax.servlet` API and Java 8 bytecode. The integration tests use H2 2.2.224 in MySQL mode, create databases only in memory, and do not call the database creation/deletion servlets. They verify seven cases: exported schema and constraints, availability helpers, inventory joins, period rentals, duration statistics, rental revenue, and repair expenditure.

The fixture has six vehicles, five rentals, and three repair reports. For the 2024 interval, the expected rental total is 410 and repair total is 100, in the schema's unspecified monetary units. Vehicle 1 has two rentals lasting two and three days, giving an average of 2.5 days. Revenue includes vehicles with no rentals in that interval.

## MySQL and Tomcat

For manual deployment, use a local MySQL 8 database and **Tomcat 9**. Tomcat 10 uses a different servlet namespace. These deployment steps are separate from the automated H2 checks.

Create a dedicated empty database, then apply the scripts in order:

```sh
mysql -u root -p -e 'CREATE DATABASE HY360_2024;'
mysql -u root -p HY360_2024 < sql/schema.sql
mysql -u root -p HY360_2024 < sql/demo-data.sql
mysql -u root -p HY360_2024 < sql/reports.sql
```

Use an account restricted to that local demo database. Configure its connection in Tomcat's environment before starting the server:

| Setting | Purpose | Default |
| --- | --- | --- |
| `DB_URL` | Full JDBC URL for application connections | `DB_SERVER_URL` + `DB_NAME` |
| `DB_SERVER_URL` | Server URL used by legacy create/drop helpers | `jdbc:mysql://localhost:3306/` |
| `DB_NAME` | Database identifier, letters/digits/underscores only | `HY360_2024` |
| `DB_USER` | Database account | `root` |
| `DB_PASSWORD` | Database password | Empty |

Each setting also accepts a JVM system property with the same name, which takes precedence. Set `DB_USER` and `DB_PASSWORD` for your own local account. Keep credentials outside the repository.

Copy `target/database.war` to Tomcat's `webapps` directory and open `http://localhost:8080/database/`. The availability endpoints are `/GetAvailableCars`, `/GetAvailableBicycles`, and `/GetAvailableElectricScooters`. Check the corresponding `@WebServlet` mappings when calling endpoints directly.

The supplied SQL fixtures are fictional. They are intended for the database checks and query exploration, not as working web-login accounts. Use the SQL scripts for initial setup. The legacy `/InitDB` endpoint initializes a database without administrative authorization. `DeleteDB` contains a drop helper but has no servlet mapping in this source. Keep this prototype on a disposable local database and do not expose it publicly.

## Implementation boundaries

The relational design separates shared vehicle attributes from category attributes. The active DDL is represented in `sql/schema.sql`. It does not enforce exclusive category membership, and `Registration.customer_id` has no foreign key back to `Customer`. Birth dates are stored as integer years, availability as text, and rental costs as integers. These are properties of the course implementation.

The web shell and several individual-record helpers are incomplete:

- Registration has a JavaScript handler mismatch and an SQL insert with inconsistent columns and values.
- Login maps a registration row into a customer object. Session restoration queries a customer column that does not exist.
- The motorcycle button routes to the cars action, the motorcycle servlet is a scaffold, and the accident button has no submission action.
- Some table helpers contain malformed SQL, swallow exceptions, or leave JDBC resources open. The initializer can report success after an error.

The prototype also concatenates SQL input and models passwords and payment details as plain fields. Production use would require prepared statements, password hashing, payment-data redesign, transaction handling, authorization, and completed web workflows. Automated checks cover the explicitly listed database paths, not every helper or servlet. The original course report is retained as historical project documentation, including claims that are broader than the current verification.
