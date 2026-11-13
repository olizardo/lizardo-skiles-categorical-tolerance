use "C:\Users\olizardo\Google Drive\WORK\IN PROGRESS\CULTURE\lizardo-reflective-duality-person-genres\ind-centralities.dta", clear
qui sum d0i
qui replace d0i = (d0i - r(mean)) / r(sd)

local i 1
local d 0 2 4 6 8 10 12 14 16
forval i = 1 / 8 {
	local k : word `i' of `d'
	ren d`k'i omnicent`i'
	gen omnit_`i' = `i'
	}


traj,var(omnicent*) model(cnorm) indep(omnit*) order(3 3 3 3) min(-3) max(6)
ren _traj_Group traj_group
joinby classicallis - hvymtllis using "C:\Users\olizardo\Google Drive\WORK\DONE\CULTURE\lizardo-skiles-genre-perception-musical-dislikes\dta\working.dta", unmatched(master)
drop degree
gen degree = .
replace degree = 0 if nodipdeg == 1
replace degree = 1 if (hsged == 1 | somcol == 1) & (aadeg == 0 & bach == 0 & ma == 0 & docprof ==0)
replace degree = 2 if aadeg == 1 & (bach == 0 & ma == 0 & docprof ==0)
replace degree = 3 if bach == 1 & (ma == 0 & docprof ==0)
replace degree = 4 if ma == 1 | docprof == 1
lab def newdeg 0 "lt high school" 1 "high school"  2 "junior college" 3 "bachelor" 4 "graduate"
lab val degree newdeg 

lab def newage 2 " " 3 " " 4 "Young" 5 " " 6 " " 7 " " 8 "Middle" 9 " " 10 " " 11 " " 12 "Old" 13 " " 14 " " 15 " "
lab val age newage

qui mlogit traj_group c.degree##c.degree##c.age##c.age i.sex i.race_eth
margins,at(degree = (1 3 4) age = (4 6 8 10 12 14))  
marginsplot, ///
	noci ///
	byd(_outcome, elabel(1 "Group 1 (11.4%)" 2 "Group 2 (32.8%)" 3 "Group 3 (40.5%)" 4 "Group 4 (15.4%)")) xd(age) ///
	scheme(stata7) ///
	byopts( ///
		rows(1) style(stata7) ///
		title("") ///
		subtitle("") ///
		graphr(color(white)) ///
		yrescale ///
		) ///
	legend(region(color(white)) rows(1)) ///
	xtitle("") ysize(3)
	
			
