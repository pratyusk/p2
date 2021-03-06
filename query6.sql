--SELECT U1.USER_ID, U1.FIRST_NAME, U1.LAST_NAME, U2.USER_ID, U2.FIRST_NAME, U2.LAST_NAME FROM UsersDummy U1, UsersDummy U2, CheckLoney F1, CheckLoney F2 
--WHERE (F1.USER1_ID = U1.USER_ID) AND (F2.USER2_ID = U2.USER_ID) AND F1.USER2_ID IN (((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 9) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 9)) INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 491) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 491))) AND F2.USER1_ID IN (((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 9) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 9)) INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 491) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 491))) AND U1.USER_ID < U2.USER_ID;

-- WITH 
--   NF AS 
--   (SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM UsersDummy U1, UsersDummy U2 
--     WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID)) 
--     AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID))), 
--   MF AS
--   (((SELECT F.USER2_ID AS MF_ID FROM CheckLoney F, NF WHERE F.USER1_ID = NF.U1_ID) UNION (SELECT F.USER1_ID AS MF_ID FROM CheckLoney F, NF WHERE F.USER2_ID = NF.U1_ID)) INTERSECT ((SELECT F.USER2_ID AS MF_ID FROM CheckLoney F, NF WHERE F.USER1_ID = NF.U2_ID) UNION (SELECT F.USER1_ID AS MF_ID FROM CheckLoney F, NF WHERE F.USER2_ID = NF.U2_ID))) SELECT * FROM MF;


-- SELECT ((SELECT F.USER2_ID AS MF_ID FROM CheckLoney F JOIN UsersDummy U1 ON F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID AS MF_ID FROM CheckLoney F JOIN UsersDummy U1 ON F.USER2_ID = U1.USER_ID)) INTERSECT ((SELECT F.USER2_ID AS MF_ID FROM CheckLoney F JOIN UsersDummy U1 ON F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID AS MF_ID FROM CheckLoney F, NF WHERE F.USER2_ID = NF.U2_ID))) SELECT * FROM MF;

-- SELECT MUTUAL_FRIENDS.M1, U1.FIRST_NAME FROM (((SELECT COUNT(*) AS MUTUAL_COUNT, MUTUAL_FRIEND.M1_ID AS M1, MUTUAL_FRIEND.M2_ID AS M2 FROM ((SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER1_ID = FR2.USER1_ID AND FR1.USER2_ID <> FR2.USER2_ID)) 
--   UNION ALL (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER1_ID AND FR1.USER1_ID <> FR2.USER2_ID)) 
--   UNION ALL (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER2_ID AND FR1.USER1_ID <> FR2.USER1_ID)) ORDER BY M3_ID) MUTUAL_FRIEND GROUP BY MUTUAL_FRIEND.M1_ID, MUTUAL_FRIEND.M2_ID ORDER BY MUTUAL_COUNT DESC) MUTUAL_FRIENDS))
--   FULL OUTER JOIN
-- (((SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER1_ID = FR2.USER1_ID AND FR1.USER2_ID <> FR2.USER2_ID)) UNION ALL (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER1_ID AND FR1.USER1_ID <> FR2.USER2_ID)) UNION ALL (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER2_ID AND FR1.USER1_ID <> FR2.USER1_ID)) ORDER BY M3_ID) MUTUAL_FRIEND1) ON (MUTUAL_FRIEND1.M1_ID = MUTUAL_FRIENDS.M1 AND MUTUAL_FRIEND1.M2_ID = MUTUAL_FRIENDS.M2)
-- FULL OUTER JOIN UsersDummy U1 ON (U1.USER_ID = MUTUAL_FRIENDS.M1) 
-- FULL OUTER JOIN UsersDummy U2 ON (U2.USER_ID = MUTUAL_FRIENDS.M2) 
-- FULL OUTER JOIN UsersDummy U3 ON (U3.USER_ID = MUTUAL_FRIEND1.M3_ID) 
-- WHERE MUTUAL_FRIENDS.M1 < MUTUAL_FRIENDS.M2 AND MUTUAL_FRIENDS.M1 NOT IN (SELECT FR.USER1_ID FROM CheckLoney FR WHERE (MUTUAL_FRIENDS.M1 = FR.USER1_ID AND MUTUAL_FRIENDS.M2 = FR.USER2_ID AND ROWNUM <= 5)) ORDER BY MUTUAL_COUNT, MUTUAL_FRIENDS.M1, MUTUAL_FRIENDS.M2, MUTUAL_FRIEND1.M3_ID;



