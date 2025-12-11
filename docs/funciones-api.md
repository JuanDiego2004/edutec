# API Reference - Funciones Almacenadas

Documentación de todas las funciones almacenadas disponibles en la base de datos.

## Funciones de Estudiantes

### `obtener_estudiantes_por_salon`

Obtiene lista de estudiantes activos de un salón específico.

**Parámetros:**
- `p_nivel` (VARCHAR): Nivel educativo ('Inicial', 'Primaria')
- `p_grado` (VARCHAR): Grado (ej: '1ro', '2do', '3 años')
- `p_seccion` (VARCHAR): Sección (ej: 'A', 'B')

**Retorna:** TABLE con campos:
- `id` (UUID)
- `nombre_completo` (VARCHAR)
- `dni` (VARCHAR)
- `fecha_nacimiento` (DATE)
- `sexo` (VARCHAR)
- `apoderado_nombre` (VARCHAR)
- `apoderado_telefono` (VARCHAR)

**Ejemplo de uso (SQL):**
```sql
SELECT * FROM obtener_estudiantes_por_salon('Primaria', '1ro', 'A');
```

**Ejemplo de uso (JavaScript):**
```javascript
const { data, error } = await estudiantes.obtenerEstudiantesPorSalon('Primaria', '1ro', 'A');
```

---

## Funciones de Calificaciones

### `registrar_calificacion`

Registra o actualiza una calificación con validaciones automáticas.

**Parámetros:**
- `p_estudiante_id` (UUID): ID del estudiante
- `p_curso_id` (UUID): ID del curso
- `p_competencia_id` (UUID): ID de la competencia
- `p_nota` (DECIMAL): Nota (0-20)
- `p_bimestre` (INTEGER): Número de bimestre (1-4)
- `p_observaciones` (TEXT, opcional): Observaciones

**Retorna:** JSON
```json
{
  "success": true/false,
  "calificacion_id": "uuid",
  "mensaje": "string",
  "error": "string" // solo si success es false
}
```

**Validaciones automáticas:**
- ✅ Estudiante debe estar activo
- ✅ Curso debe estar activo
- ✅ Competencia debe estar activa
- ✅ Nota debe estar entre 0 y 20
- ✅ Upsert automático (inserta o actualiza)

**Ejemplo de uso (JavaScript):**
```javascript
const { data, error } = await calificaciones.registrarCalificacion({
    estudianteId: 'uuid-del-estudiante',
    cursoId: 'uuid-del-curso',
    competenciaId: 'uuid-de-la-competencia',
    nota: 18.5,
    bimestre: 1,
    observaciones: 'Excelente desempeño'
});
```

---

### `calcular_promedio_curso`

Calcula el promedio ponderado de un curso para un estudiante.

**Parámetros:**
- `p_estudiante_id` (UUID): ID del estudiante
- `p_curso_id` (UUID): ID del curso
- `p_bimestre` (INTEGER): Número de bimestre

**Retorna:** DECIMAL (promedio ponderado redondeado a 2 decimales)

**Cálculo:**
- Multiplica cada nota por el peso de su competencia
- Suma todos los productos
- Divide entre la suma de pesos
- Retorna NULL si no hay calificaciones

**Ejemplo:**
```javascript
const { data, error } = await calificaciones.calcularPromedioCurso(
    'uuid-estudiante',
    'uuid-curso',
    1
);
console.log(`Promedio: ${data}`); // 16.75
```

---

### `calcular_promedio_general_estudiante`

Calcula el promedio general de todos los cursos de un estudiante.

**Parámetros:**
- `p_estudiante_id` (UUID): ID del estudiante
- `p_bimestre` (INTEGER): Número de bimestre

**Retorna:** DECIMAL (promedio general)

**Cálculo:**
- Obtiene promedio de cada curso usando `calcular_promedio_curso`
- Calcula el promedio de todos los promedios
- Retorna NULL si no hay calificaciones

---

### `obtener_reporte_calificaciones`

Genera un reporte detallado de calificaciones de un estudiante.

**Parámetros:**
- `p_estudiante_id` (UUID): ID del estudiante
- `p_bimestre` (INTEGER): Número de bimestre

**Retorna:** TABLE con campos:
- `curso_nombre` (VARCHAR)
- `competencia_nombre` (VARCHAR)
- `nota` (DECIMAL)
- `peso` (INTEGER)
- `promedio_curso` (DECIMAL)

