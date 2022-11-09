--17
SELECT pseudo "Poluje w polu", przydzial_myszy, nazwa "Banda"
FROM Kocury INNER JOIN Bandy ON kocury.nr_bandy = bandy.nr_bandy
WHERE przydzial_myszy>50 AND teren IN ('POLE', 'CALOSC');


--18
SELECT k1.imie "Imie", k1.w_stadku_od "Poluje od"
FROM Kocury k1, Kocury k2
WHERE k2.imie = 'JACEK' AND k1.w_stadku_od < k2.w_stadku_od
ORDER BY k1.w_stadku_od DESC;


--19 (HARD)
--a
SELECT k.imie, k.funkcja, k2.imie, k3.imie, k4.imie
FROM Kocury k LEFT JOIN Kocury k2 ON k.szef=k2.pseudo 
LEFT JOIN Kocury k3 ON k2.szef=k3.pseudo 
LEFT JOIN Kocury k4 ON k3.szef=k4.pseudo 
WHERE k.funkcja IN ('KOT', 'MILUSIA');

--b
 SELECT * FROM
    (SELECT imie, CONNECT_BY_ROOT imie, CONNECT_BY_ROOT funkcja, level poziom
    FROM Kocury
    CONNECT BY PRIOR szef=pseudo
    START WITH funkcja IN ('KOT', 'MILUSIA'))
    PIVOT
    (
    MIN(Imie)
    FOR poziom in (2, 3, 4)
    )

--c
SELECT imiek, funk, MAX(sciezka)
FROM
    (SELECT CONNECT_BY_ROOT imie imiek, CONNECT_BY_ROOT funkcja funk, 
    SYS_CONNECT_BY_PATH(rpad(imie, 15), ' | ') || ' |' sciezka
    FROM Kocury
    CONNECT BY PRIOR szef=pseudo
    START WITH funkcja IN ('KOT', 'MILUSIA'))
GROUP BY  imiek,  funk


--20
SELECT k.imie, b.nazwa, w.imie_wroga, w.stopien_wrogosci, wk.data_incydentu
FROM Kocury k 
    INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
    INNER JOIN wrogowie_kocurow wk ON k.pseudo=wk.pseudo
    INNER JOIN wrogowie w ON wk.imie_wroga=w.imie_wroga
WHERE k.plec='D' AND wk.data_incydentu > TO_DATE('01-01-2007', 'dd-mm-yyyy');


--21
SELECT b.nazwa, COUNT(DISTINCT k.pseudo)
FROM Kocury k
    INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
    INNER JOIN Wrogowie_kocurow wk ON k.pseudo=wk.pseudo
GROUP BY b.nazwa;


--22
SELECT k.pseudo, k.funkcja, COUNT(*)
FROM Kocury k
    INNER JOIN Wrogowie_kocurow wk ON k.pseudo=wk.pseudo
GROUP BY k.pseudo, k.funkcja
HAVING COUNT(*)>1;


--23
SELECT imie, (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 "Dawka roczna", 'powyzej 864' "DAWKA"
FROM Kocury
WHERE myszy_extra is not NULL AND (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 > 864
UNION
SELECT imie, (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 "Dawka roczna", '864' "DAWKA"
FROM Kocury
WHERE myszy_extra is not NULL AND (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 = 864
UNION
SELECT imie, (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 "Dawka roczna", 'ponizej 864' "DAWKA"
FROM Kocury
WHERE myszy_extra is not NULL AND (NVL(przydzial_myszy,0)+NVL(myszy_extra,0))*12 < 864
ORDER BY 2 DESC;


--24
--a)
SELECT b.nr_bandy, b.nazwa, b.teren
FROM Bandy b LEFT JOIN Kocury k on b.nr_bandy=k.nr_bandy
WHERE k.pseudo is NULL;
--b)
SELECT b.nr_bandy, b.nazwa, b.teren
FROM Bandy b
MINUS 
SELECT b.nr_bandy, b.nazwa, b.teren
FROM Bandy b
WHERE b.nr_bandy IN (SELECT nr_bandy
                            FROM Kocury);


--25
SELECT imie, funkcja, przydzial_myszy
FROM Kocury
WHERE przydzial_myszy >= ALL(SELECT 3*przydzial_myszy
                            FROM Kocury k
                            NATURAL JOIN Bandy b
                            WHERE k.funkcja='MILUSIA' AND b.teren='SAD');

--26
SELECT Funkcja, ROUND(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))) "Srednio najw. i najm. myszy"
FROM Kocury
HAVING 
        AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) = (SELECT MAX(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))) 
                                     FROM Kocury
                                     HAVING Funkcja != 'SZEFUNIO'
                                     GROUP BY Funkcja) 
       OR
       AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) = (SELECT MIN(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))) 
                                     FROM Kocury
                                     HAVING Funkcja != 'SZEFUNIO'
                                     GROUP BY Funkcja)
