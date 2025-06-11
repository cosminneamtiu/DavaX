-- ============================================================================
-- Script  : TimesheetDB_Annotated.sql
-- Author  : Neamtiu Cosmin Adrian
-- Purpose : Complete DDL/DML script for the TimesheetDB sample database *with
--            inline comments explaining the intent of every section,
--           object, constraint, and sample operation.
--           
-- ============================================================================

/*
    TABLE OF CONTENTS
    ---------------------------------------------------------------------------
    1.  DATABASE CONTEXT
    2.  SECURITY – LOGINS, USERS, ROLES, AND PERMISSIONS
    3.  SCHEMAS
    4.  CORE TABLES
          4.1  timesheet.Employee
          4.2  timesheet.Project
          4.3  timesheet.TimesheetEntry
          4.4  timesheet.TimesheetAudit
    5.  VIEWS (REPORTING & ANALYTICS)
    6.  INDEXES
    7.  STORED PROCEDURES
    8.  TRIGGERS
    9.  DEMO SECTION – ACID PROPERTIES & TEMP TABLES
   10.  ADDITIONAL SECURITY EXAMPLES
   11.  JSON SUPPORT & FUNCTIONAL INDEXES
*/

-- ============================================================================
-- 1. DATABASE CONTEXT & ANSI SETTINGS
-- ----------------------------------------------------------------------------
USE [TimesheetDB];
GO

-- (Optional) Make sure we have clean, predictable ANSI behaviour
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_WARNINGS ON;
SET NUMERIC_ROUNDABORT OFF;
GO

-- ============================================================================
-- 2. SECURITY – LOGINS, USERS, ROLES, AND PERMISSIONS
-- ----------------------------------------------------------------------------
-- We separate concerns by creating *login* objects at the server level and then
-- *users* (mapped to those logins) inside the database.  Each user is added to
-- a role that encapsulates the precise level of access required.

-------------------------------------------------------------------
-- 2.1 CREATE DATABASE USERS
-------------------------------------------------------------------
CREATE USER [employee_reader]  FOR LOGIN [employee_reader]  WITH DEFAULT_SCHEMA = [dbo];
CREATE USER [timesheet_viewer] FOR LOGIN [timesheet_viewer] WITH DEFAULT_SCHEMA = [dbo];
GO

-------------------------------------------------------------------
-- 2.2 CREATE DATABASE ROLES
-------------------------------------------------------------------
CREATE ROLE [EmployeeReadOnly];   -- Read‑only access to the Employee table only
CREATE ROLE [TimesheetReadOnly];  -- Read‑only access to all timesheet objects
GO

-------------------------------------------------------------------
-- 2.3 ASSIGN USERS TO ROLES
-------------------------------------------------------------------
ALTER ROLE [EmployeeReadOnly]  ADD MEMBER [employee_reader];
ALTER ROLE [TimesheetReadOnly] ADD MEMBER [timesheet_viewer];
GO

-- ============================================================================
-- 3. SCHEMAS
-- ----------------------------------------------------------------------------
-- A dedicated schema keeps the timesheet objects logically grouped and avoids
-- clutter in the default dbo schema.
CREATE SCHEMA [timesheet];
GO

-- ============================================================================
-- 4. CORE TABLES

-------------------------------------------------------------------
-- 4.1 EMPLOYEE MASTER DATA
-------------------------------------------------------------------
CREATE TABLE [timesheet].[Employee] (
    [EmployeeID]   INT            IDENTITY(1,1)  NOT NULL,
    [EmployeeName] NVARCHAR(100)                NOT NULL,
    [Department]   NVARCHAR(50)                 NULL,
    [ProfileData]  NVARCHAR(MAX)                NULL,  -- JSON blob (skills, level)
    CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED ([EmployeeID] ASC)
);
GO

