use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep prop numdislikes numlikes year
/*test for distributional equality across surveys*/
ranksum numdis,by(year) /*whole distribution*/
ranksum numdis if numdis > 0,by(year) /*zero-truncated distribution*/
ranksum numdis if numdis > 1,by(year) /*zero-truncated distribution*/

/*Figures 1 and 2 distribution of number of dislikes and number of likes by survey year*/
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep prop numdislikes numlikes nummeh year
local graphnames dislikes likes mixed 
local titles Dislikes Likes Mixed_Feelings
local i 1
foreach stub in dislikes likes meh {
	local graphname : word `i' of `graphnames'
	local title : word `i' of `titles'
	preserve
		collapse (sum) prop,by(num`stub' year)
		twoway ///
			connected prop num`stub' if year == 1993, ///
			mfc(blue) mc(blue) msize(large) lc(blue) lw(thick) || ///
			connected prop num`stub'  if year == 2012, ///
			mfc(red) mc(red) msize(large) lc(red) lw(thick) ///
			legend(label(1 "1993") label(2 "2012")) ///
			xlab(0(1)15) ylab(0(2)18) ///
			plotr(color(white)) graphr(color(white)) ///
			legend(region(color(white))) scheme(economist) ///
			xtitle("Number of `title'") ytitle("% of Respondents") ///
			ysize(4) xsize(6.5)
		cd "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans"
		graph export `graphname'_by_year.png, ///
		as(png) replace width(1300) height(800)
	restore
	local ++i
	}
	
/*table 1: bivariate analysis of categorical tolerance*/	
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep women white black hs bc pg cohortcat1 cohortcat2 cohortcat3 cohortcat4 year numdislikes
gen cattol = numdislikes == 0 if numdislikes !=.
capture {
	gen variable = ""
	gen mu1_93 = .
	gen mu2_93 = .
	gen p93 = .
	gen mu1_12 = .
	gen mu2_12 = .
	gen p12 = .
	}
local i 1
foreach x of varlist women white black hs bc pg cohortcat1 cohortcat2 cohortcat3 cohortcat4   {
	replace variable = "`x'" in `i'
	ttest `x' if year == 1993,by(cattol)
	replace mu1_93 = r(mu_1) in `i'
	replace mu2_93 = r(mu_2) in `i'
	replace p93 = r(p) in `i'
	ttest `x' if year == 2012,by(cattol)
	replace mu1_12 = r(mu_1) in `i'
	replace mu2_12 = r(mu_2) in `i'
	replace p12 = r(p) in `i'
	local ++i
	}
format mu* p12 p93 %9.2f
list variable- p12 in 1/10,table clean
cd "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans"
outsheet variable- p12 in 1/10 using ttest-table1.csv,replace comma 

/*table 2: bivariate analysis of n. of dislikes*/	
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep women white black hs bc pg cohortcat1 cohortcat2 cohortcat3 cohortcat4 year numdislikes
capture {
	gen variable = ""
	gen mu1_93 = .
	gen mu2_93 = .
	gen p93 = .
	gen mu1_12 = .
	gen mu2_12 = .
	gen p12 = .
	}
local i 1
foreach x of varlist women white black hs bc pg cohortcat1 cohortcat2 cohortcat3 cohortcat4   {
	replace variable = "`x'" in `i'
	ttest numdislikes if year == 1993 & numdislikes > 0,by(`x')
	replace mu1_93 = r(mu_1) in `i'
	replace mu2_93 = r(mu_2) in `i'
	replace p93 = r(p) in `i'
	ttest numdislikes if year == 2012 & numdislikes > 0,by(`x')
	replace mu1_12 = r(mu_1) in `i'
	replace mu2_12 = r(mu_2) in `i'
	replace p12 = r(p) in `i'
	local ++i
	}
format mu* p12 p93 %9.2f
list variable- p12 in 1/10,table clean
cd "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans"
outsheet variable- p12 in 1/10 using ttest-table2.csv,replace comma 

/*table 2: bivariate analysis of n. of dislikes*/	
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep sex white black hs bc pg cohortrec4 year numdislikes
/*vuong test*/
zip numdislikes i.year ib3.cohortrec4 i.white i.sex i.bc i.pg, ///
inflate(i.year c.cohort) vuong nolog

/*statistical model*/
est drop _all
qui poisson numdislikes i.year ib3.cohortrec4 i.white i.sex i.bc i.pg, vce(robust)
est store mod0
qui zip numdislikes i.year ib3.cohortrec4 i.white i.sex i.bc i.pg, ///
inflate(i.year c.cohort) vce(robust) 
est store mod1 
qui zip numdislikes i.year ib3.cohortrec4 i.white i.sex i.bc i.pg, ///
inflate(i.year c.cohort i.black) vce(robust) 
est store mod2 
qui zip numdislikes i.year ib3.cohortrec4 i.white i.sex i.bc i.pg, ///
inflate(i.year c.cohort i.black i.bc) vce(robust) 
est store mod3
qui zip numdislikes i.year ib3.cohortrec4 i.white i.sex i.year##i.bc i.year##i.pg, ///
inflate(i.year c.cohort i.black i.bc) vce(robust) 
est store mod5

/*exporting regression results*/
cd "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans"
esttab mod* using zip-table.doc, ///
stats(N chi2,fmt(%9.0f %9.2f)) plain lab star(* 0.05) tab varw(20) ///
compress se(%9.4f) b(%9.3f) par nogaps nolines nomtitles replace ///
drop(1993b* 0b* 3b* 2012o* 1b*) 

/*what is the substantive magnitude relationship between cohort and categorical tolerance?*/
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep sex white black hs bc pg cohor* year numdislikes
qui zip numdislikes i.year i.cohortrec i.white i.sex i.year##i.bc i.year##i.pg, ///
inflate(i.year ib3.cohortrec6 i.black i.bc)
margins,at(cohortrec6 = (1(1)6)) predict(p) level(90)

/*figure 3*/
marginsplot, ///
scheme(economist) horiz ///
plot1opts(recast(scatter) graphr(color(white)) ///
msym(diamond) msize(huge) mfc(blue) mc(blue)) ///
ci1opts(recast(rspike) lc(blue) lw(thick)) ///
xtitle("") ytitle("") title("") xsize(6.5) ///
xscal(range(0 0.15)) xlab(0(0.025)0.15)


/*is the relationship between cohort and categorical tolerance linear?*/
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep sex white black hs bc pg cohortrec4 cohort year numdislikes
qui zip numdislikes i.year i.cohortrec i.white i.sex i.year##i.bc i.year##i.pg, ///
inflate(i.year c.cohort i.black i.bc) 
est store mod1
qui zip numdislikes i.year i.cohortrec i.white i.sex i.year##i.bc i.year##i.pg, ///
inflate(i.year c.cohort##c.cohort i.black i.bc) 
est store mod2
lrtest mod2 mod1

/*what is the race-specific relationship between cohort and categorical tolerance?*/
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep sex white black hs bc pg cohortrec4 year numdislikes
qui zip numdislikes i.year i.cohortrec i.white i.sex i.year##i.bc i.year##i.pg, ///
inflate(i.year i.cohortrec4 i.black i.bc) vce(robust) 
 
margins,at(cohortrec4 = (1(1)4)) within(year black) predict(p) level(90)
/*figure 3*/
marginsplot, ///
	ylab(,nogrid) horiz level(90) ysize(3) xsize(6.5)  ///
	plot1opts(recast(scatter) graphr(color(white)) ///
	msym(diamond) msize(vlarge) mfc(blue) mc(blue)) ///
	plot2opts(recast(scatter) ///
	msym(diamond) msize(vlarge) mfc(red) mc(red)) ///
	plotopts(recast(scatter) legend(region(color(white))) subtitle(, nobox)) ///
	ci1opts(recast(rspike) lc(blue)) ///
	ci2opts(recast(rspike) lc(red)) ///
	xline(.0579, lw(vthin) lp(dash)) xline(.1638, lc(gs8) lp(dash)) ///
	xd(year) ///
	xlab(,format(%9.2f)) ///
	byd(cohortrec4) ///
	byopts( ///
		title("") ///
		graphr(color(white)) ///
		legend(pos(6) ///
		region(color(white))) ///
		) ///
	name(`l', replace) scheme(economist) ///
	ytitle("") xtitle("Prob. of Categorical Tolerance")


cd "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\soc-sci"
graph export Figure3.png, ///
as(png) replace hei(600) width(1300)

/*what are the over-time changes in symbolic exclusion?*/
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\gss-ssi-merged.dta", clear
keep sex white black hs bc pg cohortrec4 year numdislikes
local lows 1 4 9
local highs 3 8 15
local labels Low Moderate High
local i 1
foreach l of local labels {
	local lb : word `i' of `lows'
	local ub : word `i' of `highs'
	qui zip numdislikes i.year i.cohortrec4 i.white i.sex i.year##i.bc i.year##i.pg, ///
	inflate(i.year i.cohortrec4 i.black i.bc) vce(robust) 
	margins,at(cohortrec = (1(1)4)) over(year) predict(pr(`lb', `ub')) level(90)
	/*figure 4*/
	marginsplot, ///
		ylab(,nogrid) horiz level(90)  ///
		xlab(,format(%9.2f)) ///
		plot1opts(recast(scatter) msym(diamond) msize(medium) mfc(blue) mc(blue)) ///
		plot2opts(recast(scatter) msym(diamond) msize(medium) mfc(red) mc(red)) ///
		ci1opts(recast(rspike) lc(blue)) ///
		ci2opts(recast(rspike) lc(red)) ///
		xtitle("Prob. of `l' Intolerance" "(`lb' >= N =< `ub')",size(small)) ///
		plotr(color(white)) graphr(color(white)) ///
		legend(region(color(white))) ///
		title("") ytitle("") name(`l', replace) scheme(economist)
		local ++i
		}
grc1leg Low Moderate High, ///
cols(1) xcommon name(gr,replace) 
graph display gr, ysize(4) xsize(6.5) 

cd "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\soc-sci"
graph export Figure4.png, ///
as(png) replace hei(800) wid(1300)

/*which ethnoracial categories are more likely to be categorical tolerants in 2012?*/
/*do "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\dataproc-ssi.do"*/
use "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\ssi-working.dta", clear
gen agesq = agemid^2 / 100
tab race,g(race)
lab var race1 "Asian"
lab var race2 "Black"
lab var race3 "Hispanic"
lab var race5 "Mixed Race"
lab var race6 "Other"
lab var agemid "Age"
lab var agesq "Age Squared"
tab sex,g(gender)
lab var gender2 "Women"
tab degree,g(degree)
lab var degree1 "H.S. Dropout"
lab var degree2 "High School Degree"
lab var degree3 "Junior College"
lab var degree4 "Bachelor's Degree"
lab var degree5 "Postgraduate Degree"
gen loginc = log(income)
lab var loginc "Log of Income"

zip numdislikes ///
c.agemid##c.agemid ///
race1 race2 race3 race5  race6 ///
degree2 degree3 degree4 degree5, ///
inflate(c.agemid race1 race2 race3 race5 race6 degree4) ///
nolog vce(robust) 
/*figure 5*/
coefplot, ///
	keep(inflate:) scheme(economist) xline(0) ///
	drop(_cons age* degree*) ///
	plotr(color(white)) ///
	graphr(margin(r + 30 l + 15) color(white)) ///
	title("Categorical Tolerance Effect") xtitle("") ///
	msize(vlarge) mfc(blue) mc(blue) msym(diamond) ///
	ciopts(lc(blue)) name(inflate,replace) ///
	xlab(,labs(large) format(%9.2f)) ylab(,labs(large))

coefplot, ///
	keep(numdislikes:) scheme(economist) xline(0) ///
	drop(_cons age* c.age* degree*) ///
	plotr(color(white)) ///
	graphr(margin(r + 30 l + 15) color(white)) ///
	title("Symbolic Exclusion Effect") xtitle("") ///
	msize(vlarge) mfc(red) mc(red) msym(diamond) ///
	ciopts(lc(red)) name(poisson,replace) ///
	xlab(,labs(large) format(%9.2f)) ylab(,labs(large))
	
graph combine inflate poisson,rows(1) ysize(2.5) xsize(6.5)

cd "C:\Users\olizardo\Google Drive\SOCIOLOGY OF CULTURE\DONE\lizardo-skiles-refusal-to-dislike-americans\soc-sci"
graph export Figure5.png, ///
as(png) replace hei(500) wid(1300)

/*
/*which musical likes predict categorical tolerance?*/
local names Classical Opera Jazz Musicals Easy Country Bluegrass Folk Gospel Latin Rap Blues Reggae Rock Metal
local i 1
foreach x of varlist *like {
	local name : word `i' of `names'
	qui zip numdislikes i.year ib3.cohortrec4 i.white i.sex i.year##i.bc i.year##i.pg, ///
	inflate(i.year i.cohortrec i.black i.bc i.`x') vce(robust) 
	qui margins,within(`x') predict(p) level(90)
	marginsplot,plotopts(recast(bar) bc(black) bfc(none) barw(0.5)) ///
	ciopts(lw(medthick) msize(vlarge) lc(gs8)) ///
	xsize(2) ylab(0(.05).25) ytitle("") xtitle("") title("`name'") nodraw name(`name',replace)
	local ++i
	}
graph combine Classical Opera Jazz Musicals Easy Country Bluegrass Folk Gospel Latin Rap Blues Reggae Rock Metal, ///
rows(3) iscale(.45) ysize(6) xsize(6.5) 
cd " "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans\"
graph export extreme_taste.png, ///
as(png) replace width(1200) height(1300)

