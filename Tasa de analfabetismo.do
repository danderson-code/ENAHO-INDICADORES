*   TASA DE ANALFABETISMO POR GRUPO ESPECIAL DE EDAD, MÓDULO 3 - ENAHO

/*

En el marco de la formulación de la Política Regional de la Juventud de un 
determinado departamento, se considera necesario definir un grupo especial de edad, 
con énfasis en el rango de 15 a 29 años, a fin de orientar el análisis y la 
formulación de políticas de manera más precisa y pertinente.

*/

clear all
set more off

cd "C:\Users\DANIEL\Downloads\Trabajos\Política Regional\Oficial\Analfabetismo"

* Abrir base 
use enaho01a-2024-300.dta, clear

* 1. VARIABLES GEOGRÁFICAS

* Área: urbana / rural

gen area = estrato
recode area (1/5 = 1) (6/8 = 2)
label define area 1 "Urbana" 2 "Rural"
label values area area
label var area "Área de residencia"

* Región natural

gen regnat = .
replace regnat = 1 if dominio <= 3 | dominio == 8
replace regnat = 2 if dominio >= 4 & dominio <= 6
replace regnat = 3 if dominio == 7
label define regnat 1 "Costa" 2 "Sierra" 3 "Selva"
label values regnat regnat
label var regnat "Región natural"

* Dominio geográfico

gen dom = .
replace dom = 1 if regnat == 1 & area == 1
replace dom = 2 if regnat == 1 & area == 2
replace dom = 3 if regnat == 2 & area == 1
replace dom = 4 if regnat == 2 & area == 2
replace dom = 5 if regnat == 3 & area == 1
replace dom = 6 if regnat == 3 & area == 2
replace dom = 7 if dominio == 8

label define ldom                                                 ///
    1 "Costa urbana"  2 "Costa rural"                             ///
    3 "Sierra urbana" 4 "Sierra rural"                            ///
    5 "Selva urbana"  6 "Selva rural"                             ///
    7 "Lima Metropolitana"

label values dom ldom
label var dom "Dominio geográfico"

* Departamento (25)

destring ubigeo, generate(dpto)
replace dpto = dpto / 10000
replace dpto = round(dpto)
label variable dpto "Departamento"

label define dpto                                                ///
    1 "Amazonas"         2 "Áncash"         3 "Apurímac"         ///
    4 "Arequipa"         5 "Ayacucho"       6 "Cajamarca"        ///
    7 "Callao"           8 "Cusco"          9 "Huancavelica"     ///
   10 "Huánuco"         11 "Ica"           12 "Junín"            ///
   13 "La Libertad"     14 "Lambayeque"    15 "Lima"             ///
   16 "Loreto"          17 "Madre de Dios" 18 "Moquegua"         ///
   19 "Pasco"           20 "Piura"         21 "Puno"             ///
   22 "San Martín"      23 "Tacna"         24 "Tumbes"           ///
   25 "Ucayali"

label values dpto dpto

* Departamento (26): Lima diferenciada

gen dpto_26 = dpto * 10
replace dpto_26 = 151 if dom == 7
replace dpto_26 = 152 if dpto == 15 & dom ~= 7

label variable dpto_26 "Departamento (Provincia de Lima / Región Lima)"

label define dpto_26                                             ///
    10 "Amazonas"         20 "Áncash"        30 "Apurímac"       ///
    40 "Arequipa"         50 "Ayacucho"      60 "Cajamarca"      ///
    70 "Callao"           80 "Cusco"         90 "Huancavelica"   ///
   100 "Huánuco"         110 "Ica"          120 "Junín"          ///
   130 "La Libertad"     140 "Lambayeque"   151 "Provincia de Lima" ///
   152 "Región Lima"     160 "Loreto"       170 "Madre de Dios"  ///
   180 "Moquegua"        190 "Pasco"        200 "Piura"          ///
   210 "Puno"            220 "San Martín"   230 "Tacna"          ///
   240 "Tumbes"          250 "Ucayali"

label values dpto_26 dpto_26

* 2. VARIABLE DE ANALFABETISMO

gen analfa = 0 if p208a >= 15 & p204 == 1
replace analfa = 1 if p208a >= 15 & p302 == 2 & p204 == 1
label define analfa 0 "Sabe leer y escribir" 1 "No sabe leer ni escribir"
label values analfa analfa
label var analfa "Condición de alfabetismo"

* 3. RANGOS DE EDAD PERSONALIZADOS

gen rangoedad = .
replace rangoedad = 1 if p208a >= 15 & p208a <= 29
replace rangoedad = 2 if p208a >= 30 & p208a <= 44
replace rangoedad = 3 if p208a >= 45 & p208a <= 59
replace rangoedad = 4 if p208a >= 60

label define rangoedad                                          ///
    1 "15–29 años"  2 "30–44 años"  3 "45–59 años"  4 "60 y más años"
label values rangoedad rangoedad
label var rangoedad "Rangos de edad"

* 4. TABULACIONES Y ESTIMACIONES CON DISEÑO MUESTRAL

* 4.1. CONFIGURAR DISEÑO MUESTRAL

svyset [pweight = factor07], psu(conglome) strata(estrato)

* Total nacional

svy: proportion analfa, over(rangoedad)
estat cv

* Por región natural

svy: proportion analfa, over(regnat)
estat cv

* Por dominio geográfico

svy: proportion analfa, over(dom)
estat cv

* Por departamento (26)

svy: proportion analfa, over(dpto_26)
estat cv

* 5. RESULTADOS ESPECÍFICOS PARA JUNÍN

* Total Junín

svy: proportion analfa if dpto_26 == 120, over(rangoedad)
estat cv

* Hombres Junín

svy: proportion analfa if dpto_26 == 120 & p207 == 1, over(rangoedad)
estat cv

* Mujeres Junín

svy: proportion analfa if dpto_26 == 120 & p207 == 2, over(rangoedad)
estat cv

* Urbano Junín

svy: proportion analfa if dpto_26 == 120 & area == 1, over(rangoedad)
estat cv

* Rural Junín

svy: proportion analfa if dpto_26 == 120 & area == 2, over(rangoedad)
estat cv

* 6. OPCIONAL: TABLAS PORCENTUALES

svy: tab rangoedad analfa if dpto_26 == 120, row percent format(%4.1f)
svy: tab rangoedad analfa if dpto_26 == 120 & p207 == 1, row percent format(%4.1f)
svy: tab rangoedad analfa if dpto_26 == 120 & p207 == 2, row percent format(%4.1f)



