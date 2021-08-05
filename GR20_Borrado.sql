/*DROP DE LAS TABLAS*/
drop table if exists gr20_grupo cascade;
drop table if exists gr20_gr_comun cascade;
drop table if exists gr20_gr_exclusivo cascade;
drop table if exists gr20_integra cascade;
drop table if exists gr20_usuario cascade;
------------------------------------------------------------------------------------------------------------------------

/*DROP DE LOS TRIGGERS Y LAS FUNCIONES*/
drop trigger if exists tr_gr20_gr20_usuario_userinsert on gr20_usuario;
drop function if exists trfn_gr20_userinsert();

drop trigger if exists tr_gr20_integra_rowinsert on gr20_integra;
drop function if exists trfn_gr20_rowinsert();

drop trigger if exists tr_gr20_integra_rowdelete on gr20_integra;
drop function if exists trfn_gr20_rowdelete();

drop trigger if exists tr_gr20_integra_rowupdate on gr20_integra;
drop function if exists trfn_gr20_rowupdate();

drop trigger if exists tr_gr20_v_grupo_comun_rowinsert on gr20_v_grupo_comun;
drop function if exists trfn_gr20_commongroupviewinsert();

drop trigger if exists tr_gr20_v_grupo_comun_rowdelete on gr20_v_grupo_comun;
drop function if exists trfn_gr20_commongroupviewdelete();

drop trigger if exists tr_gr20_v_grupo_comun_rowupdate on gr20_v_grupo_comun;
drop function if exists trfn_gr20_commongroupviewupdate();

drop trigger if exists tr_gr20_v_grupo_exclusivo_rowinsert on gr20_v_grupo_exclusivo;
drop function if exists trfn_gr20_exclusivegroupviewinsert();

drop trigger if exists tr_gr20_v_grupo_exclusivo_rowdelete on gr20_v_grupo_exclusivo;
drop function if exists trfn_gr20_exclusivegroupviewdelete();

drop trigger if exists tr_gr20_v_grupo_exclusivo_rowupdate on gr20_v_grupo_exclusivo;
drop function if exists trfn_gr20_exclusivegroupviewupdate();
------------------------------------------------------------------------------------------------------------------------

/*DROP DE LAS VISTAS*/
drop view if exists gr20_v_grupo_exclusivo;
drop view if exists gr20_v_grupo_comun;
drop view if exists gr20_v_grupos_comp;
drop view if exists gr20_v_grupos_integ;
