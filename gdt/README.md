# Gestor de Clases (orientado a Música) 🎵

Un sistema de gestión para escuelas de música que permite administrar profesores, estudiantes, instrumentos y clases.

## 📋 Descripción

Este sistema está diseñado para facilitar la gestión de una escuela de música, permitiendo:
- Registro y gestión de profesores y estudiantes
- Programación de clases por instrumento
- Control de disponibilidad de profesores
- Seguimiento de asistencia a clases
- Gestión de estados de clases (programadas, completadas, canceladas)

## 🎯 Funcionalidades Principales

- **Gestión de Usuarios**: Administradores, profesores y estudiantes con roles específicos
- **Programación de Clases**: Sistema flexible para programar clases individuales o grupales
- **Control de Disponibilidad**: Los profesores definen sus horarios disponibles
- **Inscripciones**: Los estudiantes pueden inscribirse a múltiples clases
- **Seguimiento**: Control de asistencia y estados de las clases
- **Multi-instrumento**: Los profesores pueden enseñar múltiples instrumentos

## 🗄️ Estructura de la Base de Datos

Para detalles completos sobre las reglas de negocio, consultar [README.md](db/README.md).

## 🛡️ Validaciones y Triggers

El sistema implementa validaciones a nivel de base de datos para garantizar integridad:
- Triggers para validar capacidad de lecciones
- Funciones auxiliares para consultas de disponibilidad
- Vistas de monitoreo para administración

Ver detalles completos en [triggers_y_validaciones.md](docs/triggers_y_validaciones.md).

## 📁 Estructura del Proyecto

```
gdt/
├── README.md                  # Este archivo
├── docs/
│   ├── reglas_de_negocio.md   # Reglas de negocio del sistema
│   ├── diccionario_datos.md   # Detalles técnicos de las tablas
│   └── diagrama-er.png        # Diagrama entidad-relación
├── db/
│   ├── README.md
│   └── scripts/
│       ├── 01-create-tables.sql       # Script de creación de tablas
│       └── 02-manage-lesson-capacity  # Script de creación de triggers, funciones y vistas específicas
├── tests/
│   └── db/
│       └── 01-integridad.sql        # Tests de integridad de datos
├── src/
│   ├── backend/
│   └── frontend/

```

## 🤝 Reglas de Negocio

Para detalles completos sobre las reglas de negocio, consultar [reglas_de_negocio.md](docs/reglas_de_negocio.md).

**Principales:**
- Un profesor solo puede dar clases de instrumentos que enseña
- Las clases deben programarse dentro de la disponibilidad del profesor
- No pueden haber clases solapadas para el mismo profesor
- Los estudiantes pueden inscribirse a múltiples clases

## 📈 Próximas Mejoras

- [ ] Sistema de pagos y facturación
- [ ] Notificaciones automáticas
- [ ] Calendario integrado
- [ ] Reportes de asistencia
- [ ] API REST para integración con aplicaciones

## 📞 Contacto y Soporte

Si tienes preguntas o encuentras algún problema:
- Crear un issue en GitHub
- Contactar al equipo de desarrollo

## 📄 Licencia

[Especificar licencia]

---

⭐ Si este proyecto te resulta útil, ¡no olvides darle una estrella en GitHub!
