-- 1986 FITNESS WONHEUNG BI DATA CRM
-- 개인정보 최소화: 전화번호 및 연락처 컬럼을 두지 않는다.
create extension if not exists pgcrypto;

create type public.staff_role as enum ('지점장','상담담당','트레이너','기타');
create type public.record_status as enum ('활성','비활성');

create table public.staff (
  id uuid primary key default gen_random_uuid(), staff_code text unique not null,
  name text not null, role public.staff_role not null, status public.record_status not null default '활성',
  hired_on date, left_on date, note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.competitors (
  id uuid primary key default gen_random_uuid(), competitor_code text unique not null, name text not null,
  status text not null, position text not null, target_customer text, facility_features text,
  pt_features text, other_features text, note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.market_snapshots (
  id uuid primary key default gen_random_uuid(), snapshot_date date not null unique, season text not null,
  market_status text not null, active_competitor_count integer check(active_competitor_count>=0),
  closing_competitor_count integer check(closing_competitor_count>=0), new_competitor_count integer check(new_competitor_count>=0),
  note text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.competitor_prices (
  id uuid primary key default gen_random_uuid(), price_code text unique not null,
  competitor_id uuid not null references public.competitors(id), checked_on date not null, product_type text not null,
  duration_months integer check(duration_months>0), pt_sessions integer check(pt_sessions>0), list_price numeric(12,0) check(list_price>=0),
  displayed_price numeric(12,0) not null check(displayed_price>=0), vat_included boolean not null,
  sportswear_benefit text, locker_benefit text, other_benefit text, is_promotion boolean not null default false,
  promotion_start date, promotion_end date, source text not null, note text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz,
  check(promotion_end is null or promotion_start is null or promotion_end>=promotion_start)
);
create table public.products (
  id uuid primary key default gen_random_uuid(), product_code text unique not null, name text not null,
  product_type text not null, membership_months integer check(membership_months>0), pt_sessions integer check(pt_sessions>0),
  list_price numeric(12,0) not null check(list_price>=0), sales_start date not null, sales_end date,
  sales_status text not null, target_customer text, note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz, check(sales_end is null or sales_end>=sales_start)
);
create table public.campaigns (
  id uuid primary key default gen_random_uuid(), campaign_code text unique not null, name text not null,
  starts_on date not null, ends_on date, channel text not null, content_type text not null,
  product_id uuid references public.products(id), key_message text, cta text, status text not null,
  cost numeric(12,0) check(cost>=0), note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz, check(ends_on is null or ends_on>=starts_on)
);
create table public.exposures (
  id uuid primary key default gen_random_uuid(), exposure_date date not null, campaign_id uuid not null references public.campaigns(id),
  channel text not null, impressions integer check(impressions>=0), views integer check(views>=0), clicks integer check(clicks>=0),
  phone_clicks integer check(phone_clicks>=0), directions integer check(directions>=0), inquiries integer check(inquiries>=0),
  other_reactions integer check(other_reactions>=0), note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz, unique(exposure_date,campaign_id)
);
create table public.leads (
  id uuid primary key default gen_random_uuid(), lead_code text unique not null, first_contact_date date not null,
  name text not null, gender text not null, age_group text not null, source text not null, source_detail text,
  campaign_id uuid references public.campaigns(id), inquiry_method text not null, goal text not null,
  interested_product_id uuid references public.products(id), exercise_experience text not null, status text not null,
  staff_id uuid references public.staff(id), note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.consultations (
  id uuid primary key default gen_random_uuid(), consultation_code text unique not null, lead_id uuid not null references public.leads(id),
  consultation_date date not null, staff_id uuid not null references public.staff(id), goal text,
  desired_frequency text, desired_time text, interested_product_id uuid references public.products(id), budget_band text,
  competitor_status text not null, competitor_id uuid references public.competitors(id), competitor_product text,
  competitor_price numeric(12,0) check(competitor_price>=0), price_resistance text not null, price_statement text,
  facility_interest text, pt_interest text, equipment_interest text, trainer_interest text,
  decision_factor_1 text, decision_factor_2 text, rejection_factor_1 text, rejection_factor_2 text,
  result text not null, follow_up_needed boolean not null, follow_up_date date, note text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz,
  check(not follow_up_needed or follow_up_date is not null)
);
create table public.visits (
  id uuid primary key default gen_random_uuid(), visit_code text unique not null, lead_id uuid not null references public.leads(id),
  consultation_id uuid references public.consultations(id), scheduled_date date, actual_date date, visit_type text not null,
  status text not null, staff_id uuid not null references public.staff(id), center_tour boolean not null,
  pt_consultation boolean not null, trial boolean not null, note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz,
  check(status<>'방문완료' or actual_date is not null)
);
create table public.members (
  id uuid primary key default gen_random_uuid(), member_code text unique not null, name text not null,
  gender text not null, age_group text not null, first_lead_id uuid unique references public.leads(id), first_join_date date not null,
  first_source text, current_trainer_id uuid references public.staff(id), status text not null, note text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.sales (
  id uuid primary key default gen_random_uuid(), sale_code text unique not null, member_id uuid references public.members(id),
  lead_id uuid references public.leads(id), consultation_id uuid references public.consultations(id), payment_date date not null,
  product_id uuid not null references public.products(id), sale_type text not null, list_price numeric(12,0) not null check(list_price>=0),
  payment_amount numeric(12,0) not null check(payment_amount>=0), staff_id uuid not null references public.staff(id),
  pt_trainer_id uuid references public.staff(id), note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz,
  check(payment_amount<=list_price or sale_type in ('추가구매','업셀','기타'))
);
create table public.membership_contracts (
  id uuid primary key default gen_random_uuid(), contract_code text unique not null, member_id uuid not null references public.members(id),
  product_id uuid not null references public.products(id), sale_id uuid unique not null references public.sales(id),
  starts_on date not null, ends_on date not null, status text not null, paused_days integer not null default 0 check(paused_days>=0),
  previous_contract_id uuid references public.membership_contracts(id), note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz, check(ends_on>=starts_on)
);
create table public.attendance (
  id uuid primary key default gen_random_uuid(), member_id uuid not null references public.members(id),
  contract_id uuid references public.membership_contracts(id), attendance_date date not null,
  check_in timestamptz, check_out timestamptz, input_method text not null default '수기', note text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz,
  unique(member_id,attendance_date)
);
create table public.pt_contracts (
  id uuid primary key default gen_random_uuid(), pt_contract_code text unique not null, member_id uuid not null references public.members(id),
  product_id uuid not null references public.products(id), sale_id uuid unique not null references public.sales(id),
  trainer_id uuid not null references public.staff(id), purchased_sessions integer not null check(purchased_sessions>0),
  status text not null, previous_pt_contract_id uuid references public.pt_contracts(id), note text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.pt_sessions (
  id uuid primary key default gen_random_uuid(), pt_contract_id uuid not null references public.pt_contracts(id),
  member_id uuid not null references public.members(id), trainer_id uuid not null references public.staff(id),
  session_date date not null, status text not null, deducted_sessions integer not null default 1 check(deducted_sessions>=0),
  note text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.renewals (
  id uuid primary key default gen_random_uuid(), renewal_code text unique not null, member_id uuid not null references public.members(id),
  renewal_date date not null, previous_contract_id uuid not null references public.membership_contracts(id),
  new_contract_id uuid unique not null references public.membership_contracts(id), sale_id uuid unique not null references public.sales(id),
  staff_id uuid not null references public.staff(id), renewal_factor_1 text not null, renewal_factor_2 text,
  price_resistance text not null, considered_other_center boolean not null, competitor_id uuid references public.competitors(id),
  note text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.churns (
  id uuid primary key default gen_random_uuid(), churn_code text unique not null, member_id uuid not null references public.members(id),
  confirmed_on date not null, last_contract_id uuid not null references public.membership_contracts(id), churn_type text not null,
  churn_reason text not null, price_related boolean not null, moved_to_other_center boolean not null,
  competitor_id uuid references public.competitors(id), note text, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz
);
create table public.market_events (
  id uuid primary key default gen_random_uuid(), event_code text unique not null, starts_on date not null, ends_on date,
  event_type text not null, name text not null, impact_scope text not null, competitor_id uuid references public.competitors(id),
  campaign_id uuid references public.campaigns(id), product_id uuid references public.products(id),
  cost numeric(12,0) check(cost>=0), description text not null, created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz, check(ends_on is null or ends_on>=starts_on)
);

-- 관리자 1인용 허용 목록. auth.users의 UUID만 저장한다.
create table public.admin_users (user_id uuid primary key references auth.users(id) on delete cascade, created_at timestamptz not null default now());
create or replace function public.is_crm_admin() returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.admin_users where user_id=auth.uid()) $$;

do $$ declare t text; begin
  foreach t in array array['staff','competitors','market_snapshots','competitor_prices','products','campaigns','exposures','leads','consultations','visits','members','sales','membership_contracts','attendance','pt_contracts','pt_sessions','renewals','churns','market_events'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('create policy "crm_admin_all" on public.%I for all to authenticated using (public.is_crm_admin()) with check (public.is_crm_admin())',t);
  end loop;
end $$;
alter table public.admin_users enable row level security;
create policy "admin_self_read" on public.admin_users for select to authenticated using(user_id=auth.uid());

create index leads_first_contact_idx on public.leads(first_contact_date);
create index consultations_lead_date_idx on public.consultations(lead_id,consultation_date);
create index visits_lead_date_idx on public.visits(lead_id,actual_date);
create index sales_member_date_idx on public.sales(member_id,payment_date);
create index attendance_member_date_idx on public.attendance(member_id,attendance_date);
create index market_events_date_idx on public.market_events(starts_on,ends_on);
