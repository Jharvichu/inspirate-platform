# 🎓 Guía Maestra de Arquitectura e Implementación
## Proyecto: Inspirate UNI - Sistema de Gestión de Voluntariado

**Versión:** 1.0  
**Última actualización:** Enero 2025  
**Autor:** Equipo Inspirate UNI  
**Arquitectura:** Híbrida Optimizada (Gemini + Claude)

---

## 📑 Tabla de Contenidos

1. [Visión General del Proyecto](#1-visión-general-del-proyecto)
2. [Stack Tecnológico](#2-stack-tecnológico)
3. [Arquitectura del Sistema](#3-arquitectura-del-sistema)
4. [Modelo de Base de Datos](#4-modelo-de-base-de-datos)
5. [Estructura del Proyecto](#5-estructura-del-proyecto)
6. [Estrategia DevSecOps](#6-estrategia-devsecops)
7. [Plan de Implementación](#7-plan-de-implementación)
8. [Guías de Desarrollo](#8-guías-de-desarrollo)
9. [Deployment](#9-deployment)
10. [Mantenimiento y Monitoreo](#10-mantenimiento-y-monitoreo)

---

## 1. Visión General del Proyecto

### 1.1 Descripción

Inspirate UNI es una plataforma web para la gestión de programas de orientación vocacional que permite:

- **Voluntarios**: Registrar horas de trabajo y actividades
- **Directores**: Validar y aprobar horas trabajadas
- **Externos**: Solicitar charlas vocacionales
- **Administradores**: Emitir certificados de horas extracurriculares

### 1.2 Programas

1. **Inspirate Girl** - Orientación para estudiantes mujeres
2. **PROVOV** - Programa de Orientaciones Vocacionales
3. **Ferias** - Programa para ferias educativas

### 1.3 Requerimientos Clave

- ✅ Autenticación segura con roles (voluntario, director, admin, externo)
- ✅ Registro y validación de horas trabajadas
- ✅ Sistema de solicitudes públicas de charlas
- ✅ Emisión de certificados PDF
- ✅ Dashboard administrativo con reportes
- ✅ Despliegue en `inspirate.uni.edu.pe`

### 1.4 Usuarios Objetivo

| Rol | Descripción | Cantidad Estimada |
|-----|-------------|-------------------|
| Voluntarios | Estudiantes UNI activos | ~80-100 |
| Directores | Líderes de área por programa | ~10-15 |
| Administradores | Directiva principal | ~3-5 |
| Externos | Colegios, padres, preuniversitarios | Variable |

---

## 2. Stack Tecnológico

### 2.1 Frontend & Backend

| Categoría | Tecnología | Versión | Justificación |
|-----------|------------|---------|---------------|
| **Framework** | Next.js | 14+ (App Router) | SSR/SSG, SEO, API Routes integradas |
| **Lenguaje** | TypeScript | 5.0+ | Type safety, menos errores en runtime |
| **UI Framework** | React | 18+ | Incluido con Next.js |
| **Styling** | Tailwind CSS | 3.4+ | Utility-first, desarrollo rápido |
| **Component Library** | shadcn/ui | Latest | Componentes accesibles y customizables |
| **Validación** | Zod | 3.22+ | Schema validation, TypeScript integration |
| **Forms** | React Hook Form | 7.49+ | Performance, DX excelente |
| **State Management** | Zustand | 4.4+ | Simple, sin boilerplate |

### 2.2 Backend-as-a-Service

| Servicio | Proveedor | Función |
|----------|-----------|---------|
| **Base de Datos** | Supabase | PostgreSQL gestionado |
| **Autenticación** | Supabase Auth | Email/Password, OAuth |
| **Storage** | Supabase Storage | Almacenamiento de evidencias (PDFs, imágenes) |
| **Realtime** | Supabase Realtime | Actualizaciones en tiempo real |
| **Edge Functions** | Supabase Functions | Lógica serverless (generación PDFs) |

### 2.3 DevOps & Infrastructure

| Herramienta | Propósito |
|-------------|-----------|
| **Docker** | Containerización de aplicación |
| **Docker Compose** | Orquestación multi-container |
| **GitHub Actions** | CI/CD pipeline |
| **GHCR.io** | Container registry |
| **Nginx** | Reverse proxy, SSL termination |

### 2.4 Security & Quality

| Herramienta | Función |
|-------------|---------|
| **Trivy** | Vulnerability scanning (containers) |
| **Dependabot** | Dependency updates automáticas |
| **ESLint** | Linting de código |
| **Prettier** | Code formatting |
| **Husky** | Git hooks (pre-commit) |
| **SonarCloud** | Code quality & security analysis |
| **Sentry** | Error tracking en producción |

### 2.5 Observabilidad (Opcional)

| Herramienta | Uso |
|-------------|-----|
| **Winston** | Structured logging |
| **Uptime Kuma** | Monitoring de disponibilidad |
| **Vercel Analytics** | Web analytics |

---

## 3. Arquitectura del Sistema

### 3.1 Diagrama de Alto Nivel

```
┌─────────────────────────────────────────────────────────┐
│                   Internet                              │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ HTTPS (443)
                     │
         ┌───────────▼──────────────┐
         │  inspirate.uni.edu.pe    │
         │  (Servidor UNI)          │
         │                          │
         │  ┌────────────────────┐  │
         │  │   Nginx Proxy      │  │
         │  │   (SSL/TLS)        │  │
         │  └─────────┬──────────┘  │
         │            │              │
         │  ┌─────────▼──────────┐  │
         │  │  Docker Container  │  │
         │  │  Next.js App       │  │
         │  │  (Port 3000)       │  │
         │  └─────────┬──────────┘  │
         └────────────┼──────────────┘
                      │
                      │ API Calls
                      │
         ┌────────────▼──────────────┐
         │   Supabase Cloud          │
         │                           │
         │  ┌──────────────────────┐ │
         │  │  PostgreSQL          │ │
         │  │  (Row Level Security)│ │
         │  └──────────────────────┘ │
         │                           │
         │  ┌──────────────────────┐ │
         │  │  Auth Service        │ │
         │  └──────────────────────┘ │
         │                           │
         │  ┌──────────────────────┐ │
         │  │  Storage (S3)        │ │
         │  └──────────────────────┘ │
         └───────────────────────────┘
```

### 3.2 Flujo de Autenticación

```
Usuario → Login Page → Supabase Auth
                           ↓
                    JWT Token generado
                           ↓
                    Cookie HTTP-only
                           ↓
                    Middleware verifica
                           ↓
                    Redirección por rol:
                    ├─ Voluntario → /dashboard/member
                    ├─ Director → /dashboard/director
                    ├─ Admin → /dashboard/admin
                    └─ Externo → /dashboard/external
```

### 3.3 Flujo de Registro de Horas

```
Voluntario:
  Llena formulario → Validación (Zod)
                          ↓
                   Server Action ejecuta
                          ↓
                   INSERT en Supabase
                          ↓
                   RLS verifica permisos
                          ↓
                   Estado: PENDIENTE

Director:
  Ve lista pendientes → Revisa evidencia
                          ↓
                   Aprueba/Rechaza
                          ↓
                   UPDATE en registro_horas
                          ↓
                   RLS verifica es director del área
                          ↓
                   Estado: APROBADO/RECHAZADO
                          ↓
                   Notificación al voluntario
```

---

## 4. Modelo de Base de Datos

### 4.1 Diagrama Entidad-Relación

```
┌─────────────┐
│   auth.users │ (Supabase Auth)
└──────┬──────┘
       │ 1:1
       │
┌──────▼──────┐
│  profiles   │
│  ─────────  │
│  id (PK)    │────┐
│  email      │    │
│  full_name  │    │
│  role       │    │ 1:N
│  programa   │    │
│  area       │    │
└─────────────┘    │
                   │
       ┌───────────┴────────────┬──────────────┐
       │                        │              │
┌──────▼────────┐   ┌───────────▼───────┐   ┌▼──────────────┐
│  programas    │   │      areas        │   │ registro_horas│
│  ─────────    │   │  ─────────────    │   │ ──────────────│
│  id (PK)      │◄──┤  id (PK)          │◄──┤  id (PK)      │
│  nombre       │ 1:N│  programa_id (FK)│1:N│  voluntario_id│
│  slug         │   │  nombre           │   │  actividad_id │
│  descripcion  │   │  director_id (FK) │   │  horas        │
└───────────────┘   └──────────┬────────┘   │  estado       │
                               │ 1:N        │  validado_por │
                    ┌──────────▼────────┐   └───────────────┘
                    │   actividades     │
                    │  ─────────────    │
                    │  id (PK)          │
                    │  area_id (FK)     │
                    │  nombre           │
                    │  descripcion      │
                    │  fecha_inicio     │
                    │  fecha_fin        │
                    │  estado           │
                    └───────────────────┘

┌─────────────────┐       ┌──────────────────┐
│ solicitudes_    │       │  certificados    │
│ charlas         │       │  ────────────    │
│ ───────────     │       │  id (PK)         │
│ id (PK)         │       │  voluntario_id   │
│ nombre          │       │  programa_id     │
│ email           │       │  total_horas     │
│ institucion     │       │  periodo_inicio  │
│ programa_interes│       │  periodo_fin     │
│ fecha_preferida │       │  pdf_url         │
│ estado          │       │  codigo_verif    │
└─────────────────┘       └──────────────────┘
```

### 4.2 Esquema SQL Completo

```sql
-- ================================================
-- 1. EXTENSIONES
-- ================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- 2. ENUMS
-- ================================================
CREATE TYPE user_role AS ENUM ('admin', 'director', 'member', 'external');
CREATE TYPE programa_tipo AS ENUM ('inspirate_girl', 'provov', 'ferias');
CREATE TYPE actividad_estado AS ENUM ('planificada', 'en_progreso', 'completada', 'cancelada');
CREATE TYPE registro_estado AS ENUM ('pendiente', 'aprobado', 'rechazado');
CREATE TYPE solicitud_estado AS ENUM ('pendiente', 'en_revision', 'aprobado', 'rechazado', 'completado');
CREATE TYPE modalidad AS ENUM ('virtual', 'presencial');
CREATE TYPE tipo_solicitante AS ENUM ('colegio', 'padre', 'preuniversitario');

-- ================================================
-- 3. TABLAS
-- ================================================

-- Perfiles de usuario (extiende auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role user_role DEFAULT 'member' NOT NULL,
  programa programa_tipo,
  area TEXT,
  telefono TEXT,
  avatar_url TEXT,
  points INTEGER DEFAULT 0, -- Gamificación
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Programas principales
CREATE TABLE programas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  descripcion TEXT,
  imagen_url TEXT,
  activo BOOLEAN DEFAULT true,
  color TEXT DEFAULT '#3b82f6', -- Color para UI
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Áreas dentro de programas
CREATE TABLE areas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  programa_id UUID REFERENCES programas(id) ON DELETE CASCADE NOT NULL,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  director_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(programa_id, nombre)
);

-- Actividades por área
CREATE TABLE actividades (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  area_id UUID REFERENCES areas(id) ON DELETE CASCADE NOT NULL,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  estado actividad_estado DEFAULT 'planificada',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Registro de horas trabajadas
CREATE TABLE registro_horas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  voluntario_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  actividad_id UUID REFERENCES actividades(id) ON DELETE CASCADE NOT NULL,
  fecha DATE NOT NULL,
  horas_trabajadas DECIMAL(4,2) NOT NULL CHECK (horas_trabajadas > 0 AND horas_trabajadas <= 24),
  descripcion TEXT NOT NULL,
  evidencia_url TEXT,
  estado registro_estado DEFAULT 'pendiente',
  validado_por UUID REFERENCES profiles(id) ON DELETE SET NULL,
  comentarios_validacion TEXT,
  fecha_validacion TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CHECK (fecha <= CURRENT_DATE) -- No permitir fechas futuras
);

-- Solicitudes de charlas (público)
CREATE TABLE solicitudes_charlas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre_solicitante TEXT NOT NULL,
  email TEXT NOT NULL,
  telefono TEXT,
  tipo_solicitante tipo_solicitante NOT NULL,
  institucion TEXT,
  programa_interes programa_tipo NOT NULL,
  fecha_preferida DATE,
  horario_preferido TEXT,
  numero_participantes INTEGER,
  modalidad modalidad NOT NULL,
  mensaje TEXT,
  estado solicitud_estado DEFAULT 'pendiente',
  asignado_a UUID REFERENCES profiles(id) ON DELETE SET NULL,
  notas_internas TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Certificados emitidos
CREATE TABLE certificados (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  voluntario_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  programa_id UUID REFERENCES programas(id) ON DELETE CASCADE NOT NULL,
  total_horas DECIMAL(6,2) NOT NULL CHECK (total_horas > 0),
  periodo_inicio DATE NOT NULL,
  periodo_fin DATE NOT NULL,
  codigo_verificacion TEXT UNIQUE NOT NULL,
  pdf_url TEXT,
  emitido_por UUID REFERENCES profiles(id) ON DELETE SET NULL,
  fecha_emision TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CHECK (periodo_fin >= periodo_inicio)
);

-- Tabla de auditoría (opcional pero recomendada)
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL, -- INSERT, UPDATE, DELETE
  old_data JSONB,
  new_data JSONB,
  user_id UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- 4. ÍNDICES (Performance)
-- ================================================
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_programa ON profiles(programa);
CREATE INDEX idx_areas_programa ON areas(programa_id);
CREATE INDEX idx_areas_director ON areas(director_id);
CREATE INDEX idx_actividades_area ON actividades(area_id);
CREATE INDEX idx_actividades_estado ON actividades(estado);
CREATE INDEX idx_registro_horas_voluntario ON registro_horas(voluntario_id);
CREATE INDEX idx_registro_horas_actividad ON registro_horas(actividad_id);
CREATE INDEX idx_registro_horas_estado ON registro_horas(estado);
CREATE INDEX idx_registro_horas_fecha ON registro_horas(fecha);
CREATE INDEX idx_solicitudes_estado ON solicitudes_charlas(estado);
CREATE INDEX idx_solicitudes_programa ON solicitudes_charlas(programa_interes);
CREATE INDEX idx_certificados_voluntario ON certificados(voluntario_id);
CREATE INDEX idx_certificados_programa ON certificados(programa_id);

-- ================================================
-- 5. FUNCIONES AUXILIARES
-- ================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_programas_updated_at BEFORE UPDATE ON programas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_areas_updated_at BEFORE UPDATE ON areas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_actividades_updated_at BEFORE UPDATE ON actividades
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registro_horas_updated_at BEFORE UPDATE ON registro_horas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_solicitudes_updated_at BEFORE UPDATE ON solicitudes_charlas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para generar código de verificación único
CREATE OR REPLACE FUNCTION generate_verification_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
BEGIN
  code := 'CERT-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8));
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 6. ROW LEVEL SECURITY (RLS)
-- ================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE programas ENABLE ROW LEVEL SECURITY;
ALTER TABLE areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE actividades ENABLE ROW LEVEL SECURITY;
ALTER TABLE registro_horas ENABLE ROW LEVEL SECURITY;
ALTER TABLE solicitudes_charlas ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificados ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLÍTICAS RLS: PROFILES
-- ============================================

-- Todos pueden ver perfiles (para menciones, etc)
CREATE POLICY "Perfiles son visibles para usuarios autenticados"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

-- Los usuarios pueden actualizar su propio perfil
CREATE POLICY "Usuarios pueden actualizar su propio perfil"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Solo admins pueden cambiar roles
CREATE POLICY "Solo admins pueden cambiar roles"
  ON profiles FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- POLÍTICAS RLS: PROGRAMAS
-- ============================================

-- Todos pueden ver programas
CREATE POLICY "Programas son públicos"
  ON programas FOR SELECT
  TO authenticated
  USING (true);

-- Solo admins pueden gestionar programas
CREATE POLICY "Solo admins gestionan programas"
  ON programas FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- POLÍTICAS RLS: REGISTRO_HORAS
-- ============================================

-- Voluntarios ven solo sus horas
CREATE POLICY "Voluntarios ven sus propias horas"
  ON registro_horas FOR SELECT
  TO authenticated
  USING (
    voluntario_id = auth.uid()
    OR
    -- Directores ven horas de su área
    EXISTS (
      SELECT 1 FROM areas a
      INNER JOIN actividades act ON act.area_id = a.id
      WHERE a.director_id = auth.uid()
        AND act.id = registro_horas.actividad_id
    )
    OR
    -- Admins ven todo
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Voluntarios pueden insertar sus horas
CREATE POLICY "Voluntarios pueden registrar horas"
  ON registro_horas FOR INSERT
  TO authenticated
  WITH CHECK (
    voluntario_id = auth.uid()
    AND
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'member'
    )
  );

-- Solo directores del área pueden validar
CREATE POLICY "Directores validan horas de su área"
  ON registro_horas FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM areas a
      INNER JOIN actividades act ON act.area_id = a.id
      WHERE a.director_id = auth.uid()
        AND act.id = registro_horas.actividad_id
    )
    OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM areas a
      INNER JOIN actividades act ON act.area_id = a.id
      WHERE a.director_id = auth.uid()
        AND act.id = registro_horas.actividad_id
    )
    OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- POLÍTICAS RLS: SOLICITUDES_CHARLAS
-- ============================================

-- Solicitudes pueden ser creadas sin autenticación (público)
CREATE POLICY "Cualquiera puede crear solicitudes"
  ON solicitudes_charlas FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Solo staff puede ver solicitudes
CREATE POLICY "Staff ve solicitudes"
  ON solicitudes_charlas FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() 
        AND role IN ('admin', 'director', 'member')
    )
  );

-- Solo admins y asignados pueden actualizar
CREATE POLICY "Admins y asignados actualizan solicitudes"
  ON solicitudes_charlas FOR UPDATE
  TO authenticated
  USING (
    asignado_a = auth.uid()
    OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- POLÍTICAS RLS: CERTIFICADOS
-- ============================================

-- Voluntarios ven sus certificados
CREATE POLICY "Voluntarios ven sus certificados"
  ON certificados FOR SELECT
  TO authenticated
  USING (
    voluntario_id = auth.uid()
    OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'director')
    )
  );

-- Solo admins pueden emitir certificados
CREATE POLICY "Solo admins emiten certificados"
  ON certificados FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ================================================
-- 7. DATOS INICIALES (SEED)
-- ================================================

-- Insertar programas base
INSERT INTO programas (nombre, slug, descripcion, color) VALUES
  ('Inspirate Girl', 'inspirate-girl', 'Programa de orientación vocacional para estudiantes mujeres', '#ec4899'),
  ('PROVOV', 'provov', 'Programa de Orientaciones Vocacionales', '#3b82f6'),
  ('Ferias', 'ferias', 'Programa para participación en ferias educativas', '#10b981');

-- Nota: Los usuarios se crean automáticamente vía Supabase Auth
-- Necesitarás crear un trigger para auto-crear el perfil:

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    'member'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### 4.3 Queries Comunes

```sql
-- 1. Total de horas aprobadas por voluntario
SELECT 
  p.full_name,
  SUM(rh.horas_trabajadas) as total_horas,
  COUNT(rh.id) as num_registros
FROM registro_horas rh
JOIN profiles p ON rh.voluntario_id = p.id
WHERE rh.estado = 'aprobado'
GROUP BY p.id, p.full_name
ORDER BY total_horas DESC;

-- 2. Horas pendientes de validación por área
SELECT 
  pr.nombre as programa,
  a.nombre as area,
  COUNT(rh.id) as pendientes,
  SUM(rh.horas_trabajadas) as horas_pendientes
FROM registro_horas rh
JOIN actividades act ON rh.actividad_id = act.id
JOIN areas a ON act.area_id = a.id
JOIN programas pr ON a.programa_id = pr.id
WHERE rh.estado = 'pendiente'
GROUP BY pr.nombre, a.nombre
ORDER BY pendientes DESC;

-- 3. Solicitudes de charlas por programa
SELECT 
  programa_interes,
  estado,
  COUNT(*) as cantidad
FROM solicitudes_charlas
GROUP BY programa_interes, estado
ORDER BY programa_interes, estado;

-- 4. Top 10 voluntarios más activos
SELECT 
  p.full_name,
  p.programa,
  COUNT(DISTINCT rh.actividad_id) as actividades_participadas,
  SUM(rh.horas_trabajadas) as total_horas,
  p.points
FROM profiles p
JOIN registro_horas rh ON p.id = rh.voluntario_id
WHERE rh.estado = 'aprobado'
GROUP BY p.id, p.full_name, p.programa, p.points
ORDER BY total_horas DESC
LIMIT 10;

-- 5. Generar data para certificado
SELECT 
  p.full_name,
  p.email,
  pr.nombre as programa,
  SUM(rh.horas_trabajadas) as total_horas,
  MIN(rh.fecha) as fecha_inicio,
  MAX(rh.fecha) as fecha_fin,
  COUNT(DISTINCT rh.actividad_id) as num_actividades,
  COUNT(DISTINCT a.id) as num_areas
FROM registro_horas rh
JOIN profiles p ON rh.voluntario_id = p.id
JOIN actividades act ON rh.actividad_id = act.id
JOIN areas a ON act.area_id = a.id
JOIN programas pr ON a.programa_id = pr.id
WHERE rh.voluntario_id = $1 
  AND rh.estado = 'aprobado'
  AND rh.fecha BETWEEN $2 AND $3
GROUP BY p.id, p.full_name, p.email, pr.nombre;
```

---

## 5. Estructura del Proyecto

### 5.1 Árbol de Directorios Completo

```
inspirate-uni/
│
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Testing + Linting
│       ├── security.yml              # Security scanning
│       └── deploy.yml                # Build & Deploy
│
├── src/
│   │
│   ├── actions/                      # Server Actions (Backend Logic)
│   │   ├── auth.ts                   # Login, logout, register
│   │   ├── activities.ts             # CRUD actividades
│   │   ├── hours.ts                  # Registro y validación de horas
│   │   ├── talk-requests.ts          # Solicitudes de charlas
│   │   ├── certificates.ts           # Generación de certificados
│   │   └── index.ts                  # Export all actions
│   │
│   ├── app/                          # Next.js App Router
│   │   │
│   │   ├── (public)/                 # Layout público (sin auth)
│   │   │   ├── layout.tsx            # Layout con navbar público
│   │   │   ├── page.tsx              # Landing page principal
│   │   │   ├── about/
│   │   │   │   └── page.tsx          # Sobre Inspirate UNI
│   │   │   ├── programs/
│   │   │   │   ├── page.tsx          # Lista de programas
│   │   │   │   ├── inspirate-girl/
│   │   │   │   │   └── page.tsx
│   │   │   │   ├── provov/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── ferias/
│   │   │   │       └── page.tsx
│   │   │   └── request-talk/
│   │   │       └── page.tsx          # Solicitar charla (público)
│   │   │
│   │   ├── (auth)/                   # Rutas de autenticación
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   ├── register/
│   │   │   │   └── page.tsx
│   │   │   ├── forgot-password/
│   │   │   │   └── page.tsx
│   │   │   └── reset-password/
│   │   │       └── page.tsx
│   │   │
│   │   ├── (dashboard)/              # Layout privado (requiere auth)
│   │   │   ├── layout.tsx            # Sidebar, UserMenu, protección
│   │   │   │
│   │   │   ├── member/               # Vistas para voluntarios
│   │   │   │   ├── page.tsx          # Dashboard general
│   │   │   │   ├── hours/
│   │   │   │   │   ├── page.tsx      # Lista de horas registradas
│   │   │   │   │   ├── new/
│   │   │   │   │   │   └── page.tsx  # Registrar nuevas horas
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx  # Detalle/editar registro
│   │   │   │   ├── activities/
│   │   │   │   │   └── page.tsx      # Actividades disponibles
│   │   │   │   ├── certificates/
│   │   │   │   │   └── page.tsx      # Mis certificados
│   │   │   │   └── profile/
│   │   │   │       └── page.tsx      # Mi perfil
│   │   │   │
│   │   │   ├── director/             # Vistas para directores
│   │   │   │   ├── page.tsx          # Dashboard director
│   │   │   │   ├── approvals/
│   │   │   │   │   ├── page.tsx      # Lista pendientes
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx  # Revisar registro
│   │   │   │   ├── activities/
│   │   │   │   │   ├── page.tsx      # Gestionar actividades
│   │   │   │   │   └── new/
│   │   │   │   │       └── page.tsx  # Crear actividad
│   │   │   │   ├── reports/
│   │   │   │   │   └── page.tsx      # Reportes de área
│   │   │   │   └── team/
│   │   │   │       └── page.tsx      # Voluntarios del área
│   │   │   │
│   │   │   ├── admin/                # Vistas para administradores
│   │   │   │   ├── page.tsx          # Dashboard admin
│   │   │   │   ├── users/
│   │   │   │   │   ├── page.tsx      # Gestión de usuarios
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx  # Editar usuario
│   │   │   │   ├── programs/
│   │   │   │   │   └── page.tsx      # Gestionar programas
│   │   │   │   ├── areas/
│   │   │   │   │   └── page.tsx      # Gestionar áreas
│   │   │   │   ├── certificates/
│   │   │   │   │   ├── page.tsx      # Emitir certificados
│   │   │   │   │   └── generate/
│   │   │   │   │       └── page.tsx  # Generador
│   │   │   │   ├── talk-requests/
│   │   │   │   │   ├── page.tsx      # Gestionar solicitudes
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx  # Detalle solicitud
│   │   │   │   └── analytics/
│   │   │   │       └── page.tsx      # Estadísticas generales
│   │   │   │
│   │   │   └── external/             # Vistas para externos
│   │   │       ├── page.tsx          # Dashboard externo
│   │   │       └── my-requests/
│   │   │           └── page.tsx      # Mis solicitudes
│   │   │
│   │   ├── api/                      # API Routes
│   │   │   ├── health/
│   │   │   │   └── route.ts          # Healthcheck endpoint
│   │   │   ├── webhooks/
│   │   │   │   └── supabase/
│   │   │   │       └── route.ts      # Supabase webhooks
│   │   │   └── cron/
│   │   │       └── cleanup/
│   │   │           └── route.ts      # Tareas programadas
│   │   │
│   │   ├── globals.css               # Estilos globales
│   │   ├── layout.tsx                # Root layout
│   │   └── error.tsx                 # Error boundary global
│   │
│   ├── components/
│   │   │
│   │   ├── ui/                       # shadcn/ui components
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── dropdown-menu.tsx
│   │   │   ├── form.tsx
│   │   │   ├── table.tsx
│   │   │   ├── badge.tsx
│   │   │   ├── select.tsx
│   │   │   ├── textarea.tsx
│   │   │   ├── toast.tsx
│   │   │   └── ... (otros componentes shadcn)
│   │   │
│   │   ├── forms/                    # Formularios complejos
│   │   │   ├── register-hours-form.tsx
│   │   │   ├── validate-hours-form.tsx
│   │   │   ├── talk-request-form.tsx
│   │   │   ├── activity-form.tsx
│   │   │   └── certificate-form.tsx
│   │   │
│   │   ├── layouts/                  # Layouts reutilizables
│   │   │   ├── dashboard-layout.tsx
│   │   │   ├── public-layout.tsx
│   │   │   ├── sidebar.tsx
│   │   │   ├── navbar.tsx
│   │   │   └── footer.tsx
│   │   │
│   │   ├── tables/                   # Tablas de datos
│   │   │   ├── hours-table.tsx
│   │   │   ├── pending-approvals-table.tsx
│   │   │   ├── users-table.tsx
│   │   │   └── requests-table.tsx
│   │   │
│   │   ├── charts/                   # Visualizaciones
│   │   │   ├── hours-chart.tsx
│   │   │   ├── program-stats-chart.tsx
│   │   │   └── activity-timeline.tsx
│   │   │
│   │   └── shared/                   # Componentes compartidos
│   │       ├── user-avatar.tsx
│   │       ├── status-badge.tsx
│   │       ├── file-upload.tsx
│   │       ├── loading-spinner.tsx
│   │       └── empty-state.tsx
│   │
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts             # Cliente para browser
│   │   │   ├── server.ts             # Cliente para server
│   │   │   ├── middleware.ts         # Auth middleware
│   │   │   └── types.ts              # Tipos generados
│   │   │
│   │   ├── utils.ts                  # Utilidades generales
│   │   ├── cn.ts                     # Class name merger (tailwind)
│   │   ├── date.ts                   # Formateo de fechas
│   │   ├── logger.ts                 # Winston logger
│   │   └── constants.ts              # Constantes globales
│   │
│   ├── schemas/                      # Zod validation schemas
│   │   ├── auth.ts                   # Login, register schemas
│   │   ├── hours.ts                  # Registro de horas schema
│   │   ├── activities.ts             # Actividades schema
│   │   ├── talk-requests.ts          # Solicitudes schema
│   │   ├── certificates.ts           # Certificados schema
│   │   └── index.ts                  # Export all schemas
│   │
│   ├── hooks/                        # Custom React hooks
│   │   ├── use-auth.ts               # Hook de autenticación
│   │   ├── use-user.ts               # Hook de usuario actual
│   │   ├── use-hours.ts              # Hook para horas
│   │   ├── use-toast.ts              # Hook para notificaciones
│   │   └── use-debounce.ts           # Hook de debounce
│   │
│   ├── types/                        # TypeScript types
│   │   ├── database.ts               # Tipos de DB (generados)
│   │   ├── api.ts                    # Tipos de API
│   │   └── index.ts                  # Export all types
│   │
│   └── middleware.ts                 # Next.js middleware (auth guard)
│
├── supabase/
│   ├── migrations/                   # Database migrations
│   │   ├── 20250101000000_initial_schema.sql
│   │   ├── 20250102000000_add_rls_policies.sql
│   │   └── 20250103000000_seed_data.sql
│   │
│   ├── functions/                    # Supabase Edge Functions
│   │   ├── generate-certificate/
│   │   │   └── index.ts              # Genera PDF de certificado
│   │   └── send-notification/
│   │       └── index.ts              # Envía emails/notificaciones
│   │
│   ├── config.toml                   # Supabase config
│   └── seed.sql                      # Datos iniciales
│
├── infrastructure/
│   ├── docker/
│   │   ├── nginx/
│   │   │   ├── nginx.conf            # Configuración Nginx
│   │   │   └── ssl/
│   │   │       ├── cert.pem          # Certificado SSL
│   │   │       └── key.pem           # Private key
│   │   └── scripts/
│   │       ├── backup.sh             # Script de backup
│   │       ├── restore.sh            # Script de restore
│   │       └── health-check.sh       # Health check script
│   │
│   └── terraform/                    # (Opcional) IaC
│       └── main.tf
│
├── tests/
│   ├── unit/                         # Unit tests
│   │   ├── actions/
│   │   │   └── hours.test.ts
│   │   ├── components/
│   │   │   └── forms.test.tsx
│   │   └── utils/
│   │       └── date.test.ts
│   │
│   ├── integration/                  # Integration tests
│   │   ├── auth.test.ts
│   │   └── hours-workflow.test.ts
│   │
│   └── e2e/                          # End-to-end tests
│       ├── volunteer-flow.spec.ts
│       └── director-approval.spec.ts
│
├── docs/
│   ├── architecture.md               # Documento de arquitectura
│   ├── api.md                        # Documentación de API
│   ├── deployment.md                 # Guía de despliegue
│   ├── development.md                # Guía de desarrollo
│   └── troubleshooting.md            # Solución de problemas
│
├── public/
│   ├── images/
│   │   ├── logo.svg
│   │   └── programs/
│   │       ├── inspirate-girl.jpg
│   │       ├── provov.jpg
│   │       └── ferias.jpg
│   └── fonts/
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── security.yml
│       └── deploy.yml
│
├── .husky/                           # Git hooks
│   ├── pre-commit
│   └── pre-push
│
├── .vscode/                          # VS Code settings
│   ├── settings.json
│   └── extensions.json
│
├── .dockerignore
├── .env.example                      # Ejemplo de variables de entorno
├── .env.local                        # Variables locales (no commitear)
├── .eslintrc.json                    # ESLint config
├── .gitignore
├── .prettierrc                       # Prettier config
├── docker-compose.yml                # Docker compose para desarrollo
├── docker-compose.prod.yml           # Docker compose para producción
├── Dockerfile                        # Multi-stage Dockerfile
├── next.config.mjs                   # Next.js configuration
├── package.json
├── tsconfig.json                     # TypeScript config
├── tailwind.config.ts                # Tailwind config
├── postcss.config.js                 # PostCSS config
├── vitest.config.ts                  # Vitest config (testing)
└── README.md                         # Documentación principal
```

### 5.2 Archivos Clave de Configuración

#### `next.config.mjs`
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Configuración para subpath deployment
  basePath: process.env.NODE_ENV === 'production' ? '' : '',
  
  // Output standalone para Docker
  output: 'standalone',
  
  // Imágenes de Supabase
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: process.env.NEXT_PUBLIC_SUPABASE_URL?.replace('https://', ''),
        pathname: '/storage/v1/object/public/**',
      },
    ],
  },
  
  // Experimental features
  experimental: {
    serverActions: {
      bodySizeLimit: '5mb', // Para uploads
    },
  },
};

export default nextConfig;
```

#### `middleware.ts`
```typescript
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  const supabase = createMiddlewareClient({ req, res });

  const {
    data: { session },
  } = await supabase.auth.getSession();

  // Rutas públicas que no requieren autenticación
  const publicRoutes = ['/', '/programs', '/about', '/request-talk', '/login', '/register'];
  const isPublicRoute = publicRoutes.some(route => req.nextUrl.pathname.startsWith(route));

  // Si no hay sesión y la ruta no es pública, redirigir a login
  if (!session && !isPublicRoute) {
    return NextResponse.redirect(new URL('/login', req.url));
  }

  // Si hay sesión, verificar rol y permisos
  if (session) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', session.user.id)
      .single();

    const role = profile?.role;

    // Proteger rutas por rol
    if (req.nextUrl.pathname.startsWith('/dashboard/admin') && role !== 'admin') {
      return NextResponse.redirect(new URL('/dashboard', req.url));
    }

    if (req.nextUrl.pathname.startsWith('/dashboard/director') && 
        !['admin', 'director'].includes(role || '')) {
      return NextResponse.redirect(new URL('/dashboard', req.url));
    }
  }

  return res;
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
```

#### `src/lib/supabase/client.ts`
```typescript
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';
import type { Database } from '@/types/database';

export const createClient = () => {
  return createClientComponentClient<Database>();
};
```

#### `src/lib/supabase/server.ts`
```typescript
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs';
import { cookies } from 'next/headers';
import type { Database } from '@/types/database';

export const createServerClient = () => {
  return createServerComponentClient<Database>({ cookies });
};
```

#### Ejemplo Server Action: `src/actions/hours.ts`
```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { registerHoursSchema } from '@/schemas/hours';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

export async function registerHours(formData: z.infer<typeof registerHoursSchema>) {
  const supabase = createServerClient();

  // Validar datos
  const validated = registerHoursSchema.parse(formData);

  // Obtener usuario actual
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    throw new Error('No autenticado');
  }

  // Insertar registro
  const { data, error } = await supabase
    .from('registro_horas')
    .insert({
      voluntario_id: user.id,
      actividad_id: validated.actividad_id,
      fecha: validated.fecha,
      horas_trabajadas: validated.horas_trabajadas,
      descripcion: validated.descripcion,
      evidencia_url: validated.evidencia_url,
    })
    .select()
    .single();

  if (error) {
    throw new Error(`Error al registrar horas: ${error.message}`);
  }

  // Revalidar cache
  revalidatePath('/dashboard/member/hours');

  return { success: true, data };
}

export async function approveHours(registroId: string, comentarios?: string) {
  const supabase = createServerClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    throw new Error('No autenticado');
  }

  const { data, error } = await supabase
    .from('registro_horas')
    .update({
      estado: 'aprobado',
      validado_por: user.id,
      comentarios_validacion: comentarios,
      fecha_validacion: new Date().toISOString(),
    })
    .eq('id', registroId)
    .select()
    .single();

  if (error) {
    throw new Error(`Error al aprobar horas: ${error.message}`);
  }

  revalidatePath('/dashboard/director/approvals');

  return { success: true, data };
}
```

---

## 6. Estrategia DevSecOps

### 6.1 Pipeline CI/CD Completo

#### `.github/workflows/ci.yml` - Testing y Linting
```yaml
name: CI - Testing & Linting

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [develop]

jobs:
  lint:
    name: Linting
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run ESLint
        run: npm run lint
      
      - name: Run Prettier check
        run: npm run format:check
      
      - name: TypeScript check
        run: npm run type-check

  test:
    name: Testing
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        run: npm run test:unit
      
      - name: Run integration tests
        run: npm run test:integration
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_TEST_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_TEST_ANON_KEY }}
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          flags: unittests
          name: codecov-umbrella

  build-test:
    name: Build Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build application
        run: npm run build
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
```

#### `.github/workflows/security.yml` - Security Scanning
```yaml
name: Security Scanning

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 1' # Weekly on Mondays

jobs:
  secret-scan:
    name: Secret Scanning
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: TruffleHog OSS
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD

  dependency-scan:
    name: Dependency Scanning
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Snyk to check for vulnerabilities
        uses: snyk/actions/node@master
        continue-on-error: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
      
      - name: OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'Inspirate UNI'
          path: '.'
          format: 'HTML'
          args: >
            --failOnCVSS 7
            --enableRetired

  sonarcloud:
    name: SonarCloud Analysis
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
          args: >
            -Dsonar.projectKey=inspirate-uni
            -Dsonar.organization=your-org

  docker-scan:
    name: Docker Image Scan
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker image
        run: docker build -t inspirate-web:${{ github.sha }} .
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'inspirate-web:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
      
      - name: Upload Trivy results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```

#### `.github/workflows/deploy.yml` - Deployment
```yaml
name: Deploy to Production

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    name: Build and Push Docker Image
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            NEXT_PUBLIC_SUPABASE_URL=${{ secrets.SUPABASE_URL }}
            NEXT_PUBLIC_SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}

  deploy:
    name: Deploy to Server
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to UNI Server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          port: ${{ secrets.SERVER_PORT }}
          script: |
            # Navegar al directorio del proyecto
            cd /opt/inspirate-uni
            
            # Hacer backup de la BD (opcional)
            ./infrastructure/docker/scripts/backup.sh
            
            # Pull latest image
            docker pull ${{ needs.build-and-push.outputs.image-tag }}
            
            # Update docker-compose y restart
            docker-compose -f docker-compose.prod.yml down
            docker-compose -f docker-compose.prod.yml up -d
            
            # Cleanup old images
            docker image prune -af --filter "until=72h"
            
            # Health check
            sleep 10
            curl -f http://localhost:3000/api/health || exit 1
      
      - name: Notify deployment
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Deployment to production: ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 6.2 Docker Configuration

#### `Dockerfile` (Multi-stage optimizado)
```dockerfile
# ============================================
# Stage 1: Dependencies
# ============================================
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# ============================================
# Stage 2: Builder
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build arguments
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY

ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
ENV NEXT_PUBLIC_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_ANON_KEY
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build application
RUN npm run build

# ============================================
# Stage 3: Runner
# ============================================
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy necessary files
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "server.js"]
```

#### `docker-compose.prod.yml`
```yaml
version: '3.9'

services:
  web:
    image: ghcr.io/your-org/inspirate-uni:latest
    container_name: inspirate-web
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_SUPABASE_URL=${NEXT_PUBLIC_SUPABASE_URL}
      - NEXT_PUBLIC_SUPABASE_ANON_KEY=${NEXT_PUBLIC_SUPABASE_ANON_KEY}
      - SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}
    env_file:
      - .env.production
    networks:
      - inspirate-network
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000/api/health')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=web"

  nginx:
    image: nginx:alpine
    container_name: inspirate-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./infrastructure/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./infrastructure/docker/nginx/ssl:/etc/nginx/ssl:ro
      - ./logs/nginx:/var/log/nginx
    depends_on:
      - web
    networks:
      - inspirate-network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  inspirate-network:
    driver: bridge
```

#### `infrastructure/docker/nginx/nginx.conf`
```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 10M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general:10m rate=30r/s;

    # Upstream Next.js
    upstream nextjs {
        server web:3000;
        keepalive 32;
    }

    # HTTP Redirect to HTTPS
    server {
        listen 80;
        server_name inspirate.uni.edu.pe;
        return 301 https://$server_name$request_uri;
    }

    # HTTPS Server
    server {
        listen 443 ssl http2;
        server_name inspirate.uni.edu.pe;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        add_header Content-Security-Policy "default-src 'self' https://yourproject.supabase.co" always;

        # Root location
        location / {
            limit_req zone=general burst=20 nodelay;
            
            proxy_pass http://nextjs;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # API routes with stricter rate limiting
        location /api/ {
            limit_req zone=api burst=5 nodelay;
            
            proxy_pass http://nextjs;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Static files caching
        location /_next/static/ {
            proxy_pass http://nextjs;
            add_header Cache-Control "public, max-age=31536000, immutable";
        }

        # Health check endpoint
        location /api/health {
            proxy_pass http://nextjs;
            access_log off;
        }
    }
}
```

### 6.3 Security Best Practices

#### `.env.example`
```bash
# ============================================
# SUPABASE CONFIGURATION
# ============================================
NEXT_PUBLIC_SUPABASE_URL=https://yourproject.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# ============================================
# APPLICATION CONFIGURATION
# ============================================
NODE_ENV=production
NEXT_PUBLIC_APP_URL=https://inspirate.uni.edu.pe

# ============================================
# MONITORING & LOGGING (Optional)
# ============================================
SENTRY_DSN=your-sentry-dsn
SENTRY_AUTH_TOKEN=your-sentry-auth-token

# ============================================
# EMAIL CONFIGURATION (Optional)
# ============================================
RESEND_API_KEY=your-resend-api-key
EMAIL_FROM=noreply@inspirate.uni.edu.pe
```

#### Pre-commit Hook (`.husky/pre-commit`)
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run linting
npm run lint

# Run type checking
npm run type-check

# Check for secrets
npx secretlint "**/*"

# Run unit tests
npm run test:unit
```

---

## 7. Plan de Implementación

### 7.1 Cronograma Detallado (10 Semanas)

#### **Semana 1: Setup Inicial**
**Objetivo**: Infraestructura base funcionando

- [ ] **Día 1-2**: Setup del proyecto
  - Crear repositorio en GitHub
  - Inicializar Next.js 14 con TypeScript
  - Configurar ESLint, Prettier, Husky
  - Setup Tailwind CSS + shadcn/ui
  
- [ ] **Día 3-4**: Supabase Setup
  - Crear proyecto en Supabase
  - Ejecutar migrations (schema inicial)
  - Configurar RLS policies
  - Probar conexión local
  
- [ ] **Día 5**: Docker & CI/CD básico
  - Crear Dockerfile
  - Setup docker-compose.yml
  - Configurar GitHub Actions (CI básico)

**Entregables**:
- ✅ Repositorio configurado
- ✅ Base de datos con schema inicial
- ✅ Pipeline CI básico funcionando

---

#### **Semana 2: Autenticación y Roles**
**Objetivo**: Sistema de auth completo

- [ ] **Día 1-2**: Configurar Supabase Auth
  - Páginas de login/register
  - Middleware de protección de rutas
  - Manejo de sesiones
  
- [ ] **Día 3-4**: Sistema de roles
  - Crear tabla profiles
  - Implementar RLS por rol
  - Redirect según rol después del login
  
- [ ] **Día 5**: Testing
  - Unit tests para auth functions
  - Integration tests para flujo completo

**Entregables**:
- ✅ Login/Register funcionando
- ✅ Protección de rutas por rol
- ✅ Tests pasando

---

#### **Semana 3-4: Módulo de Voluntarios**
**Objetivo**: Voluntarios pueden registrar horas

- [ ] **Semana 3 - Día 1-3**: UI y Formularios
  - Dashboard de voluntario
  - Formulario de registro de horas (React Hook Form + Zod)
  - Lista de horas registradas (tabla con filtros)
  - Upload de evidencias a Supabase Storage
  
- [ ] **Semana 3 - Día 4-5**: Backend Logic
  - Server Actions para CRUD de horas
  - Validaciones en servidor
  - RLS policies testing
  
- [ ] **Semana 4 - Día 1-2**: Features avanzadas
  - Editar/eliminar registros (solo si pendientes)
  - Ver historial
  - Estadísticas personales
  
- [ ] **Semana 4 - Día 3-5**: Testing
  - Unit tests para server actions
  - Integration tests para flujo completo
  - E2E test con Playwright

**Entregables**:
- ✅ Voluntarios pueden registrar horas
- ✅ Upload de evidencias
- ✅ Historial completo
- ✅ Tests coverage >80%

---

#### **Semana 5: Módulo de Directores**
**Objetivo**: Directores validan horas

- [ ] **Día 1-2**: UI de Aprobación
  - Dashboard director
  - Lista de pendientes de aprobación
  - Vista detallada de registro con evidencia
  
- [ ] **Día 3-4**: Lógica de Validación
  - Server Actions para aprobar/rechazar
  - Notificaciones (email opcional)
  - Comentarios de validación
  
- [ ] **Día 5**: Reportes
  - Reportes de horas por voluntario
  - Estadísticas del área
  - Export a CSV/Excel

**Entregables**:
- ✅ Sistema de aprobación funcionando
- ✅ Notificaciones implementadas
- ✅ Reportes básicos

---

#### **Semana 6: Portal Público y Solicitudes**
**Objetivo**: Externos pueden solicitar charlas

- [ ] **Día 1-2**: Landing Page
  - Hero section
  - Sección de programas
  - Footer con contacto
  
- [ ] **Día 3-4**: Formulario de Solicitudes
  - Form público (sin auth)
  - Validación con Zod
  - Confirmación por email (opcional)
  
- [ ] **Día 5**: Gestión de Solicitudes (Admin)
  - Dashboard de solicitudes
  - Cambiar estados
  - Asignar a voluntarios

**Entregables**:
- ✅ Landing page atractiva
- ✅ Formulario de solicitudes
- ✅ Panel de gestión para admins

---

#### **Semana 7: Módulo de Administración**
**Objetivo**: Admins gestionan todo el sistema

- [ ] **Día 1-2**: Gestión de Usuarios
  - CRUD de usuarios
  - Cambiar roles
  - Ver estadísticas generales
  
- [ ] **Día 3-4**: Gestión de Programas y Áreas
  - CRUD programas
  - CRUD áreas
  - Asignar directores a áreas
  
- [ ] **Día 5**: Analytics Dashboard
  - Gráficos con Recharts
  - KPIs principales
  - Export de reportes

**Entregables**:
- ✅ Panel de admin completo
- ✅ Dashboard con métricas
- ✅ Reportes exportables

---

#### **Semana 8: Certificados**
**Objetivo**: Generar certificados PDF

- [ ] **Día 1-2**: UI de Certificados
  - Form para generar certificado
  - Previsualización
  - Lista de certificados emitidos
  
- [ ] **Día 3-4**: Generación de PDFs
  - Edge Function en Supabase para generar PDF
  - Diseño del certificado (template)
  - Código de verificación único
  
- [ ] **Día 5**: Verificación Pública
  - Página pública de verificación
  - API para validar código

**Entregables**:
- ✅ Generación de PDFs funcionando
- ✅ Sistema de verificación

---

#### **Semana 9: DevSecOps y Seguridad**
**Objetivo**: Hardening de seguridad

- [ ] **Día 1-2**: Security Scanning
  - Configurar Trivy, Dependabot
  - Implementar SonarCloud
  - Fix vulnerabilidades encontradas

- [ ] **Día 3-4**: Performance Optimization
  - Lighthouse audit
  - Image optimization
  - Code splitting
  - Caching strategies
  
- [ ] **Día 5**: Backup Strategy
  - Script de backup automático de DB
  - Backup de Storage
  - Documentar recovery procedure

**Entregables**:
- ✅ Security score >90%
- ✅ Performance score >85%
- ✅ Backup automation

---

#### **Semana 10: Deployment y Documentation**
**Objetivo**: Deploy a producción y documentación

- [ ] **Día 1-2**: Pre-deployment
  - Testing completo (E2E)
  - Load testing
  - SSL certificate setup
  
- [ ] **Día 3**: Deployment
  - Deploy a servidor UNI
  - Configurar Nginx
  - Setup monitoring
  
- [ ] **Día 4-5**: Documentación
  - README completo
  - Guía de deployment
  - Troubleshooting guide
  - Video tutorial (opcional)

**Entregables**:
- ✅ Aplicación en producción
- ✅ Documentación completa
- ✅ Monitoring activo

---

### 7.2 Roles y Responsabilidades

| Rol | Responsabilidades | Tiempo Estimado |
|-----|-------------------|-----------------|
| **Tech Lead** | Arquitectura, code reviews, decisiones técnicas | 15-20 hrs/semana |
| **Full-Stack Dev 1** | Frontend (UI/UX, componentes) | 20-25 hrs/semana |
| **Full-Stack Dev 2** | Backend (Server Actions, DB) | 20-25 hrs/semana |
| **DevOps** | CI/CD, Docker, deployment | 10-15 hrs/semana |
| **QA/Tester** | Testing, documentación | 10-15 hrs/semana |

**Nota**: Para un equipo universitario, estas responsabilidades pueden ser compartidas entre 2-4 personas.

---

## 8. Guías de Desarrollo

### 8.1 Convenciones de Código

#### Nomenclatura
```typescript
// ✅ Correcto
// Componentes: PascalCase
export function RegisterHoursForm() {}

// Variables y funciones: camelCase
const totalHours = calculateTotalHours();

// Constantes: UPPER_SNAKE_CASE
const MAX_HOURS_PER_DAY = 24;

// Archivos: kebab-case
// register-hours-form.tsx
// use-auth-hook.ts

// Tipos e Interfaces: PascalCase con I prefix opcional
interface User {}
type UserRole = 'admin' | 'member';

// Server Actions: verbNoun
async function registerHours() {}
async function approveHours() {}
```

#### Estructura de Componentes
```typescript
// ✅ Orden recomendado
import { useState } from 'react'; // External imports
import { Button } from '@/components/ui/button'; // UI imports
import { registerHours } from '@/actions/hours'; // Internal imports
import type { HourSchema } from '@/schemas/hours'; // Type imports

interface RegisterHoursFormProps {
  activityId: string;
  onSuccess?: () => void;
}

export function RegisterHoursForm({ 
  activityId, 
  onSuccess 
}: RegisterHoursFormProps) {
  // 1. State
  const [loading, setLoading] = useState(false);
  
  // 2. Hooks
  const form = useForm<HourSchema>();
  
  // 3. Handlers
  const handleSubmit = async (data: HourSchema) => {
    // ...
  };
  
  // 4. Effects
  useEffect(() => {
    // ...
  }, []);
  
  // 5. Render
  return (
    <form onSubmit={handleSubmit}>
      {/* JSX */}
    </form>
  );
}
```

#### Server Actions Pattern
```typescript
// src/actions/hours.ts
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

// 1. Define schema inline o importar
const schema = z.object({
  actividad_id: z.string().uuid(),
  fecha: z.string().date(),
  horas_trabajadas: z.number().min(0.5).max(24),
  descripcion: z.string().min(10),
});

// 2. Type-safe action
export async function registerHours(
  formData: z.infer<typeof schema>
): Promise<{ success: boolean; error?: string; data?: any }> {
  try {
    // 3. Validate
    const validated = schema.parse(formData);
    
    // 4. Auth check
    const supabase = createServerClient();
    const { data: { user } } = await supabase.auth.getUser();
    
    if (!user) {
      return { success: false, error: 'No autenticado' };
    }
    
    // 5. Business logic
    const { data, error } = await supabase
      .from('registro_horas')
      .insert({ ...validated, voluntario_id: user.id })
      .select()
      .single();
    
    if (error) throw error;
    
    // 6. Revalidate
    revalidatePath('/dashboard/member/hours');
    
    // 7. Return
    return { success: true, data };
  } catch (error) {
    console.error('Error in registerHours:', error);
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Error desconocido' 
    };
  }
}
```

### 8.2 Testing Strategy

#### Unit Tests (Vitest)
```typescript
// tests/unit/actions/hours.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { registerHours } from '@/actions/hours';

// Mock Supabase
vi.mock('@/lib/supabase/server', () => ({
  createServerClient: () => ({
    auth: {
      getUser: vi.fn().mockResolvedValue({
        data: { user: { id: 'user-123' } }
      })
    },
    from: vi.fn(() => ({
      insert: vi.fn(() => ({
        select: vi.fn(() => ({
          single: vi.fn().mockResolvedValue({
            data: { id: 'hour-123' },
            error: null
          })
        }))
      }))
    }))
  })
}));

describe('registerHours', () => {
  it('should register hours successfully', async () => {
    const result = await registerHours({
      actividad_id: 'act-123',
      fecha: '2025-01-15',
      horas_trabajadas: 4,
      descripcion: 'Preparación de charla'
    });
    
    expect(result.success).toBe(true);
    expect(result.data).toBeDefined();
  });
  
  it('should fail with invalid data', async () => {
    const result = await registerHours({
      actividad_id: 'invalid',
      fecha: 'invalid-date',
      horas_trabajadas: -1,
      descripcion: 'Short'
    });
    
    expect(result.success).toBe(false);
    expect(result.error).toBeDefined();
  });
});
```

#### Integration Tests
```typescript
// tests/integration/hours-workflow.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_TEST_URL!,
  process.env.SUPABASE_TEST_KEY!
);

describe('Hours Registration Workflow', () => {
  let userId: string;
  let activityId: string;
  
  beforeAll(async () => {
    // Setup test data
    const { data: user } = await supabase.auth.signUp({
      email: 'test@example.com',
      password: 'testpass123'
    });
    userId = user.user!.id;
    
    // Create test activity
    const { data: activity } = await supabase
      .from('actividades')
      .insert({ nombre: 'Test Activity' })
      .select()
      .single();
    activityId = activity.id;
  });
  
  it('should complete full workflow', async () => {
    // 1. Register hours
    const { data: registro } = await supabase
      .from('registro_horas')
      .insert({
        voluntario_id: userId,
        actividad_id: activityId,
        fecha: '2025-01-15',
        horas_trabajadas: 4,
        descripcion: 'Test work'
      })
      .select()
      .single();
    
    expect(registro.estado).toBe('pendiente');
    
    // 2. Director approves
    const { data: approved } = await supabase
      .from('registro_horas')
      .update({ 
        estado: 'aprobado',
        validado_por: userId 
      })
      .eq('id', registro.id)
      .select()
      .single();
    
    expect(approved.estado).toBe('aprobado');
  });
  
  afterAll(async () => {
    // Cleanup test data
    await supabase.from('registro_horas').delete().eq('voluntario_id', userId);
    await supabase.auth.admin.deleteUser(userId);
  });
});
```

#### E2E Tests (Playwright)
```typescript
// tests/e2e/volunteer-flow.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Volunteer Flow', () => {
  test('should register hours and see them in list', async ({ page }) => {
    // 1. Login
    await page.goto('/login');
    await page.fill('input[name="email"]', 'volunteer@test.com');
    await page.fill('input[name="password"]', 'testpass123');
    await page.click('button[type="submit"]');
    
    // 2. Navigate to register hours
    await expect(page).toHaveURL('/dashboard/member');
    await page.click('a[href="/dashboard/member/hours/new"]');
    
    // 3. Fill form
    await page.selectOption('select[name="actividad_id"]', { index: 1 });
    await page.fill('input[name="fecha"]', '2025-01-15');
    await page.fill('input[name="horas_trabajadas"]', '4');
    await page.fill('textarea[name="descripcion"]', 'Test description for E2E test');
    
    // 4. Upload evidence (optional)
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles('./tests/fixtures/test-evidence.pdf');
    
    // 5. Submit
    await page.click('button[type="submit"]');
    
    // 6. Verify success
    await expect(page.locator('text=Horas registradas exitosamente')).toBeVisible();
    
    // 7. Check in list
    await page.goto('/dashboard/member/hours');
    await expect(page.locator('text=Test description for E2E test')).toBeVisible();
    await expect(page.locator('text=4 horas')).toBeVisible();
    await expect(page.locator('[data-status="pendiente"]')).toBeVisible();
  });
});
```

### 8.3 Git Workflow

#### Branch Strategy
```
main (production)
  └── develop (staging)
      ├── feature/register-hours
      ├── feature/approve-hours
      ├── feature/certificates
      └── bugfix/auth-redirect
```

#### Commit Convention (Conventional Commits)
```bash
# Format: <type>(<scope>): <subject>

# Types:
feat: Nueva funcionalidad
fix: Bug fix
docs: Cambios en documentación
style: Formato, sin cambios de código
refactor: Refactorización
test: Añadir tests
chore: Cambios en build, configs

# Examples:
git commit -m "feat(hours): add register hours form"
git commit -m "fix(auth): redirect after login"
git commit -m "docs(readme): update deployment guide"
git commit -m "test(hours): add unit tests for validation"
```

#### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added that prove fix/feature works

## Screenshots (if applicable)
```

---

## 9. Deployment

### 9.1 Pre-Deployment Checklist

#### Security
- [ ] Variables de entorno en `.env.production` (NO commitear)
- [ ] SSL certificate configurado
- [ ] RLS policies probadas
- [ ] Secrets rotados
- [ ] CORS configurado correctamente
- [ ] Rate limiting activo

#### Performance
- [ ] Lighthouse score >85
- [ ] Images optimizadas
- [ ] Bundle size analizado
- [ ] Database indexes creados
- [ ] Caching configurado

#### Monitoring
- [ ] Sentry configurado (error tracking)
- [ ] Health check endpoint funcionando
- [ ] Logs configurados
- [ ] Backup automático activo

### 9.2 Paso a Paso: Deploy Inicial

#### 1. Preparar Servidor UNI
```bash
# Conectarse al servidor
ssh user@inspirate.uni.edu.pe

# Instalar Docker
sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl enable docker
sudo systemctl start docker

# Crear usuario para la app
sudo useradd -m -s /bin/bash inspirate
sudo usermod -aG docker inspirate

# Crear directorio del proyecto
sudo mkdir -p /opt/inspirate-uni
sudo chown inspirate:inspirate /opt/inspirate-uni
```

#### 2. Setup GitHub Container Registry Access
```bash
# En tu máquina local
# Crear Personal Access Token en GitHub con permisos de packages:read

# En el servidor
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

#### 3. Configurar Variables de Entorno
```bash
# En el servidor: /opt/inspirate-uni/.env.production
cat > .env.production << 'EOF'
NODE_ENV=production
NEXT_PUBLIC_SUPABASE_URL=https://yourproject.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
NEXT_PUBLIC_APP_URL=https://inspirate.uni.edu.pe
SENTRY_DSN=your-sentry-dsn
EOF

# Asegurar permisos
chmod 600 .env.production
```

#### 4. Deploy Docker Compose
```bash
# Copiar docker-compose.prod.yml al servidor
scp docker-compose.prod.yml user@inspirate.uni.edu.pe:/opt/inspirate-uni/

# En el servidor
cd /opt/inspirate-uni

# Pull latest image
docker pull ghcr.io/your-org/inspirate-uni:latest

# Start services
docker-compose -f docker-compose.prod.yml up -d

# Verificar que está corriendo
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f web
```

#### 5. Configurar Nginx con SSL
```bash
# Si la universidad maneja SSL, usar su certificado
# Si no, usar Let's Encrypt

# Copiar configuración de Nginx
sudo mkdir -p /opt/inspirate-uni/infrastructure/docker/nginx
sudo cp nginx.conf /opt/inspirate-uni/infrastructure/docker/nginx/

# SSL con Let's Encrypt (si aplica)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d inspirate.uni.edu.pe

# O copiar certificados existentes
sudo cp /path/to/cert.pem /opt/inspirate-uni/infrastructure/docker/nginx/ssl/
sudo cp /path/to/key.pem /opt/inspirate-uni/infrastructure/docker/nginx/ssl/

# Restart Nginx
docker-compose -f docker-compose.prod.yml restart nginx
```

#### 6. Verificación Post-Deployment
```bash
# Health check
curl https://inspirate.uni.edu.pe/api/health

# Check logs
docker-compose -f docker-compose.prod.yml logs -f --tail=50

# Monitor resources
docker stats
```

### 9.3 Deployment Automatizado (GitHub Actions)

Ya configurado en `.github/workflows/deploy.yml`, solo necesitas:

#### Setup Secrets en GitHub
```
Settings → Secrets and variables → Actions → New repository secret

SERVER_HOST: inspirate.uni.edu.pe
SERVER_USER: inspirate
SERVER_PORT: 22
SSH_PRIVATE_KEY: (contenido de tu private key)
SUPABASE_URL: https://yourproject.supabase.co
SUPABASE_ANON_KEY: your-anon-key
SUPABASE_SERVICE_ROLE_KEY: your-service-role-key
SLACK_WEBHOOK: (opcional, para notificaciones)
```

#### Trigger Deploy
```bash
# Automático: Push a main
git push origin main

# Manual: Workflow dispatch desde GitHub UI
```

### 9.4 Rollback Strategy

```bash
# En caso de problemas, hacer rollback a versión anterior

# Ver versiones disponibles
docker images | grep inspirate-uni

# Rollback
cd /opt/inspirate-uni
docker-compose -f docker-compose.prod.yml down

# Cambiar tag en docker-compose.prod.yml
# image: ghcr.io/your-org/inspirate-uni:previous-sha

docker-compose -f docker-compose.prod.yml up -d

# Verificar
curl https://inspirate.uni.edu.pe/api/health
```

### 9.5 Backup y Recovery

#### Script de Backup Automático
```bash
#!/bin/bash
# infrastructure/docker/scripts/backup.sh

set -e

BACKUP_DIR="/opt/inspirate-uni/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "🔄 Starting backup at $DATE"

# Backup Supabase (via pg_dump si es self-hosted, o via Supabase API)
# Para Supabase Cloud, usar su sistema de backups automático

# Backup de archivos locales (logs, configs)
tar -czf "$BACKUP_DIR/config_$DATE.tar.gz" \
  /opt/inspirate-uni/.env.production \
  /opt/inspirate-uni/docker-compose.prod.yml \
  /opt/inspirate-uni/infrastructure/

# Mantener solo últimos 7 días
find $BACKUP_DIR -type f -mtime +7 -delete

echo "✅ Backup completed: config_$DATE.tar.gz"
```

#### Cron Job para Backups Diarios
```bash
# Agregar a crontab
crontab -e

# Backup diario a las 2 AM
0 2 * * * /opt/inspirate-uni/infrastructure/docker/scripts/backup.sh >> /opt/inspirate-uni/logs/backup.log 2>&1
```

---

## 10. Mantenimiento y Monitoreo

### 10.1 Monitoring Stack Básico

#### Health Check Endpoint
```typescript
// src/app/api/health/route.ts
import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function GET() {
  try {
    // Check database connection
    const supabase = createClient();
    const { error } = await supabase.from('profiles').select('count').limit(1);
    
    if (error) throw error;
    
    return NextResponse.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'up',
        application: 'up'
      }
    });
  } catch (error) {
    return NextResponse.json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 503 });
  }
}
```

#### Uptime Monitoring con Uptime Kuma
```bash
# Instalar Uptime Kuma (opcional, en servidor separado)
docker run -d --restart=always \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  --name uptime-kuma \
  louislam/uptime-kuma:1

# Acceder a http://server:3001
# Configurar monitor para: https://inspirate.uni.edu.pe/api/health
```

#### Error Tracking con Sentry
```typescript
// src/lib/sentry.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
  
  // Only send errors from production
  beforeSend(event, hint) {
    if (process.env.NODE_ENV === 'development') {
      return null;
    }
    return event;
  },
});

// Usar en tu código
try {
  // ...
} catch (error) {
  Sentry.captureException(error);
  throw error;
}
```

### 10.2 Logs Management

#### Winston Logger Setup
```typescript
// src/lib/logger.ts
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'inspirate-uni' },
  transports: [
    new winston.transports.File({ 
      filename: 'logs/error.log', 
      level: 'error' 
    }),
    new winston.transports.File({ 
      filename: 'logs/combined.log' 
    }),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

export default logger;

// Uso en tu código
import logger from '@/lib/logger';

logger.info('User registered hours', { userId, hours: 4 });
logger.error('Failed to approve hours', { error, registroId });
```

#### Rotar Logs
```bash
# Instalar logrotate
sudo apt install logrotate

# Configurar: /etc/logrotate.d/inspirate-uni
/opt/inspirate-uni/logs/*.log {
  daily
  rotate 14
  compress
  delaycompress
  notifempty
  create 0640 inspirate inspirate
  sharedscripts
  postrotate
    docker-compose -f /opt/inspirate-uni/docker-compose.prod.yml restart web
  endscript
}
```

### 10.3 Mantenimiento Rutinario

#### Checklist Diario (Automatizado)
```bash
#!/bin/bash
# infrastructure/docker/scripts/daily-check.sh

echo "📊 Daily Health Check - $(date)"

# 1. Check if services are running
docker-compose -f /opt/inspirate-uni/docker-compose.prod.yml ps

# 2. Check disk space
df -h | grep -E '^/dev/'

# 3. Check logs for errors
tail -100 /opt/inspirate-uni/logs/error.log | grep -i "error"

# 4. Database backup status
ls -lh /opt/inspirate-uni/backups/ | tail -5

# 5. Hit health endpoint
curl -f https://inspirate.uni.edu.pe/api/health || echo "❌ Health check failed"

echo "✅ Daily check completed"
```

#### Checklist Semanal
- [ ] Revisar logs de errores
- [ ] Verificar espacio en disco
- [ ] Revisar métricas de Sentry
- [ ] Verificar backups
- [ ] Actualizar dependencias (Dependabot PRs)

#### Checklist Mensual
- [ ] Revisar security alerts de GitHub
- [ ] Actualizar Next.js y dependencias mayores
- [ ] Revisar y optimizar queries lentas en DB
- [ ] Analizar performance (Lighthouse)
- [ ] Revisar y limpiar images de Docker viejas

### 10.4 Troubleshooting Common Issues

#### Issue: Aplicación no responde
```bash
# 1. Check if container is running
docker ps | grep inspirate-web

# 2. Check logs
docker logs inspirate-web --tail=100

# 3. Check resource usage
docker stats --no-stream

# 4. Restart container
docker-compose -f docker-compose.prod.yml restart web

# 5. If persists, check Nginx
docker logs inspirate-nginx --tail=100
```

#### Issue: Database connection errors
```bash
# 1. Verify Supabase status
# Check https://status.supabase.com/

# 2. Test connection from container
docker exec -it inspirate-web sh
curl https://yourproject.supabase.co/rest/v1/

# 3. Verify environment variables
docker exec inspirate-web printenv | grep SUPABASE
```

#### Issue: High memory usage
```bash
# 1. Check memory usage
docker stats --no-stream

# 2. Restart with memory limit
# Editar docker-compose.prod.yml:
# deploy:
#   resources:
#     limits:
#       memory: 512M

# 3. Restart
docker-compose -f docker-compose.prod.yml up -d
```

---

## 11. Apéndices

### 11.1 Comandos Útiles

```bash
# Docker
docker-compose up -d                    # Start services
docker-compose down                     # Stop services
docker-compose logs -f web              # Follow logs
docker-compose ps                       # List services
docker-compose restart web              # Restart service
docker system prune -af                 # Cleanup everything

# Git
git fetch origin                        # Update from remote
git checkout -b feature/new-feature     # Create branch
git add .                              # Stage changes
git commit -m "feat: description"      # Commit
git push origin feature/new-feature    # Push branch

# Supabase CLI (local development)
npx supabase init                      # Initialize
npx supabase start                     # Start local
npx supabase db reset                  # Reset DB
npx supabase gen types typescript --local # Generate types

# Next.js
npm run dev                            # Development
npm run build                          # Production build
npm run start                          # Start production
npm run lint                           # Lint code
npm run type-check                     # TypeScript check
```

### 11.2 Variables de Entorno Completas

```bash
# .env.example - TODAS las variables posibles

# ============================================
# SUPABASE
# ============================================
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# ============================================
# APPLICATION
# ============================================
NEXT_PUBLIC_APP_URL=https://inspirate.uni.edu.pe
NODE_ENV=production
PORT=3000

# ============================================
# MONITORING
# ============================================
SENTRY_DSN=
SENTRY_AUTH_TOKEN=
NEXT_PUBLIC_SENTRY_DSN=

# ============================================
# EMAIL (Optional)
# ============================================
RESEND_API_KEY=
EMAIL_FROM=noreply@inspirate.uni.edu.pe

# ============================================
# STORAGE
# ============================================
SUPABASE_STORAGE_BUCKET=evidencias
MAX_FILE_SIZE=5242880  # 5MB in bytes

# ============================================
# RATE LIMITING (Optional)
# ============================================
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=60000  # 1 minute in ms

# ============================================
# FEATURE FLAGS (Optional)
# ============================================
ENABLE_CERTIFICATES=true
ENABLE_NOTIFICATIONS=true
ENABLE_ANALYTICS=true
```

### 11.3 Recursos y Links

#### Documentación Oficial
- [Next.js 14 Docs](https://nextjs.org/docs)
- [Supabase Docs](https://supabase.com/docs)
- [shadcn/ui](https://ui.shadcn.com/)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Zod](https://zod.dev/)
- [React Hook Form](https://react-hook-form.com/)

#### DevSecOps Tools
- [Trivy](https://aquasecurity.github.io/trivy/)
- [Dependabot](https://docs.github.com/en/code-security/dependabot)
- [SonarCloud](https://sonarcloud.io/)
- [Sentry](https://sentry.io/)

#### Learning Resources
- [Next.js App Router Tutorial](https://nextjs.org/learn)
- [Supabase Auth Tutorial](https://supabase.com/docs/guides/auth)
- [Docker Compose Guide](https://docs.docker.com/compose/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

## 12. Changelog y Versionado

### Version 1.0.0 (Enero 2025)
- ✅ Sistema de autenticación con roles
- ✅ Módulo de registro de horas
- ✅ Módulo de validación (directores)
- ✅ Portal público de solicitudes
- ✅ Dashboard administrativo
- ✅ Generación de certificados
- ✅ CI/CD completo
- ✅ Deployment en producción