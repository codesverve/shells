DELIMITER $$
CREATE PROCEDURE `tables_info`(IN order_field_index INTEGER)
    BEGIN
    DECLARE _order_field VARCHAR(200) DEFAULT 'all_mb';
        DECLARE _dbname VARCHAR(200) DEFAULT DATABASE();
    IF order_field_index = 1 THEN
        SET _order_field = 'table_name';
    ELSEIF order_field_index = 2 THEN
        SET _order_field = 'all_mb';
    ELSEIF order_field_index = 3 THEN
        SET _order_field = 'data_mb';
    ELSEIF order_field_index = 4 THEN
        SET _order_field = 'index_mb';
    ELSEIF order_field_index = 5 THEN
        SET _order_field = 'table_rows';
    ELSEIF order_field_index = 6 THEN
        SET _order_field = 'index_percent';
    END IF;
    
		SELECT `table_name`, ((`data_length`+`index_length`)/1024/1024) AS all_mb, (`data_length`/1024/1024) AS data_mb , (`index_length`/1024/1024) AS index_mb, `table_rows`,(`index_length` * 100 /(`index_length` + `data_length`)) AS index_percent FROM `information_schema`.`tables` WHERE `table_schema` = _dbname ORDER BY _order_field DESC;
    
END$$
DELIMITER ;