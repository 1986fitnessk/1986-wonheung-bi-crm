-- Phase 1: 상권·상품·PT Data Foundation
-- 이전 확정 원칙에 따라 회원 전화번호·상세주소·개인 좌표는 저장하지 않는다.

create table public.areas (
  id uuid primary key default gen_random_uuid(), area_code text unique not null, name text not null,
  area_type text not null, market_grade text not null check(market_grade in ('Core','Primary','Secondary','Expansion')),
  admin_dong text not null, legal_dong text, distance_band text not null,
  center_distance_km numeric(6,2) check(center_distance_km>=0), walking_minutes integer check(walking_minutes>=0),
  driving_minutes integer check(driving_minutes>=0), population_total integer check(population_total>=0),
  households integer check(households>=0), population_20 integer check(population_20>=0), population_30 integer check(population_30>=0),
  population_40 integer check(population_40>=0), population_50_plus integer check(population_50_plus>=0),
  male_population integer check(male_population>=0), female_population integer check(female_population>=0),
  working_population integer check(working_population>=0), residential_population integer check(residential_population>=0),
  floating_population integer check(floating_population>=0), apartment_households integer check(apartment_households>=0),
  officetel_households integer check(officetel_households>=0), accessibility_score numeric(5,2) check(accessibility_score between 0 and 100),
  parking_score numeric(5,2) check(parking_score between 0 and 100), transit_score numeric(5,2) check(transit_score between 0 and 100),
  reference_date date not null, confidence_grade text not null check(confidence_grade in ('A','B','C','D')),
  source text not null, last_updated timestamptz not null default now(), created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz
);

create table public.apartments (
  id uuid primary key default gen_random_uuid(), complex_code text unique not null, name text not null,
  area_id uuid not null references public.areas(id), households integer not null check(households>0),
  building_count integer check(building_count>0), completion_year integer check(completion_year between 1900 and 2100),
  center_distance_km numeric(6,2) check(center_distance_km>=0), walking_minutes integer check(walking_minutes>=0),
  driving_minutes integer check(driving_minutes>=0), nearest_station text, station_distance_km numeric(6,2) check(station_distance_km>=0),
  parking_access_score numeric(5,2) check(parking_access_score between 0 and 100), marketing_status text not null default '미진행',
  last_marketing_date date, marketing_channel text, reference_date date not null,
  confidence_grade text not null check(confidence_grade in ('A','B','C','D')), source text not null,
  last_updated timestamptz not null default now(), created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), deleted_at timestamptz
);

create table public.pois (
  id uuid primary key default gen_random_uuid(), poi_code text unique not null, name text not null, category text not null,
  area_id uuid not null references public.areas(id), center_distance_km numeric(6,2) check(center_distance_km>=0),
  walking_minutes integer check(walking_minutes>=0), driving_minutes integer check(driving_minutes>=0),
  estimated_population integer check(estimated_population>=0), employee_count integer check(employee_count>=0),
  visitor_volume integer check(visitor_volume>=0), target_age_fit_score numeric(5,2) check(target_age_fit_score between 0 and 100),
  pt_potential_score numeric(5,2) check(pt_potential_score between 0 and 100),
  partnership_potential_score numeric(5,2) check(partnership_potential_score between 0 and 100),
  partnership_status text not null default '미접촉', last_checked date not null,
  confidence_grade text not null check(confidence_grade in ('A','B','C','D')), source text not null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz
);

create table public.promotions (
  id uuid primary key default gen_random_uuid(), promotion_code text unique not null, name text not null,
  starts_on date not null, ends_on date, product_id uuid not null references public.products(id),
  normal_price numeric(12,0) not null check(normal_price>=0), promotion_price numeric(12,0) not null check(promotion_price>=0),
  benefits text, target_area_id uuid references public.areas(id), target_customer text, status text not null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz,
  check(ends_on is null or ends_on>=starts_on), check(promotion_price<=normal_price)
);

