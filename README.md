# Nefilim
Backup de diretórios e banco de dados.

## Sobre
O Nefilim foi criado para automatizar os meus backups de diretórios e do banco de dados MariaDB. Os backups são salvos localmente no servidor em: /var/nefilim_backup/
Os backups serão rotativos e apagados a cada N dias, o padrão é 7 dias, então você ficará com os últimos 7 dias de backup.

## Cron
Este script foi criado exclusivamente para rodar no cron. Adicione no cron a frequência que o script será executado. 
Exemplo todo dia às 14 horas.
00 14 * * * /diretorio/caminho/nefilim.sh
