# Script information ------------------------------------------------------

#' Project title: Drugostepena osporenja za mikrobiologiju
#' Script name: main.R
#' Date created: 2022-12-29
#' Date updated: 2023-02-08
#' Author: Milica
#' Script purpose: .xls u .xml konverzija

# Ucitaj potrebne biblioteke ----------------------------------------------
library(dplyr)
library(uuid)
library(XML)
library(tidyverse)
library(readxl)

# Uvezi i proveri iz eksela uvezene podatke -------------------------------
ucesceKolonaOdsutna <- TRUE
procitanXls <- read_excel("data/god_2021/godinuDana_2021_XLSs/Cela_2021.xls")
## Pogledaj ako ima upozorenja i ucitane podatke pogledaj ---- 
#warnings() # "Expecting logical in Z..." = Z kolona iz eksela pogresno pogodjen tip
#View(procitanXls)
# 
## R za ucitane podatke nagadja tip podatka za svaku kolonu; ako neko upozorenje indikuje da pogresno pogodio specificiraj tip ---- 
## Prema uputstvu sa https://readxl.tidyverse.org/articles/cell-and-column-types.html
## Specificiraj tip podatka za jednu kolonu ostale nek pogadja (preporuceno za samo problematicne kolone)
## ili 
## Specificiraj tip podatka za sve kolone (manje preporuceno, moguci novi problemi, do sada primeceno da specificiranje tipa "text" remeti brojeve oblika xx,xx)
#procitanXls <- read_excel("data/god_2021/godinuDana_2021_XLSs/Cela_2022_plus.xls", col_types = c("guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "text", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess", "guess"))
#procitanXls <- read_excel("data/god_2021/godinuDana_2021_XLSs/Cela_2022_plus.xls", col_types = "text")

# Sredi podatke ----------------------------------------------------------
## Izbaci ako postoje dve visak kolone "Vrsta Transplantacije" i "Poreklo materijala/leka" (u nekim xls-ovima postoje, u nekim ne, a svakako ne trebaju) ----
 if (ncol(procitanXls) == 55){procitanXls <-  select(procitanXls, -c('Vrsta Transplantacije', 'Poreklo materijala/leka'))}

## Promeni problematicna imena kolona (treba jedna rec) ----
names(procitanXls)[8] <- 'DatumRo??enja'
names(procitanXls)[9] <- 'TelesnaTe??inaNaPrijemu'
names(procitanXls)[10] <- 'BrojZdravstveneIsprave'
names(procitanXls)[11] <- 'NosilacOsiguranja'
names(procitanXls)[12] <- 'VrstaLe??enja'
names(procitanXls)[13] <- 'DatumOd'
names(procitanXls)[14] <- 'DatumDo'
names(procitanXls)[15] <- 'UputnaDijag.'
names(procitanXls)[16] <- 'Na??inPrijema'
names(procitanXls)[17] <- 'LBOlekarUputio'
names(procitanXls)[18] <- 'Preme??tenIzUstanove'
names(procitanXls)[19] <- 'Zavr.Dijag.'
names(procitanXls)[20] <- 'Na??inOtpusta'
names(procitanXls)[22] <- 'BrojKartona'
names(procitanXls)[24] <- 'Le??enSvojomVoljom'
names(procitanXls)[25] <- 'PoKonvenciji'
names(procitanXls)[27] <- 'TipUsluge'
names(procitanXls)[28] <- 'Slu??baPrijema'
names(procitanXls)[29] <- 'Slu??baOtpusta'
names(procitanXls)[30] <- 'LBOordiniraju??egLekara'
names(procitanXls)[31] <- 'VrstaEpizodeLe??enja'
names(procitanXls)[32] <- 'DodatneDijagnoze'
names(procitanXls)[33] <- 'ListaLekovaDijagnoze'
names(procitanXls)[34] <- 'DSG??ifra'
names(procitanXls)[35] <- 'DSGkolicina'
names(procitanXls)[36] <- 'DSGkoeficijent'
names(procitanXls)[37] <- 'DSGcena'
names(procitanXls)[38] <- 'KriterijumPrijema'
names(procitanXls)[40] <- 'DatumUsluge'
names(procitanXls)[41] <- '??ifraUsluge'
names(procitanXls)[42] <- 'EksterniIDusluge'
names(procitanXls)[43] <- '??ifraMaterijalaLeka'
names(procitanXls)[44] <- 'LBOlekara'
names(procitanXls)[45] <- '??ifraSlu??be'
names(procitanXls)[46] <- '??ifraSlu??beKojaJeTra??ilaUsl.'
names(procitanXls)[47] <- 'Org.Jedinica'
names(procitanXls)[51] <- 'OsporenIznos'
names(procitanXls)[52] <- 'RazlogOsporenja'
names(procitanXls)[53] <- 'Obrazlo??enjeOsporenja'
# print("imena kolona posle promene:")
# colnames(procitanXls) #Pogledaj imena kolona

