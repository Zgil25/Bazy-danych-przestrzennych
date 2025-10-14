--Baza danych o nazwie firma
CREATE DATABASE Firma;
GO
 
USE Firma;
GO

--Schemat o nazwie ksiegowosc.
CREATE SCHEMA Ksiegowosc;
GO

--Tworzenie tabel 
CREATE TABLE Ksiegowosc.Pracownicy(
	Id_Pracownika int  not null IDENTITY(1,1),
	Imie nvarchar(50) not null,
	Nazwisko nvarchar(50) not null,
	Adres nvarchar(150) not null,
	Telefon varchar(20) not null,
	CONSTRAINT PK_Pracownicy PRIMARY KEY (Id_Pracownika)
	
);

COMMENT ON TABLE Ksiegowosc.Pracownicy IS 'G³ówna tabela pracowników. Przechowuje dane identyfikacyjne i kontaktowe pracowników .'


CREATE TABLE Ksiegowosc.Godziny(
	Id_Godziny int not null IDENTITY(1,1),
	[Data] date not null,
	Liczba_Godzin decimal(4,2) not null,
	Id_Pracownika int not null,
	CONSTRAINT PK_Godziny PRIMARY KEY (Id_Godziny),
	CONSTRAINT FK_Godziny_Pracownicy FOREIGN KEY (Id_Pracownika) REFERENCES Ksiegowosc.Pracownicy(Id_Pracownika)
	
);
COMMENT ON TABLE Ksiegowosc.Godziny IS 'Tabela zawieraj¹ca liczbe przepracowanych godzin okreœlonego dnia przez ka¿dego pracownika.'

CREATE TABLE Ksiegowosc.Pensja(
	Id_Pensji int not null IDENTITY(1,1),
	Stanowisko nvarchar(50) not null,
	Kwota decimal(10,2) not null,
	CONSTRAINT PK_Pensja PRIMARY KEY (Id_Pensji)
	
);
COMMENT ON TABLE Ksiegowosc.Pracownicy IS 'Tabela zawieraj¹ca wysokoœæ pensji przypisanej do ka¿dego stanowiska pracy .'

CREATE TABLE Ksiegowosc.Premia(
	Id_Premii int not null IDENTITY(1,1),
	Rodzaj nvarchar(50) not null,
	Kwota decimal(10,2) not null,
	CONSTRAINT PK_Premii PRIMARY KEY (Id_Premii),
);
COMMENT ON TABLE Ksiegowosc.Pracownicy IS 'Tabela zawieraj¹ca definicje rodzajów premii i przypisane do nich kwoty .'

CREATE TABLE Ksiegowosc.Wynagrodzenie(
	Id_Wynagrodzenia int not null IDENTITY(1,1),
	[Data] date not null,
	Id_Pracownika int not null,
	Id_Godziny int not null,
	Id_Pensji int not null,
	Id_Premii int not null,
	CONSTRAINT PK_Wynagrodzenie PRIMARY KEY (Id_Wynagrodzenia),
	CONSTRAINT FK_Wynagrodzenie_Pracownicy FOREIGN KEY (Id_Pracownika) REFERENCES Ksiegowosc.Pracownicy(Id_Pracownika),
	CONSTRAINT FK_Wynagrodzenie_Godziny FOREIGN KEY (Id_Godziny) REFERENCES Ksiegowosc.Godziny(Id_Godziny),
	CONSTRAINT FK_Wynagrodzenie_Pensja FOREIGN KEY (Id_Pensji) REFERENCES Ksiegowosc.Pensja(Id_Pensji),
	CONSTRAINT FK_Wynagrodzenie_Premia FOREIGN KEY (Id_Premii) REFERENCES Ksiegowosc.Premia(Id_Premii)
);
COMMENT ON TABLE Ksiegowosc.Pracownicy IS 'Tabela ³¹cz¹ca dane o pracowniku, przepracowanych godzinach, pensji i premii, aby wyliczyæ pe³ne wynagrodzenie.'


