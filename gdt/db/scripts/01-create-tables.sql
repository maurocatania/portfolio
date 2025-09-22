SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- =========================
-- Core tables
-- =========================

IF OBJECT_ID('dbo.Lesson','U') IS NOT NULL DROP TABLE dbo.Lesson;
IF OBJECT_ID('dbo.ProfessorInstrument','U') IS NOT NULL DROP TABLE dbo.ProfessorInstrument;
IF OBJECT_ID('dbo.State','U') IS NOT NULL DROP TABLE dbo.State;
IF OBJECT_ID('dbo.Instrument','U') IS NOT NULL DROP TABLE dbo.Instrument;
IF OBJECT_ID('dbo.Professor','U') IS NOT NULL DROP TABLE dbo.Professor;
IF OBJECT_ID('dbo.Student','U') IS NOT NULL DROP TABLE dbo.Student;

CREATE TABLE dbo.LessonState (
    state_id    INT IDENTITY(1,1) NOT NULL,
    description VARCHAR(15) NOT NULL,
    CONSTRAINT PK_LessonState PRIMARY KEY CLUSTERED (state_id),
    CONSTRAINT UQ_LessonState_Description UNIQUE (description)
);

CREATE TABLE dbo.LessonStudentState (
    state_id    INT IDENTITY(1,1) NOT NULL,
    description VARCHAR(15) NOT NULL,
    CONSTRAINT PK_LessonState PRIMARY KEY CLUSTERED (state_id),
    CONSTRAINT UQ_LessonState_Description UNIQUE (description)
);

