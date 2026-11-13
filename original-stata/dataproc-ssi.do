use "N:\Private\MISC DATA SOURCES\SSI-2012\SSI2012", clear
drop classicalfemale-VD
ren age agecat
gen degree = .
replace degree = 0 if nodipdeg == 1
replace degree = 1 if (hsged == 1 | somcol == 1) & (aadeg == 0 & bach == 0 & ma == 0 & docprof ==0)
replace degree = 2 if aadeg == 1 & (bach == 0 & ma == 0 & docprof ==0)
replace degree = 3 if bach == 1 & (ma == 0 & docprof ==0)
replace degree = 4 if ma == 1 | docprof == 1
lab def degree 0 "lt high school" 1 "high school"  2 "junior college" 3 "bachelor" 4 "graduate"
lab val degree degree

ren latlpsallike latlpsallike
foreach name in classical opera jazz bwayst moodez bband crold country blueg folk hymgos ///
latspsal raphiphop blurb reggae toppop controck indalt danclub hvymtl {
	gen `name'dis = `name'taste == 2
	gen `name'meh = `name'taste == 3
	gen `name'dk = `name'taste == 4
	}
drop *taste
ren female sex
recode sex 0 = 1 1 = 2
gen year = 2012

lab def ed 0 "Less than H.S." 1 "High School" 2 "Junior College" 3 "College" 4 "Post-Graduate"
lab val degree ed
gen college = degree > 2
lab def college 1 "College Degree" 0 "No College"
lab val college college
gen black = race == 2
lab def black  1 "Black" 0 "Not Black" 
lab val black black
gen white = race == 4
lab def white 1 "White" 0 "Not White"
lab val white white
lab def sex2 1 "Men" 2 "Women"
lab val sex sex2
gen women = sex == 2
lab def women 1 "Women" 0 "Men"
lab val women women
egen numlikes = rsum(*like)
egen numdislikes = rsum(*dis)
egen nummeh = rsum(*meh)
egen numdk = rsum(*dk)
gen cohort = round(year - agemid)
recode cohort 1905/1915 = 1910 1920 / 1925 = 1920 1930/1935 = 1930 1940/1945 = 1940 1950/1955 = 1950 ///
1960/1965 = 1960 1970/1975 = 1970 1980/1985 = 1980 1990/1995 = 1990, g(cohortrec)
/*creating cohort labels*/
lab def cohortrec4 1 "before 1936" 2 "between 1936 and 1954" 3 "between 1955 and 1968" 4 "after 1968"
lab def cohortrec5 1 "before 1936" 2 "between 1936 and 1946" ///
3 "between 1947 and 1964" 4 "between 1965 and 1975" 5 "after 1975"
lab def cohortrec6 1 "before 1936" 2 "between 1936 and 1946" ///
3 "between 1947 and 1954" 4 "between 1955 and 1964" 5 "between 1965 and 1975" 6 "after 1975"
/*recoding cohort variable*/
recode cohort 1900/1935 = 1 1936/1954 = 2 1955/1968 = 3 1969/2000 = 4,g(cohortrec4)
recode cohort 1900/1935 = 1 1936/1946 = 2 1947/1964 = 3 1965/1975 = 4 1976/2000 = 5,g(cohortrec5)
recode cohort 1900/1935 = 1 1936/1946 = 2 1947/1954 = 3 1955/1964 = 4 1965/1975 = 5 1976/2000 = 6,g(cohortrec6)
/*assigning labe values*/
lab val cohortrec4 cohortrec4
lab val cohortrec5 cohortrec5
lab val cohortrec6 cohortrec6
lab val year year
for var numdislikes numlikes nummeh : recode X 12 /20 = 12,g(X12)
gen nodis = numdislikes == 0
lab def nodis 1 "No Dislikes" 0 "At Least One Dislike"
lab val nodis nodis
lab var cohort "Birth Year"
gen hs = degree == 1 | degree == 2
gen bc = degree == 3
gen pg = degree == 4
tab cohortrec4,g(cohortcat)
lab def like 0 "No" 1 "Yes"
for var *like : lab val X like
save "C:\Users\olizardo\Google Drive\lizardo-skiles-refusal-to-dislike-americans\ssi-working.dta",replace









