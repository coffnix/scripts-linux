#!/bin/bash

DATA=$(date +'%Y-%m-%d')
DEST_DIR="/backup/mailboxsize"
ZMPROV="/opt/zimbra/bin/zmprov"

mkdir -p ${DEST_DIR}

cd ${DEST_DIR}
rm ${DEST_DIR}/lista.txt

# Generate list
for MAIL in $($ZMPROV -l gaa vitallis.com.br | sort);  do
        echo -e "Espaço em disco usado pela conta $MAIL: $(/opt/zimbra/bin/zmmailbox -z -m ${MAIL} gms)" >> ${DEST_DIR}/lista.txt
done

# Sort by size
cat ${DEST_DIR}/lista.txt|grep -v MB|grep -v KB|grep -vw B|sort -r -n -k 8 > ${DEST_DIR}/lista-final-${DATA}.txt
cat ${DEST_DIR}/lista.txt|grep -v GB|grep -v KB|grep -vw B|sort -r -n -k 8 >> ${DEST_DIR}/lista-final-${DATA}.txt
cat ${DEST_DIR}/lista.txt|grep -v GB|grep -v MB|grep -vw B|sort -r -n -k 8 >> ${DEST_DIR}/lista-final-${DATA}.txt

rm ${DEST_DIR}/lista.txt