--Dane do tabelek zossta³y wygenerowane z pomoc¹ AI
INSERT INTO Ksiegowosc.Pracownicy 
	(Imie, Nazwisko, Adres, Telefon) 
VALUES
('Jan', 'Kowalski', 'ul. D³uga 1, Kraków', '501111222'),
('Joanna', 'Nowak', 'ul. Krótka 2, Wroc³aw', '502222333'),
('Piotr', 'Wiœniewski', 'ul. Leœna 3, Warszawa', '503333444'),
('Anna', 'Zalewski', 'ul. Polna 4, Poznañ', '504444555'),
('Krzysztof', 'Konieczny', 'ul. Zielona 5, Gdañsk', '505555666'),
('Marta', 'Nowicka', 'ul. Boczna 6, £ódŸ', '506666777'),
('Jakub', 'Andrzejewski', 'ul. S³oneczna 7, Katowice', '507777888'),
('Ewa', 'Baran', 'ul. Lipowa 8, Lublin', '508888999'),
('Jacek', 'Cygan', 'ul. Kwiatowa 9, Rzeszów', '509999000'),
('Julia', 'S³oñce', 'ul. G³ówna 10, Kielce', '510000111');


INSERT INTO 
	Ksiegowosc.Godziny ([Data], Liczba_Godzin, Id_Pracownika) 
VALUES
	('2024-09-01', 8, 1),
	('2024-06-04', 12, 2),
	('2024-05-02', 5, 3),
	('2024-03-03', 9, 4),
	('2025-09-14', 4, 5),
	('2025-03-05', 7, 6),
	('2025-02-09', 6, 7),
	('2024-10-06', 8, 8),
	('2025-11-06', 8, 9),
	('2024-03-17', 8, 10);


INSERT INTO Ksiegowosc.Pensja 
	(Stanowisko, Kwota) 
VALUES
	('Kierownik', 8500.00),
	('Ksiêgowy', 5800.00),
	('Specjalista ds. Kadr', 6500.00),
	('Asystent', 1200.00),
	('Sprzedawca', 4500.00),
	('Asystent Administracyjny', 4800.00),
	('Analityk danych', 9300.00),
	('Programista', 9000.00),
	('Mened¿er', 9500.00),
	('Recepcjonista', 4700.00);


INSERT INTO Ksiegowosc.Premia 
	(Rodzaj, Kwota) 
VALUES
	('Kwartalna', 1500.00),
	('Uznaniowa', 800.00),
	('Œwi¹teczna', 1000.00),
	('Za projekt', 2000.00),
	('Brak', 0.00),
	('Jubileuszowa', 3000.00),
	('Motywacyjna', 500.00),
	('Roczna', 4500.00),
	('Za wynik', 1200.00),
	('Za sta¿', 700.00);

INSERT INTO Ksiegowosc.Wynagrodzenie 
	([Data], Id_Pracownika, Id_Godziny, Id_Pensji, Id_Premii) 
VALUES
	( '2024-03-03', 1, 4, 3, 9),   
	('2025-09-14', 2, 5, 1, 5),  
	('2024-09-01', 3, 1, 10, 2),  
	('2025-02-09', 4, 7, 7, 10),  
	('2024-03-17', 5, 10, 4, 1),  
	('2024-06-04', 6, 2, 9, 7),  
	('2025-11-06', 7, 9, 5, 3),   
	('2024-05-02', 8, 3, 2, 6),   
	('2025-03-05', 9, 6, 8, 4),   
	('2024-10-06', 10, 8, 6, 8); 

select *
from Ksiegowosc.Wynagrodzenie

--Wyœwietl tylko id pracownika oraz jego nazwisko. 
SELECT Id_Pracownika, Nazwisko
FROM Ksiegowosc.Pracownicy;

