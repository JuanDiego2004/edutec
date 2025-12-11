-- =====================================================
-- DATOS INICIALES (SEEDS)
-- Sistema de gestión escolar Edutec
-- =====================================================

-- =====================================================
-- INSERTAR CURSOS BASE - NIVEL PRIMARIA
-- =====================================================
INSERT INTO cursos (nombre, descripcion, nivel, grado, activo) VALUES
-- 1er Grado Primaria
('Matemática', 'Curso de matemática básica', 'Primaria', '1ro', true),
('Comunicación', 'Lengua y literatura', 'Primaria', '1ro', true),
('Ciencia y Tecnología', 'Introducción a las ciencias', 'Primaria', '1ro', true),
('Personal Social', 'Desarrollo personal y social', 'Primaria', '1ro', true),
('Arte y Cultura', 'Educación artística', 'Primaria', '1ro', true),
('Educación Física', 'Actividad física y deporte', 'Primaria', '1ro', true),
('Educación Religiosa', 'Formación religiosa', 'Primaria', '1ro', true),

-- 2do Grado Primaria
('Matemática', 'Curso de matemática básica', 'Primaria', '2do', true),
('Comunicación', 'Lengua y literatura', 'Primaria', '2do', true),
('Ciencia y Tecnología', 'Introducción a las ciencias', 'Primaria', '2do', true),
('Personal Social', 'Desarrollo personal y social', 'Primaria', '2do', true),
('Arte y Cultura', 'Educación artística', 'Primaria', '2do', true),
('Educación Física', 'Actividad física y deporte', 'Primaria', '2do', true),
('Educación Religiosa', 'Formación religiosa', 'Primaria', '2do', true),

-- 3ro a 6to Grado Primaria (similar estructura)
('Matemática', 'Curso de matemática básica', 'Primaria', '3ro', true),
('Comunicación', 'Lengua y literatura', 'Primaria', '3ro', true),
('Ciencia y Tecnología', 'Introducción a las ciencias', 'Primaria', '3ro', true)

ON CONFLICT (nombre, nivel, grado) DO NOTHING;

-- =====================================================
-- INSERTAR CURSOS BASE - NIVEL INICIAL
-- =====================================================
INSERT INTO cursos (nombre, descripcion, nivel, grado, activo) VALUES
('Matemática', 'Nociones matemáticas básicas', 'Inicial', '3 años', true),
('Comunicación', 'Desarrollo del lenguaje', 'Inicial', '3 años', true),
('Psicomotricidad', 'Desarrollo psicomotor', 'Inicial', '3 años', true),

('Matemática', 'Nociones matemáticas básicas', 'Inicial', '4 años', true),
('Comunicación', 'Desarrollo del lenguaje', 'Inicial', '4 años', true),
('Psicomotricidad', 'Desarrollo psicomotor', 'Inicial', '4 años', true),

('Matemática', 'Nociones matemáticas básicas', 'Inicial', '5 años', true),
('Comunicación', 'Desarrollo del lenguaje', 'Inicial', '5 años', true),
('Psicomotricidad', 'Desarrollo psicomotor', 'Inicial', '5 años', true)

ON CONFLICT (nombre, nivel, grado) DO NOTHING;

-- =====================================================
-- INSERTAR SALONES EJEMPLO
-- =====================================================
INSERT INTO salones (nombre, nivel, grado, seccion, capacidad, activo) VALUES
-- Nivel Inicial
('Aula 3 años - Sección A', 'Inicial', '3 años', 'A', 25, true),
('Aula 4 años - Sección A', 'Inicial', '4 años', 'A', 25, true),
('Aula 5 años - Sección A', 'Inicial', '5 años', 'A', 25, true),

-- Nivel Primaria
('1er Grado Sección A', 'Primaria', '1ro', 'A', 30, true),
('1er Grado Sección B', 'Primaria', '1ro', 'B', 30, true),
('2do Grado Sección A', 'Primaria', '2do', 'A', 30, true),
('2do Grado Sección B', 'Primaria', '2do', 'B', 30, true),
('3er Grado Sección A', 'Primaria', '3ro', 'A', 30, true),
('4to Grado Sección A', 'Primaria', '4to', 'A', 30, true),
('5to Grado Sección A', 'Primaria', '5to', 'A', 30, true),
('6to Grado Sección A', 'Primaria', '6to', 'A', 30, true)

ON CONFLICT (nivel, grado, seccion) DO NOTHING;

-- =====================================================
-- INSERTAR COMPETENCIAS EJEMPLO PARA MATEMÁTICA
-- =====================================================
DO $$
DECLARE
    v_curso_id UUID;
BEGIN
    -- Obtener ID del curso de Matemática 1ro Primaria
    SELECT id INTO v_curso_id
    FROM cursos
    WHERE nombre = 'Matemática' AND nivel = 'Primaria' AND grado = '1ro'
    LIMIT 1;
    
    IF v_curso_id IS NOT NULL THEN
        INSERT INTO competencias (curso_id, nombre, descripcion, peso, activo) VALUES
        (v_curso_id, 'Resuelve problemas de cantidad', 'Capacidad para trabajar con números y operaciones', 40, true),
        (v_curso_id, 'Resuelve problemas de forma y movimiento', 'Geometría y ubicación espacial', 30, true),
        (v_curso_id, 'Resuelve problemas de gestión de datos', 'Estadística básica', 30, true)
        ON CONFLICT (curso_id, nombre) DO NOTHING;
    END IF;
END $$;

-- =====================================================
-- COMENTARIO
-- =====================================================
-- Este archivo contiene datos iniciales para comenzar a usar el sistema.
-- Puedes agregar más cursos, salones y competencias según las necesidades
-- de tu institución educativa.
