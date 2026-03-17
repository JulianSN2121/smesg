-- Performance indexes and VSME traceability comments

create index if not exists "Organizations_ReportingPeriod_Idx"
  on public."Organizations" ("ReportingPeriodStart", "ReportingPeriodEnd");

create index if not exists "EnergyMetrics_OrganizationId_Idx"
  on public."EnergyMetrics" ("OrganizationId");

create index if not exists "EnergyMetrics_DocumentId_Idx"
  on public."EnergyMetrics" ("DocumentId");

create index if not exists "EnergyMetrics_VSMEBaseModuleCode_Idx"
  on public."EnergyMetrics" ("VSMEBaseModuleCode");

create index if not exists "EnergyMetrics_ScopeClassification_Idx"
  on public."EnergyMetrics" ("ScopeClassification");

create index if not exists "Documents_OrganizationId_Idx"
  on public."Documents" ("OrganizationId");

create index if not exists "WorkforceData_OrganizationId_Idx"
  on public."WorkforceData" ("OrganizationId");

create index if not exists "WorkforceData_VSMEBaseModuleCode_Idx"
  on public."WorkforceData" ("VSMEBaseModuleCode");

create index if not exists "EmissionsFactors_EnergyType_Unit_Idx"
  on public."EmissionsFactors" ("EnergyType", "Unit");

comment on table public."Organizations" is
  'VSME core entity: organization profile, NACE code and reporting period.';

comment on table public."EnergyMetrics" is
  'VSME Basismodul disclosures B3-B6 for energy and GHG activity data.';

comment on table public."WorkforceData" is
  'VSME Basismodul disclosures B7-B9 for workforce indicators.';

comment on table public."EmissionsFactors" is
  'Reference factors (e.g. UBA/GEMIS) for converting activity data to CO2e.';

comment on table public."Documents" is
  'Source documents (e.g. invoices) for audit trail and metric provenance.';