## Trimuj podatke na samo sta ti treba za XML ----
if (ucesceKolonaOdsutna){ 
  kolonePotrebneZaXml <- select(procitanXls, Filijala, Ispostava, Prezime, Ime, LBO, Pol, JMBG, DatumRo??enja, BrojZdravstveneIsprave, NosilacOsiguranja, VrstaLe??enja, DatumOd, DatumDo, UputnaDijag., Zavr.Dijag., Na??inPrijema, Na??inOtpusta, OOP, BrojKartona, OO, PoKonvenciji, Dr??ava, TipUsluge, Slu??baPrijema, Slu??baOtpusta, LBOordiniraju??egLekara, DatumUsluge, ??ifraUsluge, Koli??ina, Cena, LBOlekara, ??ifraSlu??be, ??ifraSlu??beKojaJeTra??ilaUsl., Org.Jedinica, EksterniIDusluge, Obrazlo??enjeOsporenja)
} else {
  kolonePotrebneZaXml <- select(procitanXls, Filijala, Ispostava, Prezime, Ime, LBO, Pol, JMBG, DatumRo??enja, BrojZdravstveneIsprave, NosilacOsiguranja, VrstaLe??enja, DatumOd, DatumDo, UputnaDijag., Zavr.Dijag., Na??inPrijema, Na??inOtpusta, OOP, BrojKartona, OO, PoKonvenciji, Dr??ava, TipUsluge, Slu??baPrijema, Slu??baOtpusta, LBOordiniraju??egLekara, DatumUsluge, ??ifraUsluge, Koli??ina, Cena, LBOlekara, ??ifraSlu??be, ??ifraSlu??beKojaJeTra??ilaUsl., Org.Jedinica, EksterniIDusluge, Obrazlo??enjeOsporenja, Ucesce)
}

## Zameni 'NA' sa praznim stringom ----
tryCatch({
  kolonePotrebneZaXml <- replace(kolonePotrebneZaXml, is.na(kolonePotrebneZaXml), "")
}, warning = function(w) {
}, error = function(e) {
  print ("desio se NA error")
  # to be bolje hendlovano, za sad reseno tako sto u ekselu receno problematicnoj koloni da formatira ko text (desilo se samo za oktobar za kolonu 'Drzava' error "can`t convert <character> to <double>" i kad sam dodavala "Ucesce" resila sa kopiranjem pa editovanjem "Drzava" kolone rucno)
}, finally = {
})

## Napravi listu jedinstvenih brojeva kartona ----
listaJedinstvenihBrojevaKartona <- unique(kolonePotrebneZaXml$BrojKartona)
 # print ("Lista svih jedinstvenih brojeva kartona:")
 # print (listaJedinstvenihBrojevaKartona)
 # print ("Duzina lista svih jedinstvenih brojeva kartona:")
 # print (length(listaJedinstvenihBrojevaKartona))

