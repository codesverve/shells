-- 创建函数执行
-- 两个逗号分割的字符串取交集

DELIMITER $$

CREATE FUNCTION `has_intersection`(`array1_str` varchar(255), `array_str2` varchar(255)) RETURNS int(1)
NO SQL -- 申明没有SQL语句，某些数据库配置必须有申明才能成功新增函数
BEGIN
    -- 判断存在交集
    DECLARE array1_element_num INT DEFAULT 0 ; -- 数组字符串1元素字符串数量
    DECLARE array1_str_full_len INT DEFAULT 0; -- 数组字符串1字符串总长度
    DECLARE array1_str_consumed_len INT DEFAULT 0; -- 数组字符串1已消费字符串长度
    DECLARE array1_current_consume_len INT DEFAULT 0; -- 数组字符串1正在消费的字符串长度
    DECLARE array1_current_consume_str varchar(255);-- 数组字符串1正在消费的字符串数据
    DECLARE array1_current_element_str varchar(255);-- 数组字符串1正在检查的成员/元素字符串
    SET array1_str_full_len = CHAR_LENGTH(array1_str);
    WHILE array1_element_num < array1_str_full_len DO
        SET array1_element_num = array1_element_num + 1; -- 自增1
        SET array1_current_consume_str = SUBSTRING_INDEX(array1_str, ",", array1_element_num); -- 根据要消费的元素数量上限获取当前要消费的完整字符串
        -- 记录当前消费的长度
        SET array1_current_consume_len = CHAR_LENGTH(array1_current_consume_str);

        -- 按照当前元素数量上限找到的消费字符串长度与上次找到的消费字符串长度一样长
        IF array1_current_consume_len <= array1_str_consumed_len THEN
            -- 找不到新的按逗号分割后的元素字符串了，说明array1_str字符串已消费完
            RETURN 0;
        END IF;

        -- 从要消费的完整字符串中获取用于检查的元素字符串，即获取最后一个逗号之后的字符串
        IF array1_element_num = 1 THEN
            -- 如果是第一个消费
            SET array1_current_element_str = array1_current_consume_str;
        ELSE
            -- substring 序号从1开始，再加上逗号，所以开始位置要加2；截取长度需要扣掉逗号
            SET array1_current_element_str = SUBSTRING(array1_str, array1_str_consumed_len + 2, array1_current_consume_len - array1_str_consumed_len - 1);
        END IF;
        -- 调用FIND_IN_SET检查当前元素字符串
        IF array1_current_element_str != '' AND FIND_IN_SET(array1_current_element_str,array_str2) > 0 THEN
            -- 匹配到了，存在交集，返回
            RETURN 1;
        END IF;

        SET array1_str_consumed_len = array1_current_consume_len;
    END WHILE;
    RETURN 0;
END $$

DELIMITER ;