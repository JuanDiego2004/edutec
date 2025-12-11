-- =====================================================
-- FUNCIONES ALMACENADAS PARA SISTEMA EDUTEC
-- Lógica de negocio implementada en PostgreSQL
-- =====================================================

-- =====================================================
-- FUNCIÓN: obtener_estudiantes_por_salon
-- Descripción: Obtiene todos los estudiantes de un salón específico
-- Parámetros: nivel, grado, sección
-- Retorna: Lista de estudiantes activos
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_estudiantes_por_salon(
    p_nivel VARCHAR,
    p_grado VARCHAR,
    p_seccion VARCHAR
)
RETURNS TABLE (
    id UUID,
    nombre_completo VARCHAR,
    dni VARCHAR,
    fecha_nacimiento DATE,
    sexo VARCHAR,
    apoderado_nombre VARCHAR,
    apoderado_telefono VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.nombre_completo,
        e.dni,
        e.fecha_nacimiento,
        e.sexo,
        e.apoderado_nombre,
        e.apoderado_telefono
    FROM estudiantes e
    WHERE e.nivel = p_nivel 
      AND e.grado = p_grado 
      AND e.seccion = p_seccion
      AND e.activo = true
    ORDER BY e.nombre_completo;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: registrar_calificacion
-- Descripción: Registra o actualiza una calificación
-- Valida que la nota esté en rango y que el estudiante esté activo
-- =====================================================
CREATE OR REPLACE FUNCTION registrar_calificacion(
    p_estudiante_id UUID,
    p_curso_id UUID,
    p_competencia_id UUID,
    p_nota DECIMAL,
    p_bimestre INTEGER,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_estudiante_activo BOOLEAN;
    v_curso_activo BOOLEAN;
    v_competencia_activa BOOLEAN;
    v_calificacion_id UUID;
BEGIN
    -- Validar que el estudiante esté activo
    SELECT activo INTO v_estudiante_activo
    FROM estudiantes
    WHERE id = p_estudiante_id;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Estudiante no encontrado'
        );
    END IF;
    
    IF NOT v_estudiante_activo THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Estudiante no está activo'
        );
    END IF;
    
    -- Validar que el curso esté activo
    SELECT activo INTO v_curso_activo
    FROM cursos
    WHERE id = p_curso_id;
    
    IF NOT v_curso_activo THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Curso no está activo'
        );
    END IF;
    
    -- Validar que la competencia esté activa
    SELECT activo INTO v_competencia_activa
    FROM competencias
    WHERE id = p_competencia_id;
    
    IF NOT v_competencia_activa THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Competencia no está activa'
        );
    END IF;
    
    -- Validar nota
    IF p_nota < 0 OR p_nota > 20 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'La nota debe estar entre 0 y 20'
        );
    END IF;
    
    -- Insertar o actualizar calificación
    INSERT INTO calificaciones (
        estudiante_id, 
        curso_id, 
        competencia_id, 
        nota, 
        bimestre, 
        observaciones
    )
    VALUES (
        p_estudiante_id,
        p_curso_id,
        p_competencia_id,
        p_nota,
        p_bimestre,
        p_observaciones
    )
    ON CONFLICT (estudiante_id, curso_id, competencia_id, bimestre)
    DO UPDATE SET
        nota = EXCLUDED.nota,
        observaciones = EXCLUDED.observaciones,
        updated_at = NOW()
    RETURNING id INTO v_calificacion_id;
    
    RETURN json_build_object(
        'success', true,
        'calificacion_id', v_calificacion_id,
        'mensaje', 'Calificación registrada correctamente'
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: calcular_promedio_curso
-- Descripción: Calcula el promedio ponderado de un curso
-- Considera los pesos de las competencias
-- =====================================================
CREATE OR REPLACE FUNCTION calcular_promedio_curso(
    p_estudiante_id UUID,
    p_curso_id UUID,
    p_bimestre INTEGER
)
RETURNS DECIMAL AS $$
DECLARE
    v_promedio DECIMAL;
    v_suma_ponderada DECIMAL;
    v_suma_pesos INTEGER;
BEGIN
    -- Calcular suma ponderada y suma de pesos
    SELECT 
        SUM(c.nota * comp.peso) / NULLIF(SUM(comp.peso), 0),
        SUM(comp.peso)
    INTO v_suma_ponderada, v_suma_pesos
    FROM calificaciones c
    INNER JOIN competencias comp ON c.competencia_id = comp.id
    WHERE c.estudiante_id = p_estudiante_id
      AND c.curso_id = p_curso_id
      AND c.bimestre = p_bimestre
      AND comp.activo = true;
    
    -- Si no hay calificaciones, retornar NULL
    IF v_suma_pesos IS NULL OR v_suma_pesos = 0 THEN
        RETURN NULL;
    END IF;
    
    RETURN ROUND(v_suma_ponderada, 2);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: calcular_promedio_general_estudiante
-- Descripción: Calcula el promedio general de todos los cursos
-- =====================================================
CREATE OR REPLACE FUNCTION calcular_promedio_general_estudiante(
    p_estudiante_id UUID,
    p_bimestre INTEGER
)
RETURNS DECIMAL AS $$
DECLARE
    v_promedio_general DECIMAL;
BEGIN
    SELECT AVG(promedio_curso)
    INTO v_promedio_general
    FROM (
        SELECT calcular_promedio_curso(p_estudiante_id, c.id, p_bimestre) as promedio_curso
        FROM cursos c
        WHERE EXISTS (
            SELECT 1 
            FROM calificaciones cal 
            WHERE cal.estudiante_id = p_estudiante_id 
              AND cal.curso_id = c.id
              AND cal.bimestre = p_bimestre
        )
    ) promedios
    WHERE promedio_curso IS NOT NULL;
    
    RETURN ROUND(v_promedio_general, 2);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: obtener_reporte_calificaciones
-- Descripción: Genera reporte completo de calificaciones de un estudiante
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_reporte_calificaciones(
    p_estudiante_id UUID,
    p_bimestre INTEGER
)
RETURNS TABLE (
    curso_nombre VARCHAR,
    competencia_nombre VARCHAR,
    nota DECIMAL,
    peso INTEGER,
    promedio_curso DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cur.nombre as curso_nombre,
        comp.nombre as competencia_nombre,
        cal.nota,
        comp.peso,
        calcular_promedio_curso(p_estudiante_id, cur.id, p_bimestre) as promedio_curso
    FROM calificaciones cal
    INNER JOIN cursos cur ON cal.curso_id = cur.id
    INNER JOIN competencias comp ON cal.competencia_id = comp.id
    WHERE cal.estudiante_id = p_estudiante_id
      AND cal.bimestre = p_bimestre
    ORDER BY cur.nombre, comp.nombre;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: registrar_asistencia_masiva
-- Descripción: Registra asistencia para múltiples estudiantes
-- =====================================================
CREATE OR REPLACE FUNCTION registrar_asistencia_masiva(
    p_estudiantes UUID[],
    p_fecha DATE,
    p_estado VARCHAR
)
RETURNS JSON AS $$
DECLARE
    v_estudiante_id UUID;
    v_registros_creados INTEGER := 0;
BEGIN
    -- Validar estado
    IF p_estado NOT IN ('Presente', 'Ausente', 'Tardanza') THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Estado inválido. Debe ser: Presente, Ausente o Tardanza'
        );
    END IF;
    
    -- Iterar sobre estudiantes
    FOREACH v_estudiante_id IN ARRAY p_estudiantes
    LOOP
        INSERT INTO asistencia (estudiante_id, fecha, estado)
        VALUES (v_estudiante_id, p_fecha, p_estado)
        ON CONFLICT (estudiante_id, fecha)
        DO UPDATE SET
            estado = EXCLUDED.estado;
        
        v_registros_creados := v_registros_creados + 1;
    END LOOP;
    
    RETURN json_build_object(
        'success', true,
        'registros_procesados', v_registros_creados,
        'mensaje', 'Asistencia registrada correctamente'
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: obtener_estadisticas_asistencia
-- Descripción: Calcula estadísticas de asistencia de un estudiante
-- =====================================================
CREATE OR REPLACE FUNCTION obtener_estadisticas_asistencia(
    p_estudiante_id UUID,
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
RETURNS JSON AS $$
DECLARE
    v_total INTEGER;
    v_presentes INTEGER;
    v_ausentes INTEGER;
    v_tardanzas INTEGER;
    v_porcentaje_asistencia DECIMAL;
BEGIN
    -- Contar asistencias por tipo
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE estado = 'Presente'),
        COUNT(*) FILTER (WHERE estado = 'Ausente'),
        COUNT(*) FILTER (WHERE estado = 'Tardanza')
    INTO v_total, v_presentes, v_ausentes, v_tardanzas
    FROM asistencia
    WHERE estudiante_id = p_estudiante_id
      AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    -- Calcular porcentaje (considerando tardanzas como medias presencias)
    IF v_total > 0 THEN
        v_porcentaje_asistencia := ROUND(
            ((v_presentes + (v_tardanzas * 0.5)) / v_total) * 100, 
            2
        );
    ELSE
        v_porcentaje_asistencia := 0;
    END IF;
    
    RETURN json_build_object(
        'total_dias', v_total,
        'presentes', v_presentes,
        'ausentes', v_ausentes,
        'tardanzas', v_tardanzas,
        'porcentaje_asistencia', v_porcentaje_asistencia
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: validar_suma_pesos_competencias
-- Descripción: Valida que la suma de pesos de competencias no exceda 100%
-- =====================================================
CREATE OR REPLACE FUNCTION validar_suma_pesos_competencias()
RETURNS TRIGGER AS $$
DECLARE
    v_suma_actual INTEGER;
BEGIN
    -- Calcular suma de pesos para el curso (excluyendo el registro actual si es UPDATE)
    SELECT COALESCE(SUM(peso), 0)
    INTO v_suma_actual
    FROM competencias
    WHERE curso_id = NEW.curso_id
      AND activo = true
      AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::UUID);
    
    -- Validar que la suma total no exceda 100
    IF (v_suma_actual + NEW.peso) > 100 THEN
        RAISE EXCEPTION 'La suma de pesos de competencias no puede exceder 100%%. Suma actual: %, Intentando agregar: %', 
            v_suma_actual, NEW.peso;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para validar pesos
CREATE TRIGGER trigger_validar_pesos_competencias
    BEFORE INSERT OR UPDATE ON competencias
    FOR EACH ROW
    EXECUTE FUNCTION validar_suma_pesos_competencias();

-- =====================================================
-- COMENTARIOS EN FUNCIONES
-- =====================================================
COMMENT ON FUNCTION obtener_estudiantes_por_salon IS 'Obtiene lista de estudiantes activos de un salón específico';
COMMENT ON FUNCTION registrar_calificacion IS 'Registra o actualiza una calificación con validaciones';
COMMENT ON FUNCTION calcular_promedio_curso IS 'Calcula promedio ponderado de un curso para un estudiante';
COMMENT ON FUNCTION calcular_promedio_general_estudiante IS 'Calcula promedio general de todos los cursos';
COMMENT ON FUNCTION obtener_reporte_calificaciones IS 'Genera reporte detallado de calificaciones';
COMMENT ON FUNCTION registrar_asistencia_masiva IS 'Registra asistencia para múltiples estudiantes a la vez';
COMMENT ON FUNCTION obtener_estadisticas_asistencia IS 'Calcula estadísticas de asistencia de un estudiante';
