# UX Requirements Quality Checklist: WSL Xray Client Bootstrap

**Purpose**: Unit tests for the written UX-related requirements (not implementation). Ensures clarity, completeness, consistency of CLI + install/uninstall flow + .env experience.

**Created**: 2025-11-09

**Feature**: ../spec.md

**Scope Selection**: Q1=B (CLI + install/uninstall flow), extended to include .env validation aspects implicitly for usability

**Depth**: Q2=B (Enhanced)

**Audience**: Q3=C (Author + Reviewer)

**Tone & Localization Policy (Derived)**: Error/help messages SHOULD be concise, action-oriented, neutral; MUST support RU + EN fallback (explicit or structurally possible). Russian primary examples acceptable; fallback English MUST be definable.

---

## Requirement Completeness

- [x] CHK001 Are help text requirements for each user-facing script (`install.sh`, `manage.sh`, `generate-config.sh`, `uninstall.sh`, `version.sh`, `check-ip.sh`) explicitly covered? [Resolved: FR-020, FR-021, FR-022]
- [x] CHK002 Are requirements defining which commands belong to `manage.sh` complete (no undocumented actions)? [Resolved: FR-021]
- [x] CHK003 Are uninstall flow requirements fully enumerated (files, unit, binary, config removal) without missing artifacts? [Resolved: FR-027, SC-010]
- [x] CHK004 Are all environment variables required for each protocol/security mode documented (including Reality-specific)? [Resolved: FR-031, FR-034, Data Model references]
- [x] CHK005 Are localization (RU/EN) expectations stated for ALL categories of user-visible text (help, errors, status, logs)? [Resolved: FR-016]
- [x] CHK006 Are requirements present for how missing optional HTTP port is handled (explicit omission behavior)? [Resolved: FR-030]
- [x] CHK007 Are requirements present describing output content of `status` (what fields: running state, error hints)? [Resolved: FR-017]
- [x] CHK008 Are log viewing requirements (depth, filtering, follow) fully specified? [Resolved: FR-018]

## Requirement Clarity

- [x] CHK009 Is the distinction between `install.sh` idempotent behavior vs `--force` regeneration explicitly defined to avoid ambiguity? [Resolved: FR-026, SC-011]
- [x] CHK010 Is "полное удаление" (full uninstall) unambiguously tied to a closed list of removed artifacts? [Resolved: FR-027, SC-010]
- [x] CHK011 Are criteria for a "успешное подключение" clearly spelled out (e.g., external IP change vs exit code only)? [Resolved: FR-028]
- [x] CHK012 Is the acceptable latency for commands (<1s) defined with scope (cold vs warm execution)? [Resolved: SC-003, SC-008, SC-009]
- [x] CHK013 Is wording for autostart enable/disable results (messages) defined (past tense vs imperative)? [Resolved: FR-021, FR-023 message formatting]
- [x] CHK014 Is the required format for UUID explicitly stated (regex) separate from generic description? [Resolved: FR-034]
- [x] CHK015 Are error messages required to suggest corrective action ("Provide XRAY_SERVER_HOST")? [Resolved: FR-023, FR-025, FR-032]

## Requirement Consistency

- [x] CHK016 Are success criteria (SC-001..SC-011) consistent with functional requirements timing and behaviors (no conflicts)? [Resolved: Updated SC align with FR performance requirements]
- [x] CHK017 Do uninstall requirements align with idempotency rule (safe re-run yields clean state)? [Resolved: FR-027, FR-040, SC-010, SC-011]
- [x] CHK018 Are environment variable naming conventions consistent (prefix XRAY_ for all)? [Resolved: FR-034, FR-035, Data Model consistency]
- [x] CHK019 Is autostart default OFF consistently stated across spec, plan, quickstart? [Resolved: FR-013 autostart default verified]
- [x] CHK020 Is logging format requirement aligned between plan (`TIMESTAMP LEVEL script FUNCTION message`) and constitution gating? [Resolved: FR-019, FR-039 plain text alignment]

## Acceptance Criteria Quality / Measurability

- [x] CHK021 Are time-based performance goals (<120s install, <1s commands) measurable with defined start/stop points? [Resolved: SC-008, SC-009 timing criteria added]
- [x] CHK022 Can success of "IP check" be objectively measured (e.g., IP differs from baseline or matches VPN range)? [Resolved: FR-002, FR-025 connection verification]
- [x] CHK023 Are criteria for "100% removal" (SC-004) enumerated as a verifiable artifact set? [Resolved: SC-010, SC-011 artifact verification]
- [x] CHK024 Are log secrecy requirements (no secrets) measurable by defined forbidden token patterns? [Resolved: FR-019, SC-007]
- [x] CHK025 Is idempotency test condition defined (2 sequential installs produce identical state & exit 0)? [Resolved: FR-027, FR-040 idempotency requirements]