# Napravi xml ------------------------------------------------------------
spravljenXML <-  xmlOutputDOM(tag = "Osiguranici")
for(k in 1:length(listaJedinstvenihBrojevaKartona)){
  #print("Sad je broj kartona:")
  #print(listaJedinstvenihBrojevaKartona[k])
  pojedinacniOsiguranik <- filter(kolonePotrebneZaXml, BrojKartona == listaJedinstvenihBrojevaKartona[k])  
  spravljenXML$addTag("Osiguranik",close=F)
  spravljenXML$addTag("Fil",select (pojedinacniOsiguranik[1,], Filijala))
  spravljenXML$addTag("Isp",select (pojedinacniOsiguranik[1,], Ispostava))
  spravljenXML$addTag("Prez",select (pojedinacniOsiguranik[1,], Prezime))
  spravljenXML$addTag("Ime",select (pojedinacniOsiguranik[1,], Ime))
  spravljenXML$addTag("LBO",select (pojedinacniOsiguranik[1,], LBO))
  ## Promeni za "Pol": Mu??ki, mu??ki, MU??KI -> M; ??enski, ??enski, ??ENSKI -> Z
  newPol <- select (pojedinacniOsiguranik[1,], Pol)
  if(newPol == 'Mu??ki' | newPol == 'mu??ki' | newPol == 'MU??KI'){newPol <- "M"}
  if(newPol == '??enski' | newPol == '??enski' | newPol == '??ENSKI'){newPol <- "Z"}
  spravljenXML$addTag("Pol", newPol)
  spravljenXML$addTag("JMBG",select (pojedinacniOsiguranik[1,], JMBG))
  spravljenXML$addTag("DatRodj",select (pojedinacniOsiguranik[1,], DatumRo??enja))
  spravljenXML$addTag("BZK",select (pojedinacniOsiguranik[1,], BrojZdravstveneIsprave))
  ## Promeni za "NosilacOsiguranja": Da, da, DA -> 1; Ne, ne, NE -> 0
  newNos <- select (pojedinacniOsiguranik[1,], NosilacOsiguranja)
  if(newNos == 'DA' | newNos == 'da' | newNos == 'Da'){newNos <- 1}
  if(newNos == 'NE' | newNos == 'ne' | newNos == 'Ne'){newNos <- 0}
  spravljenXML$addTag("Nos", newNos)
  spravljenXML$addTag("VrsLec",select (pojedinacniOsiguranik[1,], VrstaLe??enja))
  spravljenXML$addTag("DatOd",select (pojedinacniOsiguranik[1,], DatumOd))
  spravljenXML$addTag("DatDo",select (pojedinacniOsiguranik[1,], DatumDo))
  spravljenXML$addTag("UputDij",select (pojedinacniOsiguranik[1,], UputnaDijag.))
  # "Nacin prijema" i "Nacin otpusta" - hardcode i ne varijanta (odkomentarisati sta treba po potrebi)
  #spravljenXML$addTag("NacPrijema",select (pojedinacniOsiguranik[1,], Na??inPrijema))
  #spravljenXML$addTag("NacOtpusta",select (pojedinacniOsiguranik[1,], Na??inOtpusta))
  spravljenXML$addTag("NacPrijema",2) ## !Hardcode!
  spravljenXML$addTag("ZavrDij",select (pojedinacniOsiguranik[1,], Zavr.Dijag.))
  spravljenXML$addTag("NacOtpusta",4) ## !Hardcode!
  spravljenXML$addTag("OOP",select (pojedinacniOsiguranik[1,], OOP))
  spravljenXML$addTag("BrKart",select (pojedinacniOsiguranik[1,], BrojKartona))
  spravljenXML$addTag("OO",select (pojedinacniOsiguranik[1,], OO))
  
  ## Dve alternative za "Po konvenciji" logiku: A/ true/false iz xls-a (deprecated) B/prema drzavi (aktuelno) 
  ## A/ Promeni za "PoKonvenciji": True, true, TRUE -> 1; False, false, FALSE -> 0
  # newPoKon <- select (pojedinacniOsiguranik[1,], PoKonvenciji)
  # if(newPoKon == 'True' | newPoKon == 'true' | newPoKon == 'TRUE'){newPoKon <- 1}
  # if(newPoKon == 'False' | newPoKon == 'false' | newPoKon == 'FALSE'){newPoKon <- 0}
  # spravljenXML$addTag("PoKon",newPoKon)
  ## B/
  if (is.null(select (pojedinacniOsiguranik[1,], Dr??ava)) | select (pojedinacniOsiguranik[1,], Dr??ava) == '' | is.na(select (pojedinacniOsiguranik[1,], Dr??ava))){ 
    spravljenXML$addTag("PoKon",'0')
  }
  else{
    spravljenXML$addTag("PoKon",'1')
  }
  
  newDrzava <- select (pojedinacniOsiguranik[1,], Dr??ava)
  spravljenXML$addTag("Drz", newDrzava)
  if (is.null(newDrzava) | newDrzava == '' | is.na(newDrzava)) ## Nema drzave slucaj
  { 
    spravljenXML$addTag("VrsIspKon",'') ## Zakomentarisi ako ne zelis da se pojavi prazni tag
    spravljenXML$addTag("BrIspKon",'') ## Zakomentarisi ako ne zelis da se pojavi prazni tag
    spravljenXML$addTag("NapKon",'') ## Zakomentarisi ako ne zelis da se pojavi prazni tag
  }
  else ## Ima drzave slucaj
  { 
    brZsrIsp <- select (pojedinacniOsiguranik[1,], BrojZdravstveneIsprave)
    if (substr(brZsrIsp, 1, 2) == 96)
    {
      spravljenXML$addTag("VrsIspKon", "INO1")
    }
    else
    {
      spravljenXML$addTag("VrsIspKon", "ZK")
    }
    spravljenXML$addTag("BrIspKon", brZsrIsp) 
    spravljenXML$addTag("NapKon",'') ## Zakomentarisi ako ne zelis da se pojavi prazni tag
  }
  spravljenXML$addTag("TipUsl",select (pojedinacniOsiguranik[1,], TipUsluge))
  spravljenXML$addTag("SifSluPri",select (pojedinacniOsiguranik[1,], Slu??baPrijema))
  spravljenXML$addTag("SifSluOtp",select (pojedinacniOsiguranik[1,], Slu??baOtpusta))
  spravljenXML$addTag("LBOLekarOrd",select (pojedinacniOsiguranik[1,], LBOordiniraju??egLekara))
  for(j in 1:nrow(pojedinacniOsiguranik))
  {
    spravljenXML$addTag("Usluga",close=F)
    spravljenXML$addTag("DatUsl",select (pojedinacniOsiguranik[j,], DatumUsluge))
    spravljenXML$addTag("SifUsl",select (pojedinacniOsiguranik[j,], ??ifraUsluge))
    spravljenXML$addTag("Kol",select (pojedinacniOsiguranik[j,], Koli??ina))
    spravljenXML$addTag("JedCen", sub('\\.', ",", select (pojedinacniOsiguranik[j,], Cena)))## Promeni Cena '.' u ','
    ## ucesce zavisno dal postoji kolona u XLSu ili ne 
    if (ucesceKolonaOdsutna){ 
        spravljenXML$addTag("Ucs", 0)
    } else {
      newUcs <- select (pojedinacniOsiguranik[j,], Ucesce)
      if (is.null(newUcs) | newUcs == '' | is.na(newUcs)){## Nema ucesca slucaj
        spravljenXML$addTag("Ucs", 0)
      }
      else{
        spravljenXML$addTag("Ucs", newUcs)## Ima ucesca slucaj
      }
    }
    spravljenXML$addTag("LBOLekar",select (pojedinacniOsiguranik[j,], LBOlekara))
    spravljenXML$addTag("ImeLekara", '-') ## !Hardcode!
    spravljenXML$addTag("PrezLekara", '-') ## !Hardcode!
    spravljenXML$addTag("SifSlu",select (pojedinacniOsiguranik[j,], ??ifraSlu??be))
    spravljenXML$addTag("SifSluUput",select (pojedinacniOsiguranik[j,], ??ifraSlu??beKojaJeTra??ilaUsl.))
    spravljenXML$addTag("SifOJ",select (pojedinacniOsiguranik[j,], Org.Jedinica))
    spravljenXML$addTag("EksID",select (pojedinacniOsiguranik[j,], EksterniIDusluge))
    spravljenXML$addTag("Nap",select (pojedinacniOsiguranik[j,], Obrazlo??enjeOsporenja))
    spravljenXML$addTag("Usluga_atribut",close=F)
    spravljenXML$addTag("Atribut", '00') ## !Hardcode!
    spravljenXML$closeTag()
    spravljenXML$closeTag()
  }
  spravljenXML$closeTag()
}

# Sacuvaj XML ------------------------------------------------------------
saveXML(spravljenXML$value(),file = "data/god_2021/godinuDana_2021_XMLs/Cela_2021_plus_Ucesca.xml", prefix = '')
