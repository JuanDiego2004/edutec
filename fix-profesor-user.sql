-- Verificar si el usuario profesor está en la tabla usuarios
SELECT * FROM usuarios WHERE correo = 'jose@gmail.com';

-- Si no existe, insertarlo
INSERT INTO usuarios (id, correo, nombre_usuario, rol, activo)
VALUES (
    'da36922a-31af-4052-9268-dacb89728a16',
    'jose@gmail.com',
    'Jose Profesor Sánchez Ortiz',
    'profesor',
    true
)
ON CONFLICT (id) DO UPDATE SET
    rol = 'profesor',
    nombre_usuario = 'Jose Profesor Sánchez Ortiz',
    correo = 'jose@gmail.com';