GROUP BY Funkcja;

--27
     
--a 
SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0)
FROM Kocury k
WHERE &n >=
        (SELECT COUNT(DISTINCT NVL(przydzial_myszy,0)+NVL(myszy_extra,0))
         FROM Kocury
         WHERE NVL(przydzial_myszy,0)+NVL(myszy_extra,0) >= NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0));
   
      
--b
SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0)
FROM Kocury
WHERE
    (NVL(przydzial_myszy,0)+NVL(myszy_extra,0) IN
    (SELECT *
    FROM
        (SELECT DISTINCT (NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) 
        FROM Kocury  
        ORDER BY  NVL(przydzial_myszy,0)+NVL(myszy_extra,0) DESC)
    WHERE ROWNUM <= &n));

--c
SELECT k1.pseudo, MIN(NVL(k1.przydzial_myszy,0)+NVL(k1.myszy_extra,0))
FROM Kocury k1
INNER JOIN Kocury k2 ON NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0) >= NVL(k1.przydzial_myszy,0)+NVL(k1.myszy_extra,0)
GROUP BY k1.pseudo
HAVING COUNT(DISTINCT NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0)) <= &n
--ORDER BY NVL(k1.przydzial_myszy,0)+NVL(k1.myszy_extra,0) DESC;

--d
SELECT pseudo, myszy
FROM 
    (SELECT pseudo, 
    NVL(przydzial_myszy,0)+NVL(myszy_extra,0) myszy,
    DENSE_RANK()
    OVER (ORDER BY NVL(przydzial_myszy,0)+NVL(myszy_extra,0) DESC) pozycja
    FROM Kocury)
WHERE pozycja <=&n;



--28
SELECT TO_CHAR(w_stadku_od, 'YYYY'), COUNT(*)
FROM Kocury
GROUP BY TO_CHAR(w_stadku_od, 'YYYY')
HAVING COUNT(*) IN(
    (SELECT liczba
    FROM
        (
        SELECT COUNT(*) liczba
        FROM Kocury
        GROUP BY TO_CHAR(w_stadku_od, 'YYYY') 
        HAVING COUNT(*) <= 
                (SELECT AVG(COUNT(*)) 
                FROM Kocury 
                GROUP BY TO_CHAR(w_stadku_od, 'YYYY'))
        ORDER BY COUNT(*) DESC 
        )
    WHERE ROWNUM=1),
    (SELECT liczba
    FROM
        (
        SELECT COUNT(*) liczba
        FROM Kocury
        GROUP BY TO_CHAR(w_stadku_od, 'YYYY') 
        HAVING COUNT(*) >= 
                (SELECT AVG(COUNT(*)) 
                FROM Kocury 
                GROUP BY TO_CHAR(w_stadku_od, 'YYYY'))
        ORDER BY COUNT(*) ASC 
        )
    WHERE ROWNUM=1))
UNION
SELECT 'Srednia', AVG(COUNT(*)) 
FROM Kocury 
GROUP BY TO_CHAR(w_stadku_od, 'YYYY')
ORDER BY 2


--29 (HARD)
--a
SELECT k1.imie, MIN(NVL(k1.przydzial_myszy,0)+NVL(k1.myszy_extra,0)) "Zjada", MIN(k1.nr_bandy) "Nr bandy", AVG(NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0)) "Srednia bandy"
FROM Kocury k1
LEFT JOIN Kocury k2 ON k1.nr_bandy=k2.nr_bandy
WHERE k1.plec='M'
GROUP BY k1.imie 
HAVING MIN(NVL(k1.przydzial_myszy,0)+NVL(k1.myszy_extra,0)) <= AVG(NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0));

--b
SELECT k.imie, NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0) "Zjada", k.nr_bandy "Nr bandy", bs.srednia
FROM Kocury k, (SELECT nr_bandy, AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) AS srednia
                FROM Bandy
                NATURAL JOIN Kocury
                GROUP BY nr_bandy) bs
WHERE k.plec='M' AND k.nr_bandy=bs.nr_bandy AND NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0)<=bs.srednia


--c
SELECT k.imie, NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0) "Zjada", k.nr_bandy "Nr bandy", 
(SELECT AVG(NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0))
FROM Kocury k2
WHERE k.nr_bandy=k2.nr_bandy) "Srednia bandy"
FROM Kocury k
WHERE k.plec='M' AND 
NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0) <= 
    (SELECT AVG(NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0))
    FROM Kocury k2
    WHERE k.nr_bandy=k2.nr_bandy)


