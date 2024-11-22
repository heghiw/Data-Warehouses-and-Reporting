--faktova tabulka Kontrakty
CREATE OR REPLACE TABLE `tym_11_L1.KontraktyFACT` 
AS SELECT 
faktury.idfaktury AS id_faktura, 
kontrakty.idkontr AS id_kontraktu,
kontrakty.datumod AS zacatek_zapujcky,
kontrakty.datumdo AS konec_zapujcky,
kontrakty.cena_celkem AS cena_kontraktu_celkem,
faktury.cena_celkem AS cena_faktury,
spokojenost.NPS AS nps,
faktury.dat_vystaveni AS datum_vystaveni,
faktury.dat_splatnosti AS datum_splatnosti, 
faktury.dat_zaplaceno AS datum_zaplaceno,
faktury.idvcas AS id_vcas,
faktury.idzaplaceno AS id_zaplaceno,
timestamp_diff(kontrakty.datumdo, kontrakty.datumod, DAY) AS delka_kontraktu,
timestamp_diff(faktury.dat_zaplaceno, faktury.dat_splatnosti, DAY) AS zpozdeni_platby,
ZakaznikDIM.id_zakaznika, 
ZdrojDIM.id_zdroje,
ZamestnanecDIM.id_zamestnance,
PobockaDIM.id_pob
FROM `tym_11_L0.t_faktury_vydane` AS faktury
JOIN `tym_11_L0.t_kontrakty` AS  kontrakty
ON faktury.idkontr = kontrakty.idkontr
JOIN `tym_11_L0.t_spokojenost` AS  spokojenost
ON faktury.idkontr = spokojenost.idkontr
JOIN `tym_11_L1.ZakaznikDIM` AS ZakaznikDIM
ON ZakaznikDIM.id_zakaznika = faktury.idzak
JOIN `tym_11_L1.ZdrojDIM` AS ZdrojDIM
ON kontrakty.idzdroje=ZdrojDIM.id_zdroje
JOIN `tym_11_L0.t_zakaznici` as zakaznici
ON zakaznici.idzak = faktury.idzak
JOIN `tym_11_L1.ZamestnanecDIM` AS ZamestnanecDIM
ON zakaznici.idzam= ZamestnanecDIM.id_zamestnance
JOIN `tym_11_L0.t_zamestnanci` as zamestnanci 
ON zamestnanci.idzam = ZamestnanecDIM.id_zamestnance
JOIN `tym_11_L1.PobockaDIM` AS PobockaDIM
ON zamestnanci.idpob = PobockaDIM.id_pob;

ALTER TABLE `tym_11_L1.KontraktyFACT`
ADD FOREIGN KEY (id_pob) REFERENCES `tym_11_L1.PobockaDIM`(id_pob) NOT ENFORCED,
ADD FOREIGN KEY(id_zamestnance) REFERENCES `tym_11_L1.ZamestnanecDIM`(id_zamestnance) NOT ENFORCED,
ADD FOREIGN KEY (id_zakaznika) REFERENCES `tym_11_L1.ZakaznikDIM` (id_zakaznika)NOT ENFORCED,
ADD FOREIGN KEY (id_zdroje) REFERENCES `tym_11_L1.ZdrojDIM` (id_zdroje)NOT ENFORCED;


--Zamestnanec
CREATE OR REPLACE TABLE `tym_11_L1.ZamestnanecDIM`
AS SELECT
	
	zamestnanec.idzam AS id_zamestnance,
	zamestnanec.Nadrizeny AS id_nadrizeny,
	zamestnanec.Jmeno AS jmeno,
	zamestnanec.Prijmeni AS prijemni,
	zamestnanec.Plat AS plat,
	funkce.Nazev AS funkce,
	funkce.Ohodnoceni AS plat_podle_funkce
FROM `tym_11_L0.t_zamestnanci` AS  zamestnanec
JOIN  `tym_11_L0.t_funkce` AS  funkce
ON zamestnanec.idfce = funkce.idfce;
 

ALTER TABLE `tym_11_L1.ZamestnanecDIM`
ADD PRIMARY KEY (id_zamestnance) NOT ENFORCED;

--Pobocka
CREATE OR REPLACE TABLE `tym_11_L1.PobockaDIM`
AS SELECT
	idpob as id_pob,
  Zkratka as zkratka,
  Ulice as ulice,
  pobocka.PSC as psc,
  okres.Okres as okres

