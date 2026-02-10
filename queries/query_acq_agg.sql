create or replace temporary table demo_db.public.cte_group_acq_fake as
    with falcon_auth_acq_fake_id as
    (
    select
        tb_auth.tenant,
        tb_auth.port,
        tb_auth.acq,
        date(tb_auth.date_time) date_time,
        count(*) amt,
        sum(tb_auth.amt) amt
    from source_horizon.fdw.falcon_authorization tb_auth

    where date(tb_auth.create_dt) between ( select data_inicio_criacao_dinamico from source_horizon.fdw.tmp_parametrosdt ) and ( select data_fim_criacao_dinamico from source_horizon.fdw.tmp_parametrosdt )
    and tb_auth.tenant in ( 'NPC_TENANT', 'LRB_TENANT', 'LCC_TENANT', 'DOP_TENANT', 'APV_TENANT' )
    and tb_auth.port not in ( '11HZ05', 'HZN005', 'HZN007' )
    and tb_auth.typ <> '0'
    and tb_auth.amt > 0
    and

    date(tb_auth.date_time) between ( select data_inicio_black_friday_atual from source_horizon.fdw.tmp_parametrosdt ) and ( select data_fim_black_friday_atual from source_horizon.fdw.tmp_parametrosdt )

    group by all
    )
    select
        port,
        tenant,
        date_time,
        acq,
        sum( amt ) amt
        from falcon_auth_acq_fake_id
        group by all
        order by amt desc
;;

REMOVE @~;

set copiar_query =
$$
    COPY INTO @~/at_fake_agrupado_por_acq_fake.parquet
    FROM
$$

;;

set query_pivotada =
$$
(
select top 5000 *, $$ || $expressao_soma || $$ as total
    from demo_db.public.cte_group_acq_fake
    PIVOT( SUM( amt ) FOR date_time IN (ANY ORDER BY date_time) DEFAULT ON NULL (0) )
    order by total desc
)
$$

;;

set copiar_parametros =
$$
    FILE_FORMAT = (
    TYPE = PARQUET
    COMPRESSION = SNAPPY
    )
    OVERWRITE = TRUE
    SINGLE = TRUE
    MAX_FILE_SIZE = 52428800;
$$

;;

EXECUTE IMMEDIATE
$$
DECLARE
    dynamic_sql VARCHAR;
BEGIN
    dynamic_sql := CONCAT($copiar_query, $query_pivotada, $copiar_parametros);
    EXECUTE IMMEDIATE :dynamic_sql;
END;
$$

;;

GET @~/at_fake_agrupado_por_acq_fake.parquet 'file://&caminho_saida/';

REMOVE @~;