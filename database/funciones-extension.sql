-- =====================================================
-- FUNCIONES PARA MÓDULOS ADICIONALES
-- Profesores, Reportes, Horarios
-- =====================================================

-- =====================================================
-- FUNCIÓN: obtener_profesores_activos
-- Descripción: Lista todos los profesores activos
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_profesores_activos()
RETURNS TABLE (
    id UUID,
    nombres VARCHAR,
    apellidos VARCHAR,
    nombre_completo VARCHAR,
    dni VARCHAR,
    correo VARCHAR,
    telefono VARCHAR,
    especialidad VARCHAR,
    fecha_contratacion DATE,
    total_cursos BIGINT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.nombres,
        p.apellidos,
        (p.nombres || ' ' || p.apellidos)::VARCHAR as nombre_completo,
        p.dni,
        p.correo,
        p.telefono,
        p.especialidad,
        p.fecha_contratacion,
        COUNT(DISTINCT apc.curso_id) as total_cursos
    FROM profesores p
    LEFT JOIN asignaciones_profesor_curso apc ON p.id = apc.profesor_id AND apc.activo = true
    WHERE p.activo = true
    GROUP BY p.id, p.nombres, p.apellidos, p.dni, p.correo, p.telefono, p.especialidad, p.fecha_contratacion
    ORDER BY p.apellidos, p.nombres;
END;
$$;

-- =====================================================
-- FUNCIÓN: asignar_curso_a_profesor
-- Descripción: Asigna un curso a un profesor para un salón específico
-- =====================================================
CREATE OR REPLACE FUNCTION asignar_curso_a_profesor(
    p_profesor_id UUID,
    p_curso_id UUID,
    p_salon_id UUID,
    p_anio_escolar INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_asignacion_id UUID;
BEGIN
    INSERT INTO asignaciones_profesor_curso (profesor_id, curso_id, salon_id, anio_escolar)
    VALUES (p_profesor_id, p_curso_id, p_salon_id, p_anio_escolar)
    ON CONFLICT (profesor_id, curso_id, salon_id, anio_escolar) 
    DO UPDATE SET activo = true
    RETURNING id INTO v_asignacion_id;
    
    RETURN v_asignacion_id;
END;
$$;

-- =====================================================
-- FUNCIÓN: obtener_cursos_de_profesor
-- Descripción: Lista todos los cursos asignados a un profesor
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_cursos_de_profesor(p_profesor_id UUID)
RETURNS TABLE (
    curso_id UUID,
    curso_nombre VARCHAR,
    nivel VARCHAR,
    grado VARCHAR,
    salon_nombre VARCHAR,
    salon_seccion VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id as curso_id,
        c.nombre as curso_nombre,
        c.nivel,
        c.grado,
        s.nombre as salon_nombre,
        s.seccion as salon_seccion
    FROM asignaciones_profesor_curso apc
    INNER JOIN cursos c ON apc.curso_id = c.id
    LEFT JOIN salones s ON apc.salon_id = s.id
    WHERE apc.profesor_id = p_profesor_id 
    AND apc.activo = true
    AND c.activo = true
    ORDER BY c.nivel, c.grado, c.nombre;
END;
$$;

-- =====================================================
-- FUNCIÓN: obtener_horario_semanal_salon
-- Descripción: Obtiene el horario completo de un salón
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_horario_semanal_salon(p_salon_id UUID)
RETURNS TABLE (
    dia_semana INTEGER,
    dia_nombre VARCHAR,
    hora_inicio TIME,
    hora_fin TIME,
    curso_nombre VARCHAR,
    profesor_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.dia_semana,
        CASE h.dia_semana
            WHEN 1 THEN 'Lunes'
            WHEN 2 THEN 'Martes'
            WHEN 3 THEN 'Miércoles'
            WHEN 4 THEN 'Jueves'
            WHEN 5 THEN 'Viernes'
        END::VARCHAR as dia_nombre,
        h.hora_inicio,
        h.hora_fin,
        c.nombre as curso_nombre,
        (p.nombres || ' ' || p.apellidos)::VARCHAR as profesor_nombre
    FROM horarios h
    INNER JOIN cursos c ON h.curso_id = c.id
    LEFT JOIN profesores p ON h.profesor_id = p.id
    WHERE h.salon_id = p_salon_id
    AND h.activo = true
    ORDER BY h.dia_semana, h.hora_inicio;
END;
$$;

-- =====================================================
-- FUNCIÓN: verificar_conflicto_horario
-- Descripción: Verifica si hay conflicto de horario para un profesor
-- =====================================================
CREATE OR REPLACE FUNCTION verificar_conflicto_horario(
    p_profesor_id UUID,
    p_dia_semana INTEGER,
    p_hora_inicio TIME,
    p_hora_fin TIME,
    p_horario_id UUID DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_conflicto INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_conflicto
    FROM horarios
    WHERE profesor_id = p_profesor_id
    AND dia_semana = p_dia_semana
    AND activo = true
    AND (p_horario_id IS NULL OR id != p_horario_id)
    AND (
        (hora_inicio < p_hora_fin AND hora_fin > p_hora_inicio)
    );
    
    RETURN v_conflicto > 0;
END;
$$;

-- =====================================================
-- FUNCIÓN: obtener_estadisticas_generales
-- Descripción: Obtiene estadísticas generales del sistema
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_estadisticas_generales()
RETURNS TABLE (
    total_estudiantes BIGINT,
    total_profesores BIGINT,
    total_cursos BIGINT,
    total_salones BIGINT,
    estudiantes_inicial BIGINT,
    estudiantes_primaria BIGINT,
    promedio_general NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM estudiantes WHERE activo = true) as total_estudiantes,
        (SELECT COUNT(*) FROM profesores WHERE activo = true) as total_profesores,
        (SELECT COUNT(*) FROM cursos WHERE activo = true) as total_cursos,
        (SELECT COUNT(*) FROM salones WHERE activo = true) as total_salones,
        (SELECT COUNT(*) FROM estudiantes WHERE activo = true AND nivel = 'Inicial') as estudiantes_inicial,
        (SELECT COUNT(*) FROM estudiantes WHERE activo = true AND nivel = 'Primaria') as estudiantes_primaria,
        (SELECT COALESCE(AVG(nota), 0) FROM calificaciones) as promedio_general;
END;
$$;

-- =====================================================
-- FUNCIÓN: obtener_estadisticas_por_curso
-- Descripción: Estadísticas de calificaciones por curso
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_estadisticas_por_curso(p_curso_id UUID, p_bimestre INTEGER)
RETURNS TABLE (
    curso_nombre VARCHAR,
    total_estudiantes BIGINT,
    promedio NUMERIC,
    nota_maxima NUMERIC,
    nota_minima NUMERIC,
    aprobados BIGINT,
    desaprobados BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.nombre as curso_nombre,
        COUNT(DISTINCT cal.estudiante_id) as total_estudiantes,
        ROUND(AVG(cal.nota), 2) as promedio,
        MAX(cal.nota) as nota_maxima,
        MIN(cal.nota) as nota_minima,
        COUNT(DISTINCT CASE WHEN cal.nota >= 11 THEN cal.estudiante_id END) as aprobados,
        COUNT(DISTINCT CASE WHEN cal.nota < 11 THEN cal.estudiante_id END) as desaprobados
    FROM cursos c
    LEFT JOIN calificaciones cal ON c.id = cal.curso_id AND cal.bimestre = p_bimestre
    WHERE c.id = p_curso_id
    GROUP BY c.nombre;
END;
$$;

-- =====================================================
-- FUNCIÓN: obtener_ranking_estudiantes
-- Descripción: Ranking de estudiantes por promedio general
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_ranking_estudiantes(p_limite INTEGER DEFAULT 10)
RETURNS TABLE (
    posicion BIGINT,
    estudiante_id UUID,
    nombre_completo VARCHAR,
    nivel VARCHAR,
    grado VARCHAR,
    seccion VARCHAR,
    promedio NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ROW_NUMBER() OVER (ORDER BY AVG(cal.nota) DESC) as posicion,
        e.id as estudiante_id,
        e.nombre_completo,
        e.nivel,
        e.grado,
        e.seccion,
        ROUND(AVG(cal.nota), 2) as promedio
    FROM estudiantes e
    INNER JOIN calificaciones cal ON e.id = cal.estudiante_id
    WHERE e.activo = true
    GROUP BY e.id, e.nombre_completo, e.nivel, e.grado, e.seccion
    HAVING AVG(cal.nota) IS NOT NULL
    ORDER BY promedio DESC
    LIMIT p_limite;
END;
$$;
