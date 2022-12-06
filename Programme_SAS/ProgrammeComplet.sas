/************************************************************************/
/********* IMPORTATION DES BASES ****************************************/
/************************************************************************/

%let lycee1 = "/home/u59489003/PROJET SQL 2023/EFFECTIF.csv";
%let lycee2 = "/home/u59489003/PROJET SQL 2023/REUSSITE.csv";

libname lprojet "/home/u59489003/PROJET SQL 2023"; 

/* importation des données de type csv */
/* création d'un macro programme pour eviter d'écrire 3 fois la même chose */
%MACRO importation(NumLycee= , numero=);
	PROC IMPORT DATAFILE= &NumLycee.
		DBMS=CSV
		replace  /* pour écrire par dessus l'ancienne version si deja exectuté 1 fois */
		OUT= bdd&numero.;
		delimiter=';';
		GETNAMES=YES;
	RUN;
%MEND;

/* fait appel au macro programme */
%importation(NumLycee = &lycee1.,numero = 1);  /* base importée nommée bdd1 */
%importation(NumLycee = &lycee2.,numero = 2);  /* base importée nommée bdd2 */


/************************************************************************/
/*********** Effectifs par Region **********/
/************************************************************************/


/* créer une table tab1 qui contient la somme des effectifs de dif series et la somme des taux de réussite*/ 
proc sql;  
create table tab1 as  
select  libelle_region_2016, annee,	   effectif_presents_serie_l  + effectif_presents_serie_es + effectif_presents_serie_s as effectif_generale,  
   effectif_presents_serie_stg + effectif_presents_serie_sti2d+ effectif_presents_serie_std2a + effectif_presents_serie_stmg+ effectif_presents_serie_sti + effectif_presents_serie_stl + effectif_presents_serie_st2s + effectif_presents_serie_musiq_da + effectif_presents_serie_hoteller as effectif_professionel ,  
   round(sum(taux_brut_de_reussite_serie_s , taux_brut_de_reussite_serie_l , taux_brut_de_reussite_serie_es) / 3 )as taux_reussite_generale, 
   round(sum(taux_brut_de_reussite_serie_stg , taux_brut_de_reussite_serie_sti2, taux_brut_de_reussite_serie_std2, taux_brut_de_reussite_serie_stmg,taux_brut_de_reussite_serie_sti,taux_brut_de_reussite_serie_stl,taux_brut_de_reussite_serie_st2s,taux_brut_de_reussite_serie_musi,taux_brut_de_reussite_serie_hote)/9) as taux_reussite_professionel  
from bdd2;    
run; 

/* on regroupe par année et région*/ 
proc sql;  
create table done as  
select   annee, libelle_region_2016, sum(effectif_generale) as eff_generale, sum(effectif_professionel) as eff_tech, avg(taux_reussite_generale) as taux_reu_generale, avg(taux_reussite_professionel) as taux_reu_tech  
from tab1 
group by 1, 2;  
quit; 

/************************************************************************/
/*********** Évolution des réussites et des mentions des lycée **********/
/************************************************************************/

data bdd2Compte;
set bdd2;
/* initialisation des variables */
CompteReussiteG = 0 ;
CompteReussiteT = 0 ; 
CompteReussiteAttenduG = 0 ; 
CompteReussiteAttenduT = 0 ; 
CompteReussiteAttenduFG = 0 ;
CompteReussiteAttenduFT = 0;
CompteMentionG = 0;
CompteMentionT = 0;
CompteMentionAttenduG = 0;
CompteMentionAttenduT = 0;

/* boucles qui comptent le nombre de colonne différente de 0 */
do i = taux_brut_de_reussite_serie_s, taux_brut_de_reussite_serie_es, taux_brut_de_reussite_serie_l ;
	if i > 0 then CompteReussiteG = CompteReussiteG + 1 ;
end;

do i = taux_brut_de_reussite_serie_stg, taux_brut_de_reussite_serie_sti2, taux_brut_de_reussite_serie_std2,taux_brut_de_reussite_serie_stmg,taux_brut_de_reussite_serie_sti,taux_brut_de_reussite_serie_stl,taux_brut_de_reussite_serie_st2s,taux_brut_de_reussite_serie_musi, taux_brut_de_reussite_serie_hote ;
	if i > 0 then CompteReussiteT = CompteReussiteT + 1  ;
end;

