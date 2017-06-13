
restore database LS_PRD_01 from disk = '\\mari012\z$\Bkp_Full\PRD_20101106183617'
with norecovery, stats =1,

select  'move ' + ''''+ name + ''' ' + 'TO ' + '''' + [Filename] + ''','
 from sysfiles 