## Scenario Coverage

- [x] CHK026 Are primary user flows (first install, manage lifecycle, uninstall) fully represented in user stories? [Resolved: FR-041 primary flows documentation]
- [x] CHK027 Are alternate flows (changing protocol after initial install) addressed? [Resolved: FR-042 protocol changes]
- [x] CHK028 Are exception flows (download failure, checksum mismatch) captured in requirements? [Resolved: FR-043 download retry strategy]
- [x] CHK029 Are recovery flows (retry strategy after transient network failure) specified or intentionally excluded? [Resolved: FR-043, FR-051 network handling]
- [x] CHK030 Are configuration mutation flows (editing .env then regenerate) described? [Resolved: FR-037, FR-042 configuration changes]

## Edge Case Coverage

- [x] CHK031 Are edge cases for conflicting ports (SOCKS vs HTTP) explicitly specified (error messaging)? [Resolved: FR-044 port conflict detection]
- [x] CHK032 Are edge cases for invalid Reality parameter subsets (missing one of required quartet) covered? [Resolved: FR-045 Reality validation]
- [x] CHK033 Are edge cases for re-running uninstall on already removed system handled (graceful message)? [Resolved: FR-046 repeated uninstall]
- [x] CHK034 Are zero-length / whitespace-only env var values treated distinctly from missing? [Resolved: FR-047 variable validation]
- [x] CHK035 Are unsupported protocol strings (typos) specified with error classification? [Resolved: FR-048 protocol suggestions]

## Non-Functional UX Aspects

- [x] CHK036 Are localization fallback rules (RU primary / EN fallback) defined for all user-visible strings? [Resolved: FR-016]
- [x] CHK037 Are readability standards for help output (line width, ordering, grouping) defined? [Resolved: FR-052 formatting standards]
- [x] CHK038 Are logging verbosity levels and their mapping to user commands specified (e.g., LOG_LEVEL)? [Resolved: FR-053 LOG_LEVEL control]
- [x] CHK039 Are privacy constraints (no secret echo) mapped to explicit banned variables in output? [Resolved: FR-019]
- [x] CHK040 Are color or formatting assumptions (e.g., ANSI) specified or explicitly excluded? [Resolved: FR-054 ANSI exclusion]

## Dependencies & Assumptions

- [x] CHK041 Are dependency presence error behaviors (missing jq, curl) defined (codes/messages)? [Resolved: FR-049 dependency error messages]
- [x] CHK042 Are systemd preconditions (what message if disabled) specified? [Resolved: FR-050 systemd verification]
- [x] CHK043 Are assumptions about network availability vs offline mode documented? [Resolved: FR-051 network checking]

## Ambiguities & Conflicts

- [x] CHK044 Is meaning of "быстрый" (<5 минут end-to-end) fully aligned with SC-001 and not contradicted elsewhere? [Resolved: SC-008, SC-009 timing clarification]
- [x] CHK045 Is there any conflict between logging format requirement and potential localization (order of tokens)? [Resolved: FR-053 consistent format]
- [x] CHK046 Is the difference between `status` vs `logs` outputs clearly partitioned (no overlap ambiguity)? [Resolved: FR-055 command disambiguation]
- [x] CHK047 Are variable validation error severities vs runtime errors distinguished? [Resolved: FR-047, error code taxonomy]
- [x] CHK048 Is explicit exclusion of interactive prompts (pure non-interactive CLI) stated? [Resolved: FR-056 non-interactive requirement]

## Traceability & ID Scheme

- [x] CHK049 Is there an established consistent referencing scheme (FR-###, SC-###) used in all new requirements to be added? [Resolved: FR-001 through FR-060, SC-001 through SC-011]
- [x] CHK050 Will newly added UX clarifications reference both checklist IDs and spec sections for bidirectional traceability? [Resolved: Clarifications section maps CHK to FR references]

## Consolidated Edge Case Grouping (Meta)

- [x] CHK051 Are additional minor edge cases (permission denied, partial file write, corrupted download temp file) either specified or explicitly out of scope? [Resolved: FR-057, FR-058, FR-059]

## Summary Quality Gate

- [x] CHK052 Does the current spec after addressing gaps achieve: ≥80% referenced items satisfied, all [Gap] items resolved or ticketed? [Resolved: 52/52 checklist items covered with FR references]

---
**Legend**: [Gap] = requirement missing in current spec; mark resolution path (add, defer, reject). After refinement, each [Gap] should gain a traceable spec section or explicit rationale.

**Next Action After Completion**: Update spec sections (FR/NFR/Validation/Logging/Localization) to resolve accepted [Gap] items, then re-run a lean delta checklist focusing on unresolved gaps.
