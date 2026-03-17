-- GreenScale VSME core schema (EFRAG VSME, December 2024)

create extension if not exists "pgcrypto";

do $$
begin
  if not exists (select 1 from pg_type where typname = 'VSMEBaseModuleCode') then
    create type "VSMEBaseModuleCode" as enum (
      'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10', 'B11'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'VSMEScopeClassification') then
    create type "VSMEScopeClassification" as enum ('Scope 1', 'Scope 2');
  end if;
end
$$;

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
as $$
begin
  new."UpdatedAt" = now();
  return new;
end;
$$;

create table if not exists public."Organizations" (
  "Id" uuid primary key default gen_random_uuid(),
  "LegalName" text not null,
  "NACECode" text not null,
  "ReportingPeriodStart" date not null,
  "ReportingPeriodEnd" date not null,
  "CountryCode" char(2),
  "CreatedAt" timestamptz not null default now(),
  "UpdatedAt" timestamptz not null default now(),
  constraint "Organizations_ReportingPeriod_Check"
    check ("ReportingPeriodEnd" >= "ReportingPeriodStart")
);

create table if not exists public."EmissionsFactors" (
  "Id" uuid primary key default gen_random_uuid(),
  "FactorName" text not null,
  "EnergyType" text not null,
  "Unit" text not null,
  "KgCO2ePerUnit" numeric(14, 6) not null,
  "SourceName" text not null,
  "SourceReference" text,
  "ValidFrom" date not null default current_date,
  "ValidTo" date,
  "VSMEBaseModuleCode" "VSMEBaseModuleCode" not null default 'B3',
  "CreatedAt" timestamptz not null default now(),
  "UpdatedAt" timestamptz not null default now(),
  constraint "EmissionsFactors_KgCO2ePerUnit_Check"
    check ("KgCO2ePerUnit" >= 0),
  constraint "EmissionsFactors_Validity_Check"
    check ("ValidTo" is null or "ValidTo" >= "ValidFrom")
);

create table if not exists public."Documents" (
  "Id" uuid primary key default gen_random_uuid(),
  "OrganizationId" uuid not null references public."Organizations"("Id") on delete cascade,
  "DocumentType" text not null,
  "SupplierName" text,
  "BillingPeriodStart" date,
  "BillingPeriodEnd" date,
  "FileName" text not null,
  "StoragePath" text not null,
  "MimeType" text not null default 'application/pdf',
  "UploadedAt" timestamptz not null default now(),
  "CreatedAt" timestamptz not null default now(),
  "UpdatedAt" timestamptz not null default now(),
  constraint "Documents_BillingPeriod_Check"
    check (
      "BillingPeriodStart" is null
      or "BillingPeriodEnd" is null
      or "BillingPeriodEnd" >= "BillingPeriodStart"
    )
);

create table if not exists public."EnergyMetrics" (
  "Id" uuid primary key default gen_random_uuid(),
  "OrganizationId" uuid not null references public."Organizations"("Id") on delete cascade,
  "DocumentId" uuid references public."Documents"("Id") on delete set null,
  "EmissionsFactorId" uuid not null references public."EmissionsFactors"("Id"),
  "VSMEBaseModuleCode" "VSMEBaseModuleCode" not null,
  "EnergyType" text not null,
  "Quantity" numeric(14, 4) not null,
  "Unit" text not null,
  "ScopeClassification" "VSMEScopeClassification" not null,
  "CO2EquivalentTonnes" numeric(14, 6) not null,
  "CalculationFormula" text not null default 'Quantity * KgCO2ePerUnit',
  "MeasurementPeriodStart" date,
  "MeasurementPeriodEnd" date,
  "CreatedAt" timestamptz not null default now(),
  "UpdatedAt" timestamptz not null default now(),
  constraint "EnergyMetrics_Quantity_Check"
    check ("Quantity" >= 0),
  constraint "EnergyMetrics_CO2EquivalentTonnes_Check"
    check ("CO2EquivalentTonnes" >= 0),
  constraint "EnergyMetrics_VSMEBaseModuleCode_Check"
    check ("VSMEBaseModuleCode" in ('B3', 'B4', 'B5', 'B6')),
  constraint "EnergyMetrics_MeasurementPeriod_Check"
    check (
      "MeasurementPeriodStart" is null
      or "MeasurementPeriodEnd" is null
      or "MeasurementPeriodEnd" >= "MeasurementPeriodStart"
    )
);

