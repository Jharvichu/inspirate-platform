-- Habilitamos la extensión para generar IDs aleatorios seguros (UUIDs)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Creamos tipos de datos personalizados (ENUMS)
CREATE TYPE user_status AS ENUM ('Active', 'Deleted');
CREATE TYPE period_state_enum AS ENUM ('Planning', 'Active', 'Closed');
CREATE TYPE call_state_enum AS ENUM ('Draft', 'Open', 'Closed', 'Archived');
CREATE TYPE application_state_enum AS ENUM ('Pending', 'Under_Review', 'Interviewed', 'Accepted', 'Rejected', 'Waitlist');
CREATE TYPE assignment_state_enum AS ENUM ('Active', 'Suspended', 'Resigned', 'Finished', 'Terminated');
CREATE TYPE record_state_enum AS ENUM ('Pending', 'Approved', 'Rejected', ' Correction_Requested');
CREATE TYPE availability_state_enum AS ENUM ('Available', 'Booked', 'Cancelled');
CREATE TYPE session_state_enum AS ENUM ('Scheduled', 'Completed', 'No_Show', 'Cancelled_By_Student', 'Cancelled_By_Volunteer');

-- Tipos de Usuario
CREATE TABLE user_types (
    user_type_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Programas
CREATE TABLE programs (
    program_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- Gestiones
CREATE TABLE management_periods (
    period_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    state period_state_enum DEFAULT 'Active'
);

-- Roles
CREATE TABLE organizational_roles (
    rol_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Tipos de Actividad
CREATE TABLE activity_types (
    activity_type_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    weight DECIMAL(5,2) DEFAULT 1.00
);

-- Áreas
CREATE TABLE areas (
    area_id SERIAL PRIMARY KEY,
    program_id INTEGER REFERENCES programs(program_id),
    name TEXT NOT NULL,
    UNIQUE(program_id, name)
);

-- Convocatorias
CREATE TABLE volunteers_calls (
    call_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_id INTEGER REFERENCES management_periods(period_id),
    name TEXT NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    state call_state_enum DEFAULT 'Draft'
);

-- Esta tabla es la extensión pública de 'auth.users' de Supabase
-- El Password se gestiona en auth.users
CREATE TABLE users (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    user_type_id INTEGER REFERENCES user_types(user_type_id),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    dni TEXT UNIQUE,
    photo_url TEXT,
    email TEXT UNIQUE NOT NULL, 
    university TEXT,
    university_code TEXT,
    phone_number TEXT,
    birthday_date DATE,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status user_status DEFAULT 'Active'
);

-- Historial Inspiraditos
CREATE TABLE position_assignments (
    assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    area_id INTEGER REFERENCES areas(area_id),
    rol_id INTEGER REFERENCES organizational_roles(rol_id),
    period_id INTEGER REFERENCES management_periods(period_id),
    start_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    state assignment_state_enum DEFAULT 'Active'
);

-- Postulaciones de Aspirantes
CREATE TABLE applications (
    application_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    call_id UUID REFERENCES volunteers_calls(call_id) ON DELETE CASCADE,
    area_id INTEGER REFERENCES areas(area_id),
    application_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    state application_state_enum DEFAULT 'Pending'
);

-- Registro de Horas
CREATE TABLE activity_records (
    record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID REFERENCES position_assignments(assignment_id),
    activity_type_id INTEGER REFERENCES activity_types(activity_type_id),
    description TEXT,
    performed_date DATE NOT NULL,
    recorded_hours DECIMAL(4,2) NOT NULL CHECK (recorded_hours > 0),
    evidence_url TEXT,
    state record_state_enum DEFAULT 'Pending',
    admin_comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Disponibilidad
CREATE TABLE availability (
    availability_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID REFERENCES position_assignments(assignment_id),
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    state availability_state_enum DEFAULT 'Available'
);

-- Sesiones Confirmadas
CREATE TABLE vocational_sessions (
    sessions_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    beneficiary_user_id UUID REFERENCES users(user_id),
    availability_id UUID REFERENCES availability(availability_id) UNIQUE,
    meeting_url TEXT,
    session_note TEXT,
    state session_state_enum DEFAULT 'Scheduled',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TRIGGERS

-- Función para copiar el usuario nuevo desde Auth a Public
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (user_id, email, first_name, last_name)
  VALUES (
    NEW.id,
    NEW.email,
    -- Intentamos sacar el nombre de los metadatos, si no hay, ponemos placeholder
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'Usuario'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'Nuevo')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  role_id_to_assign INTEGER;
  role_requested_text TEXT;
BEGIN
  -- A. Leemos si el Frontend pidió un rol específico (ej: 'Aspirante')
  role_requested_text := NEW.raw_user_meta_data->>'user_role';

  -- B. Si pidieron un rol, buscamos su ID en la base de datos
  IF role_requested_text IS NOT NULL THEN
    SELECT user_type_id INTO role_id_to_assign 
    FROM public.user_types 
    WHERE name = role_requested_text;
  END IF;

  -- C. EL PLAN DE EMERGENCIA (Default Seguro)
  IF role_id_to_assign IS NULL THEN
    SELECT user_type_id INTO role_id_to_assign 
    FROM public.user_types 
    WHERE name = 'Externo'; 
  END IF;

  -- D. Insertamos el usuario en tu tabla pública
  INSERT INTO public.users (
    user_id,
    email,
    user_type_id,
    first_name,
    last_name,
    dni,
    photo_url
    -- En Construccion
  )
  VALUES (
    NEW.id,
    NEW.email,
    role_id_to_assign,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'Usuario'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'Nuevo'),
    NEW.raw_user_meta_data->>'dni',
    NEW.raw_user_meta_data->>'avatar_url'
    -- En Construccion
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- El Disparador
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Habilitamos RLS en todas las tablas
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE management_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteers_calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizational_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE position_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE vocational_sessions ENABLE ROW LEVEL SECURITY;