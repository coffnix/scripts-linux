#!/bin/bash

# script de Backup diferencial
#set -x

ROOTDIR="/backup"
YEAR=$(date +%Y)
DAY=$(date +%u)
NDAY=$(date +%d)
HOUR=$(date +%H)
DATA=$(date +%d-%m-%Y)
H="$HOUR"
LOGDIR="${ROOTDIR}/logs"
LOGMAIL="${LOGDIR}/mailpy.log"
BKPLOG="${LOGDIR}/backup_compartilhamentos.log"
ERRORLOG="${LOGDIR}/error.log"
ERROR="0"
SUCESSO="SUCESSO"
FALHA="FALHA"
UUID_HDEXT="b4f40c62-ebaf-442c-a617-6246e06bfcaf"
MNT_HDEXT="/mnt_hd"
DIRSMB="/data/" # Manter o / no fim do diretório para que o comando rsync não duplique o diretório pai
DIRBKP="${MNT_HDEXT}/backup_compartilhamentos"
MACHINE="user"
FULL="${DIRBKP}/FULL"
DIFF="${DIRBKP}/DIFF"

#############################################################
# cria diretórios necessários caso não existam

if [ ! -d ${LOGDIR} ]; then
        mkdir -p ${LOGDIR}
fi

##############################################################
#if [ ! -d ${MNT_HDEXT} ]; then
#        mkdir -p ${MNT_HDEXT}
#fi
#
## monta HD externo
#
#umount ${MNT_HDEXT}
#
#sleep 3
#
#mount UUID=${UUID_HDEXT} ${MNT_HDEXT} 2> ${ERRORLOG}
#if [ $? -gt 0 ]; then
#	echo "$(date) - ERRO AO MONTAR O COMPARTILHAMENTO HD externo." >> ${BKPLOG}
#	cat $ERRORLOG | python $MAILSCRIPT "$FALHA ao montar HD externo. `date`";
#	ERROR=1;
#	exit 1
#fi

#############################################################
# limpa DIFFs antigos
find ${DIFF} -maxdepth 1 -mtime +30 -exec rm -rf {} \;

#############################################################
# cria diretórios necessários caso não existam

if [ ! -d ${DIRBKP} ]; then
        mkdir -p ${DIRBKP}
fi

if [ ! -d ${FULL} ]; then
        mkdir -p ${FULL}
fi

#############################################################


# Backup FULL
if [ "${NDAY}" = "08" -o  "${NDAY}" = "18" -o  "${NDAY}" = "28" ]; then
	echo "$(date) - Iniciando backup FULL..." >> ${BKPLOG}
        rsync -azv --delete ${DIRSMB} ${FULL} 2> ${ERRORLOG}
        if [ "$?" -gt 1 ]; then
		echo "$(date) - Finalizando backup FULL com erros." >> ${BKPLOG}
                cat $ERRORLOG | python $MAILSCRIPT "$FALHA ao sincronizar arquivos do compartilhamento. `date`";
                ERROR=1;
	else
		echo "$(date) - Finalizando com sucesso backup FULL." >> ${BKPLOG}
        fi

# Backup DIFF
else

	DIFFCURRENT="$DIFF/$DATA"
        mkdir -p ${DIFFCURRENT}
        sleep 3
	echo "$(date) - Iniciando backup DIFF..." >> ${BKPLOG}
	rsync -azv --compare-dest="${FULL}" --delete ${DIRSMB} ${DIFFCURRENT} 2> ${ERRORLOG}
        if [ "$?" -gt 1 ]; then
		echo "$(date) - Finalizando backup DIFF com erros." >> ${BKPLOG}
                cat $ERRORLOG | python $MAILSCRIPT "$FALHA ao sincronizar arquivos diferenciais do compartilhamento. `date`";
                ERROR=1;
	else
		echo "$(date) - Finalizando com sucesso backup DIFF." >> ${BKPLOG}
        fi

fi

#####################################################

# Envio para AWS

# Arquivos DIFF & FULL
#while [ 1 ]
#do
#	rsync -azvP --timeout=1500 ${DIRBKP}/ user@aws.domain.com.br:/bkp-clientes/user/ 2> ${ERRORLOG}
#		if [ "$?" = "0" ] ; then
#			echo "sucesso ao sincronizar DIFF & FULL para a AMAZON" >> ${BKPLOG}
#			break
#		else
#			cat $ERRORLOG | python $MAIL "$FALHA ao sincronizar DIFF & FULL para a AMAZON"
#			ERROR=1
#		fi
#done

#####################################################
cd /

sleep 3

umount ${MNT_HDEXT}

sleep 3

############################################
# fim