do i = tx_reussite_attendu_l, tx_reussite_attendu_es, tx_reussite_attendu_s ;
	if i > 0 then CompteReussiteAttenduG = CompteReussiteAttenduG + 1  ;
end;

do i = tx_reussite_attendu_stg, tx_reussite_attendu_sti2,tx_reussite_attendu_std2,tx_reussite_attendu_stmg,tx_reussite_attendu_sti,tx_reussite_attendu_stl,tx_reussite_attendu_st2s, tx_reussite_attendu_musiq_danse, tx_reussite_attendu_hotellerie;
	if i > 0 then CompteReussiteAttenduT = CompteReussiteAttenduT + 1  ;
end;

do i = tx_reussite_attendu_france_l, tx_reussite_attendu_france_es,tx_reussite_attendu_france_s ;
	if i > 0 then CompteReussiteAttenduFG = CompteReussiteAttenduFG + 1  ;
end;

do i = tx_reussite_attendu_france_stg , tx_reussite_attendu_france_sti2d, tx_reussite_attendu_france_std2a, tx_reussite_attendu_france_stmg,tx_reussite_attendu_france_sti,tx_reussite_attendu_france_stl,tx_reussite_attendu_france_st2s,tx_reussite_attendu_france_musiq,tx_reussite_attendu_france_hotel;
	if i > 0 then CompteReussiteAttenduFT = CompteReussiteAttenduFT + 1  ;
end;

do i = taux_mention_brut_serie_l, taux_mention_brut_serie_es,taux_mention_brut_serie_s ;
	if i > 0 then CompteMentionG = CompteMentionG + 1  ;
end;

do i = taux_mention_brut_serie_sti2d, taux_mention_brut_serie_std2a, taux_mention_brut_serie_stmg,taux_mention_brut_serie_stl,taux_mention_brut_serie_st2s,taux_mention_brut_serie_musiq_da,taux_mention_brut_serie_hoteller;
	if i > 0 then CompteMentionT = CompteMentionT + 1  ;
end;

do i = taux_mention_attendu_serie_l,taux_mention_attendu_serie_es,taux_mention_attendu_serie_s ;
	if i > 0 then CompteMentionAttenduG = CompteMentionAttenduG + 1  ;
end;

do i = taux_mention_attendu_serie_sti2d, taux_mention_attendu_serie_std2a, taux_mention_attendu_serie_stmg,taux_mention_attendu_serie_stl,taux_mention_attendu_serie_st2s,taux_mention_attendu_serie_musiq,taux_mention_attendu_serie_hotel;
	if i > 0 then CompteMentionAttenduT = CompteMentionAttenduT + 1  ;
end;

/* on ne peut pas diviser par 0 donc on mets 1 si c'est égal à 0 */
if CompteReussiteT = 0 then CompteReussiteT = 1 ;
if CompteReussiteG = 0 then CompteReussiteG = 1 ;
if CompteReussiteAttenduT = 0 then CompteReussiteAttenduT = 1;
if CompteReussiteAttenduG = 0 then CompteReussiteAttenduG = 1 ; 
if CompteReussiteAttenduFG = 0 then CompteReussiteAttenduFG = 1; 
if CompteReussiteAttenduFT = 0 then CompteReussiteAttenduFT = 1;
if CompteMentionG = 0 then CompteMentionG = 1; 
if CompteMentionT = 0 then CompteMentionT = 1;
if CompteMentionAttenduG =0 then CompteMentionAttenduG =1; 
if CompteMentionAttenduT = 0 then CompteMentionAttenduT = 1;
/* keep CompteReussiteT taux_brut_de_reussite_serie_st taux_brut_de_reussite_serie_sti2 taux_brut_de_reussite_serie_std2 taux_brut_de_reussite_serie_stmg taux_brut_de_reussite_serie_sti taux_brut_de_reussite_serie_stl taux_brut_de_reussite_serie_st2s taux_brut_de_reussite_serie_musi  taux_brut_de_reussite_serie_hote ; */
run;