-- (WITH MUTUAL_FRIEND1 AS ((SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER1_ID = FR2.USER1_ID AND FR1.USER2_ID <> FR2.USER2_ID)) UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER1_ID AND FR1.USER1_ID <> FR2.USER2_ID)) UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER2_ID AND FR1.USER1_ID <> FR2.USER1_ID)) ORDER BY M3_ID) SELECT * FROM MUTUAL_FRIEND1)




-- WITH MUTUAL_FRIENDS AS (SELECT COUNT(*) AS MUTUAL_COUNT, MUTUAL_FRIEND.M1_ID AS M1, MUTUAL_FRIEND.M2_ID AS M2 FROM 
--  ((SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER1_ID = FR2.USER1_ID AND FR1.USER2_ID <> FR2.USER2_ID)) 
--   UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER1_ID AND FR1.USER1_ID <> FR2.USER2_ID)) 
--   UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER2_ID AND FR1.USER1_ID <> FR2.USER1_ID)) ORDER BY M3_ID) MUTUAL_FRIEND GROUP BY MUTUAL_FRIEND.M1_ID, MUTUAL_FRIEND.M2_ID ORDER BY MUTUAL_COUNT DESC) MUTUAL_FRIENDS;
-- OUTER JOIN 
-- ((SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER1_ID = FR2.USER1_ID AND FR1.USER2_ID <> FR2.USER2_ID)) UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER1_ID AND FR1.USER1_ID <> FR2.USER2_ID)) UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER2_ID AND FR1.USER1_ID <> FR2.USER1_ID)) ORDER BY M3_ID) MUTUAL_FRIEND1 ON (MUTUAL_FRIEND1.M1_ID = MUTUAL_FRIENDS.M1 AND MUTUAL_FRIEND1.M2_ID = MUTUAL_FRIENDS.M2) 
-- OUTER JOIN UsersDummy U1 ON (U1.USER_ID = MUTUAL_FRIENDS.M1) 
-- OUTER JOIN UsersDummy U2 ON (U2.USER_ID = MUTUAL_FRIENDS.M2) 
-- OUTER JOIN UsersDummy U3 ON (U3.USER_ID = MUTUAL_FRIEND1.M3_ID) 
-- WHERE MUTUAL_FRIENDS.M1 < MUTUAL_FRIENDS.M2 AND MUTUAL_FRIENDS.M1 NOT IN (SELECT FR.USER1_ID FROM CheckLoney FR WHERE (MUTUAL_FRIENDS.M1 = FR.USER1_ID AND MUTUAL_FRIENDS.M2 = FR.USER2_ID)) ORDER BY MUTUAL_COUNT, MUTUAL_FRIENDS.M1, MUTUAL_FRIENDS.M2, MUTUAL_FRIEND1.M3_ID);













-- WITH MUTUAL_FRIEND AS ((SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER1_ID = FR2.USER1_ID AND FR1.USER2_ID <> FR2.USER2_ID)) 
--   UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER1_ID AND FR1.USER1_ID <> FR2.USER2_ID)) 
--   UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER2_ID AND FR1.USER1_ID <> FR2.USER1_ID)) ORDER BY M3_ID),
-- MUTUAL_FRIENDS AS (SELECT COUNT(*) AS MUTUAL_COUNT, MUTUAL_FRIEND.M1_ID AS M1, MUTUAL_FRIEND.M2_ID AS M2 FROM MUTUAL_FRIEND GROUP BY MUTUAL_FRIEND.M1_ID, MUTUAL_FRIEND.M2_ID ORDER BY MUTUAL_COUNT DESC) SELECT * FROM MUTUAL_FRIENDS OUTER JOIN
-- ((SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER1_ID = FR2.USER1_ID AND FR1.USER2_ID <> FR2.USER2_ID)) UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER1_ID AND FR1.USER1_ID <> FR2.USER2_ID)) UNION (SELECT FR1.USER1_ID AS M1_ID, FR1.USER2_ID AS M2_ID, FR2.USER2_ID AS M3_ID FROM CheckLoney FR1, CheckLoney FR2 WHERE (FR1.USER2_ID = FR2.USER2_ID AND FR1.USER1_ID <> FR2.USER1_ID)) ORDER BY M3_ID) MUTUAL_FRIEND1 ON (MUTUAL_FRIEND1.M1_ID = M1 AND MUTUAL_FRIEND1.M2_ID = M2)
-- OUTER JOIN UsersDummy U1 ON (U1.USER_ID = M1) 
-- OUTER JOIN UsersDummy U2 ON (U2.USER_ID = M2) 
-- OUTER JOIN UsersDummy U3 ON (U3.USER_ID = MUTUAL_FRIEND1.M3_ID) 
-- WHERE M1 <M2 AND M1 NOT IN (SELECT FR.USER1_ID FROM CheckLoney FR WHERE (M1 = FR.USER1_ID AND M2 = FR.USER2_ID)) ORDER BY MUTUAL_COUNT, M1, M2, MUTUAL_FRIEND1.M3_ID);











