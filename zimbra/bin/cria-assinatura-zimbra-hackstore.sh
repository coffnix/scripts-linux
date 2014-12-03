#!/bin/bash

# Debug
#set -x

# remove extra whitespace
crunch() {
        while read FOO ; do
              echo $FOO
        done
        }

ZMPROV="/opt/zimbra/bin/zmprov"
TMPDIR="/tmp/zassinatura/${ACCOUNT}"

mkdir -p "${TMPDIR}"
#########################################################

for ACCOUNT in $($ZMPROV -l gaa hackstore.com.br | sort);  do

        echo -ne "Checando assinatura de conta: ${ACCOUNT}\t"
        mkdir -p "${TMPDIR}/${ACCOUNT}"
        INFO_FILE="${TMPDIR}/${ACCOUNT}/info.txt"
# obtendo infos da conta
${ZMPROV} ga ${ACCOUNT} | egrep "givenName|sn|title|telephoneNumber|uid|zimbraPrefMailSignatureHTML|zimbraPrefDefaultSignatureId|zimbraSignatureName|mobile|company|description|displayName" |grep -v 'zimbraSharedItem:' > ${INFO_FILE}

# Preenche campos vazios com caracter '-'
NOME_ASSINATURA="SIGN-$(grep 'uid: ' ${INFO_FILE}|cut -d":" -f2|crunch)"
NOME_COMPLETO="$(grep 'displayName: ' ${INFO_FILE}|cut -d":" -f2|crunch)"
CARGO="$(grep 'title: ' ${INFO_FILE}|cut -d":" -f2|crunch)"
TELEFONE="$(grep 'telephoneNumber: ' ${INFO_FILE}|cut -d":" -f2|crunch)"
CELULAR="$(grep 'mobile: ' ${INFO_FILE}|cut -d":" -f2|crunch)"
EMPRESA="$(grep 'company: ' ${INFO_FILE}|cut -d":" -f2|crunch)"

        if [ -z "${NOME_COMPLETO}" ] ; then
                NOME_COMPLETO="-"
        fi

        if [ -z "${CARGO}" ] ; then
                CARGO="-"
        fi

        if [ -z "${TELEFONE}" ] ; then
                TELEFONE="-"
        fi



if [ -z "${ACCOUNT}" ] && [ -z "${NOME_ASSINATURA}" ] && [ -z "${NOME_COMPLETO}" ] && [ -z "${CARGO}" ] && [ -z "${TELEFONE}" ]; then
        echo -e "Argumentos ausentes:\n./set_signature.sh <e-mail> <NomeAssinatura> <NomeCompleto> <função> <telefone>\n\nUse /opt/zimbra/bin/zmprov gsig <e-mail> para visualizar a configuração atual"
        exit 1
fi


#########################################################


