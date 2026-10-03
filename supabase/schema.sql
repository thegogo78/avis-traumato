-- Avis Traumato : base de données du prototype (Supabase).
-- À coller une seule fois dans Supabase > SQL Editor > New query, puis "Run".

-- Profils : nom affiché et rôle par défaut de chaque testeur.
create table if not exists public.profils (
  id uuid primary key references auth.users (id) on delete cascade,
  nom text not null,
  role text not null default 'mg' check (role in ('mg', 'ortho')),
  created_at timestamptz not null default now()
);

-- Demandes d'avis : le dossier complet est stocké en JSON dans "data".
create table if not exists public.demandes (
  id text primary key,
  creator uuid not null default auth.uid() references auth.users (id) on delete cascade,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Photos et clichés, compressés côté navigateur (JPEG en data URI).
create table if not exists public.pieces (
  id text primary key,
  demande text not null references public.demandes (id) on delete cascade,
  creator uuid not null default auth.uid() references auth.users (id) on delete cascade,
  data text not null check (length(data) < 400000),
  created_at timestamptz not null default now()
);

alter table public.profils enable row level security;
alter table public.demandes enable row level security;
alter table public.pieces enable row level security;

-- Tout testeur connecté voit les profils, les demandes et les pièces.
create policy "profils lisibles" on public.profils for select to authenticated using (true);
create policy "profil personnel" on public.profils for insert to authenticated with check (id = auth.uid());
create policy "profil modifiable" on public.profils for update to authenticated using (id = auth.uid());

create policy "demandes lisibles" on public.demandes for select to authenticated using (true);
create policy "demande creee par soi" on public.demandes for insert to authenticated with check (creator = auth.uid());
-- L'équipe doit pouvoir prendre la demande, poser une question et rendre l'avis.
create policy "demandes modifiables" on public.demandes for update to authenticated using (true) with check (true);
create policy "demande supprimee par son auteur" on public.demandes for delete to authenticated using (creator = auth.uid());

create policy "pieces lisibles" on public.pieces for select to authenticated using (true);
create policy "piece ajoutee par soi" on public.pieces for insert to authenticated with check (creator = auth.uid());
create policy "piece supprimee par son auteur" on public.pieces for delete to authenticated using (creator = auth.uid());

-- Empêche de changer l'auteur d'une demande lors d'une modification.
create or replace function public.demandes_garde() returns trigger language plpgsql as $$
begin
  new.creator := old.creator;
  new.updated_at := now();
  return new;
end $$;
drop trigger if exists demandes_garde on public.demandes;
create trigger demandes_garde before update on public.demandes for each row execute function public.demandes_garde();

-- Mises à jour en direct.
alter publication supabase_realtime add table public.demandes;
