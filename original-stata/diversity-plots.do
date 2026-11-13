use "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\dta\cosine-working.dta", clear
local cats Gender Race Class Education Generation
local i 1
foreach lab in gend race class educ age {
	qui sum `lab'_div, meanonly
	local m = r(mean)
	qui glm `lab'_div i.race i.style c.numlabels, ///
	fam(bin) l(logit) cluster(id) nolog
	qui margins,at(race = (1 2 3 4 5))
	local cat : word `i' of `cats'
	marginsplot, ///
		horiz scheme(economist) ///
		graphr(color(white)) ///
		plotr(margin(b + 4)) ///
		plotopts( ///
			recast(scatter) ///
			lc(blue) lw(thick) ///
			msym(diamond) msiz(medium) mfc(blue) mc(blue) ///
			) ////
		ciopts(recast(rspike) lc(blue) lw(thick)) ///
		title("Effect of Race on Perceived `cat' Diversity", size(medsmall)) ///
		ytitle("") xtitle("") ///
		xline(`m') name(`lab'_race, replace) ylab(,labsize(medsmall))
	window manage close graph
	local ++i
	}
graph combine gend_race race_race class_race educ_race age_race, ///
rows(4) ysize(3) xsize(6.5) xcommon iscale(.6)
cd "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\png"
graph export race-diversity.png,as(png) hei(700) wid(1300) replace

use "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\dta\cosine-working.dta", clear
local cats Gender Race Class Education Generation
local i 1
foreach lab in gend race class educ age {
	qui sum `lab'_div, meanonly
	local m = r(mean)
	qui glm `lab'_div i.degree i.style c.numlabels, ///
	fam(bin) l(logit) cluster(id) nolog
	qui margins,at(degree = (0 1 2 3 4 5 6))
	local cat : word `i' of `cats'
	marginsplot, ///
		horiz scheme(economist) ///
		graphr(color(white)) ///
		plotr(margin(b + 4)) ///
		plotopts( ///
			recast(scatter) ///
			lc(blue) lw(thick) ///
			msym(diamond) msiz(medium) mfc(blue) mc(blue) ///
			) ////
		ciopts(recast(rspike) lc(blue) lw(thick)) ///
		title("Effect of Education on Perceived `cat' Diversity", size(medsmall)) ///
		ytitle("") xtitle("") ///
		xline(`m') name(`lab'_degree, replace) ylab(,labsize(medsmall))
	window manage close graph
	local ++i
	}
graph combine gend_degree race_degree class_degree educ_degree age_degree, ///
rows(4) ysize(3) xsize(6.5) xcommon iscale(.6)
cd "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\png"
graph export education-diversity.png,as(png) hei(700) wid(1300) replace


use "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\dta\cosine-working.dta", clear
local cats Gender Race Class Education Generation
local i 1
foreach lab in gend race class educ age {
	qui sum `lab'_div, meanonly
	local m = r(mean)
	qui glm `lab'_div i.inc_quintiles i.style c.numlabels, ///
	fam(bin) l(logit) cluster(id) nolog
	qui margins,at(inc_quintiles = (1 2 3 4 5))
	local cat : word `i' of `cats'
	marginsplot, ///
		horiz scheme(economist) ///
		graphr(color(white)) ///
		plotr(margin(b + 4)) ///
		plotopts( ///
			recast(scatter) ///
			lc(blue) lw(thick) ///
			msym(diamond) msiz(medium) mfc(blue) mc(blue) ///
			) ////
		ciopts(recast(rspike) lc(blue) lw(thick)) ///
		title("Effect of Income on Perceived `cat' Diversity", size(medsmall)) ///
		ytitle("") xtitle("") ///
		xline(`m') name(`lab'_inc, replace) ylab(,labsize(medsmall))
	window manage close graph
	local ++i
	}
graph combine gend_inc race_inc class_inc educ_inc age_inc, ///
rows(4) ysize(3) xsize(6.5) xcommon iscale(.6)
cd "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\png"
graph export income-diversity.png,as(png) hei(700) wid(1300) replace

use "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\dta\cosine-working.dta", clear
local cats Gender Race Class Education Generation
local i 1
foreach lab in gend race class educ age {
	qui sum `lab'_div, meanonly
	local m = r(mean)
	qui glm `lab'_div i.percclass i.style c.numlabels, ///
	fam(bin) l(logit) cluster(id) nolog
	qui margins,at(percclass = (1 2 3 4))
	local cat : word `i' of `cats'
	marginsplot, ///
		horiz scheme(economist) ///
		graphr(color(white)) ///
		plotr(margin(b + 4)) ///
		plotopts( ///
			recast(scatter) ///
			lc(blue) lw(thick) ///
			msym(diamond) msiz(medium) mfc(blue) mc(blue) ///
			) ////
		ciopts(recast(rspike) lc(blue) lw(thick)) ///
		title("Effect of Income on Perceived `cat' Diversity", size(medsmall)) ///
		ytitle("") xtitle("") ///
		xline(`m') name(`lab'_class, replace) ylab(,labsize(medsmall))
	window manage close graph
	local ++i
	}
graph combine gend_class race_class class_class educ_class age_class, ///
rows(4) ysize(3) xsize(6.5) xcommon iscale(.6)
cd "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\png"
graph export class-diversity.png,as(png) hei(700) wid(1300) replace

use "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\dta\cosine-working.dta", clear
local cats Gender Race Class Education Generation
local i 1
foreach lab in gend race class educ age {
	qui sum `lab'_div, meanonly
	local m = r(mean)
	qui glm `lab'_div c.agem##c.agem i.style c.numlabels, ///
	fam(bin) l(logit) cluster(id) nolog
	qui margins,at(agemid = (20 30 40 50 60 70 80))
	local cat : word `i' of `cats'
	marginsplot, ///
		horiz scheme(economist) ///
		graphr(color(white)) ///
		plotr(margin(b + 4)) ///
		plotopts( ///
			recast(scatter) ///
			lc(blue) lw(thick) ///
			msym(diamond) msiz(medium) mfc(blue) mc(blue) ///
			) ////
		ciopts(recast(rspike) lc(blue) lw(thick)) ///
		title("Effect of Income on Perceived `cat' Diversity", size(medsmall)) ///
		ytitle("") xtitle("") ///
		xline(`m') name(`lab'_age, replace) ylab(,labsize(medsmall))
	window manage close graph
	local ++i
	}
graph combine gend_age race_age age_age educ_age age_age, ///
rows(4) ysize(3) xsize(6.5) xcommon iscale(.6)
cd "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\png"
graph export age-diversity.png,as(png) hei(700) wid(1300) replace



use "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\dta\cosine-working.dta", clear
local cats Gender Race Class Education Generation
local i 1
foreach lab in gend race class educ age {
	qui sum `lab'_div, meanonly
	local m = r(mean)
	qui glm `lab'_div i.sex i.style c.numlabels, ///
	fam(bin) l(logit) cluster(id) nolog
	qui margins,at(sex = (1 2))
	local cat : word `i' of `cats'
	marginsplot, ///
		horiz scheme(economist) ///
		graphr(color(white)) ///
		plotr(margin(b + 4)) ///
		plotopts( ///
			recast(scatter) ///
			lc(blue) lw(thick) ///
			msym(diamond) msiz(medium) mfc(blue) mc(blue) ///
			) ////
		ciopts(recast(rspike) lc(blue) lw(thick)) ///
		title("Effect of Income on Perceived `cat' Diversity", size(medsmall)) ///
		ytitle("") xtitle("") ///
		xline(`m') name(`lab'_gender, replace) ylab(,labsize(medsmall))
	window manage close graph
	local ++i
	}
graph combine gend_gender race_gender class_gender educ_gender age_gender, ///
rows(4) ysize(3) xsize(6.5) xcommon iscale(.6)
cd "C:\Users\olizardo\Google Drive\lizardo-skiles-genre-perception\png"
graph export gender-diversity.png,as(png) hei(700) wid(1300) replace