-------------------------------------------------------------------
-- 4.2 PROJECT MASTER DATA
--     Computed column [Status] shows runtime state (Active/Completed/Archived)
-------------------------------------------------------------------
CREATE TABLE [timesheet].[Project] (
    [ProjectID]   INT            IDENTITY(1,1)  NOT NULL,
    [ProjectName] NVARCHAR(100)                NOT NULL,
    [StartDate]   DATE                         NOT NULL,
    [EndDate]     DATE                         NOT NULL,
    [Status]      AS (
        CASE
            WHEN [EndDate] < DATEADD(YEAR, -5, GETDATE()) THEN 'Archived'
            WHEN [EndDate] < GETDATE()                    THEN 'Completed'
            ELSE                                            'Active'
        END
    ),
    CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([ProjectID] ASC),
    CONSTRAINT [chk_EndDate] CHECK ([EndDate] >= [StartDate])
);
GO

-------------------------------------------------------------------
-- 4.3 TIMESHEET ENTRY FACT TABLE
--     Captures daily efforts per employee per project.
-------------------------------------------------------------------
CREATE TABLE [timesheet].[TimesheetEntry] (
    [TimesheetEntryID] INT            IDENTITY(1,1) NOT NULL,
    [EmployeeID]       INT                         NOT NULL,
    [ProjectID]        INT                         NOT NULL,
    [WorkDate]         DATE                        NOT NULL,
    [HoursWorked]      DECIMAL(4,2)                NULL, -- validated by CHECK (>0)
    [Notes]            NVARCHAR(MAX)               NULL, -- JSON array of tasks
    [WeekNumber]       AS (DATEPART(WEEK, [WorkDate])), -- persisted computed
    [Verified]         BIT                         NOT NULL DEFAULT (0),
    [VerifiedBy]       NVARCHAR(100)               NULL,
    [VerifiedDate]     DATETIME                    NULL,
    CONSTRAINT [PK_TimesheetEntry] PRIMARY KEY CLUSTERED ([TimesheetEntryID] ASC),
    CONSTRAINT [FK_TE_Employee]   FOREIGN KEY ([EmployeeID]) REFERENCES [timesheet].[Employee]([EmployeeID]),
    CONSTRAINT [FK_TE_Project]    FOREIGN KEY ([ProjectID])  REFERENCES [timesheet].[Project] ([ProjectID]),
    CONSTRAINT [CK_Hours_Positive] CHECK ([HoursWorked] > 0),
    CONSTRAINT [CK_WorkDate_Past]  CHECK ([WorkDate] <= GETDATE())
);
GO

-------------------------------------------------------------------
-- 4.4 AUDIT TABLE FOR TIMESHEET CHANGES
--     Trigger‑driven history of hour adjustments for compliance.
-------------------------------------------------------------------
CREATE TABLE [timesheet].[TimesheetAudit] (
    [AuditID]         INT        IDENTITY(1,1) NOT NULL,
    [TimesheetEntryID] INT                       NULL,
    [OldHoursWorked]  DECIMAL(4,2)              NULL,
    [NewHoursWorked]  DECIMAL(4,2)              NULL,
    [ChangeDate]      DATETIME    NOT NULL DEFAULT (GETDATE()),
    [ChangedBy]       SYSNAME     NOT NULL,
    CONSTRAINT [PK_TimesheetAudit] PRIMARY KEY CLUSTERED ([AuditID] ASC)
);
GO

-- ============================================================================
-- 5. VIEWS (REPORTING & ANALYTICS)
-- ----------------------------------------------------------------------------
-- Read‑only abstractions that JOIN and aggregate the raw tables.

-------------------------------------------------------------------
-- 5.1 Flat detail view (denormalised) for BI tools or exports
-------------------------------------------------------------------
CREATE VIEW [timesheet].[vw_TimesheetDetails]
AS
SELECT  te.TimesheetEntryID,
        e.EmployeeName,
        e.Department,
        p.ProjectName,
        te.WorkDate,
        te.HoursWorked,
        te.Notes
FROM timesheet.TimesheetEntry  te
JOIN timesheet.Employee        e  ON te.EmployeeID = e.EmployeeID
JOIN timesheet.Project         p  ON te.ProjectID  = p.ProjectID;
GO

