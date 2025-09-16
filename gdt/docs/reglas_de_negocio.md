# Reglas de Negocio - Sistema de Clases de Música

## 1. Usuarios del Sistema (AppUser)

### 1.1 Roles y Permisos
- **Admin**: Acceso completo al sistema
- **Professor**: Gestión de sus clases y horarios
- **Student**: Inscripción a clases y consulta de horarios
- Solo se permiten estos tres roles en el sistema
- Un usuario puede estar activo o inactivo (`is_active`)
- Todos los usuarios tienen fecha de creación automática

### 1.2 Activación de Usuarios
- Por defecto, los usuarios se crean como activos
- Solo usuarios activos pueden acceder al sistema

## 2. Estudiantes (Student)

### 2.1 Información Básica
- Cada estudiante debe tener nombre, apellido, email y teléfono
- El email debe ser único en el sistema
- Pueden tener fechas de inicio y fin de actividad
- Un estudiante puede estar activo o inactivo

### 2.2 Relación con Usuarios
- Un estudiante puede tener una cuenta de usuario asociada (opcional)
- Si tiene usuario, la relación es 1:1 (un estudiante = un usuario)

### 2.3 Fechas de Actividad
- Si se define fecha de fin, debe ser posterior o igual a la fecha de inicio
- Las fechas son opcionales (pueden ser NULL)

## 3. Profesores (Professor)

### 3.1 Información Básica
- Cada profesor debe tener nombre, apellido, email y teléfono
- El email debe ser único en el sistema
- Pueden tener fechas de inicio y fin de actividad
- Un profesor puede estar activo o inactivo

### 3.2 Relación con Usuarios
- Un profesor puede tener una cuenta de usuario asociada (opcional)
- Si tiene usuario, la relación es 1:1 (un profesor = un usuario)

### 3.3 Fechas de Actividad
- Si se define fecha de fin, debe ser posterior o igual a la fecha de inicio
- Las fechas son opcionales (pueden ser NULL)

## 4. Instrumentos (Instrument)

### 4.1 Características
- Cada instrumento debe tener un nombre único
- Pueden tener un nivel definido (principiante, intermedio, avanzado, etc.)
- El nivel es opcional

## 5. Disponibilidad de Profesores (ProfessorAvailability)

### 5.1 Horarios
- Los profesores definen su disponibilidad por día de la semana (0=Domingo, 6=Sábado)
- Deben especificar hora de inicio y fin
- La hora de fin debe ser posterior a la hora de inicio
- Cada disponibilidad puede estar activa o inactiva

### 5.2 Gestión de Horarios
- Un profesor puede tener múltiples horarios de disponibilidad
- Los horarios inactivos no se consideran para programar clases

## 6. Relación Profesor-Instrumento (ProfessorInstrument)

### 6.1 Enseñanza de Instrumentos
- Un profesor puede enseñar múltiples instrumentos
- Un instrumento puede ser enseñado por múltiples profesores (relación N:M)
- Cada profesor puede tener un instrumento marcado como primario

### 6.2 Instrumento Primario
- Solo un instrumento puede ser primario por profesor
- El instrumento primario es opcional (puede no tener ninguno)

### 6.3 Integridad de Datos
- No se puede eliminar un profesor o instrumento si existe una relación activa
- La eliminación se propaga a las relaciones

## 7. Estados de Clases (LessonState)

### 7.1 Estados Permitidos
- Cada estado tiene una descripción única
- Los estados controlan el flujo de vida de las clases
- Ejemplos comunes: "Programada", "En Curso", "Completada", "Cancelada"  (no final)

## 8. Clases (Lesson)

### 8.1 Programación
- Cada clase debe tener un profesor y un instrumento asignados
- El profesor DEBE enseñar el instrumento de la clase
- Tienen fecha/hora de inicio y fin en UTC
- La hora de fin debe ser posterior a la hora de inicio
- Se registra automáticamente la fecha de creación

### 8.2 Estados y Cancelaciones
- Cada clase tiene un estado definido
- Si se cancela, se registra la fecha de cancelación
- Las clases canceladas no se consideran para conflictos de horario

### 8.3 Restricciones de Horario
- Un profesor no puede tener clases que se solapen en horario
- La validación de solapamiento se maneja en la capa de servicio

## 9. Inscripciones a Clases (LessonStudent)

### 9.1 Inscripción
- Los estudiantes se inscriben a clases específicas (relación N:M)
- Se registra automáticamente la fecha de inscripción
- Un estudiante puede inscribirse a múltiples clases
- Una clase puede tener múltiples estudiantes

### 9.2 Asistencia
- Se registra si el estudiante asistió o no a la clase
- Por defecto, se marca como no asistido hasta confirmación

### 9.3 Eliminación en Cascada
- Si se elimina una clase, se eliminan automáticamente todas las inscripciones
- Si se elimina un estudiante, se deben manejar manualmente sus inscripciones

## 10. Reglas de Integridad General

### 10.1 Emails
- Todos los emails de estudiantes y profesores deben ser únicos
- No puede haber duplicados en el sistema

### 10.2 Fechas
- Todas las fechas de fin deben ser posteriores o iguales a las de inicio
- Las fechas se manejan en UTC para evitar problemas de zona horaria
- Se registran automáticamente las fechas de creación

### 10.3 Estados Activos/Inactivos
- Los registros inactivos no participan en operaciones del sistema
- Se mantienen para historial y auditoría

## 11. Restricciones de Negocio

### 11.1 Coherencia de Enseñanza
- Un profesor solo puede dar clases de instrumentos que enseña
- Esta restricción se valida a nivel de base de datos

### 11.2 Disponibilidad
- Las clases deben programarse dentro de la disponibilidad del profesor
- Esta validación se maneja en la capa de aplicación

### 11.3 Capacidad de Clases
- El sistema permite clases individuales y grupales
- No hay límite definido de estudiantes por clase (se maneja por reglas de negocio)