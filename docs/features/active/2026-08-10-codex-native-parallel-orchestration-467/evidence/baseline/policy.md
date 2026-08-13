# Remediation Policy Baseline

Timestamp: 2026-08-12T04-50

## Policy order and precedence

The repository policy sources were read in this order:

1. `AGENTS.md`
2. `.agents/skills/policy-compliance-order/SKILL.md`
3. `.agents/skills/general-code-change/SKILL.md`
4. `.agents/skills/general-unit-test/SKILL.md`

Repository policy overrides plan and executor instructions. `AGENTS.md`, section
`Policy Compliance Reading Order`, defines the standing-policy order and requires
the applicable language-specific skills before code or test changes.
`.agents/skills/policy-compliance-order/SKILL.md`, sections
`Required Policy Reading Order (Baseline)` and `Hard Constraints (Baseline)`,
requires language-specific policy reads, prohibits policy-file edits and secrets,
and requires repository-defined commands where available.

## Coverage thresholds

- Repository line coverage must remain at least 85%.
- Repository branch coverage must remain at least 75% where the configured
  language tooling supports branch coverage.
- Changed lines must not lose coverage.
- Production sources must remain in the coverage denominator; production-path
  exclusions are prohibited.
- New modules, classes, and methods are governed by the feature plan's explicit
  90% per-file threshold where that threshold is higher than the repository-wide
  minimum.

Sources: `.agents/skills/general-unit-test/SKILL.md`, sections
`Coverage Requirements` and `Coverage Exclusion Policy`; the plan of record,
sections `Objective` and `R1 Python batch ownership`.

## Immutability and authorized sources

- Do not modify `.claude/**` during remediation.
- Modify canonical customization sources first, regenerate bundles with repository
  tooling, and do not hand-edit generated output.
- Do not modify repository policy documents under `.agents/skills/`.

Sources: the plan of record, section `Execution contract`;
`.agents/skills/policy-compliance-order/SKILL.md`, section
`Hard Constraints (Baseline)`.

## Evidence rules

- Store remediation evidence only below
  `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/<kind>/`.
- Use the canonical `baseline`, `regression-testing`, `qa-gates`, `issue-updates`,
  `other`, and `remediation-baseline` evidence kinds.
- Command receipts must record `Timestamp:`, the exact `Command:`, integer
  `EXIT_CODE:`, and an `Output Summary:` when the plan requires those fields.
- Negative evidence claims must identify the searched scope, patterns, and result.

Sources: `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, sections
`Non-Overridable Authority`, `Evidence Artifact Schema (Machine-Checkable)`, and
`Negative Evidence Claims (Absence Must Be Auditable)`; the plan of record,
section `Execution contract`.

## File and test constraints

- Production code, test code, and reusable scripts must not exceed 500 lines.
- Temporary throwaway scripts deleted within the same session, raw text fixtures,
  and Markdown documentation are the documented exceptions.
- Tests must remain independent, isolated, fast, deterministic, readable, and in
  the mirrored `tests/` tree.
- Tests must not use temporary files, external services, mutable global state, or
  real-time waits.
- Run the applicable quality loop in policy order and restart from formatting
  after any failure or automatic file change.

Sources: `.agents/skills/general-code-change/SKILL.md`, sections
`Mandatory Toolchain Loop` and `File Size Limit`;
`.agents/skills/general-unit-test/SKILL.md`, sections `Core Principles`,
`External Dependencies`, `Test File Location`, and `Determinism Infrastructure`.

## Python policy

The executable repository Python QA sequence is:

```powershell
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

Run the commands in that order. If formatting or lint auto-fixes a file, or any
step fails, correct the failure and restart at `poetry run black .`. The baseline
format check may use `poetry run black . --check` because Phase 0 prohibits
production edits. The coverage command adds `--cov-branch` to the Python skill's
canonical Pytest invocation so the plan's numeric branch-coverage requirement is
measured. Repository `pyproject.toml` supplies coverage source paths for `src`
and `scripts/dev_tools`.

Python batches may change no more than three production files and three test
files. Avoid `Any`; public callables require complete type annotations. New units
must reach at least 90% coverage, and every touched file must preserve or improve
its individual baseline. Suppressions are permitted only when they exactly match
`.agents/skills/python-suppressions/SKILL.md` or have explicit user approval.

Every class and function, including private helpers, requires a contract-oriented
docstring. Every loop and non-trivial comprehension requires an immediately
preceding intent comment. Non-trivial branches require decision-logic comments,
and multi-step blocks require a meta-what and rationale comment. Comments must
explain intent rather than narrate individual statements, and numbered notes are
prohibited.

