# --ignore-table=dbname.tbname
mysqldump -hxxx -uxxx -pxxx hdmpdb  --opt --set-gtid-purged=OFF  --skip-definer --default-character-set=utf8 --single-transaction --hex-blob --max_allowed_packet=824288000  --ignore-table=hdmpdb .circ_000037_dtl_54_v   --ignore-table=hdmpdb .circ_000037_sum_54_v > hdmpdb.sql
