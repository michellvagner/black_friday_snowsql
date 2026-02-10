set total_dias=(select datediff(day, data_inicio_black_friday_atual, data_fim_black_friday_atual) +1 total_dias from source_horizon.fdw.tmp_parametrosdt)

;;

set expressao_soma = (
with sequencia as
(
select row_number() over (order by 1) as seq
    from table(generator(rowcount => $total_dias))
)
select
    listagg('$' || (3 + seq), '+') within group (order by seq) as resultado_str
    from sequencia )

;;