--Wyœwietl id pracowników, których p³aca jest wiêksza ni¿ 1000. 
SELECT KW.Id_Pracownika --, Pensja.Kwota+Premia.Kwota
FROM Ksiegowosc.Wynagrodzenie AS KW
JOIN Ksiegowosc.Pensja AS Pensja ON KW.Id_Pensji=Pensja.Id_Pensji
JOIN Ksiegowosc.Premia AS Premia ON KW.Id_Premii=Premia.Id_Premii
WHERE (Pensja.Kwota+Premia.Kwota)> 1000;

--Wyœwietl id pracowników nieposiadaj¹cych premii, których p³aca jest wiêksza ni¿ 2000. 
SELECT KW.Id_Pracownika , Pensja.Kwota+Premia.Kwota,Premia.Kwota
FROM Ksiegowosc.Wynagrodzenie AS KW
JOIN Ksiegowosc.Pensja AS Pensja ON KW.Id_Pensji=Pensja.Id_Pensji
JOIN Ksiegowosc.Premia AS Premia ON KW.Id_Premii=Premia.Id_Premii
WHERE Pensja.Kwota > 2000 AND Premia.Kwota=0;

--Wyœwietl pracowników, których pierwsza litera imienia zaczyna siê na literê ‘J’. 
SELECT *
FROM Ksiegowosc.Pracownicy 
WHERE Imie like 'J%';

--Wyœwietl pracowników, których nazwisko zawiera literê ‘n’ oraz imiê koñczy siê na literê ‘a’. 
SELECT *
FROM Ksiegowosc.Pracownicy 
WHERE Imie like '%a' AND Nazwisko like '%n%';

--Wyœwietl imiê i nazwisko pracowników oraz liczbê ich nadgodzin, przyjmuj¹c, i¿ standardowy czas pracy to 160h miesiêcznie.
SELECT KP.Imie, KP.Nazwisko, (SUM(KG.Liczba_Godzin)-160) AS Nadgodziny
FROM Ksiegowosc.Pracownicy AS KP
JOIN Ksiegowosc.Godziny AS KG ON KP.Id_Pracownika=KG.Id_Pracownika
GROUP BY KP.Id_Pracownika, KP.Imie, KP.Nazwisko
HAVING SUM(KG.Liczba_Godzin) >160

--Wyœwietl imiê i nazwisko pracowników, których pensja zawiera siê w przedziale 1500 – 3000 PLN.
SELECT KP.Imie, KP.Nazwisko--, KPa.Kwota
FROM Ksiegowosc.Pracownicy AS KP
JOIN Ksiegowosc.Wynagrodzenie AS KW ON KP.Id_Pracownika=KW.Id_Pracownika
JOIN Ksiegowosc.Pensja AS KPa ON KW.Id_Pensji=KPa.Id_Pensji
WHERE KPa.Kwota BETWEEN 1500 AND 3000;

--Wyœwietl imiê i nazwisko pracowników, którzy pracowali w nadgodzinach i nie otrzymali premii.
SELECT KP.Imie, KP.Nazwisko
FROM Ksiegowosc.Pracownicy AS KP
JOIN Ksiegowosc.Wynagrodzenie AS W ON KP.Id_Pracownika=W.Id_Pracownika
JOIN Ksiegowosc.Godziny AS KG ON W.Id_Godziny=KG.Id_Godziny
JOIN Ksiegowosc.Premia AS Pr ON W.Id_Premii=Pr.Id_Premii
WHERE Pr.Kwota=0
GROUP BY KP.Id_Pracownika,KP.Imie, KP.Nazwisko
HAVING SUM(KG.Liczba_Godzin) >160;

--Uszereguj pracowników wed³ug pensji

SELECT P.*, Ps.Kwota AS Pensja
FROM Ksiegowosc.Pracownicy AS P
JOIN Ksiegowosc.Wynagrodzenie AS W ON P.Id_Pracownika=W.Id_Pracownika
JOIN Ksiegowosc.Pensja AS Ps ON W.Id_Pensji=Ps.Id_Pensji
ORDER BY Ps.Kwota 

