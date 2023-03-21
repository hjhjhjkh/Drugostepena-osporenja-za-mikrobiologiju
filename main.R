# Script information ------------------------------------------------------

#' Project title: Eksel tabela u niz
#' Script name: main.R
#' Date created: 2023-3-21
#' Author: Milica
#' Script purpose: Obrada eksela

# Ucitaj potrebne biblioteke ----------------------------------------------
library(readxl)
library(xlsx)
library(writexl)

# Uvezi podatke -----------------------------------------------------------
procitanXls <- read_excel("data/uNizUlazA.xls", col_names = FALSE)

# Obradi podatke -----------------------------------------------------------
## Ucitano izmanipulisi da dobijes zgodan oblik za eksel kolonu
myList <- list()

for(k in 1:50){
  for (r in 1:10){ # 10:1 za negativne brojeve VS. 1:10 za pozitivne brojeve
    myList <- append(myList, procitanXls[k,r])
  }
}

df <- data.frame(myList)
df2 <- t(df[])

# Sacuvaj izlazni fajl ----------------------------------------------------
write.xlsx(df2, file="data/uNizIzlazA.xlsx", col.names=FALSE) 
## Voditi racuna u proveri da negativna nula nema u dobijenoj koloni (zato nema tacno 1000 nego 999 za razliku od tabele)
