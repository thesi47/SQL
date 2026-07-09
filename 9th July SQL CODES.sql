CREATE DATABASE office;
GO

USE office;
GO

CREATE TABLE Clients (
ClientId INT IDENTITY(1,1) PRIMARY KEY,
Name NVARCHAR(100) NOT NULL,
Email NVARCHAR(100),
Phone NVARCHAR(20),
IsActive BIT DEFAULT 1,
JoinDate DATE DEFAULT GETDATE()
);
GO
CREATE TABLE Employees (
EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
Name NVARCHAR(100) NOT NULL,
Department NVARCHAR(50),
Salary DECIMAL(10,2),
ManagerId INT NULL REFERENCES Employees(EmployeeId)
);
GO
CREATE TABLE Invoices (
InvoiceId INT IDENTITY(1,1) PRIMARY KEY,
ClientId INT NOT NULL REFERENCES Clients(ClientId),
Amount DECIMAL(10,2) NOT NULL,
InvoiceDate DATE DEFAULT GETDATE(),
Status NVARCHAR(20) DEFAULT 'Unpaid'
);
GO

INSERT INTO Clients (Name, Email, Phone) VALUES
('John Doe', 'john@doe.com', '123456'),
('Jane Smith', 'jane@smith.com', '654321'),
('Alice Johnson', 'alice@johnson.com', '987654'),
('Bob Brown', 'bob@brown.com', '456789'),
('Charlie Davis', 'charlie@davis.com', '321654');
GO

INSERT INTO Invoices(ClientId, Amount, InvoiceDate, Status) VALUES
(1, 1000.00, '2025-01-15', 'Unpaid'),
(1, 20000.00, '2025-02-20', 'Unpaid'),
(1, 1500.00, '2025-03-10', 'Paid'),
(1, 2000.00, '2025-04-05','Cancelled'),
(2, 30000.00, '2025-01-25', 'Unpaid'),
(2, 4000.00, '2025-02-15', 'Paid'),
(3, 2500.00, '2025-03-05', 'Unpaid'),
(3, 3500.00, '2025-04-10', 'Paid'),
(4, 15000.00, '2025-01-30', 'Unpaid'),
(4, 6000.00, '2025-02-28', 'Paid'),
(5, 17000.00, '2025-03-15', 'Unpaid'),
(5, 8000.00, '2025-04-20', 'Paid'),
(5, 9000.00, '2025-05-01', 'Cancelled');
GO

INSERT INTO Employees(Name, Department, Salary, ManagerId) VALUES
('Michael Scott', 'Sales', 75000.00, NULL),
('Dwight Schrute', 'Sales', 60000.00, 1),
('Jim Halpert', 'Sales', 65000.00, 1),
('Pam Beesly', 'Reception', 40000.00, NULL),
('Stanley Hudson', 'Sales', 70000.00, 1);

UPDATE Invoices
SET Status = 'Overdue'
WHERE InvoiceDate < DATEADD(DAY,-30,GETDATE())
AND Status='Unpaid';
GO
SELECT * FROM Invoices;
GO


UPDATE Clients
SET IsActive = 0
WHERE ClientId = 3;
GO

SELECT * FROM Clients;
GO

DELETE FROM Invoices
WHERE Status='Cancelled';
GO

SELECT * FROM Invoices;
GO
--q6: pari nai, output deikha nisi net thika
INSERT INTO Clients(Name,Email,Phone)
OUTPUT INSERTED.ClientId
VALUES
('Kevin Malone','kevin@dundermifflin.com','5552001');

--list of all invoices with client names and emails
SELECT i.InvoiceId, c.Name, c.Email, i.Amount, i.Status, i.InvoiceDate
FROM Invoices i
INNER JOIN Clients c ON i.ClientId=c.ClientId;
GO

--list of clients with the number of invoices they have
SELECT c.ClientId, c.Name, COUNT(i.InvoiceId) AS InvoiceCount
FROM Clients c
LEFT JOIN Invoices i ON c.ClientId=i.ClientId
GROUP BY c.ClientId, c.Name;
GO

--find clients who have not made any invoices
SELECT * FROM Clients c
LEFT JOIN Invoices i ON c.ClientId = i.ClientId
WHERE i.InvoiceId IS NULL;
GO

