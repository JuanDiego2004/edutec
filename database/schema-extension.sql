-- =====================================================
-- EXTENSIÓN DE SCHEMA: MÓDULOS ADICIONALES
-- Profesores, Horarios
-- =====================================================

-- =====================================================
-- TABLA: profesores
-- Descripción: Almacena información de profesores
-- =====================================================
CREATE TABLE IF NOT EXISTS profesores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni VARCHAR(8) UNIQUE NOT NULL,
    correo VARCHAR(100) UNIQUE,
    telefono VARCHAR(15),
    especialidad VARCHAR(100),
    fecha_contratacion DATE,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para profesores
CREATE INDEX IF NOT EXISTS idx_profesores_dni ON profesores(dni);
CREATE INDEX IF NOT EXISTS idx_profesores_activo ON profesores(activo);

-- =====================================================
-- TABLA: asignaciones_profesor_curso
-- Descripción: Relaciona profesores con cursos que dictan
-- =====================================================
CREATE TABLE IF NOT EXISTS asignaciones_profesor_curso (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    profesor_id UUID NOT NULL REFERENCES profesores(id) ON DELETE CASCADE,
    curso_id UUID NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    salon_id UUID REFERENCES salones(id) ON DELETE SET NULL,
    anio_escolar INTEGER NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(profesor_id, curso_id, salon_id, anio_escolar)
);

-- Índices para asignaciones
CREATE INDEX IF NOT EXISTS idx_asignaciones_profesor ON asignaciones_profesor_curso(profesor_id);
CREATE INDEX IF NOT EXISTS idx_asignaciones_curso ON asignaciones_profesor_curso(curso_id);
CREATE INDEX IF NOT EXISTS idx_asignaciones_salon ON asignaciones_profesor_curso(salon_id);

-- =====================================================
-- TABLA: horarios
-- Descripción: Horarios de clases por salón
-- =====================================================
CREATE TABLE IF NOT EXISTS horarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    salon_id UUID NOT NULL REFERENCES salones(id) ON DELETE CASCADE,
    curso_id UUID NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    profesor_id UUID REFERENCES profesores(id) ON DELETE SET NULL,
    dia_semana INTEGER NOT NULL CHECK (dia_semana >= 1 AND dia_semana <= 5), -- 1=Lunes, 5=Viernes
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    anio_escolar INTEGER NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT chk_horario_valido CHECK (hora_fin > hora_inicio)
);

-- Índices para horarios
CREATE INDEX IF NOT EXISTS idx_horarios_salon ON horarios(salon_id);
CREATE INDEX IF NOT EXISTS idx_horarios_profesor ON horarios(profesor_id);
CREATE INDEX IF NOT EXISTS idx_horarios_dia ON horarios(dia_semana);

-- =====================================================
-- TRIGGERS: Actualizar updated_at
-- =====================================================
CREATE TRIGGER trigger_profesores_updated_at
    BEFORE UPDATE ON profesores
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_horarios_updated_at
    BEFORE UPDATE ON horarios
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- =====================================================
-- COMENTARIOS
-- =====================================================
COMMENT ON TABLE profesores IS 'Información de profesores de la institución';
COMMENT ON TABLE asignaciones_profesor_curso IS 'Cursos asignados a cada profesor';
COMMENT ON TABLE horarios IS 'Horarios de clases semanales por salón';
