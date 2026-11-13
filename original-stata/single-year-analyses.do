do "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans\dataproc-ssi.do"
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

est drop _all
/*race + sex + age*/
qui zip numdislikes agemid agesq race1 race2 race3 race5 gender2, ///
inflate(agemid race1 race2 race3 race5 race6 gender2) vuong nolog
est store mod1
/*race + sex + age + educ*/
qui zip numdislikes agemid agesq race3 race5 race6 gender2 nodipdeg hsged somcol aadeg bach ma docprof, ///
inflate(agemid race2 race3 nodipdeg hsged somcol aadeg bach ma docprof) vuong nolog
est store mod2
qui zip numdislikes agemid agesq race3 race5 race6 gender2 somcol aadeg bach loginc, ///
inflate(agemid race2 race3 hsged aadeg bach loginc) vuong nolog
est store mod3
qui zip numdislikes agemid agesq race3 race5 race6 gender2 somcol aadeg bach numdk, ///
inflate(agemid race2 race3 hsged aadeg bach) vuong nolog
est store mod4
esttab mod*, ///
stats(N chi2,fmt(%9.0f %9.2f)) lab plain star(* 0.05) varw(35) ///
compress t(%9.2f) b(%9.3f) par nogaps nolines nomtitles replace   
