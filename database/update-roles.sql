-- Actualizar constraint de roles para incluir 'estudiante'
ALTER TABLE usuarios DROP CONSTRAINT IF EXISTS usuarios_rol_check;
ALTER TABLE usuarios ADD CONSTRAINT usuarios_rol_check 
    CHECK (rol IN ('admin', 'profesor', 'estudiante'));

-- Actualizar roles existentes que sean 'usuario' a 'estudiante'
UPDATE usuarios SET rol = 'estudiante' WHERE rol = 'usuario';