-- SELECT FINAL.MF1_ID, FINAL.MF2_ID FROM 
-- (SELECT MUTUAL_FRIENDS.MFU1_ID AS MF1_ID, MUTUAL_FRIENDS.MFU1_FN AS MF1_FN, MUTUAL_FRIENDS.MFU1_LN AS MF1_LN, MUTUAL_FRIENDS.MFU2_ID AS MF2_ID, MUTUAL_FRIENDS.MFU2_FN AS MF2_FN, MUTUAL_FRIENDS.MFU2_LN AS MF2_LN FROM UsersDummy U, CheckLoney F1, CheckLoney F2, ((SELECT U1.USER_ID AS MFU1_ID, U1.FIRST_NAME AS MFU1_FN, U1.LAST_NAME AS MFU1_LN, U2.USER_ID AS MFU2_ID, U2.FIRST_NAME AS MFU2_FN, U2.LAST_NAME AS MFU2_LN, COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U1, UsersDummy U2, UsersDummy U3, CheckLoney F1, CheckLoney F2,
--  ((SELECT U1.USER_ID AS NFU1_ID, U2.USER_ID AS NFU2_ID FROM UsersDummy U1, UsersDummy U2 WHERE U1.USER_ID < U2.USER_ID AND NOT EXISTS (SELECT * FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID AND F.USER2_ID = U2.USER_ID)) NOT_FRIENDS) 
--  WHERE U1.USER_ID = NOT_FRIENDS.NFU1_ID AND U2.USER_ID = NOT_FRIENDS.NFU2_ID AND ((F1.USER1_ID = U1.USER_ID AND F1.USER2_ID = U3.USER_ID)) AND ((F2.USER1_ID = U2.USER_ID AND F2.USER2_ID = U3.USER_ID)) GROUP BY U1.USER_ID, U1.FIRST_NAME, U1.LAST_NAME, U2.USER_ID, U2.FIRST_NAME, U2.LAST_NAME) MUTUAL_FRIENDS)
--   WHERE ((F1.USER1_ID = U.USER_ID AND F1.USER2_ID = MUTUAL_FRIENDS.MFU1_ID) OR (F1.USER1_ID = MUTUAL_FRIENDS.MFU1_ID AND F1.USER2_ID = U.USER_ID)) AND ((F2.USER1_ID = U.USER_ID AND F2.USER2_ID = MUTUAL_FRIENDS.MFU2_ID) OR (F2.USER1_ID = MUTUAL_FRIENDS.MFU2_ID AND F2.USER2_ID = U.USER_ID)) ORDER BY MUTUAL_FRIENDS.MUTUAL_COUNT DESC, MUTUAL_FRIENDS.MFU1_ID, MUTUAL_FRIENDS.MFU2_ID) FINAL
--  WHERE ROWNUM <= 1;





