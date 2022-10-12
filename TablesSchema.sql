CREATE TABLE Bandy(
nr_bandy NUMBER(2) CONSTRAINT ban_nr_pk PRIMARY KEY,
nazwa VARCHAR2(20) CONSTRAINT ban_naz_nn NOT NULL,
teren VARCHAR2(15)CONSTRAINT ban_ter_un UNIQUE,
szef_bandy VARCHAR2(15)CONSTRAINT ban_sze_un UNIQUE
);

CREATE TABLE Funkcje(
funkcja VARCHAR2(10) CONSTRAINT fun_fun_pr PRIMARY KEY,
min_myszy NUMBER(3) CONSTRAINT fun_mim_che CHECK(min_myszy>5),
max_myszy NUMBER(3), 
CONSTRAINT fun_max_che CHECK(max_myszy BETWEEN min_myszy AND 200)
);

CREATE TABLE Wrogowie(
imie_wroga VARCHAR2(15) CONSTRAINT wro_imi_pk PRIMARY KEY,
stopien_wrogosci NUMBER(2) CONSTRAINT wro_sto_che CHECK(stopien_wrogosci BETWEEN 1 AND 10),
gatunek VARCHAR2(15),
lapowka VARCHAR2(20)
);

CREATE TABLE Kocury(
imie VARCHAR2(15) CONSTRAINT koc_im_nn NOT NULL,
plec VARCHAR2(1) CONSTRAINT koc_ple_in CHECK(plec IN ('M','D')),
pseudo VARCHAR2(15) CONSTRAINT koc_ps_pk PRIMARY KEY,
funkcja VARCHAR2(10) CONSTRAINT koc_fu_fk REFERENCES Funkcje(funkcja),
szef VARCHAR2(15) CONSTRAINT koc_sze_fk REFERENCES Kocury(pseudo),
w_stadku_od DATE DEFAULT SYSDATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(2) CONSTRAINT koc_nrb_fk REFERENCES Bandy(nr_bandy) 
);

ALTER TABLE Bandy
ADD CONSTRAINT ban_sze_fk FOREIGN KEY(szef_bandy) REFERENCES Kocury(pseudo);

CREATE TABLE Wrogowie_kocurow(
pseudo VARCHAR2(15) CONSTRAINT wk_ps_fk REFERENCES Kocury(pseudo),
imie_wroga VARCHAR2(15) REFERENCES Wrogowie(imie_wroga),
data_incydentu DATE CONSTRAINT wk_di_nn NOT NULL,
opis_incydentu VARCHAR2(50),
CONSTRAINT wk_pk PRIMARY KEY(pseudo, imie_wroga)
);