--30
SELECT k1.imie, k1.w_stadku_od, '<-- NAJSTARSZY STAZEM W BANDZIE ' || b.nazwa " "
FROM Kocury k1 INNER JOIN Bandy b ON k1.nr_bandy=b.nr_bandy 
WHERE k1.w_stadku_od=(SELECT MIN(k2.w_stadku_od) FROM Kocury k2 WHERE k1.nr_bandy=k2.nr_bandy)
UNION
SELECT k1.imie, k1.w_stadku_od, '<-- NAJMLODSZY STAZEM W BANDZIE ' || b.nazwa " "
FROM Kocury k1 INNER JOIN Bandy b ON k1.nr_bandy=b.nr_bandy 
WHERE k1.w_stadku_od=(SELECT MAX(k2.w_stadku_od) FROM Kocury k2 WHERE k1.nr_bandy=k2.nr_bandy)
UNION
SELECT k.imie, k.w_stadku_od, ' ' " "
FROM Kocury k INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy 
WHERE k.imie NOT IN 
    (SELECT k1.imie
    FROM Kocury k1 INNER JOIN Bandy b ON k1.nr_bandy=b.nr_bandy 
    WHERE k1.w_stadku_od=(SELECT MIN(k2.w_stadku_od) FROM Kocury k2 WHERE k1.nr_bandy=k2.nr_bandy)
    UNION
    SELECT k1.imie
    FROM Kocury k1 INNER JOIN Bandy b ON k1.nr_bandy=b.nr_bandy 
    WHERE k1.w_stadku_od=(SELECT MAX(k2.w_stadku_od) FROM Kocury k2 WHERE k1.nr_bandy=k2.nr_bandy)
    )  


--31
CREATE VIEW bandy_extended(nazwa, avg, min, max, koty, myszy_extra)
AS
SELECT b.nazwa, AVG(k.przydzial_myszy), MAX(k.przydzial_myszy), 
        MIN(k.przydzial_myszy), COUNT(k.pseudo), COUNT(k.myszy_extra)
FROM Bandy b INNER JOIN Kocury k ON b.nr_bandy=k.nr_bandy
GROUP BY b.nazwa;


SELECT k.pseudo, k.imie, k.funkcja, k.przydzial_myszy, 'OD ' || be.min || ' DO ' || be.max " ", k.w_stadku_od
FROM Kocury k INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
INNER JOIN bandy_extended be ON b.nazwa=be.nazwa
WHERE k.pseudo='&pseudonim';

--32
SELECT pseudo, plec, NVL(przydzial_myszy,0), NVL(myszy_extra,0)
FROM Kocury
WHERE pseudo IN (
             (SELECT * 
             FROM (SELECT pseudo 
                   FROM Kocury k INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
                   WHERE b.nazwa = 'CZARNI RYCERZE'
                   ORDER BY w_stadku_od)
             WHERE ROWNUM <= 3)
             UNION
             (SELECT * 
              FROM (SELECT pseudo 
                   FROM Kocury k INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
                   WHERE b.nazwa = 'LACIACI MYSLIWI'
                   ORDER BY w_stadku_od)
              WHERE ROWNUM <= 3));
              

UPDATE Kocury
SET przydzial_myszy = CASE plec
    WHEN 'D' THEN  NVL(przydzial_myszy,0) + 0.1*(SELECT MIN(NVL(przydzial_myszy,0)) FROM Kocury)
    ELSE NVL(przydzial_myszy,0) + 10 END,
    myszy_extra= NVL(myszy_extra,0) + 0.15 * (SELECT AVG(NVL(myszy_extra,0)) FROM Kocury k2 GROUP BY nr_bandy HAVING k2.nr_bandy=Kocury.nr_bandy)
WHERE pseudo IN 
            ((SELECT * 
             FROM (SELECT pseudo 
                   FROM Kocury k INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
                   WHERE b.nazwa = 'CZARNI RYCERZE'
                   ORDER BY w_stadku_od)
             WHERE ROWNUM <= 3)
             UNION
             (SELECT * 
              FROM (SELECT pseudo 
                   FROM Kocury k INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
                   WHERE b.nazwa = 'LACIACI MYSLIWI'
                   ORDER BY w_stadku_od)
              WHERE ROWNUM <= 3));
          
          
