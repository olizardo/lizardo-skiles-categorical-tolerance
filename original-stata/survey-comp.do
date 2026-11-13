use "N:\Private\MISC DATA SOURCES\SSI-2012\SSI2012", clear
keep *lis
gen survey = 1
gen prop = 1 / _N
save "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans\SSI-listen.dta",replace

use "N:\Private\MISC DATA SOURCES\SPPA-2012\sppa2012_public_stata.dta", clear
keep PEA71 - PEA717
drop PEA714
gen survey = 2
local varnames classicallis operalis bwaystlis jazzlis ///
croldlis indaltlis toppoplis countrylis danclublis raphiphoplis ///
reggaelis blurblis latspsallis blueglis folklis hymgoslis 
local i 1 
foreach x of varlist PEA71 - PEA717 {
	recode `x' 2 = 0
	local varname : word `i' of `varnames'
	ren `x' `varname'
	local ++i
	}
for var *lis : drop if X == .
gen prop = 1 / _N
save "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans\SPPA-listen.dta",replace
append using "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans\SSI-listen.dta"
drop moodezlis bbandlis controcklis hvymtllis nonelis
lab def survey 1 "SSI" 2 "SPPA" 
lab val survey survey
egen numlis = rowtotal(*lis)
save "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans\SPPA-SSI-listen.dta",replace

use "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans\SPPA-SSI-listen.dta",clear
collapse (sum) prop,by(numlis survey)

twoway connected prop numlis if survey == 1, ///
msym(diamond) mfc(black) mc(white) msize(large) || ///
connected prop numlis if survey == 2, ///
msym(diamond) mfc(white) mc(gs6) msize(medlarge) lc(gs6) ///
legend(label(1 "SSI 2012") label(2 "SPPA 2012")) ///
xlab(0(1)16) ylab(0(.05).25) ///
xtitle("Number of Genres Listened To") ytitle("% of Respondents") 
cd "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans"
graph export numlis_by_survey.png, ///
as(png) replace width(800) height(400)