/* créer de nouvelles variables général et pro */
proc sql;
create table bdd2Resume as
select *,
	   effectif_presents_serie_l  + effectif_presents_serie_es + effectif_presents_serie_s as effectif_generale,
	   effectif_presents_serie_stg + effectif_presents_serie_sti2d+ effectif_presents_serie_std2a + effectif_presents_serie_stmg+ effectif_presents_serie_sti + effectif_presents_serie_stl + effectif_presents_serie_st2s + effectif_presents_serie_musiq_da + effectif_presents_serie_hoteller as effectif_techno ,
	   round(sum(taux_brut_de_reussite_serie_s , taux_brut_de_reussite_serie_l , taux_brut_de_reussite_serie_es) / CompteReussiteG )as taux_reussite_generale,
	   round(sum(taux_brut_de_reussite_serie_stg , taux_brut_de_reussite_serie_sti2, taux_brut_de_reussite_serie_std2, taux_brut_de_reussite_serie_stmg,taux_brut_de_reussite_serie_sti,taux_brut_de_reussite_serie_stl,taux_brut_de_reussite_serie_st2s,taux_brut_de_reussite_serie_musi,taux_brut_de_reussite_serie_hote)/CompteReussiteT) as taux_reussite_techno,
	   round(sum(tx_reussite_attendu_l,tx_reussite_attendu_s,tx_reussite_attendu_es)/ CompteReussiteAttenduG ) as taux_reussite_attendu_generale,
	   round(sum(tx_reussite_attendu_stg , tx_reussite_attendu_sti2d, tx_reussite_attendu_std2a, tx_reussite_attendu_stmg,tx_reussite_attendu_sti,tx_reussite_attendu_stl,tx_reussite_attendu_st2s,tx_reussite_attendu_musiq_danse,tx_reussite_attendu_hotellerie)/ CompteReussiteAttenduT ) as taux_reussite_attendu_techno,
	   round(sum(tx_reussite_attendu_france_l,tx_reussite_attendu_france_s,tx_reussite_attendu_france_es)/CompteReussiteAttenduFG) as taux_reussite_attendu_F_generale,
	   round(sum(tx_reussite_attendu_france_stg , tx_reussite_attendu_france_sti2d, tx_reussite_attendu_france_std2a, tx_reussite_attendu_france_stmg,tx_reussite_attendu_france_sti,tx_reussite_attendu_france_stl,tx_reussite_attendu_france_st2s,tx_reussite_attendu_france_musiq,tx_reussite_attendu_france_hotel)/CompteReussiteAttenduFT) as taux_reussite_attendu_F_techno,
	   round(sum(taux_mention_brut_serie_l,taux_mention_brut_serie_es,taux_mention_brut_serie_s)/CompteMentionG) as taux_mention_general,
	   round(sum(taux_mention_brut_serie_sti2d, taux_mention_brut_serie_std2a, taux_mention_brut_serie_stmg,taux_mention_brut_serie_stl,taux_mention_brut_serie_st2s,taux_mention_brut_serie_musiq_da,taux_mention_brut_serie_hoteller)/CompteMentionT) as taux_mention_techno,
	   round(sum(taux_mention_attendu_serie_l,taux_mention_attendu_serie_es,taux_mention_attendu_serie_s)/CompteMentionAttenduG) as taux_mention_attendu_generale,
	   round(sum(taux_mention_attendu_serie_sti2d, taux_mention_attendu_serie_std2a, taux_mention_attendu_serie_stmg,taux_mention_attendu_serie_stl,taux_mention_attendu_serie_st2s,taux_mention_attendu_serie_musiq,taux_mention_attendu_serie_hotel)/CompteMentionAttenduT) as taux_mention_attendu_techno 
from bdd2Compte;
run;

/* +1 si valeur non nulle, pour pouvoir faire une moyenne par la suite en divisant par la somme */
%MACRO Compte(bdd= , complement= , varG= , varT=);
	data bddCompte&complement.;
		set &bdd.;
		GCompte = 0; /* initialisation des variables */
		TCompte = 0;
		if &varG. > 0 then GCompte = GCompte +1; /* incrémenter la variable ReussiteCompte si on a une valeur non nulle dans la variable reussite */
		if &varT. > 0 then TCompte = TCompte +1;
		keep annee &varG. &varT. GCompte TCompte; /* garder uniquement les variables utiles pour la suite */
	run;
%MEND;
/* création base bddCompteReussiteAttendu qui mets 1 lorsque la valeur est non nulle afin de sommer par la suite*/
%Compte(bdd = bdd2Resume ,complement= ReussiteAttendu, varG= taux_reussite_generale, varT = taux_reussite_techno );  /* base importée nommée bdd2 */
/* création base bddCompteMentionAttendu */
%Compte(bdd = bdd2Resume ,complement= MentionAttendu, varG= taux_mention_general , varT = taux_mention_techno );  /* base importée nommée bdd2 */