SELECT pseudo, plec, NVL(przydzial_myszy,0), NVL(myszy_extra,0)
FROM Kocury
WHERE pseudo IN (
             (SELECT * 
             FROM (SELECT pseudo 
                   FROM Kocury k INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
                   WHERE b.nazwa = 'CZARNI RYCERZE'
                   ORDER BY w_stadku_od)
             WHERE ROWNUM <= 3)
             UNION
             (SELECT * 
              FROM (SELECT pseudo 
                   FROM Kocury k INNER JOIN Bandy b ON k.nr_bandy=b.nr_bandy
                   WHERE b.nazwa = 'LACIACI MYSLIWI'
                   ORDER BY w_stadku_od)
              WHERE ROWNUM <= 3));
              
ROLLBACK;

--33 (HARD)
--a
SELECT DECODE(plec, 'M', ' ', nazwa) "Nazwa bandy", plec, ile, szefunio, bandzior, lowczy, lapacz, kot, milusia, dzielczy, suma
FROM
(SELECT '--------------' nazwa, '-------------' plec, '-------------' ile, '-------------' szefunio, '-------------' bandzior, '-------------' lowczy, '-------------' lapacz, '-------------' kot, '-------------' milusia, '-------------' dzielczy, '-------------' suma
FROM DUAL
UNION
SELECT nazwa, plec "PLEC", TO_CHAR(COUNT(*)) ile, 
TO_CHAR(SUM(DECODE(k.funkcja, 'SZEFUNIO', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) szefunio,
TO_CHAR(SUM(DECODE(k.funkcja, 'BANDZIOR', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) bandzior,
TO_CHAR(SUM(DECODE(k.funkcja, 'LOWCZY', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) lowczy,
TO_CHAR(SUM(DECODE(k.funkcja, 'LAPACZ', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) lapacz,
TO_CHAR(SUM(DECODE(k.funkcja, 'KOT', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) kot,
TO_CHAR(SUM(DECODE(k.funkcja, 'MILUSIA', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) milusia,
TO_CHAR(SUM(DECODE(k.funkcja, 'DZIELCZY', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) dzielczy,
TO_CHAR(SUM(NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0))) sumamyszy
FROM Bandy b INNER JOIN Kocury k ON b.nr_bandy=k.nr_bandy
GROUP BY b.nazwa, k.plec
UNION
SELECT 'Z-------------' " ", '-------------' " ", '-------------' " ", '-------------' " ", '-------------' " ", '-------------' " ", '-------------' " ", '-------------' " ", '-------------' " ", '-------------' " ", '-------------' " "
FROM DUAL
UNION
SELECT 'ZJADA RAZEM' " ", ' ' " ", ' ' " ",
TO_CHAR(SUM(DECODE(k.funkcja, 'SZEFUNIO', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) szefunio,
TO_CHAR(SUM(DECODE(k.funkcja, 'BANDZIOR', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) bandzior,
TO_CHAR(SUM(DECODE(k.funkcja, 'LOWCZY', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) lowczy,
TO_CHAR(SUM(DECODE(k.funkcja, 'LAPACZ', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) lapacz,
TO_CHAR(SUM(DECODE(k.funkcja, 'KOT', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) kot,
TO_CHAR(SUM(DECODE(k.funkcja, 'MILUSIA', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) milusia,
TO_CHAR(SUM(DECODE(k.funkcja, 'DZIELCZY', NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0), 0))) dzielczy,
TO_CHAR(SUM(NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0))) sumamyszy
FROM Bandy b INNER JOIN Kocury k ON b.nr_bandy=k.nr_bandy);

--b

SELECT DECODE(plec, 'M', ' ', nazwa), plec, ile, NVL(szefunio,0), NVL(bandzior,0), NVL(lowczy,0), NVL(lapacz,0), NVL(kot,0), NVL(milusia,0), NVL(dzielczy,0), NVL(suma,0)
FROM 
(SELECT *
FROM
    (SELECT b.nazwa nazwa, k.plec plec, COUNT(*) OVER(PARTITION BY b.nazwa, k.plec) ile, k.funkcja funkcja, (NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) myszy, SUM(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) OVER(PARTITION BY b.nazwa, k.plec) suma 
    FROM Kocury k INNER JOIN BANDY b ON k.nr_bandy=b.nr_bandy)
    PIVOT
    (
        SUM(NVL(myszy,0))
        FOR funkcja
        IN ('SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz, 'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy)
    )
UNION
SELECT * 
FROM
    ((SELECT 'ZJADA RAZEM' " ", ' ' plec, TO_NUMBER('') "ILE", funkcja, (NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) myszy, SUM(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) OVER() "SUMA"
    FROM Kocury)
         PIVOT
        (
            SUM(NVL(myszy,0))
            FOR funkcja
            IN ('SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz, 'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy)
        )
    ))

