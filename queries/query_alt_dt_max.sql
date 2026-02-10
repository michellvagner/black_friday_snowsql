REMOVE @~;

COPY INTO @~/alt_fake_dt_max_black_friday_ano_atual.parquet
FROM (
select
    tb_auth.tenant,
    tb_auth.port,
    max(date_time) as date_time

from source_horizon.fdw.authorization tb_auth
left join
    (
    select
        import.id,
        import.strg_nm,
        array_to_string(array_sort(array_remove(array_unique_agg(import.dc_xcd), '' ::VARIANT ), false ), ' and ') dc_xcd,
        import.tenant,
        import.flg,
        max(import.created_dttm) as max_created_dttm,
        max(import.load_key) as load_key
    from source_horizon.fdw.import as import
    where tenant in ( 'NPC_TENANT', 'LRB_TENANT', 'LCC_TENANT', 'DOP_TENANT', 'APV_TENANT' )
    and import.flg = 0
    and date(import.created_dttm) between ( select data_inicio_criacao_black_atual from source_horizon.fdw.tmp_parametrosdt ) and ( select data_fim_criacao_black_friday_atual from source_horizon.fdw.tmp_parametrosdt )
    group by import.tenant, import.strg_nm, import.id, import.flg
    qualify row_number() over (partition by id order by max(import.created_dttm) asc) = 1

    ) as tb_adt

on tb_auth.id = tb_adt.id

where date(tb_auth.create_dt) between ( select data_inicio_criacao_black_atual from source_horizon.fdw.tmp_parametrosdt ) and ( select data_fim_criacao_black_friday_atual from source_horizon.fdw.tmp_parametrosdt )
and tb_auth.tenant in ( 'NPC_TENANT', 'LRB_TENANT', 'LCC_TENANT', 'DOP_TENANT', 'APV_TENANT' )
and tb_auth.port not in ('11HZ05', 'HZN005', 'HZN007')
and tb_adt.strg_nm is not null

---Filtro das Transações do mes anterior que precede a Black Friday desse ano
---Filtro das Transações do mes anterior que precede a Black Friday desse ano
---Filtro das Transações do mes anterior que precede a Black Friday desse ano

and (
(
    date(date_time) between ( select inicio_mesmo_periodo_black_mes_passado_black_atual from source_horizon.fdw.tmp_parametrosdt ) and ( select fim_mesmo_periodo_black_mes_passado_black_atual from source_horizon.fdw.tmp_parametrosdt )
)
or
(
    date(date_time) between ( select data_inicio_black_friday_atual from source_horizon.fdw.tmp_parametrosdt ) and ( select data_fim_black_friday_atual from source_horizon.fdw.tmp_parametrosdt )
)
)

group by all
)

FILE_FORMAT = (
TYPE = PARQUET
COMPRESSION = SNAPPY
)
OVERWRITE = TRUE
SINGLE = TRUE
MAX_FILE_SIZE = 5242880;

GET @~/alt_fake_dt_max_black_friday_ano_atual.parquet 'file://&caminho_saida/';