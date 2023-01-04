# Script information ------------------------------------------------------

#' Project title: Drugostepena osporenja za mikrobiologiju
#' Script name: main.R
#' Date created: 2022-12-29
#' Date updated: 2023-01-05
#' Author: Milica
#' Script purpose: .xls u .xml konverzija

# Ucitaj potrebne biblioteke ----------------------------------------------
library(dplyr)
library(uuid)
library(XML)
library(tidyverse)
library(readxl)

# Uvezi xls podatke ------------------------------------------------------
procitanXls <- read_excel("data/avgust 2022.xls")

# Proveri i sredi podatke ------------------------------------------------
# View(procitanXls) #Pogledaj podatke
## Promeni problematicna imena kolona (treba jedna rec) ----
# colnames(procitanXls) #Pogledaj imena kolona
names(procitanXls)[8] <- 'DatumRođenja'
names(procitanXls)[9] <- 'TelesnaTežinaNaPrijemu'
names(procitanXls)[10] <- 'BrojZdravstveneIsprave'
names(procitanXls)[11] <- 'NosilacOsiguranja'
names(procitanXls)[12] <- 'VrstaLečenja'
names(procitanXls)[13] <- 'DatumOd'
names(procitanXls)[14] <- 'DatumDo'
names(procitanXls)[15] <- 'UputnaDijag.'
names(procitanXls)[16] <- 'NačinPrijema'
names(procitanXls)[17] <- 'LBOlekarUputio'
names(procitanXls)[18] <- 'PremeštenIzUstanove'
names(procitanXls)[19] <- 'Zavr.Dijag.'
names(procitanXls)[20] <- 'NačinOtpusta'
names(procitanXls)[22] <- 'BrojKartona'
names(procitanXls)[24] <- 'LečenSvojomVoljom'
names(procitanXls)[25] <- 'PoKonvenciji'
names(procitanXls)[27] <- 'TipUsluge'
names(procitanXls)[28] <- 'SlužbaPrijema'
names(procitanXls)[29] <- 'SlužbaOtpusta'
names(procitanXls)[30] <- 'LBOordinirajućegLekara'
names(procitanXls)[31] <- 'VrstaEpizodeLečenja'
names(procitanXls)[32] <- 'VrstaTransplantacije'
names(procitanXls)[33] <- 'DodatneDijagnoze'
names(procitanXls)[34] <- 'ListaLekovaDijagnoze'
names(procitanXls)[35] <- 'DSGšifra'
names(procitanXls)[36] <- 'DSGkolicina'
names(procitanXls)[37] <- 'DSGkoeficijent'
names(procitanXls)[38] <- 'DSGcena'
names(procitanXls)[39] <- 'KriterijumPrijema'
names(procitanXls)[41] <- 'DatumUsluge'
names(procitanXls)[42] <- 'ŠifraUsluge'
names(procitanXls)[43] <- 'EksterniIDusluge'
names(procitanXls)[44] <- 'ŠifraMaterijalaLeka'
names(procitanXls)[45] <- 'PorekloMaterijalaLeka'
names(procitanXls)[46] <- 'LBOlekara'
names(procitanXls)[47] <- 'ŠifraSlužbe'
names(procitanXls)[48] <- 'ŠifraSlužbeKojaJeTražilaUsl.'
names(procitanXls)[49] <- 'Org.Jedinica'
names(procitanXls)[53] <- 'OsporenIznos'
names(procitanXls)[54] <- 'RazlogOsporenja'
names(procitanXls)[55] <- 'ObrazloženjeOsporenja'

## Trimuj podatke na samo sta ti treba za XML ----
kolonePotrebneZaXml <- select(procitanXls, Filijala, Ispostava, Prezime, Ime, LBO, Pol, JMBG, DatumRođenja, BrojZdravstveneIsprave, NosilacOsiguranja, VrstaLečenja, DatumOd, DatumDo, UputnaDijag., Zavr.Dijag., NačinPrijema, NačinOtpusta, OOP, BrojKartona, OO, PoKonvenciji, Država, TipUsluge, SlužbaPrijema, SlužbaOtpusta, LBOordinirajućegLekara, DatumUsluge, ŠifraUsluge, Količina, Cena, LBOlekara, ŠifraSlužbe, ŠifraSlužbeKojaJeTražilaUsl., Org.Jedinica, EksterniIDusluge, RazlogOsporenja, ObrazloženjeOsporenja)

## Napravi listu jedinstvenih brojeva kartona ----
listaJedinstvenihBrojevaKartona <- unique(kolonePotrebneZaXml$BrojKartona)

