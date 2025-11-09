<!--
Sync Impact Report
Version change: (none previous) → 1.0.0
Modified principles: (initial adoption)
Added sections: Core Principles, Architecture & Constraints, Development Workflow, Governance
Removed sections: N/A (template placeholders replaced)
Templates requiring updates:
	- .specify/templates/plan-template.md ✅ updated (added constitution gates)
	- .specify/templates/spec-template.md ⚠ pending (add Bash-specific examples)
	- .specify/templates/tasks-template.md ⚠ pending (replace Python examples with Bash tasks)
	- .specify/templates/agent-file-template.md ⚠ pending (will be auto-generated post first plan)
Deferred TODOs: None
-->

# WSL Xray Client (Rebuild) Constitution

## Core Principles

### I. Bash-Only Modular Architecture

Every feature is delivered as one or more single‑purpose Bash scripts under `scripts/` or reusable libraries under `lib/`. Each script MUST have a clear responsibility, avoid hidden side effects, and remain composable. Shared logic (logging, validation, color output, progress) MUST live in `lib/common.sh` or another dedicated library file—no duplication. Monolithic scripts ("do everything") are prohibited unless they serve as an orchestrator (e.g. `install.sh`). Simplicity and readability outweigh cleverness.

### II. Deterministic CLI Contract

All scripts MUST implement: `--help` (usage, env vars), strict argument validation, predictable exit codes (`0` success, non‑zero classified errors). Stdout is reserved for primary data (plain text or JSON); stderr for diagnostics. No interactive prompts in automation paths—use flags and env vars. Input via args/env, output via stdout only. Contracts (flags, required env vars, output format) are treated as public API.

### III. Test‑First & Idempotent Operations (NON‑NEGOTIABLE)

Before implementing a script, a failing test (bats or shellspec) MUST be added describing expected behavior. Red‑Green‑Refactor is enforced. Provisioning/install steps MUST be idempotent (safe to re‑run). Tests MUST cover: argument validation, error exit codes, side‑effect safety (no unintended file mutation), and re‑run behavior. No merging of untested scripts.

### IV. Observability, Security & Least Privilege

Scripts MUST use logging helpers yielding timestamped lines and honor `$LOG_LEVEL` (`error`, `warn`, `info`, `debug`). Secrets (.env) never logged. Sensitive files MUST have restrictive permissions (e.g. `chmod 600 .env`). `sudo` usage MUST be explicit and minimized; each privileged action documented in a comment with rationale. No embedded secrets or UUIDs. Network downloads SHOULD have checksum verification (sha256) when source provides hashes.

### V. Versioning, Change Control & AI Agent Traceability

Project version stored in `.version` (SemVer). MAJOR: breaking CLI contracts or removal of scripts. MINOR: new scripts/features without breaking existing contracts. PATCH: fixes, refactors, documentation-only, logging improvements. Every AI-generated artifact (`plan.md`, `spec.md`, `tasks.md`) MUST contain Decision/Rationale/Alternatives for substantive choices; reviewers verify alignment with principles before merge. No untracked drift: changes to shared libraries require bump decision recorded in changelog section of PR description.

## Architecture & Constraints

1. Target shell: GNU bash 5.x (WSL Ubuntu 22.04+/24.04). POSIX where feasible; bash features allowed when they improve clarity.
2. Directory layout (baseline):

```text
lib/            # reusable functions (logging, validation, colors)
scripts/        # operational commands (start, stop, status, check-ip, etc.)
install-steps/  # orchestrated modular install phases
tests/          # bats or shellspec test suites (unit/, integration/)
docs/           # user & contributor documentation
.specify/       # AI agent planning & memory artifacts
```

1. Idempotent install: Each `install-steps/*.sh` MUST guard repeated actions (e.g. check package before install).
2. Environment config: `.env.example` tracked; `.env` ignored and validated. Scripts fail fast if required variables missing.
3. No binary artifacts committed (xray core downloads cached under a configurable path ignored by git).
4. Performance baseline: Typical script MUST execute core operation < 1s for common tasks (status, check-ip); heavy operations documented.
5. Port allocations and network assumptions documented in `docs/CONFIGURATION.md`.
6. Code Review: Reviewers verify principle compliance (architecture, CLI contract, tests, security). PR rejected if any gate violated or missing rationale for complexity.
7. Logging & exit codes validated in CI. CI MUST run shellcheck + formatting (shfmt) + test suite.
8. AI Agent Usage: Agent suggestions treated as drafts; human curator MUST approve final changes. Auto-generated files edited only around clearly marked manual additions blocks.
9. Release: Update `.version`, add entry to `CHANGELOG.md` (if present) summarizing changes against principles.
10. Documentation sync: After merging a feature, regenerate agent guidelines (`agent-file-template.md` derivative) to reflect new scripts and technologies.

## Governance

1. Supremacy: This constitution overrides prior informal practices. Conflicts resolved by aligning with non‑negotiable principles (I–V).
2. Amendment Process: Propose PR labeled `governance` containing diff + rationale + migration impact. Determine SemVer bump type: MAJOR (remove/alter principle), MINOR (add principle or expand gates), PATCH (clarifications only). Last amended date updated only when content changes.
3. Compliance Review: Each PR must include a checklist confirming gates (architecture, CLI contract, tests, security, versioning) are satisfied. Missing items = block.
4. Versioning Policy: See Principle V; constitution version increments independently from project `.version`.
5. Audit Frequency: Quarterly (every 90 days) run review script (future `scripts/audit-constitution.sh`) to scan for drift (undocumented sudo usage, missing tests, duplicate logic). Findings become issues.
6. Emergency Changes: Security hotfix may bypass normal planning but MUST add retroactive spec/plan within 48h and still follow versioning rules.
7. Deprecation: Mark scripts slated for removal with `DEPRECATED:` comment header + entry in docs; removal requires MAJOR bump if CLI contract breaks.

**Version**: 1.0.0 | **Ratified**: 2025-11-08 | **Last Amended**: 2025-11-08
