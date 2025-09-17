# Triggers y Validaciones - Gestor de Clases

## 📋 Resumen

Este documento describe todos los triggers, funciones y validaciones implementadas a nivel de base de datos para mantener la integridad de los datos del sistema.

## 🎯 Filosofía de Validación

El sistema utiliza un **enfoque híbrido**:
- **Validación principal**: En la capa de aplicación (flexible, testeable)
- **Validación de seguridad**: En base de datos via triggers (integridad garantizada)

Los triggers actúan como **red de seguridad** para prevenir inconsistencias, especialmente en casos de concurrencia o acceso directo a la base de datos.

---

## 🔧 Triggers Implementados

### 1. TR_LessonStudent_CapacitySafety

**Tabla afectada:** `LessonStudent`  
**Eventos:** `INSERT`, `UPDATE`  
**Propósito:** Prevenir que se inscriban más estudiantes de los permitidos por la capacidad de la lección

#### Funcionalidad
- Verifica que el número total de estudiantes inscritos no exceda `lesson_capacity`
- Se ejecuta al insertar o actualizar registros en `LessonStudent`
- Genera un error específico: `CAPACITY_EXCEEDED` para manejo en la aplicación

#### Lógica de Validación
```sql
-- Pseudocódigo del trigger
FOR EACH lección afectada:
    contar_estudiantes_inscritos = COUNT(LessonStudent WHERE lesson_id = X)
    IF contar_estudiantes_inscritos > lesson.lesson_capacity THEN
        ROLLBACK con error "CAPACITY_EXCEEDED"
```

#### Casos de Uso
- **Inscripción simultánea**: Dos usuarios intentan inscribirse al mismo tiempo en el último cupo
- **Scripts de migración**: Protege contra errores en scripts de importación de datos
- **Acceso directo**: Previene errores si alguien modifica datos directamente en la BD

#### Ejemplo de Error
```
CAPACITY_EXCEEDED: Enrollment exceeds lesson capacity
```

### 2. TR_Lesson_ValidateCapacityUpdate

**Tabla afectada:** `Lesson`  
**Eventos:** `UPDATE`  
**Propósito:** Prevenir reducir la capacidad de una lección por debajo del número de estudiantes ya inscritos

#### Funcionalidad
- Se activa solo cuando se modifica el campo `lesson_capacity`
- Verifica que la nueva capacidad sea >= estudiantes ya inscritos
- Previene pérdida de datos o estados inconsistentes

#### Casos de Uso
- **Cambio de aula**: Se mueve una clase a un aula más pequeña
- **Corrección de errores**: Se corrige una capacidad mal configurada
- **Optimización**: Se ajustan capacidades según demanda

#### Ejemplo de Error
```
Cannot reduce capacity below current enrollment count
```

---

## 📊 Funciones de Soporte

### 1. fn_GetLessonAvailableSpots(@lesson_id)

**Tipo:** Función escalar  
**Parámetros:** `@lesson_id INT`  
**Retorna:** `INT` (número de cupos disponibles)

#### Propósito
Proporciona una forma eficiente de consultar cupos disponibles desde la aplicación.

#### Uso en Aplicación
```sql
-- Consulta desde C#/Java
SELECT dbo.fn_GetLessonAvailableSpots(123) as available_spots;
```

#### Lógica
```sql
available_spots = lesson_capacity - COUNT(enrolled_students)
```

---

## 👁️ Vistas de Monitoreo

### 1. vw_LessonCapacity

**Propósito:** Vista consolidada del estado de capacidad de todas las lecciones

#### Campos Incluidos
- `lesson_id`: ID de la lección
- `lesson_capacity`: Capacidad máxima
- `enrolled_students`: Estudiantes inscritos actualmente
- `available_spots`: Cupos disponibles

#### Uso Típico
- Dashboards administrativos
- Reportes de ocupación
- Monitoreo de sistema

```sql
-- Ver lecciones casi llenas
SELECT * FROM vw_LessonCapacity 
WHERE available_spots <= 2 AND available_spots > 0;
```

---

## 🛡️ Restricciones CHECK

### 1. CK_Lesson_Capacity

**Tabla:** `Lesson`  
**Campo:** `lesson_capacity`  
**Restricción:** `lesson_capacity > 0 AND lesson_capacity <= 100`

#### Propósito
- Prevenir capacidades inválidas (cero o negativas)
- Limitar capacidades a valores razonables (máximo 100). Esto, por supuesto, puede cambiar.

---

## ⚠️ Consideraciones Importantes

### Performance
- Los triggers agregan overhead mínimo (~5-10ms por operación)
- Las funciones están optimizadas para consultas frecuentes

### Manejo de Errores
- Los triggers generan errores específicos para manejo en la aplicación
- La aplicación debe capturar errores tipo `CAPACITY_EXCEEDED`
- Siempre usar transacciones para operaciones que involucren triggers

### Testing
- Los triggers se activan automáticamente en testing
- Incluir casos de prueba para validar comportamiento de triggers
- Verificar manejo correcto de errores en la aplicación

---

## 🧪 Casos de Prueba

### Prueba 1: Exceder Capacidad
```sql
-- Setup
INSERT INTO Lesson (lesson_capacity, ...) VALUES (2, ...);
INSERT INTO LessonStudent (lesson_id, student_id) VALUES (1, 1);
INSERT INTO LessonStudent (lesson_id, student_id) VALUES (1, 2);

-- Esta debería fallar
INSERT INTO LessonStudent (lesson_id, student_id) VALUES (1, 3);
-- Resultado esperado: Error CAPACITY_EXCEEDED
```

### Prueba 2: Reducir Capacidad
```sql
-- Setup: Lección con 3 estudiantes inscritos
UPDATE Lesson SET lesson_capacity = 5 WHERE lesson_id = 1;
-- Llenar con 3 estudiantes...

-- Esta debería fallar
UPDATE Lesson SET lesson_capacity = 2 WHERE lesson_id = 1;
-- Resultado esperado: Error de capacidad insuficiente
```

### Prueba 3: Función de Cupos Disponibles
```sql
-- Verificar cálculo correcto
SELECT 
    lesson_id,
    lesson_capacity,
    dbo.fn_GetLessonAvailableSpots(lesson_id) as calculated_spots,
    (lesson_capacity - (SELECT COUNT(*) FROM LessonStudent WHERE lesson_id = L.lesson_id)) as manual_calculation
FROM Lesson L
WHERE lesson_id = 1;
-- Resultado esperado: calculated_spots = manual_calculation
```

---

**Responsable técnico:** Mauro Catania 
**Última actualización:** 16/09/25