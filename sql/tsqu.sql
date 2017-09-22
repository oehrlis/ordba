----------------------------------------------------------------------------
--     $Id: $
----------------------------------------------------------------------------
--     Trivadis AG, Infrastructure Managed Services
--     Europa-Strasse 5, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--     File-Name........:  tsqu.sql
--     Author...........:  Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--     Editor...........:  $LastChangedBy:   $
--     Date.............:  $LastChangedDate: $
--     Revision.........:  $LastChangedRevision: $
--     Purpose..........:  List user with unlimited quota on one or any 
--                         tablespace. Query is doing a like &1		 
--     Usage............:  @tsqu <USERNAME> or % for all
--     Group/Privileges.:  SYS (or grant manually to a DBA)
--     Input parameters.:  Username or part of a username
--     Called by........:  as DBA or user with access to dba_ts_quotas
--                         dba_sys_privs,dba_role_privs,dba_users
--     Restrictions.....:  unknown
--     Notes............:  --
----------------------------------------------------------------------------
--     Revision history.:  
----------------------------------------------------------------------------
col tsqu_username head "User Name" for a30
col tsqu_tablespace_name head "Tablespace Name" for a30
col tsqu_privilege head "Privilege" for a25

SET VERIFY OFF
SET TERMOUT OFF

column 1 new_value 1
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
define username = '&1'

SET TERMOUT ON

SELECT 
  username tsqu_username,
  tablespace_name tsqu_tablespace_name,
  privilege tsqu_privilege
FROM (
  SELECT 
    grantee username, 'Any Tablespace' tablespace_name, privilege
  FROM (
    -- first get the users with direct grants
    SELECT 
      p1.grantee grantee, privilege
    FROM 
      dba_sys_privs p1
    WHERE 
      p1.privilege='UNLIMITED TABLESPACE'
    UNION ALL
    -- and then the ones with UNLIMITED TABLESPACE through a role...
    SELECT 
      r3.grantee, granted_role privilege
    FROM 
      dba_role_privs r3
      START WITH r3.granted_role IN (
          SELECT 
            DISTINCT p4.grantee 
          FROM 
            dba_role_privs r4, dba_sys_privs p4 
          WHERE 
            r4.granted_role=p4.grantee AND p4.privilege = 'UNLIMITED TABLESPACE')
    CONNECT BY PRIOR grantee = granted_role)
    -- we just whant to see the users not the roles
  WHERE grantee IN (SELECT username FROM dba_users) OR grantee = 'PUBLIC'
  UNION ALL 
  -- list the user with unimited quota on a dedicated tablespace
  SELECT 
    username,tablespace_name,'DBA_TS_QUOTA' privilege 
  FROM 
    dba_ts_quotas 
  WHERE 
    max_bytes <0)
WHERE username LIKE UPPER('%&username%')
ORDER BY tsqu_username,tsqu_tablespace_name,tsqu_privilege;

SET HEAD OFF
select 'Filter on user name => '||NVL('&username','%') from dual;    
SET HEAD ON
undefine 1