--Uszereguj pracowników wed³ug pensji i premii malej¹co. 
SELECT P.*, Ps.Kwota, Pr.Kwota
FROM Ksiegowosc.Pracownicy AS P
JOIN Ksiegowosc.Wynagrodzenie AS W ON P.Id_Pracownika=W.Id_Pracownika
JOIN Ksiegowosc.Pensja AS Ps ON W.Id_Pensji=Ps.Id_Pensji
JOIN Ksiegowosc.Premia AS Pr ON W.Id_Premii=Pr.Id_Premii
ORDER BY Ps.Kwota DESC, Pr.Kwota DESC

--Zlicz i pogrupuj pracowników wed³ug pola ‘stanowisko’. 
SELECT Ps.Stanowisko,COUNT(P.Id_Pracownika) AS Liczba_Pracownikow
FROM Ksiegowosc.Pracownicy AS P
JOIN Ksiegowosc.Wynagrodzenie AS W ON P.Id_Pracownika = W.Id_Pracownika
JOIN Ksiegowosc.Pensja AS Ps ON W.Id_Pensji = Ps.Id_Pensji
GROUP BY Ps.Stanowisko
ORDER BY Liczba_Pracownikow 

--Policz œredni¹, minimaln¹ i maksymaln¹ p³acê dla stanowiska ‘kierownik’ (je¿eli takiego nie masz, to przyjmij dowolne inne).

SELECT Stanowisko,AVG(Kwota) AS Œrednia, MIN(Kwota) as Minimum, MAX(Kwota) AS Maksimum
FROM Ksiegowosc.Pensja
WHERE Stanowisko='Kierownik'
GROUP BY Stanowisko;

--Policz sumê wszystkich wynagrodzeñ. 
SELECT SUM(Ps.Kwota+Pr.Kwota) AS Suma_Wynagrodzeñ
FROM Ksiegowosc.Wynagrodzenie AS W
JOIN Ksiegowosc.Pensja AS Ps ON W.Id_Pensji=Ps.Id_Pensji
JOIN Ksiegowosc.Premia AS Pr ON W.Id_Premii=Pr.Id_Premii

--Policz sumê wynagrodzeñ w ramach danego stanowiska. 
SELECT Ps.Stanowisko, SUM(Ps.Kwota+Pr.Kwota) AS Suma_Wynagrodzeñ
FROM Ksiegowosc.Wynagrodzenie AS W
JOIN Ksiegowosc.Pensja AS Ps ON W.Id_Pensji=Ps.Id_Pensji
JOIN Ksiegowosc.Premia AS Pr ON W.Id_Premii=Pr.Id_Premii
GROUP BY Ps.Stanowisko


--Wyznacz liczbê premii przyznanych dla pracowników danego stanowiska. 
SELECT Ps.Stanowisko, COUNT(Pr.Id_Premii) as Liczba_Premii
FROM Ksiegowosc.Pensja AS Ps
JOIN Ksiegowosc.Wynagrodzenie AS W ON Ps.Id_Pensji=W.Id_Pensji
JOIN Ksiegowosc.Premia AS Pr ON W.Id_Premii=Pr.Id_Premii
WHERE Pr.Rodzaj != 'Brak'
GROUP BY Ps.Stanowisko ;

--Usuñ wszystkich pracowników maj¹cych pensjê mniejsz¹ ni¿ 1200 z³.
DELETE FROM Ksiegowosc.Pracownicy
WHERE Id_Pracownika IN (
    SELECT W.Id_Pracownika
    FROM Ksiegowosc.Wynagrodzenie AS W
    JOIN Ksiegowosc.Pensja AS Ps ON W.Id_Pensji = Ps.Id_Pensji
    WHERE Ps.Kwota < 1200
);

