export type UUID = string;

export type VSMEBaseModuleCode =
  | "B1"
  | "B2"
  | "B3"
  | "B4"
  | "B5"
  | "B6"
  | "B7"
  | "B8"
  | "B9"
  | "B10"
  | "B11";

export type VSMEScopeClassification = "Scope 1" | "Scope 2";

export type VSMEEnvironmentModuleCode = "B3" | "B4" | "B5" | "B6";
export type VSMEWorkforceModuleCode = "B7" | "B8" | "B9";

export interface Organizations {
  Id: UUID;
  LegalName: string;
  NACECode: string;
  ReportingPeriodStart: string; // ISO date (YYYY-MM-DD)
  ReportingPeriodEnd: string; // ISO date (YYYY-MM-DD)
  CountryCode: string | null;
  CreatedAt: string; // ISO timestamp
  UpdatedAt: string; // ISO timestamp
}

export interface EmissionsFactors {
  Id: UUID;
  FactorName: string;
  EnergyType: string;
  Unit: string;
  KgCO2ePerUnit: number;
  SourceName: string;
  SourceReference: string | null;
  ValidFrom: string; // ISO date (YYYY-MM-DD)
  ValidTo: string | null; // ISO date (YYYY-MM-DD)
  VSMEBaseModuleCode: VSMEBaseModuleCode;
  CreatedAt: string; // ISO timestamp
  UpdatedAt: string; // ISO timestamp
}

export interface Documents {
  Id: UUID;
  OrganizationId: UUID;
  DocumentType: string;
  SupplierName: string | null;
  BillingPeriodStart: string | null; // ISO date (YYYY-MM-DD)
  BillingPeriodEnd: string | null; // ISO date (YYYY-MM-DD)
  FileName: string;
  StoragePath: string;
  MimeType: string;
  UploadedAt: string; // ISO timestamp
  CreatedAt: string; // ISO timestamp
  UpdatedAt: string; // ISO timestamp
}

export interface EnergyMetrics {
  Id: UUID;
  OrganizationId: UUID;
  DocumentId: UUID | null;
  EmissionsFactorId: UUID;
  VSMEBaseModuleCode: VSMEEnvironmentModuleCode;
  EnergyType: string;
  Quantity: number;
  Unit: string;
  ScopeClassification: VSMEScopeClassification;
  CO2EquivalentTonnes: number;
  CalculationFormula: string;
  MeasurementPeriodStart: string | null; // ISO date (YYYY-MM-DD)
  MeasurementPeriodEnd: string | null; // ISO date (YYYY-MM-DD)
  CreatedAt: string; // ISO timestamp
  UpdatedAt: string; // ISO timestamp
}

export interface WorkforceData {
  Id: UUID;
  OrganizationId: UUID;
  VSMEBaseModuleCode: VSMEWorkforceModuleCode;
  ReportingYear: number;
  FTE: number;
  Headcount: number;
  FemaleRatioPercent: number | null;
  MaleRatioPercent: number | null;
  NonBinaryRatioPercent: number | null;
  WorkAccidents: number;
  TrainingHours: number;
  CreatedAt: string; // ISO timestamp
  UpdatedAt: string; // ISO timestamp
}
