## Gerar SNOWSQL

# 📊 Gerar Relatório Black Friday - Versão SnowSQL

Esse projeto é uma simulação de um case real de pipeline de dados em snowflake desenvolvido e adaptado para empresa ficticia chamada "Horizon Events" onde todo o script é fake apenas para fins academicos.

O objetivo é gerar relatórios de períodos da Black Friday levando em consideração Black Fridays de qualquer ano a partir de dados armazenados no snowflake e utilizando SnowSQL e SQL Puro, de forma simples, rápida e automatizada.

O case foi pensado para evitar dependência de linguagem python, permitindo que qualquer analista sem conhecimento em SQL e Snowflake consiga executar o projeto apenas rodando o script .bat.

O que esse projeto faz?

Ele olha dois periodos da Black Friday, o do ano atual e o do ano anterior, olhando sempre o mesmo periodo da black friday no mes passado de ambos os periodos, além disso ele olha a data da black friday e sempre avança até o fim do dia da cyber-monday

# 📁 Arquivos na pasta

BLACK_FRIDAY_SNOWSQL.pbix - Arquivo do Power BI - Não vai pro repositório
run.bat - Script para execução automática das queries necessárias

# 👣 Passo a passo para gerar o relatório:

# ❄️ Configurar o SnowSQL

Instale o SnowSQL.
Abra o CMD (Executar -> cmd).
Digite:

    - snowsql --version

Na primeira execução, o SnowSQL fará as configurações iniciais. Ao final, deve aparecer algo como: Version: x.x.xx. Feche o CMD.
No Executar, digite: %USERPROFILE%\.snowsql, abra o arquivo de configuração e edite com o Notepad++.
Você deve procurar pelos campos de accountname que fica tudo como # na frente e isso significa que os campos estão todos como comentário.
Nos campos você pode copiar todos eles e colocar acima e não precisa necessariamente mecher nos campos de baixo, os campos são os seguintes:

    - [connections.snow_conexoes]
    - accountname = horizon
    - region = us-east-1
    - username = seu.email@horizon.user
    - authenticator = externalbrowser
    - dbname = DEMO_DB
    - schemaname = PUBLIC
    - warehousename = HORIZON_2XL_WH
    - rolename = defaultrolename
    - rolename = USER_RL_USER

Note que voce precisa adicionar esse campo acima de tudo: [connections.snow_conexoes]

Após editar essas configurações com as suas, salve e feche o arquivo config
Se quiser testar, abra o cmd novamente e digite o comando snowsql -c snow_conexoes

# ➡️ Executar o script

Execute o arquivo run.bat.
Após a conclusão, pode fechar a janela.

# 🔄 Atualização

Após a atualização, um email será enviado que disparará um evento no power automate para atualizar o relatório
Essa versão utiliza o SNOWSQL como orquestrador das informações da Black Friday, centralizando e armazenando os dados na rede.

    Vídeo tutorial de como realizar instalação e atualização dos dados:
    https://horizon.sharepoint.com/