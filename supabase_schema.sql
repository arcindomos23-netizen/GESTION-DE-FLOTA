-- =====================================================================
-- Gestión de Flota · Interaseo — Esquema para Supabase
-- Ejecutar completo en: Supabase > SQL Editor > New query > Run
-- =====================================================================

-- 1. Tabla de vehículos (alimenta las sugerencias y el filtro del panel)
create table if not exists public.vehiculos (
    id          bigint generated always as identity primary key,
    codigo      text,                       -- código interno / móvil
    placa       text not null unique,       -- en MAYÚSCULAS, ej: ABC123
    descripcion text,
    creado_en   timestamptz not null default now()
);

-- 2. Tabla de registros diarios de los conductores
create table if not exists public.registros (
    id      bigint generated always as identity primary key,
    nombre  text not null,
    placa   text not null references public.vehiculos(placa) on update cascade,
    ruta    text,
    km      numeric not null check (km >= 0),
    horas   numeric not null check (horas >= 0),
    fecha   timestamptz not null default now()
);

-- Índice para consultar rápido el último registro de cada vehículo
create index if not exists registros_placa_fecha_idx
    on public.registros (placa, fecha desc);

-- 3. Tabla de administradores autorizados (solo modificable desde Supabase)
create table if not exists public.admins (
    email     text primary key,
    creado_en timestamptz not null default now()
);

-- Función auxiliar para validar si el usuario autenticado es administrador
create or replace function public.es_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1
        from public.admins
        where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
    );
$$;

-- 4. Permisos de esquema/tablas y Seguridad (RLS)
grant usage on schema public to anon, authenticated;

-- Admins: cada usuario autenticado solo puede verificar si su propio correo es admin
revoke insert, update, delete on public.admins from anon, authenticated;
grant select on public.admins to authenticated;

-- Vehículos: lectura pública (conductores y consultores); alta y baja SOLO admin
revoke insert, update, delete on public.vehiculos from anon;
grant select on public.vehiculos to anon, authenticated;
grant insert, delete on public.vehiculos to authenticated;

-- Registros: lectura e inserción para conductores y panel de consulta
grant select, insert on public.registros to anon, authenticated;
grant usage, select on all sequences in schema public to anon, authenticated;

alter table public.admins enable row level security;
alter table public.vehiculos enable row level security;
alter table public.registros enable row level security;

drop policy if exists "consultar propio rol admin" on public.admins;
create policy "consultar propio rol admin" on public.admins
    for select to authenticated
    using (lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')));

-- Cualquiera con la app puede leer la lista de vehículos
drop policy if exists "leer vehiculos" on public.vehiculos;
create policy "leer vehiculos" on public.vehiculos
    for select to anon, authenticated using (true);

-- EXCLUSIVAMENTE el usuario registrado en public.admins puede agregar o eliminar vehículos
drop policy if exists "insertar vehiculos" on public.vehiculos;
create policy "insertar vehiculos" on public.vehiculos
    for insert to authenticated with check (public.es_admin());

drop policy if exists "eliminar vehiculos" on public.vehiculos;
create policy "eliminar vehiculos" on public.vehiculos
    for delete to authenticated using (public.es_admin());

-- El formulario puede leer registros (para comparar con el anterior)
-- y el panel puede consultarlos
drop policy if exists "leer registros" on public.registros;
create policy "leer registros" on public.registros
    for select to anon, authenticated using (true);

-- El formulario puede insertar registros (no editar ni borrar)
drop policy if exists "insertar registros" on public.registros;
create policy "insertar registros" on public.registros
    for insert to anon, authenticated with check (true);

-- 4. Vehículos de ejemplo — REEMPLAZA con tu flota real
insert into public.vehiculos (codigo, placa, descripcion) values
    ('M-001', 'ABC123', 'Compactador'),
    ('M-002', 'DEF456', 'Volqueta'),
    ('M-003', 'GHI789', 'Camioneta')
on conflict (placa) do nothing;
