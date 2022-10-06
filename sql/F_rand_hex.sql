DELIMITER $$

-- 函数：生成随机16进制字符串
-- hex_len：16进制字符串长度
CREATE FUNCTION `rand_hex`(`hex_len` INT) RETURNS VARCHAR(255)
NO SQL -- 申明没有SQL语句，某些数据库配置必须有申明才能成功新增函数
BEGIN
    DECLARE hex_str VARCHAR(255) DEFAULT '';
    -- 考虑到可能需要的长度太大，POW函数承载不了那么大，没办法一次性生成那么长的随机16进制字符串，按每4位生成一次
    WHILE hex_len > 0 DO
        IF hex_len > 4 THEN
            -- 大于4位
            SET hex_str = CONCAT(hex_str, LPAD(HEX(FLOOR(RAND() * POW(16, 4))), 4, '0'));
            SET hex_len = hex_len - 4;
        ELSE
            SET hex_str = CONCAT(hex_str, LPAD(HEX(FLOOR(RAND() * POW(16, hex_len))), hex_len, '0'));
            SET hex_len = 0;
        END IF;
    END WHILE;
  -- 返回生成的随机16进制字符串
  RETURN hex_str;
END $$

DELIMITER ;