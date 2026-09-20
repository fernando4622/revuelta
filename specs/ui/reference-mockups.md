# UI Reference Mockups

**Status:** APPROVED AS VISUAL REFERENCE. The images are not authoritative for domain rules, permissions or real data.

## 1. Source inventory

| Asset | Observed content | Specification use |
|---|---|---|
| `apps/revuelta-mobile/resources/ejemplo1.png` | Splash, onboarding, login, registration, email verification, optional profile and welcome | Visual language; username/password login is approved, while registration and verification remain deferred |
| `apps/revuelta-mobile/resources/ejemplo2.png` | Student home, QR scan, return confirmation, route, validation, success, history, impact, profile and notifications | Primary student mobile journey |
| `apps/revuelta-mobile/resources/ejemplo3.png` | Consolidated student mobile journey, responsive dashboard and design-system panel | Navigation, responsive structure and component patterns |
| `apps/revuelta-mobile/resources/logo.jpeg` | Script “RV/ReVuelta” mark and “cada vuelta cuenta” tagline | Approved prototype brand asset |

## 2. What the images approve

The references approve these visual intentions:

- warm off-white surfaces with dark green primary actions;
- rounded cards, inputs and buttons;
- container illustration as the main operational object;
- concise Spanish copy;
- prominent central scan action;
- status chips paired with text;
- progress/validation feedback;
- student bottom navigation;
- responsive student dashboard using the same destinations;
- restrained decorative plant/leaf illustrations.

They do not approve:

- exact business deadlines;
- exact environmental conversion formulas;
- real student names or email domains;
- “Cafetería Central” as an official location;
- social login or public registration;
- a specific actor for final return acceptance;
- automatic movement from `RETURNED` to `AVAILABLE`;
- notifications that have no backend source;
- multi-campus behavior.

## 3. Conflicts and normalization

| Mockup evidence | Governing interpretation |
|---|---|
| Some screens use “universidad”, “campus” or generic email examples. | Use ITVer-specific terminology from `context.md`. |
| “Cafetería Central” and “Biblioteca” appear as example locations. | Use “Punto ReVuelta — Cafetería del Instituto”. |
| The student appears to confirm/finalize a return. | Alumno may initiate/inspect; Cafetería scans and confirms physical receipt. |
| The mockups show login, registration, Google and Microsoft. | Keep the approved provisioned-account login. Registration, Google/Microsoft login and public account creation remain deferred. |
| Mockups show numeric impact metrics. | Demo builds may show them only with “Datos de demostración”; production values remain blocked by D-017. |
| The circular leaf logo in the mockups differs from `logo.jpeg`. | Use `logo.jpeg`; do not extract the alternate mark. |

## 4. Candidate design tokens

The current Flutter theme may use these semantic tokens while visual implementation is reviewed:

| Token | Current candidate | Use |
|---|---|---|
| `forestGreen` | `#1B4D3E` | Primary dark actions and selected navigation |
| `deepTeal` | `#133B30` | High-emphasis text/accent |
| `primaryGreen` | `#27AE60` | Success and primary accent |
| `mintGreen` | `#E1EFEA` | Soft status/background surfaces |
| `background` | `#F8F9FA` | Application background |
| `surfaceWhite` | `#FFFFFF` | Cards and controls |
| `textPrimary` | `#1A2E28` | Main text |
| `textSecondary` | `#6B7E77` | Supporting text |
| `warningOrange` | `#F39C12` | Warnings |
| `errorRed` | `#E74C3C` | Failures |

These values are implementation candidates already represented by the current theme. They are not a declaration of official ITVer colors.

## 5. Component contract

Reusable components visible in the references:

- ReVuelta brand header;
- container status card;
- status chip with icon and text;
- primary filled button;
- secondary outlined button;
- bottom navigation/desktop navigation rail;
- QR scan viewport;
- progress stepper;
- history row;
- metric card;
- notification row;
- empty/error/retry panel.

Every component MUST support:

- semantic labels;
- dynamic text scaling;
- non-color-only status;
- loading/disabled state where actionable;
- real data of variable length;
- Spanish text without clipping.

## 6. Asset rules

- Do not extract a logo from a composite mockup.
- Use an approved source asset with adequate resolution and transparency.
- Do not present the ITVer logo or visual identity without supplied authorization.
- Decorative imagery MUST NOT obscure controls or status.
- Example student photographs, initials and names are placeholders only.