-------------------------------------------------------------------
-- 5.2 Hours per project (WITH SCHEMABINDING prevents accidental dependency drops)
-------------------------------------------------------------------
CREATE VIEW [timesheet].[vw_TotalHoursPerProject]
WITH SCHEMABINDING
AS
SELECT  te.ProjectID,
        COUNT_BIG(*)                 AS EntryCount,
        SUM(ISNULL(te.HoursWorked,0)) AS TotalHours -- ISNULL ⇒ deterministic
FROM timesheet.TimesheetEntry te
GROUP BY te.ProjectID;
GO

-------------------------------------------------------------------
-- 5.3 Hours per employee (simple aggregate)
-------------------------------------------------------------------
CREATE VIEW [timesheet].[vw_TotalHoursPerEmployee]
AS
SELECT  e.EmployeeName,
        SUM(te.HoursWorked) AS TotalHours
FROM timesheet.Employee        e
JOIN timesheet.TimesheetEntry  te ON e.EmployeeID = te.EmployeeID
GROUP BY e.EmployeeName;
GO

-------------------------------------------------------------------
-- 5.4 Employee list INCLUDING those without timesheets (LEFT JOIN)
-------------------------------------------------------------------
CREATE VIEW [timesheet].[vw_EmployeeWithOrWithoutTimesheet]
AS
SELECT  e.EmployeeName,
        te.WorkDate,
        te.HoursWorked
FROM timesheet.Employee        e
LEFT JOIN timesheet.TimesheetEntry te ON e.EmployeeID = te.EmployeeID;
GO

-------------------------------------------------------------------
-- 5.5 Running total of hours per employee (window function)
-------------------------------------------------------------------
CREATE VIEW [timesheet].[vw_RunningTotalHoursPerEmployee]
AS
SELECT  e.EmployeeName,
        te.WorkDate,
        te.HoursWorked,
        SUM(te.HoursWorked) OVER (
            PARTITION BY e.EmployeeName
            ORDER BY     te.WorkDate
        ) AS RunningTotalHours
FROM timesheet.TimesheetEntry te
JOIN timesheet.Employee        e ON te.EmployeeID = e.EmployeeID;
GO

-------------------------------------------------------------------
-- 5.6 Separating VERIFIED / UNVERIFIED entries for audit queues
-------------------------------------------------------------------
CREATE VIEW [timesheet].[vw_VerifiedTimesheets]
AS
SELECT  te.TimesheetEntryID,
        e.EmployeeName,
        te.WorkDate,
        te.HoursWorked,
        te.Verified,
        te.VerifiedBy,
        te.VerifiedDate
FROM timesheet.TimesheetEntry te
JOIN timesheet.Employee        e ON te.EmployeeID = e.EmployeeID
WHERE te.Verified = 1;
GO

CREATE VIEW [timesheet].[vw_UnverifiedTimesheets]
AS
SELECT  te.TimesheetEntryID,
        e.EmployeeName,
        te.WorkDate,
        te.HoursWorked,
        te.Verified,
        te.VerifiedBy,
        te.VerifiedDate
FROM timesheet.TimesheetEntry te
JOIN timesheet.Employee        e ON te.EmployeeID = e.EmployeeID
WHERE te.Verified = 0;
GO

-- ============================================================================
-- 6. INDEXES
-- ----------------------------------------------------------------------------
-- Clustered index on vw_TotalHoursPerProject to speed up lookups by ProjectID
CREATE UNIQUE CLUSTERED INDEX [IX_vw_TotalHoursPerProject]
    ON [timesheet].[vw_TotalHoursPerProject] ([ProjectID] ASC);
GO

-- Non‑clustered functional index over JSON‑extracted employee level
CREATE NONCLUSTERED INDEX IX_Employee_LevelFromJSON
    ON timesheet.Employee(LevelFromJSON);
GO

-- ============================================================================
-- 7. STORED PROCEDURES
-- ----------------------------------------------------------------------------
-- Parameterised helper to fetch an employee's timesheets for a date range.
CREATE PROCEDURE [timesheet].[GetEmployeeTimesheets]
    @EmployeeName NVARCHAR(100),
    @StartDate    DATE,
    @EndDate      DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  e.EmployeeName,
            p.ProjectName,
            te.WorkDate,
            te.HoursWorked
    FROM timesheet.TimesheetEntry te
    JOIN timesheet.Employee       e ON te.EmployeeID = e.EmployeeID
    JOIN timesheet.Project        p ON te.ProjectID  = p.ProjectID
    WHERE e.EmployeeName = @EmployeeName
      AND te.WorkDate BETWEEN @StartDate AND @EndDate
    ORDER BY te.WorkDate;