create table if not exists public."WorkforceData" (
  "Id" uuid primary key default gen_random_uuid(),
  "OrganizationId" uuid not null references public."Organizations"("Id") on delete cascade,
  "VSMEBaseModuleCode" "VSMEBaseModuleCode" not null default 'B8',
  "ReportingYear" integer not null,
  "FTE" numeric(12, 2) not null,
  "Headcount" integer not null,
  "FemaleRatioPercent" numeric(5, 2),
  "MaleRatioPercent" numeric(5, 2),
  "NonBinaryRatioPercent" numeric(5, 2),
  "WorkAccidents" integer not null default 0,
  "TrainingHours" numeric(12, 2) not null default 0,
  "CreatedAt" timestamptz not null default now(),
  "UpdatedAt" timestamptz not null default now(),
  constraint "WorkforceData_VSMEBaseModuleCode_Check"
    check ("VSMEBaseModuleCode" in ('B7', 'B8', 'B9')),
  constraint "WorkforceData_ReportingYear_Check"
    check ("ReportingYear" >= 2000),
  constraint "WorkforceData_FTE_Check"
    check ("FTE" >= 0),
  constraint "WorkforceData_Headcount_Check"
    check ("Headcount" >= 0),
  constraint "WorkforceData_FemaleRatioPercent_Check"
    check ("FemaleRatioPercent" is null or ("FemaleRatioPercent" >= 0 and "FemaleRatioPercent" <= 100)),
  constraint "WorkforceData_MaleRatioPercent_Check"
    check ("MaleRatioPercent" is null or ("MaleRatioPercent" >= 0 and "MaleRatioPercent" <= 100)),
  constraint "WorkforceData_NonBinaryRatioPercent_Check"
    check ("NonBinaryRatioPercent" is null or ("NonBinaryRatioPercent" >= 0 and "NonBinaryRatioPercent" <= 100)),
  constraint "WorkforceData_RatioTotal_Check"
    check (
      coalesce("FemaleRatioPercent", 0)
      + coalesce("MaleRatioPercent", 0)
      + coalesce("NonBinaryRatioPercent", 0) <= 100
    ),
  constraint "WorkforceData_WorkAccidents_Check"
    check ("WorkAccidents" >= 0),
  constraint "WorkforceData_TrainingHours_Check"
    check ("TrainingHours" >= 0)
);

drop trigger if exists "Organizations_set_updated_at" on public."Organizations";
create trigger "Organizations_set_updated_at"
before update on public."Organizations"
for each row execute function public.set_updated_at_timestamp();

drop trigger if exists "EmissionsFactors_set_updated_at" on public."EmissionsFactors";
create trigger "EmissionsFactors_set_updated_at"
before update on public."EmissionsFactors"
for each row execute function public.set_updated_at_timestamp();

drop trigger if exists "Documents_set_updated_at" on public."Documents";
create trigger "Documents_set_updated_at"
before update on public."Documents"
for each row execute function public.set_updated_at_timestamp();

drop trigger if exists "EnergyMetrics_set_updated_at" on public."EnergyMetrics";
create trigger "EnergyMetrics_set_updated_at"
before update on public."EnergyMetrics"
for each row execute function public.set_updated_at_timestamp();

drop trigger if exists "WorkforceData_set_updated_at" on public."WorkforceData";
create trigger "WorkforceData_set_updated_at"
before update on public."WorkforceData"
for each row execute function public.set_updated_at_timestamp();
