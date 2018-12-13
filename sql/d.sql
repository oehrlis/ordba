----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: d.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2018.12.11
--  Revision..:  
--  Purpose...: search an object in DICT
--  Notes.....:  
--  Reference.: Idea based on a script from tanel@tanelpoder.com
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
COLUMN d_table_name HEADING TABLE_NAME FORMAT A30 
COLUMN d_comments HEADING COMMENTS FORMAT A80 word_wrap
BREAK ON d_table_name

SELECT d.table_name d_table_name, d.comments d_comments
	FROM dict d
	WHERE upper(d.table_name) LIKE upper('%&1%')
UNION ALL
SELECT t.table_name d_table_name, 'BASE TABLE' d_comments
	FROM dba_tables t
	WHERE t.owner = 'SYS'
	AND upper(t.table_name) LIKE upper('%&1%');

SELECT ft.name d_table_name, (SELECT fvd.view_name 
			FROM v$fixed_view_definition fvd 
			where instr(upper(fvd.view_definition),upper(ft.name)) > 0
			AND ROWNUM = 1) comments
	FROM v$fixed_table ft
	WHERE ft.type = 'TABLE'
	AND upper(ft.name) LIKE upper('%&1%');
-- EOF ---------------------------------------------------------------------