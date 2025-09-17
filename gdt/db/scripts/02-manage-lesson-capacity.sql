-- =========================
-- Creación de: trigger, función y vista para el manejo de la capacidad máxima de las clases
-- =========================

-- 1. Trigger SIMPLE como red de seguridad (solo prevenir, no gestionar)

CREATE OR ALTER TRIGGER TR_LessonStudent_CapacitySafety
ON dbo.LessonStudent
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.Lesson l ON i.lesson_id = l.lesson_id
        INNER JOIN (
            SELECT lesson_id, COUNT(*) as student_count
            FROM dbo.LessonStudent 
            WHERE lesson_id IN (SELECT lesson_id FROM inserted)
            GROUP BY lesson_id
        ) sc ON l.lesson_id = sc.lesson_id
        WHERE sc.student_count > l.lesson_capacity
    )
    BEGIN
        RAISERROR('CAPACITY_EXCEEDED: Enrollment exceeds lesson capacity', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

GO

-- 2. Función que será utilizada por la aplicación

CREATE OR ALTER FUNCTION dbo.fn_GetLessonAvailableSpots(@lesson_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @available_spots INT;
    
    SELECT @available_spots = l.lesson_capacity - ISNULL(sc.student_count, 0)
    FROM dbo.Lesson l
    LEFT JOIN (
        SELECT lesson_id, COUNT(*) as student_count
        FROM dbo.LessonStudent 
        WHERE lesson_id = @lesson_id
        GROUP BY lesson_id
    ) sc ON l.lesson_id = sc.lesson_id
    WHERE l.lesson_id = @lesson_id;
    
    RETURN ISNULL(@available_spots, 0);
END;

GO

-- 3. Vista simple de monitoreo

CREATE OR ALTER VIEW vw_LessonCapacity AS
SELECT 
    l.lesson_id,
    l.lesson_capacity,
    ISNULL(sc.enrolled_students, 0) as enrolled_students,
    l.lesson_capacity - ISNULL(sc.enrolled_students, 0) as available_spots
FROM dbo.Lesson l
LEFT JOIN (
    SELECT lesson_id, COUNT(*) as enrolled_students
    FROM dbo.LessonStudent
    GROUP BY lesson_id
) sc ON l.lesson_id = sc.lesson_id
WHERE l.canceled_at IS NULL;