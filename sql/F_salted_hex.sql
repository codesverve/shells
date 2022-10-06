DELIMITER $$

-- 函数：10进制数值转为16进制值，并添加几位随机16进制值
-- num：10进制数值
-- pre_len：从第几位开始添加随机16机制值
-- salt_len：添加随机16进制值个数（间隔添加，隔一位添加一次）
-- 如：按照参数pre_len = 3，salt_len = 3，输入num转为16进制后为0AE3F，添加随机位后值为 _0_A_E3F
CREATE FUNCTION `salted_hex`(`num` INT, `pre_len` INT, `salt_len` INT) RETURNS VARCHAR(255)
NO SQL -- 申明没有SQL语句，某些数据库配置必须有申明才能成功新增函数
BEGIN
    DECLARE raw_str VARCHAR(255) DEFAULT HEX(num);
    DECLARE hex_str VARCHAR(255) DEFAULT '';
    -- 加3个随机盐，加随机盐前至少保留3位原字符
    -- 加盐位置： _C_A_E3F
--    DECLARE salt_len INT DEFAULT 3;
--    DECLARE pre_len INT DEFAULT 3;

    SET pre_len = pre_len - 1;

    IF pre_len > 0 THEN
        IF LENGTH(raw_str) >= pre_len THEN
            SET hex_str = RIGHT(raw_str, pre_len);
            SET raw_str = SUBSTR(raw_str, 1, LENGTH(raw_str) - pre_len);
        ELSE
            SET hex_str = LPAD(raw_str, pre_len, '0');
            SET raw_str = '';
        END IF;
    END IF;

    WHILE salt_len > 0 DO

        IF LENGTH(raw_str) > 0 THEN
            SET hex_str = CONCAT(RIGHT(raw_str, 1), hex_str);
            SET raw_str = SUBSTR(raw_str, 1, LENGTH(raw_str) - 1);
        ELSE
            SET hex_str = CONCAT('0', hex_str);
            SET raw_str = '';
        END IF;

        -- 加随机值
        SET hex_str = CONCAT(RAND_HEX(1), hex_str);

        SET salt_len = salt_len - 1;
    END WHILE;

    SET hex_str = CONCAT(raw_str, hex_str);
  -- 返回加随机盐之后的16进制值
  RETURN hex_str;
END $$

DELIMITER ;