CREATE TABLE dbo.AppUser (
  user_id       INT IDENTITY(1,1) PRIMARY KEY,
  role          VARCHAR(20) NOT NULL
      CONSTRAINT CK_AppUser_Role CHECK (role IN ('Admin','Professor','Student')),
  is_active     BIT NOT NULL CONSTRAINT DF_AppUser_IsActive DEFAULT (1),
  created_at    DATETIME2 NOT NULL CONSTRAINT DF_AppUser_Created DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Student (
    student_id  INT IDENTITY(1,1) NOT NULL,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
	user_id INT NULL,
	email VARCHAR(100) NOT NULL,
	telephone varchar(15) NOT NULL,
	is_active BIT NOT NULL,
    start_date  DATETIME2   NULL,
    end_date    DATETIME2   NULL,
    CONSTRAINT PK_Student PRIMARY KEY CLUSTERED (student_id),
	CONSTRAINT FK_Student_User FOREIGN KEY (user_id) REFERENCES dbo.AppUser(user_id),
    CONSTRAINT CK_Student_Dates CHECK (end_date IS NULL OR end_date >= start_date),
	CONSTRAINT UQ_Student_Email UNIQUE (email)
);

CREATE TABLE dbo.Professor (
    professor_id INT IDENTITY(1,1) NOT NULL,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
	user_id INT NULL,
	email VARCHAR(100) NOT NULL,
	telephone varchar(15) NOT NULL,
	is_active BIT NOT NULL,
    start_date   DATETIME2   NULL,
    end_date     DATETIME2   NULL,
    CONSTRAINT PK_Professor PRIMARY KEY CLUSTERED (professor_id),
	CONSTRAINT FK_Professor_User FOREIGN KEY (user_id) REFERENCES dbo.AppUser(user_id),
    CONSTRAINT CK_Professor_Dates CHECK (end_date IS NULL OR end_date >= start_date),
	CONSTRAINT UQ_Professor_Email UNIQUE (email)
);

CREATE UNIQUE INDEX UX_Student_User   ON dbo.Student(user_id)   WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX UX_Professor_User ON dbo.Professor(user_id) WHERE user_id IS NOT NULL;

CREATE TABLE dbo.Instrument (
    instrument_id   INT IDENTITY(1,1) NOT NULL,
    instrument_name VARCHAR(50) NOT NULL,
	instrument_level VARCHAR(15),
    CONSTRAINT PK_Instrument PRIMARY KEY CLUSTERED (instrument_id),
    CONSTRAINT UQ_Instrument_Name UNIQUE (instrument_name)
);

CREATE TABLE dbo.ProfessorAvailability (
	availability_id INT IDENTITY(1,1) NOT NULL,
	professor_id INT NOT NULL,
	day_of_week TINYINT NOT NULL,
	start_time time NOT NULL,
	end_time time NOT NULL,
	is_active BIT NOT NULL,

	CONSTRAINT PK_ProfessorAvailability PRIMARY KEY CLUSTERED (availability_id),
	CONSTRAINT FK_ProfessorAvailability FOREIGN KEY (professor_id) REFERENCES dbo.Professor(professor_id),
	CONSTRAINT CK_PA_Day CHECK (day_of_week BETWEEN 0 AND 6),
	CONSTRAINT CK_PA_TimeRange CHECK (end_time > start_time)
);

CREATE INDEX IX_PA_Professor ON dbo.ProfessorAvailability(professor_id);

-- =========================
-- N:M Professor <-> Instrument
-- =========================
CREATE TABLE dbo.ProfessorInstrument (
    professor_id  INT NOT NULL,
    instrument_id INT NOT NULL,
    is_primary    BIT NOT NULL CONSTRAINT DF_PI_IsPrimary DEFAULT (0),
    CONSTRAINT PK_ProfessorInstrument PRIMARY KEY (professor_id, instrument_id),
	-- Lo siguiente ayuda a mantener coherencia y validación de datos (no podemos insertar cualquier cosa en ProfessorInstrument. Si borramos en Professor o Instrument, se borra en ProfessorInstrument también)
	CONSTRAINT FK_PI_Professor FOREIGN KEY (professor_id) REFERENCES dbo.Professor (professor_id),
	CONSTRAINT FK_PI_Instrument FOREIGN KEY (instrument_id) REFERENCES dbo.Instrument (instrument_id)
);
-- Búsquedas por instrumento
CREATE INDEX IX_PI_Instrument ON dbo.ProfessorInstrument(instrument_id);

-- Asegurar un único instrumento primario por profesor
CREATE UNIQUE INDEX UX_PI_PrimaryPerProfessor
ON dbo.ProfessorInstrument(professor_id)
WHERE is_primary = 1;

-- =========================
-- Lesson
-- =========================
CREATE TABLE dbo.Lesson (
    lesson_id     INT IDENTITY(1,1) NOT NULL,
    professor_id  INT NOT NULL,
    instrument_id INT NOT NULL,
	start_utc DATETIME2 NOT NULL,
	end_utc DATETIME2 NOT NULL,
    state_id      INT NOT NULL,
    lesson_date   DATETIME2 NOT NULL,
    lesson_capacity INT NOT NULL,
    created_at    DATETIME2 NOT NULL CONSTRAINT DF_Lesson_CreatedAt DEFAULT SYSUTCDATETIME(),
    canceled_at   DATETIME2 NULL,        -- nullable: solo si se canceló
    CONSTRAINT PK_Lesson PRIMARY KEY CLUSTERED (lesson_id),

    CONSTRAINT FK_Lesson_State   FOREIGN KEY (state_id)   REFERENCES dbo.LessonState(state_id),
	CONSTRAINT CK_Lesson_TimeRange CHECK (end_utc > start_utc),
    CONSTRAINT CK_Lesson_Capacity CHECK (lesson_capacity > 0 AND lesson_capacity <= 50), -- límite básico
    -- Enforce: el profesor realmente enseña ese instrumento
    CONSTRAINT FK_Lesson_ProfInstr FOREIGN KEY (professor_id, instrument_id)
        REFERENCES dbo.ProfessorInstrument(professor_id, instrument_id) -- esto impedirá borrar un registro en ProfessorInstrument si existe una referencia en Lesson
);
--Luego, en la service layer, hacé la validación de solape (con transacción SERIALIZABLE o lock por profesor) antes de insertar.
-- Índices de acceso típicos
CREATE INDEX IX_Lesson_ProfessorDate ON dbo.Lesson(professor_id, lesson_date);
CREATE INDEX IX_Lesson_State         ON dbo.Lesson(state_id);
CREATE INDEX IX_Lesson_ProfessorInstrument ON dbo.Lesson(professor_id, instrument_id);
CREATE INDEX IX_Lesson_Prof_Start ON dbo.Lesson(professor_id, start_utc) WHERE canceled_at IS NULL;


-- Tabla puente N:M
CREATE TABLE dbo.LessonStudent (
    lesson_id  INT NOT NULL,
    student_id INT NOT NULL,
    enrolled_at DATETIME2 NOT NULL CONSTRAINT DF_LS_EnrolledAt DEFAULT SYSUTCDATETIME(),
    attended   BIT NOT NULL CONSTRAINT DF_LS_Attended DEFAULT (0),
    state_id INT NOT NULL
    CONSTRAINT PK_LessonStudent PRIMARY KEY (lesson_id, student_id),
    CONSTRAINT FK_LS_Lesson  FOREIGN KEY (lesson_id)  REFERENCES dbo.Lesson(lesson_id) ON DELETE CASCADE,
    CONSTRAINT FK_LS_Student FOREIGN KEY (student_id) REFERENCES dbo.Student(student_id),
    CONSTRAINT FK_LS_State FOREIGN KEY (state_id) REFERENCES dbo.LessonStudentState(state_id)
);

-- Índices de soporte
CREATE INDEX IX_LS_Student ON dbo.LessonStudent(student_id);
CREATE INDEX IX_LS_Lesson  ON dbo.LessonStudent(lesson_id);
CREATE INDEX IX_LS_Student_Lesson ON dbo.LessonStudent(student_id, lesson_id);

COMMIT TRANSACTION;