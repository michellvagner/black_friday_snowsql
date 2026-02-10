REMOVE @~;

COPY INTO @~/alt_fake_black_friday_ano_atual.parquet
from (
select
    tb_auth.tenant,
    tb_auth.port,
    tb_auth.typ,
    tb_auth.t_post_at,
    date(tb_auth.date_time) date_time,
    demo_db.public.fx_time(tb_auth.date_time) fx_time,
    tb_auth.c_t_cd,
    substr(trim(tb_auth.usr_dat_4), 5, 3) as cd_coin,
    tb_auth.code,
    left(tb_auth.usr_ind_3, 2) as nump,
    demo_db.public.nump_desc(left(tb_auth.usr_ind_3, 2)) nump_desc,
    tb_auth.tpec,
    substr(tb_auth.usr_ind_7, 1, 1) as type,
    tb_auth.tad,
    tb_auth.tcv_vrf,
    tb_auth.cpr,
    tb_auth.crr,
    tb_auth.prsn,
case
    when trim(substr(tb_auth.usr_dat_4, 8, 3)) = '' and ( tb_auth.prsn in ('00','10','85' ) ) and tb_auth.dec = 'D' and contains(tb_adt.dcx, 'decline') = true then '201'
    when trim(substr(tb_auth.usr_dat_4, 8, 3)) = '' and ( tb_auth.prsn in ('00','10','85' ) ) then '000'
    when trim(substr(tb_auth.usr_dat_4, 8, 3)) = '000' and tb_auth.prsn not in ('00','10','85' ) then '999'
    else trim(substr(tb_auth.usr_dat_4, 8, 3))
end as nrsn,
tb_auth.dec_orig,
tb_auth.dec,
tb_auth.dcx,
tb_auth.arxc,
tb_auth.arr,
tb_auth.usr_dat_2 as wll,
tb_auth.atni,
substr(trim(tb_auth.usr_dat_3), 9, 3) as fac,
tb_auth.usr_ind_6 as ic,
sum(
    case
        when substr(trim(tb_auth.usr_dat_3), 9, 3) in ('211', '212') and tb_auth.atni = 'M' then 1
        when tb_auth.usr_ind_6 in ('1', '2', '5', '6') and tb_auth.atni = 'V' then 1 else 0 end
    ) as tresds,
demo_db.public.fx_score(ext_scor1, atni) fx_score1,
demo_db.public.fx_score(frd_scor, 'F') fx_frd_score,
count(*) as amt,
sum(tb_auth.amt) as amt

from source_horizon.fdw.authorization tb_auth
left join
    (
    select
        import.id,
        import.strg_nm,
        array_to_string(array_sort(array_remove(array_unique_agg(import.dcx), '' ::VARIANT ), false ), ' and ') dcx,
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
and tb_auth.typ <> '0'
and tb_auth.amt > 0

---Filtro das Transações do mes anterior que precede a Black Friday desse ano
---Filtro das Transações do mes anterior que precede a Black Friday desse ano
---Filtro das Transações do mes anterior que precede a Black Friday desse ano

and (
    (
        date(date_time) between ( select inicio_mesmo_periodo_black_mes_passado_black_atual from source_horizon.fdw.tmp_parametrosdt ) and ( select fin_mesmo_periodo_black_mes_passado_black_atual from source_horizon.fdw.tmp_parametrosdt )
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
MAX_FILE_SIZE = 209715200;

GET @~/at_fake_black_friday_ano_atual.parquet 'file://&caminho_saida/';

REMOVE @~;