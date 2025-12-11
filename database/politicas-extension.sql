-- =====================================================
-- POLÍTICAS RLS PARA MÓDULOS ADICIONALES
-- Profesores, Asignaciones, Horarios
-- =====================================================

-- =====================================================
-- TABLA: profesores
-- =====================================================

-- Habilitar RLS
ALTER TABLE profesores ENABLE ROW LEVEL SECURITY;

-- Política: Administradores pueden hacer todo
CREATE POLICY politica_admin_profesores ON profesores
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE usuarios.id = auth.uid()
            AND usuarios.rol = 'admin'
            AND usuarios.activo = true
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE usuarios.id = auth.uid()
            AND usuarios.rol = 'admin'
            AND usuarios.activo = true
        )
    );

-- Política: Profesores pueden ver todos los profesores
CREATE POLICY politica_profesor_ver_profesores ON profesores
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE usuarios.id = auth.uid()
            AND usuarios.rol IN ('profesor', 'admin')
            AND usuarios.activo = true
        )
    );

-- =====================================================
-- TABLA: asignaciones_profesor_curso
-- =====================================================

ALTER TABLE asignaciones_profesor_curso ENABLE ROW LEVEL SECURITY;

-- Política: Administradores pueden gestionar asignaciones
CREATE POLICY politica_admin_asignaciones ON asignaciones_profesor_curso
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE usuarios.id = auth.uid()
            AND usuarios.rol = 'admin'
            AND usuarios.activo = true
        )
    );

-- Política: Profesores pueden ver sus propias asignaciones
CREATE POLICY politica_profesor_ver_asignaciones ON asignaciones_profesor_curso
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM usuarios u
            INNER JOIN profesores p ON u.correo = p.correo
            WHERE u.id = auth.uid()
            AND asignaciones_profesor_curso.profesor_id = p.id
            AND u.activo = true
        )
        OR
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE usuarios.id = auth.uid()
            AND usuarios.rol = 'admin'
            AND usuarios.activo = true
        )
    );

-- =====================================================
-- TABLA: horarios
-- =====================================================

ALTER TABLE horarios ENABLE ROW LEVEL SECURITY;

-- Política: Administradores pueden gestionar horarios
CREATE POLICY politica_admin_horarios ON horarios
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE usuarios.id = auth.uid()
            AND usuarios.rol = 'admin'
            AND usuarios.activo = true
        )
    );

-- Política: Profesores y usuarios pueden ver horarios
CREATE POLICY politica_ver_horarios ON horarios
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE usuarios.id = auth.uid()
            AND usuarios.activo = true
        )
    );
