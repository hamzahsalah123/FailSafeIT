CREATE TABLE dbo.Kund (
    KundID INT IDENTITY(1,1) PRIMARY KEY,
    Organisationsnummer CHAR(11) NOT NULL UNIQUE,
    Foretagsnamn NVARCHAR(100) NOT NULL,
    Epost NVARCHAR(254) NOT NULL,
    Telefonnummer VARCHAR(25) NOT NULL
);

CREATE TABLE dbo.Konsult (
    KonsultID INT IDENTITY(1,1) PRIMARY KEY,
    Personnummer CHAR(13) NOT NULL UNIQUE,
    Namn NVARCHAR(100) NOT NULL,
    Timpris DECIMAL(10,2) NOT NULL,
    Specialitet NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Uppdrag (
    UppdragID INT IDENTITY(1,1) PRIMARY KEY,
    KundID INT NOT NULL,
    KonsultID INT NOT NULL,
    Startdatum DATE NOT NULL,
    Slutdatum DATE NOT NULL,
    Rollbeskrivning NVARCHAR(250) NOT NULL,
    FOREIGN KEY (KundID) REFERENCES dbo.Kund (KundID),
    FOREIGN KEY (KonsultID) REFERENCES dbo.Konsult (KonsultID),
    CHECK (Slutdatum >= Startdatum)
);

-- Testdata för kunder och konsulter
INSERT INTO dbo.Kund (Organisationsnummer, Foretagsnamn, Epost, Telefonnummer)
VALUES
    ('000000-0001', N'Nordhamn Energi AB', N'kontakt@nordhamn.example', '08-555 01 01'),
    ('000000-0002', N'Svea Logistik AB', N'kontakt@svealogistik.example', '08-555 01 02'),
    ('000000-0003', N'Bergvik Handel AB', N'kontakt@bergvik.example', '08-555 01 03'),
    ('000000-0004', N'Vikens Media AB', N'kontakt@vikensmedia.example', '08-555 01 04');

INSERT INTO dbo.Konsult (Personnummer, Namn, Timpris, Specialitet)
VALUES
    ('19900230-0001', N'Sara Lind', 1450.00, N'Cybersecurity'),
    ('19910230-0002', N'Amir Hassan', 1300.00, N'DevOps'),
    ('19920230-0003', N'Emma Berg', 1100.00, N'C# Developer');

    -- Testdata för uppdrag
DECLARE @Idag DATE = CAST(GETDATE() AS DATE);

INSERT INTO dbo.Uppdrag (KundID, KonsultID, Startdatum, Slutdatum, Rollbeskrivning)
SELECT
    k.KundID,
    c.KonsultID,
    DATEADD(day, u.Startdag, @Idag),
    DATEADD(day, u.Slutdag, @Idag),
    u.Rollbeskrivning
FROM (VALUES
    ('000000-0001', '19900230-0001', -14,  30, N'Säkerhetsgranskning av API-miljö'),
    ('000000-0001', '19910230-0002',  -7,  45, N'Bygga CI/CD-pipeline'),
    ('000000-0002', '19920230-0003', -10,  20, N'Utveckla integration i C#'),
    ('000000-0002', '19900230-0001', -60, -15, N'Granska åtkomst till molntjänster'),
    ('000000-0003', '19910230-0002',  14,  60, N'Automatisera driftsättning')
) AS u (Organisationsnummer, Personnummer, Startdag, Slutdag, Rollbeskrivning)
JOIN dbo.Kund AS k ON k.Organisationsnummer = u.Organisationsnummer
JOIN dbo.Konsult AS c ON c.Personnummer = u.Personnummer;

-- Fråga A: Konsulter med timpris över 1 200 kr
SELECT Namn, Timpris
FROM dbo.Konsult
WHERE Timpris > 1200
ORDER BY Timpris DESC;

-- Fråga B: Sammanställning av alla uppdrag
SELECT
    k.Foretagsnamn,
    c.Namn AS Konsultnamn,
    u.Startdatum,
    u.Slutdatum
FROM dbo.Uppdrag AS u
JOIN dbo.Kund AS k ON k.KundID = u.KundID
JOIN dbo.Konsult AS c ON c.KonsultID = u.KonsultID
ORDER BY u.Startdatum, u.UppdragID;

-- Fråga C: Antal aktiva uppdrag per kund
SELECT
    k.Foretagsnamn,
    COUNT(u.UppdragID) AS AntalAktivaUppdrag
FROM dbo.Kund AS k
LEFT JOIN dbo.Uppdrag AS u
    ON u.KundID = k.KundID
    AND @Idag BETWEEN u.Startdatum AND u.Slutdatum
GROUP BY k.KundID, k.Foretagsnamn
ORDER BY AntalAktivaUppdrag DESC, k.Foretagsnamn;

-- Fråga D – uppdatera Emma Bergs timpris
UPDATE dbo.Konsult
SET Timpris = 1250.00
WHERE Personnummer = '19920230-0003';

-- Fråga E – ta bort Vikens Media AB om kunden saknar uppdrag
DELETE FROM dbo.Kund
OUTPUT deleted.Foretagsnamn AS BorttagenKund
WHERE Organisationsnummer = '000000-0004'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Uppdrag
      WHERE dbo.Uppdrag.KundID = dbo.Kund.KundID
  );