**Ejemplo de uso:**
```javascript
const { data, error } = await calificaciones.obtenerReporteCalificaciones(
    'uuid-estudiante',
    1
);

// data es un array de objetos:
// [
//   {
//     curso_nombre: 'Matemática',
//     competencia_nombre: 'Resuelve problemas de cantidad',
//     nota: 18,
//     peso: 40,
//     promedio_curso: 16.5
//   },
//   ...
// ]
```

---

## Funciones de Asistencia

### `registrar_asistencia_masiva`

Registra asistencia para múltiples estudiantes a la vez.

**Parámetros:**
- `p_estudiantes` (UUID[]): Array de IDs de estudiantes
- `p_fecha` (DATE): Fecha de la asistencia
- `p_estado` (VARCHAR): 'Presente', 'Ausente' o 'Tardanza'

**Retorna:** JSON
```json
{
  "success": true/false,
  "registros_procesados": number,
  "mensaje": "string",
  "error": "string" // solo si success es false
}
```

**Validaciones:**
- ✅ Estado debe ser válido
- ✅ Upsert automático por estudiante y fecha

**Ejemplo JavaScript:**
```javascript
const estudiantesIds = ['uuid1', 'uuid2', 'uuid3'];
const { data, error } = await asistencia.registrarAsistenciaMasiva(
    estudiantesIds,
    'Presente',
    new Date()
);
console.log(`${data.registros_procesados} asistencias registradas`);
```

---

### `obtener_estadisticas_asistencia`

Calcula estadísticas de asistencia de un estudiante en un período.

**Parámetros:**
- `p_estudiante_id` (UUID): ID del estudiante
- `p_fecha_inicio` (DATE): Fecha de inicio
- `p_fecha_fin` (DATE): Fecha de fin

**Retorna:** JSON
```json
{
  "total_dias": number,
  "presentes": number,
  "ausentes": number,
  "tardanzas": number,
  "porcentaje_asistencia": decimal
}
```

**Cálculo del porcentaje:**
- Tardanzas cuentan como 0.5 presencias
- Fórmula: `((presentes + tardanzas * 0.5) / total) * 100`

**Ejemplo:**
```javascript
const { data, error } = await asistencia.obtenerEstadisticasAsistencia(
    'uuid-estudiante',
    '2024-01-01',
    '2024-03-31'
);

console.log(`Asistencia: ${data.porcentaje_asistencia}%`);
// {
//   total_dias: 60,
//   presentes: 55,
//   ausentes: 3,
//   tardanzas: 2,
//   porcentaje_asistencia: 93.33
// }
```

---

## Triggers y Validaciones Automáticas

### `validar_suma_pesos_competencias`

Trigger que se ejecuta automáticamente al insertar o actualizar competencias.

**Validación:**
- La suma de pesos de todas las competencias activas de un curso no puede exceder 100%

**Comportamiento:**
- Si la validación falla, lanza una excepción con el mensaje de error
- Previene la corrupción de datos en el cálculo de promedios

**Ejemplo de error:**
```
Error: La suma de pesos de competencias no puede exceder 100%. 
Suma actual: 70%, Intentando agregar: 40%
```

---

### `actualizar_updated_at`

Trigger que actualiza automáticamente el campo `updated_at` en todas las tablas.

**Aplicado a:**
- usuarios
- estudiantes
- cursos
- competencias
- calificaciones
- salones

**No necesitas hacer nada:** El campo se actualiza automáticamente en cada UPDATE.

---

## Consejos de Uso

### Manejo de Errores

Siempre verifica el campo `error`:

```javascript
const { data, error } = await algunaFuncion();

if (error) {
    console.error('Error:', error.message);
    utils.mostrarError(error.message);
    return;
}

// Usar data
```

### Funciones que retornan JSON

Algunas funciones retornan JSON con un campo `success`:

```javascript
const { data, error } = await calificaciones.registrarCalificacion({...});

if (error) {
    // Error de red o de base de datos
    utils.mostrarError(error.message);
    return;
}

if (data && !data.success) {
    // Error de validación de negocio
    utils.mostrarError(data.error);
    return;
}

// Todo OK
utils.mostrarExito(data.mensaje);
```

### Optimización con Índices

Todas las funciones están optimizadas con índices en:
- IDs (UUIDs)
- Campos de filtrado frecuente (nivel, grado, sección)
- Campos de ordenamiento (nombre, fecha)

Esto garantiza consultas rápidas incluso con miles de registros.
