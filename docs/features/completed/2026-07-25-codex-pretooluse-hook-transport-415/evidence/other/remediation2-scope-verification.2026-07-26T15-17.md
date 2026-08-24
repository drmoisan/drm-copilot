# Scope and Hygiene Verification (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P7-T6]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **`<BASELINE_SHA>`:** `21fc8c3b7f549723097efe4d8dc0e1404dca1867` (recorded at [P0-T2] re-run, `FEATURE/evidence/remediation-baseline/phase0-git-baseline.2026-07-26T15-17.md`)
- **Merge-base:** `fb483b8468204e4385b5583c3b3ec4c0a987eede`

Timestamp: 2026-07-26T15-17

## Commands and Exit Codes

Command: `git status --porcelain`
EXIT_CODE: 0

Command: `git diff 21fc8c3b7f549723097efe4d8dc0e1404dca1867 --name-only` (the cycle-2 delta)
EXIT_CODE: 0

Command: `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD`
EXIT_CODE: 0

Command: `git diff -- .codex/config.toml`
EXIT_CODE: 0 — **empty output**

Command: `git diff fb483b8468204e4385b5583c3b3ec4c0a987eede --stat -- .codex/config.toml`
EXIT_CODE: 0 — **empty output**

Command: `git diff 21fc8c3b7f549723097efe4d8dc0e1404dca1867 --name-only -- .codex/config.toml`
EXIT_CODE: 0 — **empty output**

Command: `git diff 21fc8c3b7f549723097efe4d8dc0e1404dca1867 --name-only -- docs/.../spec.md`
EXIT_CODE: 0 — **empty output**

Command: `git diff --cached --name-only | grep "^\.codex/state"`
EXIT_CODE: 1 (no match)

Command: `ls -d .codex/state`
EXIT_CODE: 2 (`No such file or directory`)

Baseline-SHA note: `21fc8c3b` is the pre-implementation point on the rebased branch and the exact
post-rebase equivalent of the pre-rebase `37d0ecb4` recorded at 14-37 — both are the docs-only commit
`docs(415): clear cycle-2 remediation plan preflight`. Using it makes `git diff <BASELINE_SHA> --name-only`
equal the cycle-2 implementation delta, which is what this task asserts against. The rationale is recorded
in full in the [P0-T2] artifact.

## Output Summary — All Five Assertions

### (a) NO path under `.claude/` in the cycle-2 delta — **HOLDS**

Command: union of `git diff <BASELINE_SHA> --name-only` and all `git status --porcelain` paths
(tracked and untracked), filtered for `.claude/`
EXIT_CODE: 1 (grep found no match)

Zero `.claude/` paths. No file under `.claude/` — including `.claude/state/`, `.claude/agent-memory/`, and
any bundled `.claude` copy — was created, modified, or deleted. Hard Constraint 1 holds.

### (b) The delta contains ONLY the permitted paths — **HOLDS**

Cycle-2 delta, tracked (`git diff 21fc8c3b --name-only`), non-documentation paths:

| # | Path | Permitted category |
|---|---|---|
| 1 | `.codex/hooks/enforce-epic-child-worktree-binding.ps1` | root hook (2 permitted) |
| 2 | `.codex/hooks/enforce-epic-planning-only.ps1` | root hook (2 permitted) |
| 3 | `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-epic-child-worktree-binding.ps1` | bundle mirror (2 permitted) |
| 4 | `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` | bundle mirror (2 permitted) |
| 5 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | runsettings copy (2 permitted) |
| 6 | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | runsettings copy (2 permitted) |
| 7 | `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` | the named test file |

Cycle-2 delta, untracked non-documentation paths:

| # | Path | Permitted category |
|---|---|---|
| 8 | `tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1` | additional test file 1 of at most 5 |
| 9 | `tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1` | additional test file 2 of at most 5 |

Every remaining path in the delta is under
`docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/` (the FEATURE folder): the plan
document, the appended [P0-T1] artifact, and 15 new evidence artifacts.

Budget reconciliation:

| Budget | Allowed | Used | Verdict |
|---|---|---|---|
| Root hooks | 2 | 2 | PASS |
| Bundle mirrors | 2 | 2 | PASS |
| Runsettings copies | 2 | 2 | PASS |
| The named test file | 1 | 1 | PASS |
| Additional test files under `tests/scripts/codex-hooks/` | <= 5 (<= 2 Phase 5, <= 3 Phase 6) | 2 (both from Phase 5; Phase 6 took `NO-FURTHER-GAP` and created none) | PASS |
| Files outside `FEATURE/` and the above | 0 | 0 | PASS |

Nothing outside the permitted set appears in the delta.

### (c) `.codex/config.toml` shows no diff at all — **HOLDS**

| Check | Result |
|---|---|
| `git diff -- .codex/config.toml` | empty |
| `git diff fb483b84 --stat -- .codex/config.toml` | empty |
| `git diff 21fc8c3b --name-only -- .codex/config.toml` | empty |
| Present in `git status --porcelain` | no |

The file is unmodified, unstaged, and uncommitted, matching the clean [P0-T2] baseline exactly. Hard
Constraint 3 holds. The registrations, matchers, and handler set are untouched in both root and bundle.

### (d) No `.codex/state/*` file staged — **HOLDS**

`git diff --cached --name-only` contains no `.codex/state` path (grep exit 1), and the directory does not
exist in the working tree (`ls -d .codex/state` exit 2). No such file can be or has been staged.

### (e) No spec acceptance-criteria edit — **HOLDS**

`git diff 21fc8c3b --name-only -- docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/spec.md`
produced **empty output**: `spec.md` was not touched at any point in cycle 2. It appears in the
merge-base..HEAD diff only because cycle 1 authored it, which is expected and unrelated.

All 12 acceptance criteria (`spec.md:262-273`) remain `- [x]` with their original text. None was unchecked,
none was edited, and none was added. Hard Constraint 10 and the AC-tracking rule "do not add phantom
criteria" both hold.

## Working-Tree State

`git status --porcelain` shows 7 modified and 18 untracked paths, all within the permitted set enumerated
in (b). `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD` reports
`242 files changed, 20721 insertions(+), 1378 deletions(-)`, which includes the 21 upstream `main` commits
brought in by the rebase (issues #421, #422, #423, #426) in addition to this branch's own work.

## Verdict

| Assertion | Result |
|---|---|
| (a) No `.claude/` path in the cycle-2 delta | **PASS** |
| (b) Delta limited to the permitted path set | **PASS** |
| (c) `.codex/config.toml` shows no diff at all | **PASS** |
| (d) No `.codex/state/*` file staged | **PASS** |
| (e) No spec acceptance-criteria edit | **PASS** |

All five assertions hold with command output captured.

EXIT_CODE: 0
