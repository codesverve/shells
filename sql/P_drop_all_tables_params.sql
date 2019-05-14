delimiter $$
CREATE PROCEDURE `drop_all_tables`(IN dbname VARCHAR(64))
BEGIN
    DECLARE count INT;
	DECLARE tb VARCHAR(200);
    DECLARE tbnames cursor FOR SELECT CONCAT('DROP TABLE `',dbname,'`.`',table_name,'`') FROM information_schema.tables WHERE table_schema = dbname;
    SELECT count(*) INTO count FROM information_schema.tables WHERE table_schema = dbname;
    OPEN tbnames;
    loop_i:LOOP
		IF count = 0 THEN 
			LEAVE loop_i;
		END IF;
        FETCH tbnames INTO tb;
        SET @tb = tb;
        PREPARE stmt FROM @tb;  
        EXECUTE stmt;  
        DEALLOCATE PREPARE stmt;
        SET count = count - 1;
	END LOOP;
    CLOSE tbnames;
END$$
delimiter ;