-- SELECT * FROM 
-- (SELECT MUTUAL_FRIENDS.MFU1_ID, MUTUAL_FRIENDS.MFU1_FN, MUTUAL_FRIENDS.MFU1_LN, MUTUAL_FRIENDS.MFU2_ID, MUTUAL_FRIENDS.MFU2_FN, MUTUAL_FRIENDS.MFU2_LN FROM UsersDummy U, CheckLoney F1, CheckLoney F2, ((SELECT U1.USER_ID AS MFU1_ID, U1.FIRST_NAME AS MFU1_FN, U1.LAST_NAME AS MFU1_LN, U2.USER_ID AS MFU2_ID, U2.FIRST_NAME AS MFU2_FN, U2.LAST_NAME AS MFU2_LN, COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U1, UsersDummy U2, UsersDummy U3, CheckLoney F1, CheckLoney F2,
 -- ((SELECT U1.USER_ID AS NFU1_ID, U2.USER_ID AS NFU2_ID FROM UsersDummy U1, UsersDummy U2 WHERE U1.USER_ID < U2.USER_ID AND NOT EXISTS (SELECT * FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID AND F.USER2_ID = U2.USER_ID)) NOT_FRIENDS) 
 -- WHERE U1.USER_ID = NOT_FRIENDS.NFU1_ID AND U2.USER_ID = NOT_FRIENDS.NFU2_ID AND ((F1.USER1_ID = U1.USER_ID AND F1.USER2_ID = U3.USER_ID) OR (F1.USER1_ID = U3.USER_ID AND F1.USER2_ID = U1.USER_ID)) AND ((F2.USER1_ID = U2.USER_ID AND F2.USER2_ID = U3.USER_ID) OR (F2.USER1_ID = U3.USER_ID AND F2.USER2_ID = U2.USER_ID)) GROUP BY U1.USER_ID, U1.FIRST_NAME, U1.LAST_NAME, U2.USER_ID, U2.FIRST_NAME, U2.LAST_NAME) MUTUAL_FRIENDS)
  -- WHERE ((F1.USER1_ID = U.USER_ID AND F1.USER2_ID = MUTUAL_FRIENDS.MFU1_ID) OR (F1.USER1_ID = MUTUAL_FRIENDS.MFU1_ID AND F1.USER2_ID = U.USER_ID)) AND ((F2.USER1_ID = U.USER_ID AND F2.USER2_ID = MUTUAL_FRIENDS.MFU2_ID) OR (F2.USER1_ID = MUTUAL_FRIENDS.MFU2_ID AND F2.USER2_ID = U.USER_ID)) ORDER BY MUTUAL_FRIENDS.MUTUAL_COUNT, MUTUAL_FRIENDS.MFU1_ID, MUTUAL_FRIENDS.MFU2_ID)
--  WHERE ROWNUM <= 5;




-- SELECT U1, MUTUAL_COUNT FROM 
-- (SELECT U.USER_ID AS U1, U.FIRST_NAME, U.LAST_NAME, COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U, CheckLoney F
-- WHERE ((U.USER_ID = F.USER1_ID) OR (U.USER_ID = F.USER2_ID)) 
-- AND F.USER1_ID IN (((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 9) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 9)) INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 491) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 491)))) MUTUAL_FRIENDS
-- WHERE ROWNUM <= 15;

-- U1.USER_ID < U2.USER_ID
-- (F.USER1_ID = U1.USER_ID) AND (F.USER2_ID = U2.USER_ID) AND 



-- SELECT MUTUAL_FRIEND FROM
-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID, U3.USER_ID AS U3_ID FROM UsersDummy U1, UsersDummy U2, UsersDummy U3 WHERE U1.USER_ID < U2.USER_ID AND U1.USER_ID = 9 AND U2.USER_ID = 491 AND U3.USER_ID IN
-- (SELECT U.USER_ID AS MF_ID FROM UsersDummy U
-- WHERE U.USER_ID IN (((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID AND F.USER2_ID <> U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID AND F.USER1_ID <> U2.USER_ID)) INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID AND F.USER2_ID <> U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID AND F.USER1_ID <> U1.USER_ID)))) ORDER BY U3.USER_ID; 

-- SELECT MUTUAL_COUNT FROM
-- (SELECT COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U
-- WHERE U.USER_ID IN (((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 9) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 9)) INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 491) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 491))) OR U.USER_ID IN (((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 9) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 9)) INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = 491) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = 491))));





-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID, U3.USER_ID AS U3_ID FROM UsersDummy U1, UsersDummy U2, UsersDummy U3 JOIN ((((SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER2_ID) WHERE F.USER1_ID = U1.USER_ID AND F.USER2_ID <> U2.USER_ID)
--  UNION (SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER1_ID) WHERE F.USER2_ID = U1.USER_ID AND F.USER1_ID <> U2.USER_ID)) 
-- INTERSECT ((SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER2_ID) WHERE F.USER1_ID = U2.USER_ID AND F.USER2_ID <> U1.USER_ID)
--  UNION (SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER1_ID) WHERE F.USER2_ID = U2.USER_ID AND F.USER1_ID <> U1.USER_ID))) MUTUAL_FRIENDS) ON U3.USER_ID = MUTUAL_FRIENDS.MF_ID WHERE U1.USER_ID < U2.USER_ID AND U1.USER_ID = 9 AND U2.USER_ID = 491 ORDER BY U3.USER_ID;




