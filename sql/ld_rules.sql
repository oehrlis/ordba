----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: ld_rules.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.08.19
--  Usage.....: @ld_rules
--  Purpose...: Displays information about lockdown rules in the current container
--  Notes.....: 
--  Reference.: https://oracle-base.com/dba/script?category=18c&file=lockdown_rules.sql
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
SET LINESIZE 180

COLUMN rule_type FORMAT A20
COLUMN rule FORMAT A20
COLUMN clause FORMAT A20
COLUMN clause_option FORMAT A20
COLUMN pdb_name FORMAT A30

SELECT  lr.rule_type,
        lr.rule,
        lr.status,
        lr.clause,
        lr.clause_option,
        lr.users,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
ORDER BY 1, 2;
-- EOF ---------------------------------------------------------------------