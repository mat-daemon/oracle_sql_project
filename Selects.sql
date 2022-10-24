--1
SELECT imie_wroga "WROG", opis_incydentu "PRZEWINA " FROM Wrogowie_kocurow 
WHERE TO_CHAR(data_incydentu, 'YYYY')='2009';

--2
SELECT imie, funkcja, w_stadku_od "Z NAMI OD"
FROM Kocury 
WHERE plec='D' AND w_stadku_od BETWEEN TO_DATE('01/09/2005', 'dd/mm/yyyy') AND TO_DATE('31/07/2007', 'dd/mm/yyyy');

--3
SELECT imie_wroga "WROG", gatunek "GATUNEK", stopien_wrogosci "STOPIEN WROGOSCI" FROM Wrogowie
WHERE lapowka is NULL
ORDER BY Stopien_wrogosci;

--4
SELECT imie || ' zwany ' || pseudo || ' (fun. ' || funkcja || ') ' || 'lowi myszki w bandzie ' || nr_bandy || ' od ' || w_stadku_od "Wszystko o kocurach"
FROM Kocury
WHERE plec='M'
ORDER BY w_stadku_od DESC, pseudo;

--5
SELECT pseudo "PSEUDO", 
    REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'A', '#', 1, 1), 'L', '%', 1, 1) "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE pseudo LIKE '%A%' AND pseudo LIKE '%L%';

--6
SELECT imie, w_stadku_od "W stadku", 
FLOOR(NVL(przydzial_myszy,0)/1.1) "Zjadal", ADD_MONTHS(w_stadku_od, 6) "Podwyzka",
przydzial_myszy "Zjada"
FROM Kocury
WHERE months_between(SYSDATE, w_stadku_od)/12 >= 13
AND TO_CHAR(w_stadku_od, 'mm') BETWEEN 3 AND 9;


--7
SELECT imie, 3*NVL(przydzial_myszy,0) "myszy kwartalnie",
3*NVL(myszy_extra,0) "kwartalne dodatki"
FROM Kocury
WHERE NVL(przydzial_myszy,0) > 2*NVL(myszy_extra,0) AND NVL(przydzial_myszy, 0) >= 55;


--8
SELECT Imie,
CASE 
    WHEN (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 > 660 
    THEN TO_CHAR((NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12)
ELSE
    CASE
    WHEN (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 = 660 
    THEN 'Limit'
    ELSE 'Ponizej 660'
    END
END "Zjada rocznie"
FROM Kocury;


--9
SELECT pseudo, w_stadku_od,
CASE
    WHEN TO_CHAR(w_stadku_od, 'DD') BETWEEN 1 AND 15
    THEN
        CASE
        WHEN NEXT_DAY('2022/10/25', 'Środa') > LAST_DAY('2022/10/25')
        THEN NEXT_DAY(LAST_DAY(TO_DATE('2022/10/25')+7) - INTERVAL '7' DAY, 'Środa')
        ELSE NEXT_DAY(LAST_DAY('2022/10/25') - INTERVAL '7' DAY, 'Środa')
        END
    ELSE
        NEXT_DAY(LAST_DAY(ADD_MONTHS('2022/10/25', 1))- INTERVAL '7' DAY, 'Środa')
    END "wyplata"
FROM Kocury;

SELECT pseudo, w_stadku_od,
CASE
    WHEN TO_CHAR(w_stadku_od, 'DD') BETWEEN 1 AND 15
    THEN
        CASE
        WHEN NEXT_DAY('2022/10/27', 'Środa') > LAST_DAY('2022/10/28')
        THEN NEXT_DAY(LAST_DAY(TO_DATE('2022/10/27')+7) - INTERVAL '7' DAY, 'Środa')
        ELSE NEXT_DAY(LAST_DAY('2022/10/27') - INTERVAL '7' DAY, 'Środa')
        END
    ELSE
        NEXT_DAY(LAST_DAY(ADD_MONTHS('2022/10/27', 1))- INTERVAL '7' DAY, 'Środa')
    END "wyplata"
FROM Kocury;


--10
SELECT pseudo||'-'|| 
DECODE(COUNT(*), 1, 'Unikalny', 'nieunikalny') "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo;

SELECT szef||'-'|| 
DECODE(COUNT(szef), 1, 'Unikalny', 'nieunikalny') "Unikalnosc atr. SZEF"
FROM Kocury
GROUP BY szef
    HAVING szef is not NULL;


--11
SELECT pseudo "Pseudonim", COUNT(*) "Liczba wrogow"
FROM Wrogowie_kocurow
GROUP BY pseudo
    HAVING COUNT(*) >= 2;


--12
SELECT 'Liczba kotow= ' || COUNT(*) || ' lowi jako ' 
|| funkcja || ' i zjada max. ' || MAX(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) 
|| ' myszy miesiecznie' " "
FROM Kocury
WHERE plec='D' AND funkcja!='Szefunio'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) > 50;


--13
SELECT nr_bandy, plec, MIN(przydzial_myszy) "Minimalny przydzial"
FROM Kocury
GROUP BY nr_bandy, plec;


--14
SELECT level "Poziom", pseudo "Pseudonim", funkcja, nr_bandy
FROM Kocury
WHERE plec='M'
CONNECT BY PRIOR pseudo=szef
START WITH funkcja='BANDZIOR';


--15
SELECT LPAD(level-1, 4*(level-1)+LENGTH(level),'===>') || '            ' || imie "Hierarchia",
DECODE(szef, NULL, 'Sam sobie panem', szef) "Pseudo szefa", funkcja
FROM Kocury
WHERE myszy_extra is not NULL
CONNECT BY PRIOR pseudo=szef
START WITH szef is NULL;


--16
SELECT RPAD(' ', 4 * (LEVEL - 1), ' ') || pseudo "Sciezka pseudonimow"
FROM Kocury
CONNECT BY PRIOR szef = pseudo
START WITH plec ='M' AND (months_between('2022/07/14', w_stadku_od)/12)>13
           AND myszy_extra IS NULL;