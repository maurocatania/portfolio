-- =========================
-- Creación de: trigger, función y vista para el manejo de la capacidad máxima de las clases
-- =========================

-- 1. Trigger SIMPLE como red de seguridad (solo prevenir, no gestionar)
-- =========================
-- TRIGGER: Validación de capacidad de lección
-- Documentación: docs/triggers_y_validaciones.md
-- Sección: TR_LessonStudent_CapacitySafety
-- =========================

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
            FROM dbo.LessonStudent ls
            WHERE lesson_id IN (SELECT lesson_id FROM inserted) AND ls.state_id != 3 -- estado cancelado
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

-- 2. Trigger para evitar reducir el cupo a un número menor a la cant. de estudiantes
-- =========================
-- TRIGGER: Validación de actualización de capacidad de lección
-- Documentación: docs/triggers_y_validaciones.md
-- Sección: TR_Lesson_ValidateCapacityUpdate
-- =========================

CREATE OR ALTER TRIGGER TR_Lesson_ValidateCapacityUpdate
ON dbo.Lesson
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Solo ejecutar si se modificó lesson_capacity
    IF UPDATE(lesson_capacity)
    BEGIN
        -- Verificar si hay lecciones donde la nueva capacidad sea menor 
        -- al número de estudiantes ya inscritos
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN (
                -- Contar estudiantes actualmente inscritos por lección
                SELECT 
                    lesson_id,
                    COUNT(*) as current_enrolled
                FROM dbo.LessonStudent 
                WHERE lesson_id IN (SELECT lesson_id FROM inserted)
                GROUP BY lesson_id
            ) student_count ON i.lesson_id = student_count.lesson_id
            WHERE i.lesson_capacity < student_count.current_enrolled
        )
        BEGIN
            -- Preparar mensaje de error con información detallada
            DECLARE @ErrorDetails NVARCHAR(MAX) = '';
            
            -- Construir información detallada de las lecciones problemáticas
            SELECT @ErrorDetails = @ErrorDetails + 
                'Lección ID: ' + CAST(i.lesson_id AS VARCHAR(10)) +
                ' - Capacidad anterior: ' + CAST(d.lesson_capacity AS VARCHAR(10)) +
                ' - Nueva capacidad: ' + CAST(i.lesson_capacity AS VARCHAR(10)) +
                ' - Estudiantes inscritos: ' + CAST(ISNULL(sc.current_enrolled, 0) AS VARCHAR(10)) + 
                CHAR(13) + CHAR(10)
            FROM inserted i
            INNER JOIN deleted d ON i.lesson_id = d.lesson_id
            LEFT JOIN (
                SELECT 
                    lesson_id,
                    COUNT(*) as current_enrolled
                FROM dbo.LessonStudent 
                WHERE lesson_id IN (SELECT lesson_id FROM inserted)
                GROUP BY lesson_id
            ) sc ON i.lesson_id = sc.lesson_id
            WHERE i.lesson_capacity < ISNULL(sc.current_enrolled, 0);
            
            -- Lanzar error con detalles
            DECLARE @ErrorMsg NVARCHAR(MAX) = 
                'CAPACITY_REDUCTION_ERROR: No se puede reducir la capacidad por debajo del número de estudiantes ya inscritos.' +
                CHAR(13) + CHAR(10) + 'Detalles:' + CHAR(13) + CHAR(10) + @ErrorDetails;
            
            RAISERROR(@ErrorMsg, 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;

GO

-- 3. Función que será utilizada por la aplicación

CREATE OR ALTER FUNCTION dbo.fn_GetLessonAvailableSpots(@lesson_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @available_spots INT;
    
    SELECT @available_spots = l.lesson_capacity - ISNULL(sc.student_count, 0)
    FROM dbo.Lesson l
    LEFT JOIN (
        SELECT lesson_id, COUNT(*) as student_count
        FROM dbo.LessonStudent ls
        WHERE lesson_id = @lesson_id
        AND ls.state_id != 3
        GROUP BY lesson_id
    ) sc ON l.lesson_id = sc.lesson_id
    WHERE l.lesson_id = @lesson_id;
    
    RETURN ISNULL(@available_spots, 0);
END;

GO

-- 4. Vista simple de monitoreo

CREATE OR ALTER VIEW vw_LessonCapacity AS
SELECT 
    l.lesson_id,
    l.lesson_capacity,
    ISNULL(sc.enrolled_students, 0) as enrolled_students,
    l.lesson_capacity - ISNULL(sc.enrolled_students, 0) as available_spots
FROM dbo.Lesson l
LEFT JOIN (
    SELECT lesson_id, COUNT(*) as enrolled_students
    FROM dbo.LessonStudent ls
    WHERE ls.state_id != 3
    GROUP BY lesson_id
) sc ON l.lesson_id = sc.lesson_id
WHERE l.canceled_at IS NULL;