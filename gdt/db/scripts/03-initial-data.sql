SET XACT_ABORT ON;
BEGIN TRANSACTION

-- =========================
-- Initial data
-- =========================

-- The idea is not to insert in all of the tables, just the not customizable ones. 
-- The rest, they can be fed in the application

-- 1. LessonState 

INSERT INTO LessonState (description) VALUES ('SCHEDULED');
INSERT INTO LessonState (description) VALUES ('ONGOING');
INSERT INTO LessonState (description) VALUES ('COMPLETED');
INSERT INTO LessonState (description) VALUES ('CANCELED');
INSERT INTO LessonState (description) VALUES ('RESCHEDULED');

-- 2. LessonStudentState

INSERT INTO LessonStudentState (description) VALUES ('PENDING');
INSERT INTO LessonStudentState (description) VALUES ('CONFIRMED');
INSERT INTO LessonStudentState (description) VALUES ('CANCELED');

COMMIT TRANSACTION