atualizaassinatura() {

echo "Criando assinatura ${NOME_ASSINATURA} na conta ${ACCOUNT}"
    SIGNATURED=$(/opt/zimbra/bin/zmprov csig "${ACCOUNT}" "${NOME_ASSINATURA}" zimbraPrefMailSignatureHTML "<meta charset=\"utf-8\"> <style type=\"text/css\"> body { font-family: sans-serif; font-size: 10px; } .disclaimer { font-size: 8px; width: 800px; text-align: justify; } .assinatura {  padding-left: 5px; } .dados { padding-left: 10px;   } </style>    <div class=\"assinatura\"> <div id=\"logo\"><img width=\"235\" height=\"90\" alt=\"Hackstore Saúde S/A\" src=\"http://www.hackstore.com.br/assinaturas/ass_email_new.png\"> </div> <div class=\"dados\"> <span id=\"nome\"><strong>${NOME_COMPLETO}</strong></span><br>    <span id=\"departamento\">${CARGO}</span><br> <span id=\"telefone\" class=\"fone\">+55 ${TELEFONE}</span><br> <span id=\"celular\" class=\"fone\">+55 ${CELULAR}</span><br> <span id=\"endereco\"><p> Belo Horizonte<br> <a href=\"http://www.hackstore.com.br\">www.hackstore.com.br</a> </p> </span> <div class=\"disclaimer\"><p>Esta mensagem é destinada exclusivamente ao seu destinatário e as informações nela contidas são confidenciais, protegidas por sigilo profissional ou por lei. É vedada a transmissão ou divulgação de seu conteúdo a terceiros, que não seus destinatários. O uso não autorizado de tais informações, incluindo, mas não se limitando a, qualquer divulgação, cópia, distribuição ou qualquer ação ou omissão, é proibido e sujeitará o agente às penalidades cabíveis. Qualquer opinião que porventura esteja contida nesta mensagem expressa única e exclusivamente a própria opinião do autor e não representa a opinião da empresa.<br></p><div><br></div> This message is intended solely for its addressee and the information contained therein is confidential, and protected by professional privilege or by law. The transmission or disclosure of its contents to third parties other than its addressees is forbidden. Unauthorized use of such information, including, but not limited to, any disclosure, copy, distribution or any action or omission, is prohibited and will subject the agent to the applicable penalties. The opinions that may be contained in this message only and exclusively express the opinion of the author and do not represent the opinion of the company. <p></p> </div> </div>    </div>")

echo "Setando assinatura default para ${NOME_ASSINATURA}"
/opt/zimbra/bin/zmprov ma ${ACCOUNT} zimbraPrefDefaultSignatureId $(/opt/zimbra/bin/zmprov gsig ${ACCOUNT} | grep -B 1 "SIGN" | grep "Id" | cut -d" " -f2|tail -1)
if [ $? -gt 0 ]; then
echo -e "\nError ao criar assinatura. Corrija-o!\nSe a assinatura existir, é necessário deleta-la, pode-se usar o comando /opt/zimbra/bin/zmprov dsig ${ACCOUNT} ${NOME_ASSINATURA}"
exit 2
fi


echo "Setando assinatura default de resposta para ${NOME_ASSINATURA}"
/opt/zimbra/bin/zmprov ma ${ACCOUNT} zimbraPrefForwardReplySignatureId $(/opt/zimbra/bin/zmprov gsig ${ACCOUNT} | grep -B 1 "SIGN" | grep "Id" | cut -d" " -f2|tail -1)
if [ $? -gt 0 ]; then
echo -e "\nError ao criar assinatura. Corrija-o!\nSe a assinatura existir, é necessário deleta-la, pode-se usar o comando /opt/zimbra/bin/zmprov dsig ${ACCOUNT} ${NOME_ASSINATURA}"
exit 2
fi

}
        # obtem assinatura atual para comparacao
        SIGN_ATUAL=$(grep zimbraPrefDefaultSignatureId: ${INFO_FILE} |sed s,'zimbraPrefDefaultSignatureId: ',,g)
        if [ ! -z "${SIGN_ATUAL}" ]; then
                /opt/zimbra/bin/zmprov gsig ${ACCOUNT}|grep $SIGN_ATUAL -B1|grep zimbraPrefMailSignatureHTML:|sed s,'zimbraPrefMailSignatureHTML: ',,g > ${TMPDIR}/${ACCOUNT}/assinatura-atual.txt
        fi

        # obtem nova assinatura para comparacao
        echo "<meta charset=\"utf-8\"> <style type=\"text/css\"> body { font-family: sans-serif; font-size: 10px; } .disclaimer { font-size: 8px; width: 800px; text-align: justify; } .assinatura {  padding-left: 5px; } .dados { padding-left: 10px;   } </style>    <div class=\"assinatura\"> <div id=\"logo\"><img width=\"235\" height=\"90\" alt=\"Hackstore Saúde S/A\" src=\"http://www.hackstore.com.br/assinaturas/ass_email_new.png\"> </div> <div class=\"dados\"> <span id=\"nome\"><strong>${NOME_COMPLETO}</strong></span><br>    <span id=\"departamento\">${CARGO}</span><br> <span id=\"telefone\" class=\"fone\">+55 ${TELEFONE}</span><br> <span id=\"celular\" class=\"fone\">+55 ${CELULAR}</span><br> <span id=\"endereco\"><p> Belo Horizonte<br> <a href=\"http://www.hackstore.com.br\">www.hackstore.com.br</a> </p> </span> <div class=\"disclaimer\"><p>Esta mensagem é destinada exclusivamente ao seu destinatário e as informações nela contidas são confidenciais, protegidas por sigilo profissional ou por lei. É vedada a transmissão ou divulgação de seu conteúdo a terceiros, que não seus destinatários. O uso não autorizado de tais informações, incluindo, mas não se limitando a, qualquer divulgação, cópia, distribuição ou qualquer ação ou omissão, é proibido e sujeitará o agente às penalidades cabíveis. Qualquer opinião que porventura esteja contida nesta mensagem expressa única e exclusivamente a própria opinião do autor e não representa a opinião da empresa.<br></p><div><br></div> This message is intended solely for its addressee and the information contained therein is confidential, and protected by professional privilege or by law. The transmission or disclosure of its contents to third parties other than its addressees is forbidden. Unauthorized use of such information, including, but not limited to, any disclosure, copy, distribution or any action or omission, is prohibited and will subject the agent to the applicable penalties. The opinions that may be contained in this message only and exclusively express the opinion of the author and do not represent the opinion of the company. <p></p> </div> </div>    </div>" > ${TMPDIR}/${ACCOUNT}/assinatura-setada.txt


if [ ! -z "${EMPRESA}" ]; then
# Executa a comparacao das assinaturas. Se a assinatura estiver diferente, deleta a atual e depois atualiza pra nova:
NOME_ASSINATURA_ATUAL=$(grep 'zimbraSignatureName' ${INFO_FILE}|wc -l)
if [ "${NOME_ASSINATURA_ATUAL}" -eq 0 ]; then
        echo -e "Conta sem assinatura\n" 
        atualizaassinatura

else
        COMPARA_ASSINATURA=$(diff ${TMPDIR}/${ACCOUNT}/assinatura-atual.txt ${TMPDIR}/${ACCOUNT}/assinatura-setada.txt|wc -l)
        if [ ${COMPARA_ASSINATURA} -eq 0 ]; then
                echo -e "\nAssinatura atualizada... ignorando update de assinatura."
else
                echo -e "\nAssinatura desatualizada... definindo nova assinatura."
# deleta assinatura
 /opt/zimbra/bin/zmprov dsig ${ACCOUNT} ${NOME_ASSINATURA}
        atualizaassinatura
            fi

fi
else
        echo -e "Empresa ausente... ignorando update de assinatura."
fi

done

# Fim