FROM `tym_11_L0.t_pobocky` AS  pobocka
JOIN `tym_11_L0.t_PSC` AS psc
ON psc.PSC = pobocka.PSC
JOIN `tym_11_L0.t_Okresy` AS okres
ON psc.idokres = okres.idokres;


ALTER TABLE `tym_11_L1.PobockaDIM`
ADD PRIMARY KEY (id_pob) NOT ENFORCED;



--zdroj
CREATE OR REPLACE TABLE `tym_11_L1.ZdrojDIM`
AS SELECT
zdroje.idzdroje as id_zdroje,
zdroje.Nazev AS nazev,
typ_zdroje.Typ AS typ_zdroje,
zdroje.naklady AS naklady_zdroje,
zdroje.cena AS cena_zdroje,
zdroje.cena - zdroje.naklady as profitabilita
FROM `tym_11_L0.t_zdroje` AS zdroje
JOIN  `tym_11_L0.t_typy_zdroju` AS  typ_zdroje
ON zdroje.idtypzdroje = typ_zdroje.idtypzdroje;
 
ALTER TABLE `tym_11_L1.ZdrojDIM`
ADD PRIMARY KEY (id_zdroje) NOT ENFORCED;

--zakaznik
CREATE OR REPLACE TABLE `tym_11_L1.ZakaznikDIM`
AS SELECT
    zakaznik.idzak AS id_zakaznika,
    zakaznik.Nazev AS nazev,
    zakaznik.Kredit AS vyse_kreditu,
    kategorie.Nazev AS kategorie,
    kategorie.Sleva AS sleva,
    zakaznik.ICO AS ico,
    zakaznik.Ulice AS ulice,
    zakaznik.PSC AS psc,
    okres.Okres AS okres,
    kraj.Kraj AS kraj
FROM `tym_11_L0.t_zakaznici` AS zakaznik
JOIN `tym_11_L0.t_kategorie_zakazniku` AS kategorie
ON zakaznik.idkat = kategorie.idkat
JOIN `tym_11_L0.t_PSC` AS psc
ON psc.PSC = zakaznik.PSC
JOIN `tym_11_L0.t_Okresy` AS okres
ON psc.idokres = okres.idokres
JOIN `tym_11_L0.t_Kraje` AS kraj
ON kraj.idkraj = okres.idkraj;
 
ALTER TABLE `tym_11_L1.ZakaznikDIM`
ADD PRIMARY KEY (id_zakaznika) NOT ENFORCED;

--kategorie/transakce

CREATE OR REPLACE TABLE `tym_11_L1.KategorieTransakceDIM`
AS SELECT
kategorie.idoper as id_oper, 
kategorie.oper as kategorie_transakce
FROM `tym_11_L0.pomOper` AS kategorie
;
 
ALTER TABLE `tym_11_L1.KategorieTransakceDIM`
ADD PRIMARY KEY (id_oper) NOT ENFORCED;
 
INSERT INTO `tym_11_L1.KategorieTransakceDIM` (id_oper, kategorie_transakce) 
VALUES (6, 'Příjem');
 
ALTER TABLE `tym_11_L1.KategorieTransakceDIM`
ADD COLUMN prijem_vydaj BOOLEAN;
 
UPDATE `tym_11_L1.KategorieTransakceDIM`
SET prijem_vydaj = FALSE
WHERE id_oper IN (1, 2, 3, 4, 5);
 
UPDATE `tym_11_L1.KategorieTransakceDIM`
SET prijem_vydaj = TRUE
WHERE id_oper = 6;


--faktova tabulka prijmy vydaje
CREATE OR REPLACE TABLE `tym_11_L1.PrijmyVydajeFACT` AS
SELECT
  prijmy_skutecnost.idpol AS id_transakce,
  prijmy_skutecnost.datum AS datum,
  prijmy_plan.idkontr AS id_kontraktu,
  PobockaDIM.id_pob,
  ZamestnanecDIM.id_zamestnance,
  KategorieTransakceDIM.id_oper,
  ZakaznikDIM.id_zakaznika,
  ZdrojDIM.id_zdroje,
  prijmy_plan.castka AS planovana_castka,
  prijmy_skutecnost.castka AS skutecna_castka,
  prijmy_plan.castka - prijmy_skutecnost.castka AS rozdil_plan_skut,
  prijmy_skutecnost.idrefpol AS id_transakce_plan
