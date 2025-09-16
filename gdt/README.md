# Gestor de Clases (orientado a M¨²sica) ??

Un sistema de gesti¨®n para escuelas de m¨²sica que permite administrar profesores, estudiantes, instrumentos y clases.

## ?? Descripci¨®n

Este sistema est¨¢ dise?ado para facilitar la gesti¨®n de una escuela de m¨²sica, permitiendo:
- Registro y gesti¨®n de profesores y estudiantes
- Programaci¨®n de clases por instrumento
- Control de disponibilidad de profesores
- Seguimiento de asistencia a clases
- Gesti¨®n de estados de clases (programadas, completadas, canceladas)

## ?? Funcionalidades Principales

- **Gesti¨®n de Usuarios**: Administradores, profesores y estudiantes con roles espec¨ªficos
- **Programaci¨®n de Clases**: Sistema flexible para programar clases individuales o grupales
- **Control de Disponibilidad**: Los profesores definen sus horarios disponibles
- **Inscripciones**: Los estudiantes pueden inscribirse a m¨²ltiples clases
- **Seguimiento**: Control de asistencia y estados de las clases
- **Multi-instrumento**: Los profesores pueden ense?ar m¨²ltiples instrumentos

## ???Estructura de la Base de Datos

Para detalles completos sobre la estructura de la base de datos, consultar [README.md](db/README.md).

## ?? Estructura del Proyecto

```
gdt/
©À©¤©¤ README.md					# Este archivo
©À©¤©¤ docs/
©¦   ©À©¤©¤ reglas_de_negocio.md	# Reglas de negocio del sistema
©¦   ©À©¤©¤ diccionario_datos.md	# Detalles t¨¦cnicos de las tablas
©¦   ©¸©¤©¤ diagrama-er.png			# Diagrama entidad-relaci¨®n
©À©¤©¤ db/
©¦   ©À©¤©¤ README.md				# Estructura de la base de datos
©¦   ©¸©¤©¤ scripts/
©¦       ©À©¤©¤ database-setup.sql		# Script de creaci¨®n de BD
©¦       ©À©¤©¤ datos-ejemplo.sql		# Datos de prueba
©¦       ©¸©¤©¤ consultas-comunes.sql	# Queries frecuentes
©À©¤©¤ tests/
©¦   ©¸©¤©¤ db/
©¦       ©¸©¤©¤ 01-integridad.sql		# Tests de integridad de datos
©À©¤©¤ src/
©¦   ©À©¤©¤ backend/   (AppointmentApi)		# API del proyecto (.NET 8)
©¦   ©¸©¤©¤ frontend/  (turnos/web)			# Front con React
```

## ?? Caracter¨ªsticas T¨¦cnicas

### ¨ªndices Optimizados
- B¨²squedas por profesor y fecha
- Consultas de disponibilidad
- Relaciones entre tablas

### Validaciones Implementadas
- ?Emails ¨²nicos para profesores y estudiantes
- ?Horarios de clases v¨¢lidos (fin > inicio)
- ?Fechas de actividad coherentes
- ?Profesores solo ense?an instrumentos registrados
- ?Un instrumento primario por profesor m¨¢ximo

### Integridad Referencial
- Eliminaci¨®n en cascada para inscripciones
- Prevenci¨®n de eliminaci¨®n de datos con dependencias
- Relaciones N:M correctamente implementadas

## ?? Reglas de Negocio

Para detalles completos sobre las reglas de negocio, consultar [reglas_de_negocio.md](docs/reglas_de_negocio.md).

**Principales:**
- Un profesor solo puede dar clases de instrumentos que ense?a
- Las clases deben programarse dentro de la disponibilidad del profesor
- No pueden haber clases solapadas para el mismo profesor
- Los estudiantes pueden inscribirse a m¨²ltiples clases

## ?? Pr¨®ximas Mejoras

- [ ] Sistema de pagos y facturaci¨®n
- [ ] Notificaciones autom¨¢ticas
- [ ] Calendario integrado
- [ ] Reportes de asistencia
- [ ] API REST para integraci¨®n con aplicaciones

## ?? Problemas Conocidos

- La validaci¨®n de solapamiento de horarios se maneja en la capa de aplicaci¨®n
- Las zonas horarias deben manejarse cuidadosamente (UTC en BD)

## ?? Contacto y Soporte

Si tienes preguntas o encuentras alg¨²n problema:
- Crear un issue en GitHub
- Contactar al equipo de desarrollo

## ?? Licencia

[Especificar la licencia de tu proyecto]

---

?Si este proyecto te resulta ¨²til, ?no olvides darle una estrella en GitHub!