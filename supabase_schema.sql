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

-- 3. Permisos de esquema/tablas y Seguridad (RLS)
grant usage on schema public to anon, authenticated;
grant select on public.vehiculos to anon, authenticated;
grant select, insert on public.registros to anon, authenticated;
grant usage, select on all sequences in schema public to anon, authenticated;

alter table public.vehiculos enable row level security;
alter table public.registros enable row level security;

-- Cualquiera con la app puede leer la lista de vehículos
drop policy if exists "leer vehiculos" on public.vehiculos;
create policy "leer vehiculos" on public.vehiculos
    for select to anon, authenticated using (true);

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