FROM `tym_11_L0.t_prijmy_skutecnost` AS prijmy_skutecnost
LEFT JOIN `tym_11_L0.t_prijmy_plan` AS prijmy_plan
  ON prijmy_skutecnost.idrefpol = prijmy_plan.idpol
JOIN `tym_11_L0.t_kontrakty` AS kontrakty
  ON prijmy_plan.idkontr = kontrakty.idkontr
JOIN `tym_11_L0.t_zakaznici` AS zakaznici
  ON kontrakty.idzak = zakaznici.idzak
JOIN `tym_11_L0.t_zamestnanci` AS zamestnanci
  ON zamestnanci.idzam = zakaznici.idzam
JOIN `tym_11_L1.PobockaDIM` AS PobockaDIM
  ON zamestnanci.idpob = PobockaDIM.id_pob
JOIN `tym_11_L1.ZakaznikDIM` AS ZakaznikDIM
  ON kontrakty.idzak = ZakaznikDIM.id_zakaznika
JOIN `tym_11_L1.ZamestnanecDIM` AS ZamestnanecDIM
  ON ZamestnanecDIM.id_zamestnance = zakaznici.idzam
JOIN `tym_11_L1.KategorieTransakceDIM` AS KategorieTransakceDIM
  ON KategorieTransakceDIM.id_oper = 6
JOIN `tym_11_L1.ZdrojDIM` AS ZdrojDIM
  ON ZdrojDIM.id_zdroje = kontrakty.idzdroje

UNION ALL

SELECT
  vydaje_mzdy_skutecnost.idpol AS id_transakce,
  vydaje_mzdy_skutecnost.datum AS datum,
  NULL AS id_kontraktu,
  PobockaDIM.id_pob,
  ZamestnanecDIM.id_zamestnance,
  KategorieTransakceDIM.id_oper,
  NULL AS id_zakaznika,
  NULL AS id_zdroje,
  vydaje_mzdy_plan.castka AS planovana_castka,
  vydaje_mzdy_skutecnost.castka AS skutecna_castka,
  vydaje_mzdy_plan.castka - vydaje_mzdy_skutecnost.castka AS rozdil_plan_skut,
  vydaje_mzdy_skutecnost.idrefpol AS id_transakce_plan
FROM `tym_11_L0.t_vydaje_mzdy_skutecnost` AS vydaje_mzdy_skutecnost
LEFT JOIN `tym_11_L0.t_vydaje_mzdy_plan` AS vydaje_mzdy_plan
  ON vydaje_mzdy_skutecnost.idrefpol = vydaje_mzdy_plan.idpol  
JOIN `tym_11_L0.t_zamestnanci` AS zamestnanci
  ON zamestnanci.idzam = vydaje_mzdy_plan.idzam
JOIN `tym_11_L1.PobockaDIM` AS PobockaDIM
  ON zamestnanci.idpob = PobockaDIM.id_pob
JOIN `tym_11_L1.ZamestnanecDIM` AS ZamestnanecDIM
  ON ZamestnanecDIM.id_zamestnance = vydaje_mzdy_plan.idzam
JOIN `tym_11_L1.KategorieTransakceDIM` AS KategorieTransakceDIM
  ON KategorieTransakceDIM.id_oper = 3

UNION ALL

SELECT
  vydaje_osobni_skutecnost.idpol AS id_transakce,
  vydaje_osobni_skutecnost.datum AS datum,
  NULL AS id_kontraktu,
  PobockaDIM.id_pob,
  ZamestnanecDIM.id_zamestnance,
  KategorieTransakceDIM.id_oper,
  NULL AS id_zakaznika,
  NULL AS id_zdroje,
  vydaje_osobni_plan.castka AS planovana_castka,
  vydaje_osobni_skutecnost.castka AS skutecna_castka,
  vydaje_osobni_plan.castka - vydaje_osobni_skutecnost.castka AS rozdil_plan_skut,
  vydaje_osobni_skutecnost.idrefpol AS id_transakce_plan
FROM `tym_11_L0.t_vydaje_osobni_skutecnost` AS vydaje_osobni_skutecnost
LEFT JOIN `tym_11_L0.t_vydaje_osobni_plan` AS vydaje_osobni_plan
  ON vydaje_osobni_skutecnost.idrefpol = vydaje_osobni_plan.idpol  
