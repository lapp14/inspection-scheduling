#   App server config
#   NOTE: For security purposes, `config.py` is NOT committed to source control.
#
#   - Rename `_config.py` to `config.py`
#   - Fill out all required connection parameters in `config.py`

DB_SERVER               = ''
DB_DATABASE_NAME        = ''
DB_USER                 = ''
DB_PASS                 = ''
SQL_CONNECTION_STRING   = "DRIVER={{ODBC Driver 13 for SQL Server}}; SERVER={};DATABASE={};UID={};PWD={}".format(DB_SERVER, DB_DATABASE_NAME, DB_USER, DB_PASS)