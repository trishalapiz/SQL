/* QUESTION ONE */
DELIMITER &
CREATE PROCEDURE init(IN p INT(11)) 
BEGIN
    DECLARE column_count INT;
    SELECT COUNT(*) INTO column_count FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema = 'stu_tlap632_COMPSCI_351_C_S1_2020' AND table_name = 'PROJECT';
    IF column_count < 5 THEN
        ALTER TABLE PROJECT ADD COLUMN Hours FLOAT;
        UPDATE PROJECT SET Hours = 0.0 WHERE Pnumber = p;
    ELSE
        UPDATE PROJECT
        SET Hours = 0.0 WHERE Pnumber = p;
    END IF; 
END &
call init(1);
call init(10); [AFTER ‘Hours’ IS ADDED INTO ‘PROJECT’]

/* QUESTION TWO */
DELIMITER &
CREATE PROCEDURE stat()
BEGIN
    DECLARE p INT;
    DECLARE pmin INT; 
    DECLARE pmax INT; 
    DECLARE total_hours FLOAT;

    SET pmin = (SELECT MIN(Pnumber) FROM PROJECT); -- smallest project number 
    SET pmax = (SELECT MAX(Pnumber) FROM PROJECT); -- largest project number 
    SET p = pmin; -- starting number
    
    WHILE p <= pmax DO
        -- if p is in PROJECT (doesn't necessarily mean p is worked on)
        IF p IN (SELECT Pnumber FROM PROJECT WHERE EXISTS (SELECT * FROM PROJECT)) THEN
            -- if there are people working on it
            IF p IN (SELECT Pnumber FROM PROJECT WHERE EXISTS (SELECT * FROM WORKS_ON WHERE Pnumber=Pno)) THEN
                SELECT SUM(w.Hours) INTO total_hours FROM PROJECT p INNER JOIN WORKS_ON w ON p.Pnumber = w.Pno WHERE p.Pnumber = p;
                UPDATE PROJECT
                SET Hours = total_hours 
                WHERE Pnumber = p;
                SET p = p + 1;
            -- if p exists but no one’s working on it
            ELSE
                UPDATE PROJECT
                SET Hours = 0.0 
                WHERE Pnumber = p;
                SET p = p + 1; 
            END IF;
        ELSE -- if p isn't in PROJECT 
            SET p = p + 1;
        END IF; 
    END WHILE;
END