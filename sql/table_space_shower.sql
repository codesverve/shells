DELIMITER $$

CREATE PROCEDURE `table_space_show`(IN dbname VARCHAR(64))
BEGIN
    DECLARE dbname VARCHAR(200) DEFAULT DATABASE();
    SELECT `table_name`, (`data_length`/1024/1024) AS data_mb , (`index_length`/1024/1024)   
AS index_mb, ((`data_length`+`index_length`)/1024/1024) AS all_mb, `table_rows`,(`index_length` * 100 /(`index_length` + `data_length`)) AS index_percent
FROM `information_schema`.`tables` WHERE `table_schema` = dbname ORDER BY `index_percent` DESC;
END$$

DELIMITER ;