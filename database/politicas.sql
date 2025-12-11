-- =====================================================
-- POLÍTICAS DE SEGURIDAD (ROW LEVEL SECURITY)
-- Sistema de gestión escolar Edutec
-- =====================================================

-- =====================================================
-- HABILITAR RLS EN TODAS LAS TABLAS
-- =====================================================
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE estudiantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cursos ENABLE ROW LEVEL SECURITY;
ALTER TABLE competencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE calificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE asistencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE salones ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS PARA TABLA: usuarios
-- =====================================================

-- Los usuarios autenticados pueden ver todos los usuarios
CREATE POLICY "usuarios_select_policy" ON usuarios
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Solo administradores pueden insertar usuarios
CREATE POLICY "usuarios_insert_policy" ON usuarios
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- Los usuarios pueden actualizar su propia información
-- Los admins pueden actualizar cualquier usuario
CREATE POLICY "usuarios_update_policy" ON usuarios
    FOR UPDATE
    USING (
        auth.uid() = id OR
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- Solo administradores pueden eliminar usuarios
CREATE POLICY "usuarios_delete_policy" ON usuarios
    FOR DELETE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- =====================================================
-- POLÍTICAS PARA TABLA: estudiantes
-- =====================================================

-- Todos los usuarios autenticados pueden ver estudiantes
CREATE POLICY "estudiantes_select_policy" ON estudiantes
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Usuarios autenticados pueden crear estudiantes
CREATE POLICY "estudiantes_insert_policy" ON estudiantes
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Usuarios autenticados pueden actualizar estudiantes
CREATE POLICY "estudiantes_update_policy" ON estudiantes
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Solo admins pueden eliminar estudiantes
CREATE POLICY "estudiantes_delete_policy" ON estudiantes
    FOR DELETE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- =====================================================
-- POLÍTICAS PARA TABLA: cursos
-- =====================================================

-- Todos pueden ver cursos activos
CREATE POLICY "cursos_select_policy" ON cursos
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Solo admins y profesores pueden crear cursos
CREATE POLICY "cursos_insert_policy" ON cursos
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'profesor')
        )
    );

-- Solo admins y profesores pueden actualizar cursos
CREATE POLICY "cursos_update_policy" ON cursos
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'profesor')
        )
    );

-- Solo admins pueden eliminar cursos
CREATE POLICY "cursos_delete_policy" ON cursos
    FOR DELETE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- =====================================================
-- POLÍTICAS PARA TABLA: competencias
-- =====================================================

-- Todos los autenticados pueden ver competencias
CREATE POLICY "competencias_select_policy" ON competencias
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Solo admins y profesores pueden crear competencias
CREATE POLICY "competencias_insert_policy" ON competencias
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'profesor')
        )
    );

-- Solo admins y profesores pueden actualizar competencias
CREATE POLICY "competencias_update_policy" ON competencias
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'profesor')
        )
    );

-- Solo admins pueden eliminar competencias
CREATE POLICY "competencias_delete_policy" ON competencias
    FOR DELETE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- =====================================================
-- POLÍTICAS PARA TABLA: calificaciones
-- =====================================================

-- Todos los autenticados pueden ver calificaciones
CREATE POLICY "calificaciones_select_policy" ON calificaciones
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Usuarios autenticados pueden insertar calificaciones
CREATE POLICY "calificaciones_insert_policy" ON calificaciones
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Usuarios autenticados pueden actualizar calificaciones
CREATE POLICY "calificaciones_update_policy" ON calificaciones
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Solo admins pueden eliminar calificaciones
CREATE POLICY "calificaciones_delete_policy" ON calificaciones
    FOR DELETE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- =====================================================
-- POLÍTICAS PARA TABLA: asistencia
-- =====================================================

-- Todos los autenticados pueden ver asistencia
CREATE POLICY "asistencia_select_policy" ON asistencia
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Usuarios autenticados pueden registrar asistencia
CREATE POLICY "asistencia_insert_policy" ON asistencia
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Usuarios autenticados pueden actualizar asistencia
CREATE POLICY "asistencia_update_policy" ON asistencia
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Solo admins pueden eliminar asistencia
CREATE POLICY "asistencia_delete_policy" ON asistencia
    FOR DELETE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- =====================================================
-- POLÍTICAS PARA TABLA: salones
-- =====================================================

-- Todos los autenticados pueden ver salones
CREATE POLICY "salones_select_policy" ON salones
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Usuarios autenticados pueden crear salones
CREATE POLICY "salones_insert_policy" ON salones
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'profesor')
        )
    );

-- Usuarios autenticados pueden actualizar salones
CREATE POLICY "salones_update_policy" ON salones
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol IN ('admin', 'profesor')
        )
    );

-- Solo admins pueden eliminar salones
CREATE POLICY "salones_delete_policy" ON salones
    FOR DELETE
    USING (
        auth.uid() IN (
            SELECT id FROM usuarios WHERE rol = 'admin'
        )
    );

-- =====================================================
-- COMENTARIOS
-- =====================================================
COMMENT ON POLICY "usuarios_select_policy" ON usuarios IS 'Permite a usuarios autenticados ver todos los usuarios';
COMMENT ON POLICY "estudiantes_select_policy" ON estudiantes IS 'Permite a usuarios autenticados ver estudiantes';
COMMENT ON POLICY "cursos_select_policy" ON cursos IS 'Permite a usuarios autenticados ver cursos';