# Napravi xml ------------------------------------------------------------
spravljenXML <-  xmlOutputDOM(tag = "Osiguranici")
for(k in 1:n_distinct(listaJedinstvenihBrojevaKartona)){
  #print("Sad je broj kartona:")
  #print(listaJedinstvenihBrojevaKartona[k])
  pojedinacniOsiguranik <- filter(kolonePotrebneZaXml, BrojKartona == listaJedinstvenihBrojevaKartona[k])  
  spravljenXML$addTag("Osiguranik",close=F)
  spravljenXML$addTag("Fil",select (pojedinacniOsiguranik[1,], Filijala))
  spravljenXML$addTag("Isp",select (pojedinacniOsiguranik[1,], Ispostava))
  spravljenXML$addTag("Prez",select (pojedinacniOsiguranik[1,], Prezime))
  spravljenXML$addTag("Ime",select (pojedinacniOsiguranik[1,], Ime))
  spravljenXML$addTag("LBO",select (pojedinacniOsiguranik[1,], LBO))
  spravljenXML$addTag("Pol",select (pojedinacniOsiguranik[1,], Pol))
  spravljenXML$addTag("JMBG",select (pojedinacniOsiguranik[1,], JMBG))
  spravljenXML$addTag("DatRodj",select (pojedinacniOsiguranik[1,], DatumRođenja))
  spravljenXML$addTag("BZK",select (pojedinacniOsiguranik[1,], BrojZdravstveneIsprave))
  ## Promeni za "NosilacOsiguranja": Da, da, DA -> 1; Ne, ne, NE -> 0
  newNos <- select (pojedinacniOsiguranik[1,], NosilacOsiguranja)
  if(newNos == 'DA' | newNos == 'da' | newNos == 'Da'){newNos <- 1}
  if(newNos == 'NE' | newNos == 'ne' | newNos == 'Ne'){newNos <- 0}
  spravljenXML$addTag("Nos", newNos)
  spravljenXML$addTag("VrsLec",select (pojedinacniOsiguranik[1,], VrstaLečenja))
  spravljenXML$addTag("DatOd",select (pojedinacniOsiguranik[1,], DatumOd))
  spravljenXML$addTag("DatDo",select (pojedinacniOsiguranik[1,], DatumDo))
  spravljenXML$addTag("UputDij",select (pojedinacniOsiguranik[1,], UputnaDijag.))
  spravljenXML$addTag("ZavrDij",select (pojedinacniOsiguranik[1,], Zavr.Dijag.))
  spravljenXML$addTag("NacPrijema",select (pojedinacniOsiguranik[1,], NačinPrijema))
  spravljenXML$addTag("NacOtpusta",select (pojedinacniOsiguranik[1,], NačinOtpusta))
  spravljenXML$addTag("OOP",select (pojedinacniOsiguranik[1,], OOP))
  spravljenXML$addTag("BrKart",select (pojedinacniOsiguranik[1,], BrojKartona))
  spravljenXML$addTag("OO",select (pojedinacniOsiguranik[1,], OO))
  spravljenXML$addTag("PoKon",select (pojedinacniOsiguranik[1,], PoKonvenciji))
  spravljenXML$addTag("Drz",select (pojedinacniOsiguranik[1,], Država))
  spravljenXML$addTag("TipUsl",select (pojedinacniOsiguranik[1,], TipUsluge))
  spravljenXML$addTag("SifSluPri",select (pojedinacniOsiguranik[1,], SlužbaPrijema))
  spravljenXML$addTag("SifSluOtp",select (pojedinacniOsiguranik[1,], SlužbaOtpusta))
  spravljenXML$addTag("LBOLekarOrd",select (pojedinacniOsiguranik[1,], LBOordinirajućegLekara))
  for(j in 1:nrow(pojedinacniOsiguranik))
  {
    spravljenXML$addTag("Usluga",close=F)
    spravljenXML$addTag("DatUsl",select (pojedinacniOsiguranik[j,], DatumUsluge))
    spravljenXML$addTag("SifUsl",select (pojedinacniOsiguranik[j,], ŠifraUsluge))
    spravljenXML$addTag("Kol",select (pojedinacniOsiguranik[j,], Količina))
    spravljenXML$addTag("JedCen", sub('\\.', ",", select (pojedinacniOsiguranik[j,], Cena)))## Promeni Cena '.' u ','
    spravljenXML$addTag("Ucs", 0)
    spravljenXML$addTag("LBOLekar",select (pojedinacniOsiguranik[j,], LBOlekara))
    spravljenXML$addTag("SifSlu",select (pojedinacniOsiguranik[j,], ŠifraSlužbe))
    spravljenXML$addTag("SifSluUput",select (pojedinacniOsiguranik[j,], ŠifraSlužbeKojaJeTražilaUsl.))
    spravljenXML$addTag("SifOJ",select (pojedinacniOsiguranik[j,], Org.Jedinica))
    spravljenXML$addTag("EksID",select (pojedinacniOsiguranik[j,], EksterniIDusluge))
    spravljenXML$addTag("Nap",select (pojedinacniOsiguranik[j,], RazlogOsporenja))
    spravljenXML$addTag("Usluga_atribut",close=F)
    spravljenXML$addTag("Atribut",select (pojedinacniOsiguranik[j,], ObrazloženjeOsporenja))
    spravljenXML$closeTag()
    spravljenXML$closeTag()
  }
  spravljenXML$closeTag()
}

# Sacuvaj XML ------------------------------------------------------------
saveXML(spravljenXML$value(),file = "zavrsenXML.xml", prefix = '')