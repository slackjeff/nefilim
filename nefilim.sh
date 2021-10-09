#!/usr/bin/env bash
#============================================================================#
# AUTOR     : Jefferson Carneiro <slackjeff@riseup.net>
# LICENÇA   : GPLv2
# DESCRIÇÃO : Backup para arquivos/diretórios e banco de dados MariaDB
#
# Versão: 1.0
#============================================================================#

#============== BACKUP DE ARQUIVOS ==========================================#
# Esta é a sessão para backup de arquivos! Para ativar o backup de arquivos
# Para desativar esta sessão desligue a chave abaixo para false.
BACKUP_FILES=true

# Selecione os diretorios que deseja fazer backup
# Conforme for adicionando diretorios utilize as aspas simples ou duplas
# para envolver o diretorio.
# É de importância você adicionar o caminho absoluto do diretório. Não
# esqueça de retirar o comentário '#'.
SOURCE_DIRS=(
#    '/caminho/absoluto/aqui'
#    '/caminho/absoluto/aqui'
#    '/caminho/absoluto/aqui'
)

# Caso precise que o nefilim pule alguns diretórios na hora do backup
# adicione o caminho absoluto dos mesmos aqui.
# Exemplo: '--exclude=/home/usuario/Downloads'
# Neste caso o diretório Downloads do usuário não entrará no backup.
EXCLUDE_DIRS=(
#    '--exclude=/caminho/absoluto/do/diretorio/'
#    '--exclude=/caminho/absoluto/do/diretorio/'
#    '--exclude=/caminho/absoluto/do/diretorio/'
)

#============== BACKUP MariaDB ==============================================#
# Esta é a sessão para backup do banco de dados do MariaDB!
# Para desativar esta sessão desligue a chave abaixo para false.
BACKUP_DB=true

# Usuário do banco de dados.
user='MeuUSUARIOaqui'

# Password do banco de dados
password='MinhaSenhaAqui'

#============== Variaveis GLOBAIS ===========================================#

# Automaticamente a cada 'N' dias os backups mais antigos serao apagados.
# Digite um numero inteiro para quantos dias voce deseja manter os backups.
# O padrao e manter os backups por 7 dias.
KEEP_DAY='7'

# Diretorio aonde o backup sera salvo.
BACKUP_DIR='/var/nefilim_backup'

# O log sera registrado aqui
LOG='/var/log/nefilim-mariadb.log'

# Formato de Hora para utilizar no nome do backup.
# O padrao e: (dd-mm-aaaa)
DATE="$(date +%d-%b-%Y)"

#============== TESTES ======================================================#

# Verificando se diretorio para backup existe.
[ ! -d $BACKUP_DIR ] && mkdir $BACKUP_DIR

#============== FUNÇÕES ======================================================#
die() { echo "$@" >>${LOG}; exit 1 ;}

#============== INICIO ======================================================#

# Backup para arquivos
if [ "$BACKUP_FILES" = 'true' ]; then
    tar ${EXCLUDE_DIRS[@]} -cpzf "${BACKUP_DIR}/daily_backup-${DATE}.tar.gz" "${SOURCE_DIRS[@]}" || die "------ $(date +'%d-%m-%Y %T') Backup Diretorios [ERRO]"
    echo "------ $(date +'%d-%m-%Y %T') Backup Diretorios [SUCESSO]" >>${LOG}
fi

# Backup para banco de dados
if [ "$BACKUP_DB" = 'true' ]; then
    sqlfile="mariadb_${DATE}.sql" # Nome temporario quando exportado do DB.
    mysqldump -u "$user" -p"$password" --all-databases > ${BACKUP_DIR}/$sqlfile 2>>${LOG} || die "------ $(date +'%d-%m-%Y %T') Backup database [ERRO]"
    tar cJf "${BACKUP_DIR}/mariadb_${DATE}.tar.xz" ${BACKUP_DIR}/$sqlfile && rm ${BACKUP_DIR}/$sqlfile
    echo "------ $(date +'%d-%m-%Y %T') Backup database [SUCESSO]" >>${LOG}
fi

# Checagem de Backups antigos mais antigos.
# Se existirem serão removidos.
find "$BACKUP_DIR" -mtime "$KEEP_DAY" -delete
