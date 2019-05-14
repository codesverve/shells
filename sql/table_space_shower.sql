select table_name, (data_length/1024/1024) as data_mb , (index_length/1024/1024)   
as index_mb, ((data_length+index_length)/1024/1024) as all_mb, table_rows,(index_length * 100 /(index_length + data_length)) index_percent
from information_schema.tables where table_schema = 'demo' order by index_percent desc;