alter table public.products add column if not exists variable_cost numeric(12,0) check(variable_cost>=0);
alter table public.members add column if not exists area_id uuid references public.areas(id);
alter table public.members add column if not exists complex_id uuid references public.apartments(id);
alter table public.members add column if not exists distance_band text;
alter table public.members add column if not exists primary_transport text;
alter table public.members add column if not exists station_route text;
alter table public.leads add column if not exists area_id uuid references public.areas(id);
alter table public.leads add column if not exists complex_id uuid references public.apartments(id);
alter table public.competitors add column if not exists area_id uuid references public.areas(id);
alter table public.competitors add column if not exists center_distance_km numeric(6,2) check(center_distance_km>=0);
alter table public.competitors add column if not exists business_type text;
alter table public.competitors add column if not exists facility_size_sqm numeric(10,2) check(facility_size_sqm>=0);
alter table public.competitors add column if not exists is_24h boolean;
alter table public.competitors add column if not exists review_count integer check(review_count>=0);
alter table public.competitors add column if not exists rating numeric(3,2) check(rating between 0 and 5);
alter table public.competitors add column if not exists main_marketing_message text;
alter table public.competitors add column if not exists last_checked date;
alter table public.competitors add column if not exists confidence_grade text check(confidence_grade in ('A','B','C','D'));
alter table public.competitors add column if not exists source text;
alter table public.membership_contracts add column if not exists payment_method text;
alter table public.membership_contracts add column if not exists promotion_id uuid references public.promotions(id);
alter table public.membership_contracts add column if not exists refund_status text not null default '환불없음';
alter table public.membership_contracts add column if not exists refund_amount numeric(12,0) not null default 0 check(refund_amount>=0);
alter table public.pt_contracts add column if not exists service_sessions integer not null default 0 check(service_sessions>=0);
alter table public.pt_contracts add column if not exists starts_on date;
alter table public.pt_contracts add column if not exists expires_on date;
alter table public.pt_contracts add column if not exists refund_status text not null default '환불없음';
alter table public.pt_contracts add column if not exists refund_amount numeric(12,0) not null default 0 check(refund_amount>=0);
alter table public.campaigns add column if not exists area_id uuid references public.areas(id);
alter table public.campaigns add column if not exists complex_id uuid references public.apartments(id);
alter table public.campaigns add column if not exists poi_id uuid references public.pois(id);
alter table public.campaigns add column if not exists actual_spend numeric(12,0) check(actual_spend>=0);

-- 공헌이익은 가격·원가 원천값에서 계산하며 저장하지 않는다.
create or replace view public.product_economics as
select id, product_code, name, product_type, list_price, variable_cost,
       case when variable_cost is null then null else list_price-variable_cost end as contribution_margin,
       case when variable_cost is null or list_price=0 then null else (list_price-variable_cost)/list_price end as contribution_margin_ratio
from public.products where deleted_at is null;

-- 외부 데이터의 계산 KPI는 중복 저장하지 않고 View/BI Layer에서 산출한다.
create or replace view public.apartment_performance as
select a.id as complex_id, a.name as complex_name, a.area_id, a.households,
       count(distinct m.id) filter(where m.deleted_at is null) as current_members,
       count(distinct m.id) filter(where m.status='이용중' and m.deleted_at is null) as active_members,
       coalesce(sum(s.payment_amount) filter(where s.deleted_at is null),0) as total_revenue
from public.apartments a
left join public.members m on m.complex_id=a.id
left join public.sales s on s.member_id=m.id
where a.deleted_at is null group by a.id,a.name,a.area_id,a.households;

do $$ declare t text; begin
  foreach t in array array['areas','apartments','pois','promotions'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('create policy "crm_admin_all" on public.%I for all to authenticated using (public.is_crm_admin()) with check (public.is_crm_admin())',t);
  end loop;
end $$;
grant select on public.product_economics, public.apartment_performance to authenticated;

create index areas_admin_dong_idx on public.areas(admin_dong);
create index apartments_area_idx on public.apartments(area_id);
create index members_location_idx on public.members(area_id,complex_id);
create index leads_location_idx on public.leads(area_id,complex_id);
create index pois_area_idx on public.pois(area_id);