Sources: `.agents/skills/python/SKILL.md`, sections `Toolchain`, `Coding
Standards`, and `Pytest Rules`; `.agents/skills/python-change-budget-router/SKILL.md`,
section `Per-Batch Change Budget (Hard Gate)`;
`.agents/skills/python-qa-gate/SKILL.md`, sections `Toolchain Execution Sequence`
and `Delta Requirements (Zero-Regression Hard Gate)`;
`.agents/skills/python-suppressions/SKILL.md`, sections `Authorization Requirement`
and `Policy Enforcement Checklist`;
`.agents/skills/self-explanatory-code-commenting/SKILL.md`, sections `Mandatory
Class Docstrings`, `Mandatory Function and Method Docstrings`, `Loops and
Comprehensions — Intent Comments Required`, `Branching — Decision-Logic Comments
Required`, and `Multi-Step Blocks — Meta-What Comments`.

## PowerShell policy

The executable repository PowerShell QA sequence uses the configured MCP surface:

```text
mcp__drm_copilot__run_poshqc_format({ workspace_root: "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25" })
mcp__drm_copilot__run_poshqc_analyze({ workspace_root: "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25" })
mcp__drm_copilot__run_poshqc_test({ workspace_root: "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25" })
```

Run format, analysis, and Pester in that order. If any command fails or changes a
file, correct the result and restart at formatting. `run_poshqc_test` resolves its
default scan folders from `config/poshqc-scan.json` and loads
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. That configuration
enables Pester `CoverageGutters` output. Preserve the raw MCP result and the
generated coverage XML, then calculate attributable coverage per runtime path as
`covered commands / analyzed commands * 100`, recording both numeric counts and
the percentage. The targeted variant passes the owning production and Pester
paths through `scan_folders`; the final gate omits `scan_folders` for full scope.

PowerShell has no separate type-check stage. Repository line coverage must remain
at least 85%; new runtime files must reach at least 90%; every touched runtime file
must have numeric attributable line coverage and no regression. The configured
Pester coverage format does not provide branch coverage, so branch coverage must
be recorded as unsupported and must not be represented as passing.

A batch may change at most three production files and three Pester files. Use a
narrow wrapper-function seam for external executables before considering an
injectable script block. Mock the wrapper, not the executable, and keep mock named
parameters identical to production.

Sources: `.agents/skills/powershell/SKILL.md`, sections `Toolchain`, `Change
Budget`, `Design Seams (Minimal DI)`, and `Mocking Rules`;
`.agents/skills/powershell-change-budget-router/SKILL.md`, sections `Canonical
Routing Rules` and `Direct-Mode Rejection Rule`;
`.agents/skills/powershell-qa-gate/SKILL.md`, sections `Toolchain Execution
Sequence` and `Delta Requirements (Zero-Regression Hard Gate)`;
`config/poshqc-scan.json`; and
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

## TypeScript policy

The executable repository TypeScript QA and coverage sequence is:

```powershell
npm --prefix extensions/drm-copilot run format
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=lcov --coverageReporters=text --coverageReporters=json-summary
```

Run the commands in that order and restart at formatting if any step fails or
changes a file. A no-write baseline or verification pass uses
`npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts"
"test/**/*.ts" "*.json" "*.cjs"` in place of the write-mode formatter.
`test:coverage` invokes Jest with coverage and LCOV/text-summary reporters; the
appended reporters retain LCOV, human-readable per-file coverage, and a
machine-readable JSON summary for numeric line and branch attribution. The test
command must not use `--passWithNoTests`, `--onlyChanged`, or `--lastCommit`.

Repository line coverage must remain at least 85%, repository branch coverage
must remain at least 75%, and every changed file must restore its individual
baseline or higher without changed-line regression. New units must reach at least
90%. Tests must use Jest, run without the VS Code extension host, and remain in
the mirrored `tests/` tree.

Avoid `any` and unjustified type assertions. TypeScript and ESLint suppressions
must use a pre-authorized single-line form with a specific `-- <reason>` suffix or
receive explicit user approval. File-level ESLint disables, `@ts-ignore`, and
`@ts-nocheck` are prohibited without that approval.

Sources: `.agents/skills/typescript/SKILL.md`, sections `Toolchain` and `Testing
Standards`; `.agents/skills/typescript-suppressions/SKILL.md`, sections
`Authorization Requirement`, `Pre-Authorized Patterns`, and `Explicitly Prohibited
Patterns`; `extensions/drm-copilot/package.json`, scripts `format`, `lint`,
`typecheck`, and `test:coverage`; and
`extensions/drm-copilot/run-jest.cjs`.