-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID, U3.USER_ID AS U3_ID, COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U1, UsersDummy U2, UsersDummy U3 WHERE U3.USER_ID IN 
-- (((SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER2_ID) WHERE F.USER1_ID = U1.USER_ID AND F.USER2_ID <> U2.USER_ID)
--  UNION (SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER1_ID) WHERE F.USER2_ID = U1.USER_ID AND F.USER1_ID <> U2.USER_ID)) 
-- INTERSECT ((SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER2_ID) WHERE F.USER1_ID = U2.USER_ID AND F.USER2_ID <> U1.USER_ID)
--  UNION (SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER1_ID) WHERE F.USER2_ID = U2.USER_ID AND F.USER1_ID <> U1.USER_ID))) 
-- AND U1.USER_ID < U2.USER_ID GROUP BY U1.USER_ID, U2.USER_ID, U3.USER_ID ORDER BY MUTUAL_COUNT DESC, U1.USER_ID, U2.USER_ID;


-- SELECT COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U1, UsersDummy U2, UsersDummy U3 WHERE U3.USER_ID IN 
-- (((SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER2_ID) WHERE F.USER1_ID = U1.USER_ID AND F.USER2_ID <> U2.USER_ID)
--  UNION (SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER1_ID) WHERE F.USER2_ID = U1.USER_ID AND F.USER1_ID <> U2.USER_ID)) 
-- INTERSECT ((SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER2_ID) WHERE F.USER1_ID = U2.USER_ID AND F.USER2_ID <> U1.USER_ID)
--  UNION (SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER1_ID) WHERE F.USER2_ID = U2.USER_ID AND F.USER1_ID <> U1.USER_ID))) 
-- AND U1.USER_ID < U2.USER_ID ORDER BY MUTUAL_COUNT DESC;

-- CREATE OR REPLACE VIEW NOT_FRIENDS AS 
-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM UsersDummy U1, UsersDummy U2 
-- WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID)) 
-- AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID));

-- SELECT COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U3, NOT_FRIENDS NF WHERE U3.USER_ID IN 
-- (((SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER2_ID) WHERE F.USER1_ID = NF.U1_ID)
--  UNION (SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER1_ID) WHERE F.USER2_ID = NF.U1_ID)) 
-- INTERSECT ((SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER2_ID) WHERE F.USER1_ID = NF.U2_ID)
--  UNION (SELECT U.USER_ID AS MF_ID FROM UsersDummy U JOIN CheckLoney F ON (U.USER_ID = F.USER1_ID) WHERE F.USER2_ID = NF.U2_ID))) 
-- GROUP BY NF.U1_ID, NF.U2_ID ORDER BY MUTUAL_COUNT DESC;

-- DROP VIEW NOT_FRIENDS;




-- CREATE OR REPLACE VIEW NOT_FRIENDS AS 
-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM UsersDummy U1, UsersDummy U2 
-- WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID)) 
-- AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID));

-- CREATE OR REPLACE VIEW MUTUAL_FRIENDS AS
-- SELECT NF.U1_ID AS MFU1_ID, NF.U2_ID AS MFU2_ID, COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U3, NOT_FRIENDS NF WHERE U3.USER_ID IN
-- (((SELECT F.USER2_ID AS MF_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER2_ID) AND F.USER1_ID = NF.U1_ID)
--  UNION (SELECT F.USER1_ID AS MF_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER1_ID) AND F.USER2_ID = NF.U1_ID)) 
-- INTERSECT ((SELECT F.USER2_ID AS MF_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER2_ID) AND F.USER1_ID = NF.U2_ID)
--  UNION (SELECT F.USER1_ID AS MF_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER1_ID) AND F.USER2_ID = NF.U2_ID))) GROUP BY NF.U1_ID, NF.U2_ID ORDER BY MUTUAL_COUNT DESC;