END;
GO

-- ============================================================================
-- 8. TRIGGERS
-- ----------------------------------------------------------------------------

-------------------------------------------------------------------
-- 8.1 Audit trigger – writes to TimesheetAudit on hours update
-------------------------------------------------------------------
CREATE TRIGGER [timesheet].[trg_AuditTimesheetChange]
ON [timesheet].[TimesheetEntry]
AFTER UPDATE
AS
BEGIN
    INSERT INTO timesheet.TimesheetAudit (
        TimesheetEntryID,
        OldHoursWorked,
        NewHoursWorked,
        ChangedBy
    )
    SELECT  i.TimesheetEntryID,
            d.HoursWorked,
            i.HoursWorked,
            SYSTEM_USER
    FROM inserted i
    JOIN deleted  d ON i.TimesheetEntryID = d.TimesheetEntryID
    WHERE i.HoursWorked <> d.HoursWorked;
END;
GO

-------------------------------------------------------------------
-- 8.2 Validation trigger – enforces (Verified, VerifiedDate) business rule
-------------------------------------------------------------------
CREATE TRIGGER [timesheet].[trg_VerifiedDate_Validation]
ON [timesheet].[TimesheetEntry]
AFTER INSERT, UPDATE
AS
BEGIN
    -- Throw an error if verified flag & date are inconsistent
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE (Verified = 1 AND VerifiedDate IS NULL)
           OR (Verified = 0 AND VerifiedDate IS NOT NULL)
    )
    BEGIN
        RAISERROR ('Invalid VerifiedDate: Must be set only when Verified = 1, and NULL otherwise.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- ============================================================================
-- 9. DEMO SECTION – ACID PROPERTIES & TEMP TABLES
-- ----------------------------------------------------------------------------
/*
   The following sandbox code blocks *demonstrate* atomicity, consistency,
   isolation, and durability.
*/

-- ---------------------------------------------------------------------------
-- 9.1 Atomicity & Consistency (Negative hours should violate CK_Hours_Positive)
-- ---------------------------------------------------------------------------
BEGIN TRANSACTION;
    INSERT INTO timesheet.TimesheetEntry (EmployeeID, ProjectID, WorkDate, HoursWorked, Notes)
    VALUES (1, 1, GETDATE(), -5, N'{"tasks": ["Bug fixing"]}');

    -- Expect zero rows; insert should roll back once we ROLLBACK
    SELECT * FROM timesheet.TimesheetEntry WHERE HoursWorked < 0;
ROLLBACK; -- Undo

-- ---------------------------------------------------------------------------
-- 9.2 Durability (Committed data persists)
-- ---------------------------------------------------------------------------
BEGIN TRANSACTION;
    INSERT INTO timesheet.TimesheetEntry (EmployeeID, ProjectID, WorkDate, HoursWorked, Notes)
    VALUES (1, 1, GETDATE(), 4.5, N'{"tasks": ["Code Review"]}');
COMMIT; -- Persist

SELECT TOP 1 *
FROM timesheet.TimesheetEntry
ORDER BY TimesheetEntryID DESC; -- Should include new row

-- ---------------------------------------------------------------------------
-- 9.3 Isolation (run Session 1 & Session 2 in separate tabs)
-- ---------------------------------------------------------------------------
-- Session 1
 BEGIN TRANSACTION;
 UPDATE timesheet.Employee SET Department = 'IT Updated' WHERE EmployeeID = 1;
 -- Do NOT COMMIT yet

-- Session 2
 SELECT * FROM timesheet.Employee WHERE EmployeeID = 1; -- Blocked/dirty‑read test

-- ---------------------------------------------------------------------------
-- 9.4 Local vs global temp tables
-- ---------------------------------------------------------------------------
-- Local #TempEmployeeHours (visible to current session only)
SELECT EmployeeID, SUM(HoursWorked) AS TotalHours
INTO   #TempEmployeeHours
FROM   timesheet.TimesheetEntry
GROUP  BY EmployeeID;

SELECT * FROM #TempEmployeeHours;

-- Global ##TempProjectEntries (visible to all sessions until last handle closes)
SELECT ProjectID, COUNT(*) AS EntryCount
INTO   ##TempProjectEntries
FROM   timesheet.TimesheetEntry
GROUP  BY ProjectID;

SELECT * FROM ##TempProjectEntries;

-- ============================================================================
-- 10. ADDITIONAL SECURITY EXAMPLES
-- ----------------------------------------------------------------------------
/*
   Example of how to create a restricted login/user that can *only* read
   timesheet views, plus another that can *only* read the Employee table.
*/

-- (1) Timesheet view‑only
CREATE LOGIN timesheet_viewer WITH PASSWORD = 'StrongPass123!';
GO
CREATE USER timesheet_viewer FOR LOGIN timesheet_viewer;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'TimesheetReadOnly')
    CREATE ROLE TimesheetReadOnly;
