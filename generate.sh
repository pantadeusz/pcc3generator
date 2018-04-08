#!/bin/bash -e

# Plik z tabelka
CSV="dane.csv"

# szablon plikow .pdf
RESULTNAME="deklaracja_pcc_3"

# TWOJE DANE #

PESEL="00000000000"
US="Pcim dolny 7"
IMIE="Mateusz"
NAZWISKO="Morawiecki"
RODZICE="Mosze, Wanda"
PODATNIK="$IMIE, $NAZWISKO, 1944-03-14"

ADR_KRAJ="POLSKA"
ADR_WOJEW="Opolskie"
ADR_POWIAT="Inny"
ADR_GMINA="Picimiska"
ADR_ULICA="Jaworzego"
ADR_NRDOM="10"
ADR_NRLOK="22"
ADR_MIEJSC="Barka"
ADR_KOD="00-000"
ADR_POCZTA="Barka"

# Numery kolumn z pliku CSV
KOLUMNAPARA="0"
KOLUMNAWARTOSC="11"
KOLUMNADATA="1"



##############################################################################
############   KOD   ############# (tam dalej nie ruszaj jesli nie trzeba) ###
##############################################################################

DATAROWS=()
while IFS=";" read -r -a ROW
do
    DATAROWS+=("${ROW[$KOLUMNAPARA]} ${ROW[$KOLUMNADATA]} $(echo ${ROW[$KOLUMNAWARTOSC]} | tr ',' '.')")
done < "$CSV"

id=0
for i in "${DATAROWS[@]}"; do
ROW=($i)
PARA="${ROW[0]}"
WARTOSC="${ROW[2]}"
OPDATEARR=( $(echo ${ROW[1]} | tr '.' ' ') )
OPDATE="${OPDATEARR[2]} ${OPDATEARR[1]} ${OPDATEARR[0]}"

##########  dane do deklaracji
#PARA="BTC-LTC"
#WARTOSC="100.53"
#OPDATE="dd mm rrrr" # data wykonania zamiany walut
###


RESULTTEX="$(cat szablon.tex)"


WARTOSCRND="$(echo "$WARTOSC" | sed "s/\\..*//g")"
echo "${PARA} ${WARTOSC} (${WARTOSCRND})  ${OPDATE}"  

RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##1##/${PESEL}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##4##/${OPDATE}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##5##/${US}/g")"

RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##9##/${PODATNIK}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##10##/${RODZICE}/g")"


RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##11##/${ADR_KRAJ}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##12##/${ADR_WOJEW}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##13##/${ADR_POWIAT}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##14##/${ADR_GMINA}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##15##/${ADR_ULICA}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##16##/${ADR_NRDOM}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##17##/${ADR_NRLOK}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##18##/${ADR_MIEJSC}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##19##/${ADR_KOD}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##20##/${ADR_POCZTA}/g")"

RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##47##/$(( (WARTOSCRND*2/100)/2 )).$(( 5*((WARTOSCRND*2/100)%2) ))/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##65##/${IMIE}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##66##/${NAZWISKO}/g")"


if [ "$(echo $PARA | grep PLN)" = "" ]; then
# krypto-krypto
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##7#1##//g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##7#2##/%/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##24##/Zamiana kryptowalut ${PARA}/g")"

RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##30##/1.0/g")"

RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##29##/${WARTOSC}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##31##/$(( (WARTOSCRND*2/100)/2 )).$(( 5*((WARTOSCRND*2/100)%2) ))/g")"

RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##25##/ /g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##26##/ /g")"
else
# pln-krypto
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##7#1##/%/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##7#2##//g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##24##/Zakup krytpowaluty (${PARA})/g")"

RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##30##/ /g")"


RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##25##/${WARTOSC}/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##26##/$(( (WARTOSCRND*2/100)/2 )).$(( 5*((WARTOSCRND*2/100)%2) ))/g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##29##/ /g")"
RESULTTEX="$(echo "${RESULTTEX}" | sed "s/##31##/ /g")"
fi


echo "$RESULTTEX" > ___pccauto.tex
texi2pdf ___pccauto.tex > ${RESULTNAME}_${id}.log
mv ___pccauto.pdf ${RESULTNAME}_${id}.pdf
rm -f ___pccauto.*

id=$((id+1))
done
