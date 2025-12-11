# Configuración de Supabase para Edutec

Esta guía te ayudará a configurar Supabase para tu proyecto escolar.

## Paso 1: Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. Haz clic en "Start your project"
3. Inicia sesión o crea una cuenta (puedes usar GitHub, Google, etc.)
4. Haz clic en "New Project"
5. Completa los datos:
   - **Name**: `Edutec` (o el nombre que prefieras)
   - **Database Password**: Crea una contraseña segura (¡guárdala!)
   - **Region**: Selecciona la más cercana a tu ubicación
   - **Pricing Plan**: Selecciona "Free" para empezar

6. Haz clic en "Create new project"
7. Espera 1-2 minutos mientras se crea tu proyecto

## Paso 2: Ejecutar Scripts SQL

Una vez creado el proyecto:

### 2.1 Ejecutar Schema (Crear Tablas)

1. En el menú lateral, ve a **SQL Editor**
2. Haz clic en "+ New query"
3. Abre el archivo `database/schema.sql` de tu proyecto
4. Copia todo el contenido
5. Pégalo en el editor SQL de Supabase
6. Haz clic en **Run** (o presiona Ctrl+Enter)
7. Deberías ver el mensaje: "Success. No rows returned"

### 2.2 Ejecutar Funciones Almacenadas

1. Crea una nueva query
2. Abre el archivo `database/funciones.sql`
3. Copia todo el contenido
4. Pégalo en el editor SQL
5. Haz clic en **Run**

### 2.3 Configurar Políticas de Seguridad

1. Crea una nueva query
2. Abre el archivo `database/politicas.sql`
3. Copia todo el contenido
4. Pégalo en el editor SQL
5. Haz clic en **Run**

### 2.4 Insertar Datos Iniciales (Opcional)

1. Crea una nueva query
2. Abre el archivo `database/seeds.sql`
3. Copia todo el contenido
4. Pégalo en el editor SQL
5. Haz clic en **Run**

## Paso 3: Verificar Tablas

1. En el menú lateral, ve a **Table Editor**
2. Deberías ver todas las tablas creadas:
   - usuarios
   - estudiantes
   - cursos
   - competencias
   - calificaciones
   - asistencia
   - salones

## Paso 4: Configurar Autenticación

1. En el menú lateral, ve a **Authentication** > **Providers**
2. Asegúrate de que "Email" esté habilitado
3. Ve a **Authentication** > **Policies** para verificar que RLS esté activo

### Crear Usuario Administrador

1. Ve a **Authentication** > **Users**
2. Haz clic en **Add user** > **Create new user**
3. Completa:
   - **Email**: tu correo (ej: admin@edutec.com)
   - **Password**: una contraseña segura
   - **Auto Confirm User**: ✅ Activar
4. Haz clic en **Create user**

## Paso 5: Obtener Credenciales

1. En el menú lateral, ve a **Settings** > **API**
2. Busca la sección **Project URL** y **API Keys**
3. Copia los siguientes valores:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public** (API Key): `eyJhbGc...`

## Paso 6: Configurar el Frontend

1. Abre el archivo `public/js/config.js` en tu editor de código
2. Reemplaza los valores:

```javascript
const SUPABASE_URL = 'https://tu-proyecto.supabase.co'; // Pega tu Project URL
const SUPABASE_ANON_KEY = 'tu-anon-key-aqui'; // Pega tu anon public key
```

3. Guarda el archivo

## Paso 7: Probar la Aplicación

1. Abre `public/login.html` en tu navegador (usa Live Server en VS Code)
2. Intenta iniciar sesión con las credenciales del usuario que creaste
3. Si todo está bien, deberías poder acceder al sistema

## Verificación

### Verificar que las tablas están creadas

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
```

### Verificar que las funciones existen

```sql
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_type = 'FUNCTION'
ORDER BY routine_name;
```

### Probar función de estudiantes por salón

```sql
SELECT * FROM obtener_estudiantes_por_salon('Primaria', '1ro', 'A');
```

## Solución de Problemas

### Error: "relation does not exist"
- Asegúrate de haber ejecutado `schema.sql` correctamente
- Verifica que estés en el proyecto correcto de Supabase

### Error: "permission denied"
- Verifica que hayas ejecutado `politicas.sql`
- Asegúrate de estar autenticado

### No se puede conectar desde el frontend
- Verifica que copiaste correctamente las credenciales en `config.js`
- Asegúrate de que la URL no tenga espacios al inicio o final
- Verifica la consola del navegador (F12) para ver errores específicos

## Recursos Adicionales

- [Documentación de Supabase](https://supabase.com/docs)
- [Guía de JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

## Siguiente Paso

Una vez configurado Supabase, puedes:
1. Crear estudiantes desde `public/registro.html`
2. Registrar calificaciones desde `public/calificaciones.html`
3. Marcar asistencia desde `public/asistencia.html`

¡Listo! Tu sistema está configurado y funcionando. 🎉
