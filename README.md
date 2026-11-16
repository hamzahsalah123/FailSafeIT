# FailSafe IT

Databasen hanterar kunder, konsulter och uppdrag. Varje uppdrag kopplar en kund till en konsult. En kund och en konsult kan båda ha flera uppdrag.

## Normalisering

- **1NF** – Varje kolumn innehåller ett värde per rad. Varje uppdrag ligger på en egen rad med separata fält för startdatum, slutdatum och rollbeskrivning.
- **2NF** – Alla tabeller har en primärnyckel som består av en enda kolumn. Uppdragets datum och rollbeskrivning hör till hela `UppdragID`.
- **3NF** – Varje uppgift lagras där den hör hemma. Kundens företagsnamn och kontaktuppgifter finns i `Kund`, och konsultens namn, timpris och specialitet finns i `Konsult`. `Uppdrag` använder främmande nycklar för att koppla ihop posterna, så att uppgifterna inte behöver upprepas.

## DevSecOps

**Sec – SQL-injektion**  
Jag använder parametriserade SQL-frågor så att det användaren skriver behandlas som data. Webbappen får bara de databasbehörigheter den behöver och saknar rätt att radera tabeller eller databasen.

**Ops – Snabb sökning efter organisationsnummer**  
Jag använder ett unikt index på `Kund.Organisationsnummer` för att göra uppslag på ett specifikt nummer snabba. SQL Server skapar det indexet automatiskt genom kolumnens `UNIQUE`-villkor.

## Kör skriptet

Skapa en tom databas som heter `FailSafeIT` i SQL Server eller LocalDB. Öppna sedan `FailSafeIT.sql` i SSMS, välj databasen och kör hela filen med Execute.