/* Grouper les observations par années*/
%MACRO Grouper(bdd= , complement= , varG= , varT=, CompteG= , CompteT= );
	proc sql;
		create table bddGroup&complement. as
		select annee,sum(&varG.)/sum(&CompteG.) as G , sum(&varT.)/sum(&CompteT.) as T
		from &bdd.
		group by annee 
		having G ge 1 and T ge 1 ; /* garder uniquement les variables >= 1*/
	quit;
%MEND;
%Grouper(bdd = bddCompteReussiteAttendu ,complement= Reussite, varG= taux_reussite_generale, varT = taux_reussite_techno, CompteG= GCompte, CompteT= TCompte );  /* bddGroupReussite crée */
%Grouper(bdd = bddCompteMentionAttendu ,complement= Mention, varG= taux_mention_general, varT = taux_mention_techno, CompteG= GCompte, CompteT= TCompte );  /* bddGroupMention crée */


/* transposer la data pour pouvoir ensuite faire le graphique afin d'avoir une colonne avec les 2 classes */
%MACRO Transposer(bdd= , complement= , varG= , varT=, CompteG= , CompteT= );
	PROC TRANSPOSE DATA =&bdd. OUT = bddTranspose&complement. ;
	  BY annee ; /* variable qui reste identique */
	  VAR G T; /* variables qui vont se transposer */
	RUN ;
%MEND;
%Transposer(bdd = bddGroupReussite ,complement= Reussite, varG= taux_reussite_generale, varT = taux_reussite_techno, CompteG= GCompte, CompteT= TCompte );  /* bddTransposeReussite crée */
%Transposer(bdd = bddGroupMention ,complement= Mention, varG= taux_mention_general, varT = taux_mention_techno, CompteG= GCompte, CompteT= TCompte );  /* bddTransposeMention crée */


/* graphique */
%MACRO Graphique(bdd= , LabY= , Titre=  );
	pattern1 COLOR= GREEN; /* couleur des batons */
	pattern2 COLOR= GREENYELLOW;
	AXIS1 LABEL=(ANGLE=90 &LabY.);
	title1  height=2 color=grey justify=center italic &Titre.;
	PROC GCHART DATA = &bdd. ;
	  format col1 4.;
	  VBAR _name_ / DISCRETE GROUP = annee raxis=axis1  outside=sum SUMVAR = col1 TYPE = percent SUBGROUP = _NAME_  raxis=axis1 nolegend;
	  LABEL col1 = &LabY. _name_ = "Général (G) / Technologique (T)" ;
	RUN ; QUIT ;
%MEND;
%Graphique(bdd = bddTransposeReussite ,LabY = "Taux de réussite (%)", Titre = 'Évolution des réussites au bac au fils des années');  /* bddTransposeReussite crée */
%Graphique(bdd = bddTransposeMention ,LabY = "Taux de mention (%)", Titre = 'Évolution des mentions au bac au fils des années');  /* bddTransposeReussite crée */

/* exporter données */
proc export data= bddGroupMention
    outfile="/folders/myfolders/export/GroupeMention.csv"
    dbms=csv;
run;


/************************************************************************/
/* ECARTS ENTRE LA REUSSITE/MENTION ATTENDU ET LE REEL  */
/************************************************************************/
/* On extrait les taux (brut de attendu) pour les réussite et les mentions, et on calcule les écarts */ 