--employee and their manager names
SELECT e.Name AS Employee, m.Name AS Manager
FROM Employees e
LEFT JOIN Employees m ON e.ManagerId = m.EmployeeId;
GO

--total amount of invoices for each client
SELECT c.ClientId, c.Name, SUM(i.Amount) AS TotalAmount
FROM Clients c
INNER JOIN Invoices i ON c.ClientId=i.ClientId
GROUP BY c.ClientId, c.Name
ORDER BY TotalAmount DESC;
GO

--clients with total unpaid invoices greater than 10000
SELECT c.ClientId, c.Name, SUM(i.Amount) AS TotalUnpaidAmount
FROM Clients c
INNER JOIN Invoices i ON c.ClientId=i.ClientId
WHERE i.Status='Unpaid'
GROUP BY c.ClientId, c.Name
HAVING SUM(i.Amount) > 10000.00;
GO

--list of clients and their invoices, including clients with no invoices
SELECT c.Name, c.Email, i.InvoiceId, i.Amount, i.Status
FROM Clients c
FULL OUTER JOIN Invoices i ON c.ClientId=i.ClientId;
GO

CREATE VIEW vw_ActiveClients AS
SELECT * FROM Clients
WHERE IsActive = 1;
GO

SELECT ClientId,Name,Email FROM vw_ActiveClients;
GO

CREATE VIEW vw_InvoiceSummary AS
SELECT c.ClientId , c.Name, SUM(i.Amount) AS TotalAmount, SUM(CASE WHEN i.Status='Unpaid' THEN i.Amount ELSE 0 END) AS TotalUnpaidAmount
FROM Clients c
LEFT JOIN Invoices i ON c.ClientId=i.ClientId
GROUP BY c.ClientId, c.Name;
GO

SElECT * FROM vw_InvoiceSummary;
GO

SELECT TOP 3 * FROM vw_InvoiceSummary
ORDER BY TotalAmount DESC;
GO

UPDATE vw_ActiveClients
SET Email = 'shawon@email.com'
WHERE ClientId = 1;
GO

SELECT * FROM vw_ActiveClients;
GO

ALTER VIEW vw_ActiveClients AS
SELECT ClientId, Name, Email, Phone FROM Clients
WHERE IsActive = 1;
GO
SELECT * FROM vw_ActiveClients;
GO

DROP VIEW vw_InvoiceSummary;
GO
CREATE OR ALTER VIEW vw_InvoiceSummary AS
SELECT c.ClientId , c.Name, SUM(i.Amount) AS TotalAmount, SUM(CASE WHEN i.Status='Unpaid' THEN i.Amount ELSE 0 END) AS TotalUnpaidAmount
FROM Clients c
LEFT JOIN Invoices i ON c.ClientId=i.ClientId
GROUP BY c.ClientId, c.Name;
GO

SELECT * FROM vw_InvoiceSummary;
GO



CREATE PROCEDURE sp_GetClientById 
@ClientId INT AS
BEGIN
	SELECT * FROM Clients
	WHERE ClientId=@ClientId;
END;
GO

CREATE PROCEDURE sp_AddClient @Name NVARCHAR(100), @Email NVARCHAR(100), @Phone NVARCHAR(20), @NewClientId INT OUTPUT
AS
BEGIN
	INSERT INTO Clients(Name,Email,Phone)
	VALUES(@Name,@Email,@Phone);
	SET @NewClientId=SCOPE_IDENTITY();
END;

EXEC sp_AddClient 'Tommy Shelby', 'tommy@shelby.com', '6533243',8;
GO

SELECT * FROM Clients;
GO

CREATE PROCEDURE sp_UpdateInvoiceStatus @InvoiceId INT, @NewStatus NVARCHAR(20)
AS
BEGIN
	UPDATE Invoices
	SET Status=@NewStatus
	WHERE InvoiceId=@InvoiceId;
END;
GO
EXEC sp_UpdateInvoiceStatus 1, 'Paid';
GO
SELECT * FROM Invoices;
GO

CREATE PROCEDURE sp_GetOverdueInvoices 
AS
BEGIN
	SELECT * FROM Invoices
	WHERE Status='Overdue';
END;
GO
EXEC sp_GetOverdueInvoices;
GO

--24 & 25 Unknown to me