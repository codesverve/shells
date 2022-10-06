DELIMITER $$

CREATE FUNCTION `json_parse`(`jsondata` longtext,`keyname` text) RETURNS text CHARSET utf8
BEGIN
	DECLARE delim VARCHAR(128);
	DECLARE	result longtext;
	DECLARE startpos INTEGER;
	DECLARE endpos INTEGER;
	DECLARE endpos1 INTEGER;
    DECLARE findpos INTEGER;
	DECLARE leftbrace INTEGER;
	DECLARE tmp longtext;
    DECLARE tmp2 longtext;
	DECLARE Flag INTEGER;

	SET delim = CONCAT('"', keyname, '":"');
	SET startpos = locate(delim,jsondata);
	IF startpos <= 0 THEN
	    SET delim = CONCAT('"', keyname, '": "');
        SET startpos = locate(delim,jsondata);
	END IF;

	IF startpos > 0 THEN
		SET findpos = startpos+length(delim);
		SET leftbrace = 1;
		SET endpos = 0;
		SET Flag =1;
		get_token_loop:repeat
            IF substr(jsondata,findpos,2)='\\"' THEN
                SET findpos = findpos + 2;
                iterate get_token_loop;
            ELSEIF substr(jsondata,findpos,2)='\\\\' THEN
                SET findpos = findpos + 2;
                iterate get_token_loop;
            ELSEIF substr(jsondata,findpos,1)='"' AND Flag = 1  THEN
                    SET endpos = findpos;
                    SET findpos = LENGTH(jsondata)+1;
                    leave get_token_loop;
            END IF;
            SET findpos = findpos + 1;
        UNTIL findpos > LENGTH(jsondata) END repeat;

        IF endpos > 0 THEN
            SELECT
                substr(
                    jsondata
                    ,startpos
                    +length(delim) -- 取出value值的起始位置
                    ,endpos -- 取出value值的结束位置
                    -(
                        startpos
                        +length(delim)
                        ) -- 减去value值的起始位置，得到value值字符长度
                ) INTO result
            FROM DUAL;
            SET result= replace(result,'\\"','"');
            SET result= replace(result,'\\\\','\\');
        ELSE
            SET result=null;
        END IF;
	ELSE
        SET delim = CONCAT('"', keyname, '":{');
        SET startpos = locate(delim,jsondata);
        IF startpos <= 0 THEN
            SET delim = CONCAT('"', keyname, '": {');
            SET startpos = locate(delim,jsondata);
        END IF;

        IF startpos > 0 THEN
            SET findpos = startpos+length(delim);
            SET leftbrace = 0;
            SET endpos = 0;
            SET Flag =0;

            get_token_loop:repeat
                IF substr(jsondata,findpos,2)='{"' THEN
                    SET leftbrace = leftbrace + 1;
                    SET findpos = findpos + 2;
                    iterate get_token_loop;
                ELSEIF substr(jsondata,findpos,2)='\\"' THEN
                    SET findpos = findpos + 2;
                    iterate get_token_loop;
                ELSEIF substr(jsondata,findpos,3)=':"' THEN
                        SET Flag = 1;
                        SET findpos = findpos + 3;
                        iterate get_token_loop;
                ELSEIF substr(jsondata,findpos,1)='"' THEN
                    SET Flag = 0;
                ELSEIF substr(jsondata,findpos,1)='}' AND Flag = 0  THEN
                    IF leftbrace > 0 THEN
                        SET leftbrace = leftbrace - 1;
                    ELSE
                        SET endpos = findpos;
                        SET findpos = LENGTH(jsondata)+1;
                    END IF;
                END IF;
                SET findpos = findpos + 1;
            UNTIL findpos > LENGTH(jsondata) END repeat;

            IF endpos > 0 THEN
                SELECT
                    substr(
                        jsondata
                        ,startpos
                        +length(delim) -- 取出value值的起始位置
                        ,endpos -- 取出value值的结束位置
                        -(
                            startpos
                            +length(delim)
                            ) -- 减去value值的起始位置，得到value值字符长度
                    ) INTO result
                FROM DUAL;
                SET result=CONCAT("{",result, '}');
            ELSE
                SET result=null;
            END IF;
        ELSE
            SET delim = CONCAT('"', keyname, '":[');
            SET startpos = locate(delim,jsondata);
            IF startpos <= 0 THEN
                SET delim = CONCAT('"', keyname, '": [');
                SET startpos = locate(delim,jsondata);
            END IF;

            IF startpos > 0 THEN
                SET findpos = startpos+length(delim);
                SET leftbrace = 0;
                SET endpos = 0;

                SET tmp = substring_index(jsondata,delim,-1);
                SET tmp2 = substring_index(tmp,']',1);

                IF locate('[',tmp2) =0 THEN
                    SET endpos = locate(']',tmp);
                    SET endpos = endpos+findpos-1;
                ELSE
                    get_token_loop:repeat
                        IF substr(jsondata,findpos,2)='\\"' THEN
                            SET findpos = findpos + 2;
                            iterate get_token_loop;
                        ELSEIF substr(jsondata,findpos,3)=':"' THEN
                                SET Flag = 1;
                                SET findpos = findpos + 3;
                                iterate get_token_loop;
                        ELSEIF substr(jsondata,findpos,1)='[' AND Flag = 0 THEN
                            SET leftbrace = leftbrace + 1;
                            SET findpos = findpos + 1;
                            iterate get_token_loop;
                        ELSEIF substr(jsondata,findpos,1)='"' THEN
                            SET Flag = 0;
                        ELSEIF substr(jsondata,findpos,1)=']' AND Flag = 0  THEN
                            IF leftbrace > 0 THEN
                                SET leftbrace = leftbrace - 1;
                            ELSE
                                SET endpos = findpos;
                                SET findpos = LENGTH(jsondata)+1;
                            END IF;
                        END IF;
                        SET findpos = findpos + 1;
                    UNTIL findpos > LENGTH(jsondata) END repeat;
                END IF;
                IF endpos > 0 THEN
                    SELECT
                        substr(
                            jsondata
                            ,startpos
                            +length(delim) -- 取出value值的起始位置
                            ,endpos -- 取出value值的结束位置
                            -(
                                locate(delim,jsondata)
                                +length(delim)
                                ) -- 减去value值的起始位置，得到value值字符长度
                        ) INTO result
                    FROM DUAL;
                    SET result=CONCAT("[",result, ']');
                ELSE
                    SET result=null;
                END IF;
            ELSE
                SET delim = CONCAT('"', keyname, '":');
                SET startpos = locate(delim,jsondata);
                IF startpos > 0 THEN
                    SET endpos = locate(',',jsondata,startpos+length(delim));
                    SET endpos1 = locate('}',jsondata,startpos+length(delim));
                    IF endpos>0 OR endpos1>0 THEN
                        IF endpos1>0 AND endpos1 < endpos OR endpos =0 THEN
                            SET endpos = endpos1;
                        END IF;
                        SELECT
                            substr(
                                jsondata
                                ,startpos
                                +length(delim) -- 取出value值的起始位置
                                ,endpos -- 取出value值的结束位置
                                -(
                                    locate(delim,jsondata)
                                    +length(delim)
                                    ) -- 减去value值的起始位置，得到value值字符长度
                            ) INTO result
                        FROM DUAL;

                        IF STRCMP(result,'null')=0 THEN
                            SET result=null;
                        END IF;
                    ELSE
                        SET result=null;
                    END IF;
                ELSE
                    SET result=null;
                END IF;
            END IF;
        END IF;
	END IF;
	IF result='' AND RIGHT(keyname,2)='Id' THEN
		SET result=null;
	END IF;
	RETURN result;
END $$

DELIMITER ;