proc sql; 
create table Ecarts_int as 
select code_etablissement, 
taux_brut_de_reussite_serie_l, tx_reussite_attendu_france_l, 
taux_brut_de_reussite_serie_l - tx_reussite_attendu_france_l as ecart_reussite_serie_l, 
taux_brut_de_reussite_serie_es, tx_reussite_attendu_france_es, 
taux_brut_de_reussite_serie_es - tx_reussite_attendu_france_es as ecart_reussite_serie_es, 
taux_brut_de_reussite_serie_s, tx_reussite_attendu_france_s, 
taux_brut_de_reussite_serie_s - tx_reussite_attendu_france_s as ecart_reussite_serie_s, 
taux_brut_de_reussite_serie_sti2, tx_reussite_attendu_france_sti2d, 
taux_brut_de_reussite_serie_sti2 - tx_reussite_attendu_france_sti2d as ecart_reussite_serie_sti2d, 
taux_brut_de_reussite_serie_std2, tx_reussite_attendu_france_std2a, 
taux_brut_de_reussite_serie_std2 - tx_reussite_attendu_france_std2a as ecart_reussite_serie_std2a, 
taux_brut_de_reussite_serie_stmg, tx_reussite_attendu_france_stmg, 
taux_brut_de_reussite_serie_stmg - tx_reussite_attendu_france_stmg as ecart_reussite_serie_stmg, 
taux_brut_de_reussite_serie_stl, tx_reussite_attendu_france_stl, 
taux_brut_de_reussite_serie_stl - tx_reussite_attendu_france_stl as ecart_reussite_serie_stl, 
taux_brut_de_reussite_serie_st2s, tx_reussite_attendu_france_st2s, 
taux_brut_de_reussite_serie_st2s - tx_reussite_attendu_france_st2s as ecart_reussite_serie_st2s, 
taux_brut_de_reussite_serie_musi, tx_reussite_attendu_france_musiq, 
taux_brut_de_reussite_serie_musi - tx_reussite_attendu_france_musiq as ecart_reussite_serie_musiq, 
taux_brut_de_reussite_serie_hote, tx_reussite_attendu_france_hotel, 
taux_brut_de_reussite_serie_hote - tx_reussite_attendu_france_hotel as ecart_reussite_serie_hotel, 
taux_mention_brut_serie_l, taux_mention_attendu_serie_l, 
taux_mention_brut_serie_l - taux_mention_attendu_serie_l as ecart_mention_serie_l, 
taux_mention_brut_serie_es, taux_mention_attendu_serie_es, 
taux_mention_brut_serie_es - taux_mention_attendu_serie_es as ecart_mention_serie_es, 
taux_mention_brut_serie_s, taux_mention_attendu_serie_s, 
taux_mention_brut_serie_s - taux_mention_attendu_serie_s as ecart_mention_serie_s, 
taux_mention_brut_serie_sti2d, taux_mention_attendu_serie_sti2d, 
taux_mention_brut_serie_sti2d - taux_mention_attendu_serie_sti2d as ecart_mention_serie_sti2d, 
taux_mention_brut_serie_std2a, taux_mention_attendu_serie_std2a, 
taux_mention_brut_serie_std2a - taux_mention_attendu_serie_std2a as ecart_mention_serie_std2a, 
taux_mention_brut_serie_stmg, taux_mention_attendu_serie_stmg, 
taux_mention_brut_serie_stmg - taux_mention_attendu_serie_stmg as ecart_mention_serie_stmg, 
taux_mention_brut_serie_stl, taux_mention_attendu_serie_stl, 
taux_mention_brut_serie_stl - taux_mention_attendu_serie_stl as ecart_mention_serie_stl, 
taux_mention_brut_serie_st2s, taux_mention_attendu_serie_st2s, 
taux_mention_brut_serie_st2s - taux_mention_attendu_serie_st2s as ecart_mention_serie_st2s, 
taux_mention_brut_serie_musiq_da, taux_mention_attendu_serie_musiq, 
taux_mention_brut_serie_musiq_da - taux_mention_attendu_serie_musiq as ecart_mention_serie_musiq, 
taux_mention_brut_serie_hoteller, taux_mention_attendu_serie_hotel, 
taux_mention_brut_serie_hoteller - taux_mention_attendu_serie_hotel as ecart_mention_serie_hotel 
from bdd2 
where annee = 2019; 
run; 

 /* Pour chaque filière, on extrait les données qui ont un sens, c'est-à-dire les lycées pour lesquels on connaît les taux de réussite brut et attendu */ 
proc sql; 
create table trl as 
select code_etablissement, taux_brut_de_reussite_serie_l, tx_reussite_attendu_france_l, ecart_reussite_serie_l 
from ecarts_int 
where (taux_brut_de_reussite_serie_l ^= 0) & (tx_reussite_attendu_france_l ^= 0) & (taux_brut_de_reussite_serie_l ^= .) & (tx_reussite_attendu_france_l ^= .); 
run; 

proc sql; 
create table tres as 
select code_etablissement, taux_brut_de_reussite_serie_es, tx_reussite_attendu_france_es, ecart_reussite_serie_es 
from ecarts_int 
where (taux_brut_de_reussite_serie_es ^= 0) & (tx_reussite_attendu_france_es ^= 0) & (taux_brut_de_reussite_serie_es ^= .) & (tx_reussite_attendu_france_es ^= .); 
run; 