JOIN `tym_11_L0.t_zamestnanci` AS zamestnanci
  ON zamestnanci.idzam = vydaje_osobni_plan.idzam
JOIN `tym_11_L1.PobockaDIM` AS PobockaDIM
  ON zamestnanci.idpob = PobockaDIM.id_pob
JOIN `tym_11_L1.ZamestnanecDIM` AS ZamestnanecDIM
  ON ZamestnanecDIM.id_zamestnance = vydaje_osobni_plan.idzam
JOIN `tym_11_L1.KategorieTransakceDIM` AS KategorieTransakceDIM
  ON KategorieTransakceDIM.id_oper = 4

UNION ALL

SELECT
  vydaje_najem_skutecnost.idpol AS id_transakce,
  vydaje_najem_skutecnost.datum AS datum,
  NULL AS id_kontraktu,
  PobockaDIM.id_pob,
  NULL AS id_zamestnance,
  KategorieTransakceDIM.id_oper,
  NULL AS id_zakaznika,
  NULL AS id_zdroje,
  vydaje_najem_plan.castka AS planovana_castka,
  vydaje_najem_skutecnost.castka AS skutecna_castka,
  vydaje_najem_plan.castka - vydaje_najem_skutecnost.castka AS rozdil_plan_skut,
  vydaje_najem_skutecnost.idrefpol AS id_transakce_plan
FROM `tym_11_L0.t_vydaje_najem_skutecnost` AS vydaje_najem_skutecnost
LEFT JOIN `tym_11_L0.t_vydaje_najem_plan` AS vydaje_najem_plan
  ON vydaje_najem_skutecnost.idrefpol = vydaje_najem_plan.idpol  
JOIN `tym_11_L1.PobockaDIM` AS PobockaDIM
  ON vydaje_najem_plan.idpob = PobockaDIM.id_pob
JOIN `tym_11_L1.KategorieTransakceDIM` AS KategorieTransakceDIM
  ON KategorieTransakceDIM.id_oper = 1
UNION ALL 
---edit kat 5
SELECT 
  vydaje_rezie_skutecnost.idpol AS id_transakce,
  vydaje_rezie_skutecnost.datum AS datum,
  NULL AS id_kontraktu,
  PobockaDIM.id_pob,
  NULL AS id_zamestnance,
  KategorieTransakceDIM.id_oper,
  NULL AS id_zakaznika,
  NULL AS id_zdroje,
  vydaje_rezie_plan.castka AS planovana_castka,
  vydaje_rezie_skutecnost.castka AS skutecna_castka,
  vydaje_rezie_plan.castka - vydaje_rezie_skutecnost.castka AS rozdil_plan_skut,
  vydaje_rezie_skutecnost.idrefpol AS id_transakce_plan
FROM `tym_11_L0.t_vydaje_rezie_skutecnost` as vydaje_rezie_skutecnost
LEFT JOIN `tym_11_L0.t_vydaje_rezie_plan` as vydaje_rezie_plan
ON vydaje_rezie_skutecnost.idrefpol = vydaje_rezie_plan.idpol
JOIN `tym_11_L1.PobockaDIM` AS PobockaDIM
  ON vydaje_rezie_plan.idpob = PobockaDIM.id_pob
JOIN `tym_11_L1.KategorieTransakceDIM` AS KategorieTransakceDIM
  ON KategorieTransakceDIM.id_oper = 5


---edit kat 2 

UNION ALL 
SELECT 
  vydaje_zroje_skutecnost.idpol AS id_transakce,
  vydaje_zroje_skutecnost.datum AS datum,
  vydaje_zroje_plan.idkontr as id_kontraktu,
  PobockaDIM.id_pob,---?
  null as id_zamestnance, --?
  KategorieTransakceDIM.id_oper,
  null as id_zakaznika, ---? 
  ZdrojDIM.id_zdroje,
  vydaje_zroje_plan.castka AS planovana_castka,
  vydaje_zroje_skutecnost.castka AS skutecna_castka,
  vydaje_zroje_plan.castka - vydaje_zroje_skutecnost.castka AS rozdil_plan_skut,
  vydaje_zroje_skutecnost.idrefpol AS id_transakce_plan