GO
GRANT SELECT ON SCHEMA::timesheet TO TimesheetReadOnly; -- all views/tables in schema
EXEC sp_addrolemember 'TimesheetReadOnly', 'timesheet_viewer';
GO

-- (2) Employee table‑only
CREATE LOGIN employee_reader WITH PASSWORD = 'SecurePass123!';
GO
CREATE USER employee_reader FOR LOGIN employee_reader;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'EmployeeReadOnly')
    CREATE ROLE EmployeeReadOnly;
GO
GRANT SELECT ON timesheet.Employee TO EmployeeReadOnly;
EXEC sp_addrolemember 'EmployeeReadOnly', 'employee_reader';
GO

-- ============================================================================
-- 11. JSON SUPPORT & FUNCTIONAL INDEXES
-- ----------------------------------------------------------------------------
-- a) Query by JSON scalar value
SELECT *
FROM   timesheet.Employee
WHERE  JSON_VALUE(ProfileData, '$.level') = 'junior';

-- b) Free‑text search for skill inside JSON blob
SELECT *
FROM   timesheet.Employee
WHERE  ProfileData LIKE '%SQL%';

-- c) Virtual column + index for JSON property (added earlier)
ALTER TABLE timesheet.Employee
ADD LevelFromJSON AS JSON_VALUE(ProfileData, '$.level');
GO

-- ============================================================================
-- 12. SAMPLE BUSINESS OPERATIONS (VERIFICATION & AUDIT)
-- ----------------------------------------------------------------------------
-- Mark a specific timesheet as verified
UPDATE timesheet.TimesheetEntry
SET    Verified     = 1,
       VerifiedBy   = 'TeamLead_Jane',
       VerifiedDate = GETDATE()
WHERE  TimesheetEntryID = 42;

-- Query lists of verified / unverified entries
SELECT * FROM timesheet.TimesheetEntry WHERE Verified = 1; -- verified
SELECT * FROM timesheet.TimesheetEntry WHERE Verified = 0; -- pending

-- Bump hours to trigger audit trail
UPDATE timesheet.TimesheetEntry
SET    HoursWorked = HoursWorked + 1
WHERE  TimesheetEntryID = 1;

SELECT * FROM timesheet.TimesheetAudit WHERE TimesheetEntryID = 1;

-- Validation trigger demonstration (should FAIL then PASS)
-- 1) Fail – Verified=1 but date NULL
 UPDATE timesheet.TimesheetEntry
 SET Verified = 1, VerifiedDate = NULL
 WHERE TimesheetEntryID = 1;

-- 2) Pass – Verified=1 with date
 UPDATE timesheet.TimesheetEntry
 SET Verified = 1, VerifiedDate = GETDATE()
 WHERE TimesheetEntryID = 7;

-- 3) Fail – Verified=0 but date set
 UPDATE timesheet.TimesheetEntry
 SET Verified = 0, VerifiedDate = GETDATE()
 WHERE TimesheetEntryID = 1;

-- ============================================================================
-- END OF FILE
-- ============================================================================