proc sql; 
create table trs as 
select code_etablissement, taux_brut_de_reussite_serie_s, tx_reussite_attendu_france_s, ecart_reussite_serie_s 
from ecarts_int 
where (taux_brut_de_reussite_serie_s ^= 0) & (tx_reussite_attendu_france_s ^= 0) & (taux_brut_de_reussite_serie_s ^= .) & (tx_reussite_attendu_france_s ^= .); 
run; 

proc sql; 
create table trsti2d as 
select code_etablissement, taux_brut_de_reussite_serie_sti2, tx_reussite_attendu_france_sti2d, ecart_reussite_serie_sti2d 
from ecarts_int 
where (taux_brut_de_reussite_serie_sti2 ^= 0) & (tx_reussite_attendu_france_sti2d ^= 0) & (taux_brut_de_reussite_serie_sti2 ^= .) & (tx_reussite_attendu_france_sti2d ^= .); 
run; 

proc sql; 
create table trstd2a as 
select code_etablissement, taux_brut_de_reussite_serie_std2, tx_reussite_attendu_france_std2a, ecart_reussite_serie_std2a 
from ecarts_int 
where (taux_brut_de_reussite_serie_std2 ^= 0) & (tx_reussite_attendu_france_std2a ^= 0) & (taux_brut_de_reussite_serie_std2 ^= .) & (tx_reussite_attendu_france_std2a ^= .); 
run; 

proc sql; 
create table trstmg as 
select code_etablissement, taux_brut_de_reussite_serie_stmg, tx_reussite_attendu_france_stmg, ecart_reussite_serie_stmg 
from ecarts_int 
where (taux_brut_de_reussite_serie_stmg ^= 0) & (tx_reussite_attendu_france_stmg ^= 0) & (taux_brut_de_reussite_serie_stmg ^= .) & (tx_reussite_attendu_france_stmg ^= .); 
run; 

proc sql; 
create table trstl as 
select code_etablissement, taux_brut_de_reussite_serie_stl, tx_reussite_attendu_france_stl, ecart_reussite_serie_stl 
from ecarts_int 
where (taux_brut_de_reussite_serie_stl ^= 0) & (tx_reussite_attendu_france_stl ^= 0) & (taux_brut_de_reussite_serie_stl ^= .) & (tx_reussite_attendu_france_stl ^= .); 
run; 

proc sql; 
create table trst2s as 
select code_etablissement, taux_brut_de_reussite_serie_st2s, tx_reussite_attendu_france_st2s, ecart_reussite_serie_st2s 
from ecarts_int 
where (taux_brut_de_reussite_serie_st2s ^= 0) & (tx_reussite_attendu_france_st2s ^= 0) & (taux_brut_de_reussite_serie_st2s ^= .) & (tx_reussite_attendu_france_st2s ^= .); 
run; 

proc sql; 
create table trmusiq as 
select code_etablissement, taux_brut_de_reussite_serie_musi, tx_reussite_attendu_france_musiq, ecart_reussite_serie_musiq 
from ecarts_int 
where (taux_brut_de_reussite_serie_musi ^= 0) & (tx_reussite_attendu_france_musiq ^= 0) & (taux_brut_de_reussite_serie_musi ^= .) & (tx_reussite_attendu_france_musiq ^= .); 
run; 

proc sql; 
create table trhotel as 
select code_etablissement, taux_brut_de_reussite_serie_hote, tx_reussite_attendu_france_hotel, ecart_reussite_serie_hotel 
from ecarts_int 
where (taux_brut_de_reussite_serie_hote ^= 0) & (tx_reussite_attendu_france_hotel ^= 0) & (taux_brut_de_reussite_serie_hote ^= .) & (tx_reussite_attendu_france_hotel ^= .); 
run; 

/* On fusionne à nouveau ces bases */ 
proc sql; 
create table ecarts_reussite as 
select * 
from trs as a 
left join trl as b on a.code_etablissement = b.code_etablissement 
left join tres as c on a.code_etablissement = c.code_etablissement 
left join trsti2d as d on a.code_etablissement = d.code_etablissement 
left join trstd2a as e on a.code_etablissement = e.code_etablissement 
left join trstmg as f on a.code_etablissement = f.code_etablissement 
left join trstl as g on a.code_etablissement = g.code_etablissement 
left join trst2s as h on a.code_etablissement = h.code_etablissement 
left join trmusiq as i on a.code_etablissement = i.code_etablissement 
left join trhotel as j on a.code_etablissement = j.code_etablissement; 
run; 