FROM `tym_11_L0.t_vydaje_zdroje_skutecnost` AS vydaje_zroje_skutecnost
LEFT JOIN `tym_11_L0.t_vydaje_zdroje_plan` AS vydaje_zroje_plan
  ON vydaje_zroje_skutecnost.idrefpol = vydaje_zroje_plan.idpol
JOIN `tym_11_L0.t_kontrakty` AS kontrakty
  ON vydaje_zroje_plan.idkontr = kontrakty.idkontr
JOIN `tym_11_L0.t_zakaznici` AS  zakaznici
 ON kontrakty.idzak = zakaznici.idzak
JOIN `tym_11_L0.t_zamestnanci` AS zamestnanci
 ON zamestnanci.idzam = zakaznici.idzam
JOIN `tym_11_L1.PobockaDIM` AS PobockaDIM
 ON zamestnanci.idpob = PobockaDIM.id_pob
JOIN `tym_11_L1.KategorieTransakceDIM` AS KategorieTransakceDIM
  ON KategorieTransakceDIM.id_oper = 2
JOIN `tym_11_L1.ZdrojDIM` AS ZdrojDIM
  ON ZdrojDIM.id_zdroje = vydaje_zroje_plan.idzdroje

;

ALTER TABLE `tym_11_L1.PrijmyVydajeFACT`
ADD FOREIGN KEY (id_pob) REFERENCES `tym_11_L1.PobockaDIM`(id_pob) NOT ENFORCED,
ADD FOREIGN KEY(id_zamestnance) REFERENCES `tym_11_L1.ZamestnanecDIM`(id_zamestnance) NOT ENFORCED,
ADD FOREIGN KEY(id_oper) REFERENCES `tym_11_L1.KategorieTransakceDIM`(id_oper) NOT ENFORCED,
ADD FOREIGN KEY (id_zakaznika) REFERENCES `tym_11_L1.ZakaznikDIM` (id_zakaznika) NOT ENFORCED,
ADD FOREIGN KEY (id_zdroje) REFERENCES `tym_11_L1.ZdrojDIM` (id_zdroje) NOT ENFORCED;



---Zmena datoveho typu v tabulce in vydaje_najem_plan

ALTER TABLE `fis4it526-cujm00-dvod08.tym_11_L0.t_vydaje_najem_plan`
ADD COLUMN datum_timestamp TIMESTAMP;


UPDATE `fis4it526-cujm00-dvod08.tym_11_L0.t_vydaje_najem_plan`
SET datum_timestamp = CAST(datum AS TIMESTAMP)
WHERE datum IS NOT NULL;


ALTER TABLE `fis4it526-cujm00-dvod08.tym_11_L0.t_vydaje_najem_plan`
DROP COLUMN datum;


ALTER TABLE `fis4it526-cujm00-dvod08.tym_11_L0.t_vydaje_najem_plan`
RENAME COLUMN datum_timestamp TO datum;

---Zmena datoveho typu v tabulce in vydaje_najem_skutecnost

ALTER TABLE `fis4it526-cujm00-dvod08.tym_11_L0.t_vydaje_najem_skutecnost`
ADD COLUMN datum_timestamp TIMESTAMP;


UPDATE `fis4it526-cujm00-dvod08.tym_11_L0.t_vydaje_najem_skutecnost`
SET datum_timestamp = CAST(datum AS TIMESTAMP)
WHERE datum IS NOT NULL;


ALTER TABLE `fis4it526-cujm00-dvod08.tym_11_L0.t_vydaje_najem_skutecnost`
DROP COLUMN datum;


ALTER TABLE `fis4it526-cujm00-dvod08.tym_11_L0.t_vydaje_najem_skutecnost`
RENAME COLUMN datum_timestamp TO datum;

#UPDATE `fis4it526-cujm00-dvod08.tym_11_L1.PrijmyVydajeFACT`
#vSET datum = TIMESTAMP(DATETIME_SUB(CAST(datum AS DATETIME), INTERVAL 3 YEAR))
#WHERE id_oper = 5 AND planovana_castka IS NOT NULL;


UPDATE `fis4it526-cujm00-dvod08.tym_11_L1.KontraktyFACT`
SET datum_vystaveni = TIMESTAMP(DATETIME_SUB(CAST(datum_vystaveni AS DATETIME), INTERVAL 1 YEAR))
WHERE datum_vystaveni > datum_splatnosti;