-- =====================================================
-- SISTEMA DE GESTIÓN ESCOLAR - EDUTEC
-- Base de datos PostgreSQL con nombres en español
-- =====================================================

-- =====================================================
-- TABLA: usuarios
-- Descripción: Almacena usuarios del sistema (administradores, profesores, etc.)
-- =====================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    rol VARCHAR(20) DEFAULT 'usuario' CHECK (rol IN ('admin', 'profesor', 'usuario')),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para usuarios
CREATE INDEX IF NOT EXISTS idx_usuarios_correo ON usuarios(correo);
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON usuarios(rol);

-- =====================================================
-- TABLA: estudiantes
-- Descripción: Almacena información de estudiantes
-- =====================================================
CREATE TABLE IF NOT EXISTS estudiantes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    dni VARCHAR(8) UNIQUE NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    sexo VARCHAR(10) NOT NULL CHECK (sexo IN ('Masculino', 'Femenino')),
    nivel VARCHAR(20) NOT NULL CHECK (nivel IN ('Inicial', 'Primaria')),
    grado VARCHAR(20) NOT NULL,
    seccion VARCHAR(5) NOT NULL,
    direccion TEXT,
    apoderado_nombre VARCHAR(100),
    apoderado_dni VARCHAR(8),
    apoderado_telefono VARCHAR(15),
    apoderado_correo VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para estudiantes
CREATE INDEX IF NOT EXISTS idx_estudiantes_dni ON estudiantes(dni);
CREATE INDEX IF NOT EXISTS idx_estudiantes_nivel ON estudiantes(nivel);
CREATE INDEX IF NOT EXISTS idx_estudiantes_grado_seccion ON estudiantes(grado, seccion);
CREATE INDEX IF NOT EXISTS idx_estudiantes_activo ON estudiantes(activo);

-- =====================================================
-- TABLA: cursos
-- Descripción: Almacena cursos disponibles por nivel y grado
-- =====================================================
CREATE TABLE IF NOT EXISTS cursos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    nivel VARCHAR(20) CHECK (nivel IN ('Inicial', 'Primaria')),
    grado VARCHAR(20),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(nombre, nivel, grado)
);

-- Índices para cursos
CREATE INDEX IF NOT EXISTS idx_cursos_nivel ON cursos(nivel);
CREATE INDEX IF NOT EXISTS idx_cursos_grado ON cursos(grado);

-- =====================================================
-- TABLA: competencias
-- Descripción: Almacena competencias de cada curso con pesos para calificaciones
-- =====================================================
CREATE TABLE IF NOT EXISTS competencias (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    curso_id UUID NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    peso INTEGER DEFAULT 0 CHECK (peso >= 0 AND peso <= 100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(curso_id, nombre)
);

-- Índices para competencias
CREATE INDEX IF NOT EXISTS idx_competencias_curso_id ON competencias(curso_id);

-- =====================================================
-- TABLA: calificaciones
-- Descripción: Almacena calificaciones de estudiantes por competencia y bimestre
-- =====================================================
CREATE TABLE IF NOT EXISTS calificaciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    estudiante_id UUID NOT NULL REFERENCES estudiantes(id) ON DELETE CASCADE,
    curso_id UUID NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    competencia_id UUID NOT NULL REFERENCES competencias(id) ON DELETE CASCADE,
    nota DECIMAL(5,2) CHECK (nota >= 0 AND nota <= 20),
    bimestre INTEGER DEFAULT 1 CHECK (bimestre >= 1 AND bimestre <= 4),
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(estudiante_id, curso_id, competencia_id, bimestre)
);

-- Índices para calificaciones
CREATE INDEX IF NOT EXISTS idx_calificaciones_estudiante ON calificaciones(estudiante_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_curso ON calificaciones(curso_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_bimestre ON calificaciones(bimestre);

-- =====================================================
-- TABLA: asistencia
-- Descripción: Registro de asistencia de estudiantes
-- =====================================================
CREATE TABLE IF NOT EXISTS asistencia (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    estudiante_id UUID NOT NULL REFERENCES estudiantes(id) ON DELETE CASCADE,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    estado VARCHAR(10) NOT NULL CHECK (estado IN ('Presente', 'Ausente', 'Tardanza')),
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(estudiante_id, fecha)
);

-- Índices para asistencia
CREATE INDEX IF NOT EXISTS idx_asistencia_estudiante ON asistencia(estudiante_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_fecha ON asistencia(fecha);
CREATE INDEX IF NOT EXISTS idx_asistencia_estado ON asistencia(estado);

-- =====================================================
-- TABLA: salones
-- Descripción: Información de salones/aulas por nivel, grado y sección
-- =====================================================
CREATE TABLE IF NOT EXISTS salones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nivel VARCHAR(20) NOT NULL CHECK (nivel IN ('Inicial', 'Primaria')),
    grado VARCHAR(20) NOT NULL,
    seccion VARCHAR(5) NOT NULL,
    capacidad INTEGER DEFAULT 30,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(nivel, grado, seccion)
);

-- Índices para salones
CREATE INDEX IF NOT EXISTS idx_salones_nivel ON salones(nivel);
CREATE INDEX IF NOT EXISTS idx_salones_grado_seccion ON salones(grado, seccion);

-- =====================================================
-- TRIGGERS: Actualizar updated_at automáticamente
-- =====================================================
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas con updated_at
CREATE TRIGGER trigger_usuarios_updated_at
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_estudiantes_updated_at
    BEFORE UPDATE ON estudiantes
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_cursos_updated_at
    BEFORE UPDATE ON cursos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_competencias_updated_at
    BEFORE UPDATE ON competencias
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_calificaciones_updated_at
    BEFORE UPDATE ON calificaciones
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_salones_updated_at
    BEFORE UPDATE ON salones
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- =====================================================
-- COMENTARIOS EN TABLAS
-- =====================================================
COMMENT ON TABLE usuarios IS 'Usuarios del sistema (administradores, profesores)';
COMMENT ON TABLE estudiantes IS 'Estudiantes matriculados en la institución';
COMMENT ON TABLE cursos IS 'Cursos disponibles por nivel y grado';
COMMENT ON TABLE competencias IS 'Competencias evaluadas en cada curso';
COMMENT ON TABLE calificaciones IS 'Calificaciones de estudiantes por competencia';
COMMENT ON TABLE asistencia IS 'Registro diario de asistencia';
COMMENT ON TABLE salones IS 'Salones y secciones disponibles';