/* Idem pour les mentions */ 
proc sql; 
create table tml as 
select code_etablissement, taux_mention_brut_serie_l, taux_mention_attendu_serie_l, ecart_mention_serie_l 
from ecarts_int 
where (taux_mention_attendu_serie_l ^= 0) & (taux_mention_brut_serie_l ^= .) & (taux_mention_attendu_serie_l ^= .); 
run; 

proc sql; 
create table tmes as 
select code_etablissement, taux_mention_brut_serie_es, taux_mention_attendu_serie_es, ecart_mention_serie_es 
from ecarts_int 
where (taux_mention_attendu_serie_es ^= 0) & (taux_mention_brut_serie_es ^= .) & (taux_mention_attendu_serie_es ^= .); 
run; 

proc sql; 
create table tms as 
select code_etablissement, taux_mention_brut_serie_s, taux_mention_attendu_serie_s, ecart_mention_serie_s 
from ecarts_int 
where (taux_mention_attendu_serie_s ^= 0) & (taux_mention_brut_serie_s ^= .) & (taux_mention_attendu_serie_s ^= .); 
run; 

proc sql; 
create table tmsti2d as 
select code_etablissement, taux_mention_brut_serie_sti2d, taux_mention_attendu_serie_sti2d, ecart_mention_serie_sti2d 
from ecarts_int 
where (taux_mention_brut_serie_sti2d ^= 0) & (taux_mention_attendu_serie_sti2d ^= 0) & (taux_mention_brut_serie_sti2d ^= .) & (taux_mention_attendu_serie_sti2d ^= .); 
run; 

proc sql; 
create table tmstd2a as 
select code_etablissement, taux_mention_brut_serie_std2a, taux_mention_attendu_serie_std2a, ecart_mention_serie_std2a 
from ecarts_int 
where (taux_mention_brut_serie_std2a ^= 0) & (taux_mention_attendu_serie_std2a ^= 0) & (taux_mention_brut_serie_std2a ^= .) & (taux_mention_attendu_serie_std2a ^= .); 
run; 

proc sql; 
create table tmstmg as 
select code_etablissement, taux_mention_brut_serie_stmg, taux_mention_attendu_serie_stmg, ecart_mention_serie_stmg 
from ecarts_int 
where (taux_mention_brut_serie_stmg ^= 0) & (taux_mention_attendu_serie_stmg ^= 0) & (taux_mention_brut_serie_stmg ^= .) & (taux_mention_attendu_serie_stmg ^= .); 
run; 

proc sql; 
create table tmstl as 
select code_etablissement, taux_mention_brut_serie_stl, taux_mention_attendu_serie_stl, ecart_mention_serie_stl 
from ecarts_int 
where (taux_mention_brut_serie_stl ^= 0) & (taux_mention_attendu_serie_stl ^= 0) & (taux_mention_brut_serie_stl ^= .) & (taux_mention_attendu_serie_stl ^= .); 
run; 

proc sql; 
create table tmst2s as 
select code_etablissement, taux_mention_brut_serie_st2s, taux_mention_attendu_serie_st2s, ecart_mention_serie_st2s 
from ecarts_int 
where (taux_mention_brut_serie_st2s ^= 0) & (taux_mention_attendu_serie_st2s ^= 0) & (taux_mention_brut_serie_st2s ^= .) & (taux_mention_attendu_serie_st2s ^= .); 
run; 

proc sql; 
create table tmmusiq as 
select code_etablissement, taux_mention_brut_serie_musiq_da, taux_mention_attendu_serie_musiq, ecart_mention_serie_musiq 
from ecarts_int 
where (taux_mention_brut_serie_musiq_da ^= 0) & (taux_mention_attendu_serie_musiq ^= 0) & (taux_mention_brut_serie_musiq_da ^= .) & (taux_mention_attendu_serie_musiq ^= .); 
run; 

