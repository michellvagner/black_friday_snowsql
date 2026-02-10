REMOVE @~;

COPY INTO @~/lista_datas_black_friday.parquet
FROM
(
    select 'PORT' as nomes_colunas
    union all
    select 'TENANT' as nomes_colunas
    union all
    select 'MID' as nomes_colunas
    union all
    select to_varchar(dateadd(day, seq4(), ( select data_inicio_black_friday_atual from source_horizon.fdw.tmp_parametrosdt ) ), 'yyyy-mm-dd' ) as nomes_colunas
        from table(generator(rowcount => $total_dias))
    union all
    select 'TOTAL' as nomes_colunas
)

FILE_FORMAT = (
TYPE = PARQUET
COMPRESSION = SNAPPY
)
OVERWRITE = TRUE
SINGLE = TRUE
MAX_FILE_SIZE = 52428800;

GET @~/lista_datas_black_friday.parquet 'file://&caminho_saida/';