/*
Objetivo:
    Gerar intervalos de datas para análises da Black Friday:
    - Ano atual vs. ano anterior
    - Período da Black Friday (semana que inclui a sexta-feira da Black Friday e vai até a segunda-feira seguinte)
    - Período comparativo (mesma semana do mês anterior, outubro)

Fonte:
    source_horizon.fdw.tmp_calendar_dimension (contém datas da Black Friday por ano)

Lógica:
    1. Identifica a segunda-feira após a Black Friday do ano atual e anterior.
    2. Calcula:
        - Semana da Black Friday (segunda anterior até segunda posterior)
        - Período comparativo (mesma semana do mês anterior)
    3. Ajusta dinamicamente:
        - Se a Black Friday atual ainda não chegou, usa datas do ano anterior.

Principais campos:
    - data_inicio_criacao_black_*: início do período de criação
    - data_fim_criacao_black_*: fim do período de criação
    - inicio_mesmo_periodo_black_mes_passado_*: início do período comparativo
    - fim_mesmo_periodo_black_mes_passado_*: fim do período comparativo
    - data_inicio_black_friday_*: início da semana da Black Friday
    - data_fim_black_friday_*: fim da semana da Black Friday
*/
--- Criar tabela de parametros de data
create or replace temporary table source_horizon.fdw.tmp_parametrosdt as
with datas_black_friday as
(
    select
        next_day(max(case when year = year(current_date()) then date end)-1, 'monday') as bf_esse_ano,
        next_day(dateadd(day, 1, max(case when year = year(current_date()) - 1 then date end))-1, 'monday') as bf_ano_passado
    from source_horizon.fdw.tmp_calendar_dimension
    where day_type = 'Black Friday'
)
,
alt_dt_max_black_friday_ano_atual as
(
    select
        date(max(tb_auth.date_time)) data_ultima_transacao
    from source_horizon.fdw.authorization tb_auth
    where date(tb_auth.create_dt) >= ( select dateadd( day, -5, current_date ) )
    and tb_auth.tenant in ( 'NPC_TENANT', 'LRB_TENANT', 'LCC_TENANT', 'DOP_TENANT', 'APV_TENANT' )
    and tb_auth.port not in ( '11HZ05', 'HZN005', 'HZN007' )
    and tb_auth.typ <> '0'
    and tb_auth.amt > 0
    group by all
)
select
--- O periodo da black friday é a semana da black friday começando na segunda feira passando o dia da black-friday e avançando a data até segunda feira
--- Data parametro de inicio da blackfriday do ano anterior que volta tres dias antes do inicio do periodo da blackfriday, apenas para filtrar as datas melhor

--- Criação
dateadd(day, -3, next_day(dateadd(month, -1, dateadd(day, -7, bf_ano_passado))-1, 'monday')) data_inicio_criacao_black_anterior,
dateadd(day, 10, bf_ano_passado) data_fim_criacao_black_anterior,
--- Mesmo periodo da black friday do ano anterior anterior do mes passado
next_day(dateadd(month, -1, dateadd(day, -7, bf_ano_passado))-1, 'monday') inicio_mesmo_periodo_black_mes_passado_black_anterior,
next_day(dateadd(month, -1, bf_ano_passado)- 1, 'monday') fim_mesmo_periodo_black_mes_passado_black_anterior,
--- Data de inicio e fim Black friday
dateadd(day, -7, bf_ano_passado) data_inicio_black_friday_anterior,
bf_ano_passado data_fim_black_friday_anterior,

-------------------------------------------------------------------------
-------------------------------------------------------------------------

--- Data parametro da blackfriday do ano atual, caso o periodo anterior da semana da black-friday nao tenha chegado ainda, gera a black do ano passado

case
when
    next_day(dateadd(month, -1, dateadd(day, -7, bf_esse_ano))-1, 'monday') <= current_date then
    dateadd(day, -3, next_day(dateadd(month, -1, dateadd(day, -7, bf_esse_ano))-1, 'monday'))
else dateadd(day, -3, next_day(dateadd(month, -1, dateadd(day, -7, bf_ano_passado))-1, 'monday'))
end as data_inicio_criacao_black_atual,

case
when next_day(dateadd(month, -1, dateadd(day, -7, bf_esse_ano))-1, 'monday') <= current_date then dateadd(day, 10, bf_esse_ano)
else dateadd(day, 10, bf_ano_passado)
end as data_fim_criacao_black_friday_atual,

--- Enquanto o inicio da semana que antecede a blackfriday não chega, gera data de inicio criacao do ano anterior
--- Serve para usar de parametro em queries dinamicas
case
when
    dateadd(day, -7, bf_esse_ano) <= current_date then
    dateadd(day, -3, next_day(dateadd(month, -1, dateadd(day, -7, bf_esse_ano))-1, 'monday'))
else dateadd(day, -3, next_day(dateadd(month, -1, dateadd(day, -7, bf_ano_passado))-1, 'monday'))
end as data_inicio_criacao_dinamico,

--- Enquanto o inicio da semana que antecede a blackfriday não chega, gera data de criacao do ano anterior
--- Serve para usar de parametro em queries dinamicas
case
when
    dateadd(day, -7, bf_esse_ano) <= current_date then
    dateadd(day, 10, bf_esse_ano)
else dateadd(day, 10, bf_ano_passado)
end as data_fim_criacao_dinamico,

--- Enquanto o inicio da semana do periodo da black friday do ano atual for maior que a data atual o parametro de data gera o periodo da black friday do ano anterior
case
when
    next_day(dateadd(month, -1, dateadd(day, -7, bf_esse_ano))-1, 'monday') <= current_date then
    next_day(dateadd(month, -1, dateadd(day, -7, bf_esse_ano))-1, 'monday')
else next_day(dateadd(month, -1, dateadd(day, -7, bf_ano_passado))-1, 'monday')
end as inicio_mesmo_periodo_black_mes_passado_black_atual,

--- Enquanto o inicio da semana do periodo da black friday do ano atual for maior que a data atual o parametro de data gera o periodo da black friday do ano anterior
--- Ou seja, se a data de hoje é maior que o inicio da semana do periodo do mes anterior da black significa que volta no periodo do ano passado
case
when
    next_day(dateadd(month, -1, dateadd(day, -7, bf_esse_ano))-1, 'monday') <= current_date then
    next_day(dateadd(month, -1, bf_esse_ano)- 1, 'monday')
else next_day(dateadd(month, -1, bf_ano_passado)- 1, 'monday')
end as fim_mesmo_periodo_black_mes_passado_black_atual,

--- Enquanto o inicio da semana que antecede a blackfriday não chega, gera a black do ano anterior
case
when
    dateadd(day, -7, bf_esse_ano) <= current_date then
    dateadd(day, -7, bf_esse_ano)
else dateadd(day, -7, bf_ano_passado)
end as data_inicio_black_friday_atual,

--- Enquanto o inicio da semana que antecede a blackfriday não chega, gera a black do ano anterior
case
when
    dateadd(day, -7, bf_esse_ano) <= current_date then
    case
        when bf_esse_ano < current_date then bf_esse_ano
        else ( select data_ultima_transacao from alt_dt_max_black_friday_ano_atual )
    end
else bf_ano_passado
end as data_fim_black_friday_atual
from datas_black_friday

;;