proc sql; 
create table tmhotel as 
select code_etablissement, taux_mention_brut_serie_hoteller, taux_mention_attendu_serie_hotel, ecart_mention_serie_hotel 
from ecarts_int 
where (taux_mention_brut_serie_hoteller ^= 0) & (taux_mention_attendu_serie_hotel ^= 0) & (taux_mention_brut_serie_hoteller ^= .) & (taux_mention_attendu_serie_hotel ^= .); 
run; 

proc sql; 
create table ecarts_mention as 
select * 
from tms as a 
left join tml as b on a.code_etablissement = b.code_etablissement 
left join tmes as c on a.code_etablissement = c.code_etablissement 
left join tmsti2d as d on a.code_etablissement = d.code_etablissement 
left join tmstd2a as e on a.code_etablissement = e.code_etablissement 
left join tmstmg as f on a.code_etablissement = f.code_etablissement 
left join tmstl as g on a.code_etablissement = g.code_etablissement 
left join tmst2s as h on a.code_etablissement = h.code_etablissement; 
run; 

/* BDD finale */ 
proc sql; 
create table ecarts as 
select * 
from ecarts_reussite as a 
inner join ecarts_mention as b on a.code_etablissement = b.code_etablissement; 
run; 

proc sql; 
create table ecarts_general as 
select * 
from tms as a 
inner join tml as b on a.code_etablissement = b.code_etablissement 
inner join tmes as c on a.code_etablissement = c.code_etablissement 
inner join trs as d on a.code_etablissement = d.code_etablissement 
inner join trl as e on a.code_etablissement = e.code_etablissement 
inner join tres as f on a.code_etablissement = f.code_etablissement; 
run; 

PROC EXPORT DATA = work.ecarts 
    DBMS = csv  
    OUTFILE="/home/u59489493/SAS/ECARTS.csv"   
    REPLACE; 
 		    DELIMITER=";"; 
run; 

PROC EXPORT DATA = work.ecarts_general 
    DBMS = csv  
    OUTFILE="/home/u59489493/SAS/ECARTS_G.csv"   
    REPLACE; 
 		    DELIMITER=";"; 
run; 

/* Par année */ 

proc sql; 
create table ecarts_annees as 
select annee, 
mean(ecart_reussite_serie_l) as MoyenneReuL, 
mean(ecart_reussite_serie_es) as MoyenneReuES, 
mean(ecart_reussite_serie_s) as MoyenneReuS, 
mean(ecart_reussite_serie_std2a) as MoyenneReuSTD2A, 
mean(ecart_reussite_serie_sti2d) as MoyenneReuSTI2D, 
mean(ecart_reussite_serie_stmg) as MoyenneReuSTMG, 
mean(ecart_reussite_serie_stl) as MoyenneReuSTL, 
mean(ecart_reussite_serie_st2s) as MoyenneReuST2S, 
mean(ecart_reussite_serie_musiq) as MoyenneReuMusiq, 
mean(ecart_reussite_serie_hotel) as MoyenneReuHotel, 
mean(ecart_mention_serie_l) as MoyenneMenL, 
mean(ecart_mention_serie_es) as MoyenneMenES, 
mean(ecart_mention_serie_s) as MoyenneMenS, 
mean(ecart_mention_serie_std2a) as MoyenneMenSTD2A, 
mean(ecart_mention_serie_sti2d) as MoyenneMenSTI2D, 
mean(ecart_mention_serie_stmg) as MoyenneMenSTMG, 
mean(ecart_mention_serie_stl) as MoyenneMenSTL, 
mean(ecart_mention_serie_st2s) as MoyenneMenST2S, 
mean(ecart_mention_serie_musiq) as MoyenneMenMusiq, 
mean(ecart_mention_serie_hotel) as MoyenneMenHotel 
from ecarts_int 
group by 1; 
run; 

PROC SQL; 
Create Table Ecarts_Gen as 
Select annee, MoyenneReuL, MoyenneReuES, MoyenneReuS, MoyenneMenL, MoyenneMenES, MoyenneMenS 
From Ecarts_Annees 
Where annee <= 2019; 
RUN;  

PROC EXPORT DATA = work.Ecarts_Annees 
    DBMS = xlsx 
    OUTFILE="/home/u59489493/SAS/ECARTS_ANNEES.xlsx"   
    REPLACE;; 
run; 

PROC EXPORT DATA = work.Ecarts_General 
    DBMS = xlsx 
    OUTFILE="/home/u59489493/SAS/ECARTS_GEN.xlsx"   
    REPLACE;; 
run; 

 

 