-- SELECT MUTUAL_COUNT FROM MUTUAL_FRIENDS MF WHERE MF.MFU1_ID = 9 AND MF.MFU2_ID = 491;
--  WHERE EXISTS
-- (((SELECT F.USER1_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER2_ID) AND F.USER1_ID = NF.U1_ID)
--  UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER1_ID) AND F.USER2_ID = NF.U1_ID)) 
-- INTERSECT ((SELECT F.USER1_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER2_ID) AND F.USER1_ID = NF.U2_ID)
--  UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER1_ID) AND F.USER2_ID = NF.U2_ID))) 
--  AND NF.U1_ID = 9 AND NF.U2_ID = 491 GROUP BY NF.U1_ID, NF.U2_ID ORDER BY MUTUAL_COUNT DESC;

-- DROP VIEW MUTUAL_FRIENDS;
-- DROP VIEW NOT_FRIENDS;




-- CREATE OR REPLACE VIEW NOT_FRIENDS AS 
-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM UsersDummy U1, UsersDummy U2 
-- WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID)) 
-- AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID));

-- SELECT COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U3, NOT_FRIENDS NF WHERE EXISTS
-- (((SELECT F.USER2_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER2_ID) AND F.USER1_ID = NF.U1_ID)
--  UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER1_ID) AND F.USER2_ID = NF.U1_ID)) 
-- INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER2_ID) AND F.USER1_ID = NF.U2_ID)
--  UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER1_ID) AND F.USER2_ID = NF.U2_ID))) 
--  AND NF.U1_ID = 9 AND NF.U2_ID = 491 GROUP BY NF.U1_ID, NF.U2_ID ORDER BY MUTUAL_COUNT DESC;

-- DROP VIEW NOT_FRIENDS;



-- CREATE OR REPLACE VIEW NOT_FRIENDS AS 
-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM UsersDummy U1, UsersDummy U2 
-- WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID)) 
-- AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID));

-- SELECT COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U3, NOT_FRIENDS NF JOIN CheckLoney F ON (F.USER1_ID = NF.U1_ID AND U3.USER_ID = F.USER2_ID) OR (U3.USER_ID = F.USER1_ID AND F.USER2_ID = NF.U1_ID)
-- INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER2_ID) AND F.USER1_ID = NF.U2_ID)
--  UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER1_ID) AND F.USER2_ID = NF.U2_ID))) 
--  AND NF.U1_ID = 9 AND NF.U2_ID = 491 GROUP BY NF.U1_ID, NF.U2_ID ORDER BY MUTUAL_COUNT DESC;

-- DROP VIEW NOT_FRIENDS;


-- CREATE OR REPLACE VIEW NOT_FRIENDS AS 
-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM UsersDummy U1, UsersDummy U2 
-- WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID)) 
-- AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID));

-- SELECT MF_ID, NFU1_ID, NFU2_ID, COUNT(*) AS MUTUAL_COUNT FROM 
-- ((SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM CheckLoney F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER1_ID = NF.U1_ID))
--  FULL OUTER JOIN UsersDummy U3 ON ((U3.USER_ID = F.USER2_ID)) UNION ALL
-- SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM CheckLoney F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER2_ID = NF.U1_ID))
--  FULL OUTER JOIN UsersDummy U3 ON ((U3.USER_ID = F.USER1_ID)))
-- INNER JOIN 
-- (SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM CheckLoney F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER1_ID = NF.U2_ID))
--  FULL OUTER JOIN UsersDummy U3 ON ((U3.USER_ID = F.USER2_ID)) UNION ALL
-- SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM CheckLoney F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER2_ID = NF.U2_ID))
--  FULL OUTER JOIN UsersDummy U3 ON ((U3.USER_ID = F.USER1_ID))))
-- GROUP BY MF_ID, NFU1_ID, NFU2_ID ORDER BY MUTUAL_COUNT DESC;

-- DROP VIEW NOT_FRIENDS;


-- COUNT(*) AS MUTUAL_COUNT GROUP BY MF_ID, NFU1_ID, NFU2_ID ORDER BY MUTUAL_COUNT DESC

-- CREATE OR REPLACE VIEW NOT_FRIENDS AS 
-- SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM UsersDummy U1, UsersDummy U2 
-- WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID)) 
-- AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID));

