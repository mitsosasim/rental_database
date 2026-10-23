-- Synthetic fixtures only. These are not customer identities or payment details.
INSERT INTO Registration VALUES
 (1,1,'demo1','demo-only','2024-01-01'),
 (2,2,'demo2','demo-only','2024-01-01');
INSERT INTO Customer VALUES
 (1,1,'Demo','Customer1','Example Street',1990,200001,'100001','12/2030',0,'Example City','Example Region',10001,34),
 (2,2,'Demo','Customer2','Example Street',1992,200002,'100002','12/2030',0,'Example City','Example Region',10002,32);
INSERT INTO Vehicle VALUES
 (1,'Blue','Demo Car A',400,50,10,'yes'),
 (2,'White','Demo Car B',350,60,10,'no'),
 (3,'Black','Demo Motorcycle',200,30,5,'yes'),
 (4,'Green','Demo Bicycle',40,15,2,'yes'),
 (5,'Red','Demo Scooter A',30,20,3,'no'),
 (6,'Gray','Demo Scooter B',35,20,3,'yes');
INSERT INTO Car VALUES (1,1001,'compact',4),(2,1002,'sedan',5);
INSERT INTO Motorcycle VALUES (3,1003);
INSERT INTO Bicycle VALUES (4,1004);
INSERT INTO Electric_Scooter (vehicle_id, special_number) VALUES (5,1005),(6,1006);
INSERT INTO Rental VALUES
 (101,1,1,'Demo','Customer1','2024-02-01',2,100),
 (102,2,1,'Demo','Customer2','2024-03-01',3,150),
 (103,1,3,'Demo','Customer1','2024-04-01',4,120),
 (104,2,4,'Demo','Customer2','2023-12-20',1,15),
 (105,2,5,'Demo','Customer2','2024-05-01',2,40);
INSERT INTO Report VALUES
 (1,1,1,'Demo repair A','2024-06-01','yes',80),
 (2,2,3,'Demo repair B','2024-07-01','no',20),
 (3,2,4,'Demo repair C','2023-11-01','yes',10);
