# Anforderungen: VSME Reporting System "GreenScale"

## 1. Projektziel
Entwicklung einer schlanken Web-Anwendung zur Erstellung von Nachhaltigkeitsberichten gemäß dem **EFRAG VSME Standard (Dezember 2024)**. Das Tool soll kleinen Unternehmen helfen, quantitative Umwelt- und Sozialdaten zu erfassen, CO2-Bilanzierungen vorzunehmen und einen konformen Bericht zu exportieren.

## 2. Technischer Stack
- **Framework:** Next.js 14+ (App Router, TypeScript)
- **Datenbank & Auth:** Supabase (PostgreSQL)
- **Styling:** Tailwind CSS + Shadcn UI
- **Lokale KI (Inferenz):** Ollama (Modell: Mistral) via lokaler API-Schnittstelle
- **PDF-Parsing:** `pdf-parse` oder `pdf-standard` (lokal)

## 3. Funktionale Anforderungen

### 3.1 Das VSME Datenmodell (Kerninstanz)
Das System muss folgende Module des Standards abbilden:
- **Basismodul (B1-B11):** Quantitative Kennzahlen zu Energie, Emissionen, Belegschaft und Governance.
- **PAT-Modul (Policies, Actions, Targets):** Qualitative Textfelder für Strategien.
- **Berechnungslogik:** Automatische Umrechnung von Aktivitätsdaten (kWh, Liter) in $tCO_2e$ (Scope 1 & 2) unter Verwendung einer hinterlegten Faktoren-Tabelle.

### 3.2 Lokale KI-Pipeline (Ollama/Mistral)
Anstatt Cloud-APIs zu nutzen, wird eine lokale Pipeline für den Rechnungs-Import implementiert:
1. **Datei-Upload:** Nutzer lädt eine PDF-Rechnung (Strom/Gas/Tanken) hoch.
2. **Lokale Extraktion:** Das System extrahiert den Rohtext aus der PDF.
3. **Ollama-Analyse:** Der Text wird an `http://localhost:11434/api/generate` gesendet.
4. **Prompt-Logik:** Extraktion von: *Lieferant, Zeitraum, Menge (kWh/l), Einheit, Betrag*.
5. **Review:** Anzeige der KI-Ergebnisse in einem Formular zur manuellen Bestätigung durch den Nutzer.

### 3.3 Dashboard & Reporting
- **Status-Tracker:** Anzeige des Fortschritts pro VSME-Abschnitt (z.B. "Umwelt: 80% vollständig").
- **Audit-Trail:** Jede berechnete CO2-Zahl muss mit der ursprünglichen Quelldatei (PDF) verknüpft sein.
- **Export:** Generierung eines strukturierten Berichts (HTML/PDF), der exakt der Gliederung des VSME-Standards folgt.

## 4. Datenstruktur (Referenz für Cursor)
*Cursor soll beim Setup folgende Tabellen in Supabase/Prisma erstellen:*

- `Organizations`: Stammdaten, NACE-Code, Berichtszeitraum.
- `EnergyMetrics`: Energieart, Menge, Einheit, Scope-Zuordnung, CO2-Äquivalent.
- `WorkforceData`: FTE, Kopfzahl, Geschlechterquote, Arbeitsunfälle, Fortbildungsstunden.
- `EmissionsFactors`: Referenzwerte (kg CO2 pro Einheit) mit Quellenangabe (UBA/GEMIS).
- `Documents`: Metadaten zu hochgeladenen Rechnungen und Verknüpfung zu Einträgen.

## 5. UI/UX Anforderungen
- **Wizard-Struktur:** Schritt-für-Schritt Führung durch die VSME-Module.
- **Einheiten-Konverter:** Automatische Umrechnung (z.B. Heizöl Liter zu kWh Brennwert), falls Faktoren in anderen Einheiten vorliegen.
- **Sicherheits-Fokus:** Da lokale KI genutzt wird, muss im UI klar ersichtlich sein, dass keine Daten an externe LLMs gesendet werden.

## 6. Spezifische Anweisungen für Cursor (Sprints)
1. **Schritt 1:** Setup des Datenbankschemas basierend auf den Tabellen in Punkt 4.
2. **Schritt 2:** Erstellung der API-Route zur Kommunikation mit Ollama.
3. **Schritt 3:** Bau der Formulare für das Basismodul (Umweltdaten B3-B6).
4. **Schritt 4:** Implementierung des PDF-Uploads und der Validierungs-Logik für die KI-Extraktion.