-- SELECT COUNT(*) AS MUTUAL_COUNT FROM UsersDummy U3, NOT_FRIENDS NF FULL OUTER JOIN CheckLoney F ON (F.USER1_ID = NF.U1_ID AND U3.USER_ID = F.USER2_ID) OR (U3.USER_ID = F.USER1_ID AND F.USER2_ID = NF.U1_ID)
-- INTERSECT ((SELECT F.USER2_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER2_ID) AND F.USER1_ID = NF.U2_ID)
--  UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE (U3.USER_ID = F.USER1_ID) AND F.USER2_ID = NF.U2_ID))) 
--  AND NF.U1_ID = 9 AND NF.U2_ID = 491 GROUP BY NF.U1_ID, NF.U2_ID ORDER BY MUTUAL_COUNT DESC;

-- DROP VIEW NOT_FRIENDS;



CREATE OR REPLACE VIEW NOT_FRIENDS AS 
SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM UsersDummy U1, UsersDummy U2 
WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U1.USER_ID)) 
AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM CheckLoney F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM CheckLoney F WHERE F.USER2_ID = U2.USER_ID));

CREATE OR REPLACE VIEW U1_MF AS 
SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM CheckLoney F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER1_ID = NF.U1_ID))
 FULL OUTER JOIN UsersDummy U3 ON ((U3.USER_ID = F.USER2_ID)) UNION ALL
SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM CheckLoney F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER2_ID = NF.U1_ID))
 FULL OUTER JOIN UsersDummy U3 ON ((U3.USER_ID = F.USER1_ID));

CREATE OR REPLACE VIEW U2_MF AS 
SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM CheckLoney F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER1_ID = NF.U2_ID))
 FULL OUTER JOIN UsersDummy U3 ON ((U3.USER_ID = F.USER2_ID)) UNION ALL
SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM CheckLoney F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER2_ID = NF.U2_ID))
 FULL OUTER JOIN UsersDummy U3 ON ((U3.USER_ID = F.USER1_ID));

CREATE OR REPLACE VIEW MF_PAIRS AS 
SELECT * FROM
(SELECT U1_MF.NFU1_ID AS MF1_ID, U1.FIRST_NAME AS MF1_FN, U1.LAST_NAME AS MF1_LN, U1_MF.NFU2_ID AS MF2_ID, U2.FIRST_NAME AS MF2_FN, U2.LAST_NAME AS MF2_LN, COUNT(*) AS MUTUAL_COUNT FROM U1_MF INNER JOIN U2_MF ON (U1_MF.MF_ID = U2_MF.MF_ID) AND (U1_MF.NFU1_ID = U2_MF.NFU1_ID AND U1_MF.NFU2_ID = U2_MF.NFU2_ID) INNER JOIN UsersDummy U1 ON (U1_MF.NFU1_ID = U1.USER_ID) INNER JOIN UsersDummy U2 ON (U1_MF.NFU2_ID = U2.USER_ID) GROUP BY U1_MF.NFU1_ID, U1.FIRST_NAME, U1.LAST_NAME, U1_MF.NFU2_ID, U2.FIRST_NAME, U2.LAST_NAME ORDER BY MUTUAL_COUNT DESC, MF1_ID, MF2_ID)
WHERE ROWNUM <= 5;


CREATE OR REPLACE VIEW MF AS
SELECT U1_MF.MF_ID AS MF_ID, U.FIRST_NAME AS MF_FN, U.LAST_NAME AS MF_LN FROM U1_MF INNER JOIN U2_MF ON (U1_MF.MF_ID = U2_MF.MF_ID) AND (U1_MF.NFU1_ID = U2_MF.NFU1_ID AND U1_MF.NFU2_ID = U2_MF.NFU2_ID) INNER JOIN UsersDummy U ON (U1_MF.MF_ID = U.USER_ID)
 WHERE U1_MF.NFU1_ID = 9 AND U1_MF.NFU2_ID = 491 ORDER BY MF_ID;

-- SELECT * FROM (select MF_PAIRS.MF1_ID AS MF1_ID, MF_PAIRS.MF1_FN AS MF1_FN, MF_PAIRS.MF1_LN AS MF1_LN, MF_PAIRS.MF2_ID AS MF2_ID, MF_PAIRS.MF2_FN AS MF2_FN, MF_PAIRS.MF2_FN AS MF2_LN, ROW_NUMBER() OVER (ORDER BY MF_PAIRS.MUTUAL_COUNT) AS ROWNUM_MF FROM MF_PAIRS) WHERE ROWNUM_MF = 1;
-- SELECT * from MF;

DROP VIEW MF;
DROP VIEW MF_PAIRS;
DROP VIEW U2_MF;
DROP VIEW U1_MF;
DROP VIEW NOT_FRIENDS;