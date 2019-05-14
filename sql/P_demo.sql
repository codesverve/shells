
# 借助存储过程将发行计划的旧数据更新为取默认值的新数据
DELIMITER $$
CREATE PROCEDURE `add_default_type_reason`()
BEGIN
    DECLARE vid BIGINT(20);
    DECLARE count INT;
	DECLARE plan_time DATE;
	DECLARE state VARCHAR(64);
	DECLARE cuid VARCHAR(64);
    DECLARE vids cursor FOR SELECT id,plan_release_time,state,create_uid FROM t_versions;
    SELECT count(id) INTO count FROM t_versions;
    OPEN vids;
    loop_i:LOOP
		IF count = 0
        THEN
        LEAVE loop_i;
        END IF;
        FETCH vids INTO vid,plan_time,state,cuid;
        INSERT INTO `t_versions_type`(`vid`,`type`) VALUES(vid,'pending');
        INSERT INTO `t_versions_release_reason`(`vid`,`reason`) VALUES(vid,'pending');
		UPDATE `t_versions` SET `plan_test_time`=plan_time,`owner_uid`=cuid where `id`=vid;
        SET count = count - 1;
	END LOOP;
    CLOSE vids;
END
$$
DELIMITER ;
CALL add_default_type_reason();
DROP PROCEDURE `add_default_type_reason`;
