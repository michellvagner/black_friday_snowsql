!set quiet=false
!print
!print ==========================================================================================
!print                             INICIANDO EXECUÇÃO DAS QUERIES
!print ==========================================================================================

!print [INFO] Definindo configurações gerais...
!set quiet=true
!source &caminho_queries/query_dcalendario.sql
!source &caminho_queries/query_parametros_data.sql

!set quiet=false
!print [INFO] Exportando alertas fake...
!set quiet=true
!source &caminho_queries/query_alt.sql

!set quiet=false
!print [INFO] Exportando data maxima dos alertas fake...
!set quiet=true
!source &caminho_queries/query_alt_dt_max.sql

!set quiet=false
!print [INFO] Exportando autorizacoes...
!set quiet=true
!source &caminho_queries/query_at.sql

!set quiet=false
!print [INFO] Exportando data maxima das auts fake...
!set quiet=true
!source &caminho_queries/query_at_dt_max.sql

!set quiet=true
!source &caminho_queries/query_expressao_soma.sql
!source &caminho_queries/query_lista_datas.sql

!set quiet=false
!print [INFO] Exportando merchan fake agrupado...
!set quiet=true
!source &caminho_queries/query_merchan_fake_agg.sql

!set quiet=false
!print [INFO] Exportando acq fake agrupado...
!set quiet=true
!source &caminho_queries/query_acq_agg.sql