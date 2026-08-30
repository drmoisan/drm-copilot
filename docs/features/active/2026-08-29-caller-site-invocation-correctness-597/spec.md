# caller-site-invocation-correctness (Spec)

- **Issue:** #597
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-29T16-30
- **Status:** Draft
- **Version:** 0.2

## Context
Three `Import-Module` call sites under `.claude/**` use a relative module path, an ambient
PowerShell host assumption, no `-ErrorAction Stop`, and an unguarded `if ($result)` truthiness
read against `Test-BlastRadiusConflict`'s return value. Each of these defects makes the invocation
unreliable on a destination runtime that only guarantees `pwsh`, not an ambient `powershell.exe`
host with a permissive execution policy.

A research pass on this branch
(`docs/features/active/2026-08-29-caller-site-invocation-correctness-597/research/caller-site-invocation-correctness.2026-08-29T16-30.md`)
found that two of the three line numbers cited in the originating `issue.md` have drifted since
promotion. This spec supersedes those stale line numbers with the corrected ones re-verified
against the current tree:

| Site | issue.md line (stale) | Corrected line (this spec) |
|---|---|---|
| `.claude/skills/parallel-plan/SKILL.md` | 185 | **183** |
| `.claude/skills/parallel-add/SKILL.md` | 64 | **62** |
| `.claude/agents/parallel-planner.md` | 151 | 151 (unchanged) |
| `.claude/skills/parallel-plan/SKILL.md` sibling truthiness warning | 310-314 | **307-311** |
| `.claude/lib/blast-radius/BlastRadius.psm1` truthiness warning | 432-441 | 432-441 (unchanged) |

Environment:
- OS/version: Windows and Linux destination runtimes receiving the `.claude/**` push-down payload.
- Python version: N/A (PowerShell-only defect).
- Command/flags used: `Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force` as written
  at the three sites below.
- Data source or fixture: N/A.

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Open `.claude/skills/parallel-plan/SKILL.md:183` (inside a fenced ```powershell block opened at
   182, closed at 184), `.claude/skills/parallel-add/SKILL.md:62` (an inline parenthetical prose
   sentence fragment, not a fenced block), and `.claude/agents/parallel-planner.md:151` (inside a
   fenced ```powershell block opened at 150, closed at 152).
2. Observe each instructs `Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force` with a
   relative path, no `pwsh` host qualifier, no `-ErrorAction Stop`, and no corrected
   `$result['conflict']` read pattern.
3. Run the instructed invocation from a working directory other than the repository root, or under
   the Windows PowerShell 5.1 default execution policy.

Expected:
Each call site should invoke `pwsh` explicitly (the default PowerShell 5.1 execution policy blocks
`Import-Module` of a `.psm1` file, so `pwsh` is mandatory), use a root-anchored module path so the
import does not depend on the caller's current working directory, pass `-ErrorAction Stop` so a
missing or broken module fails fast rather than silently, and read the conflict verdict from
`$result['conflict']` per the existing warning at
`.claude/lib/blast-radius/BlastRadius.psm1:432-441` and the sibling warning at
`.claude/skills/parallel-plan/SKILL.md:307-311`.

Actual:
All three sites use a relative path (`Import-Module .claude/lib/blast-radius/BlastRadius.psm1
-Force`) with no `pwsh` qualifier, no `-ErrorAction Stop`, and no documented execution-policy trap.
A relative-path import resolves against the caller's current working directory rather than the
repository root, so the same instruction text fails differently depending on where it is invoked
from; the missing `-ErrorAction Stop` lets a broken import continue silently; the missing `pwsh`
qualifier omits the fact that Windows PowerShell 5.1's default execution policy blocks
`Import-Module` of a `.psm1`.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: N/A — this is a documentation/instruction-text defect, not a runtime stack trace.


## Scope & Non-Goals
- In scope:
  - Correcting the `Import-Module` invocation text at the three prose call sites and their three
    bundle mirrors (six files total): `.claude/skills/parallel-plan/SKILL.md:183`,
    `.claude/skills/parallel-add/SKILL.md:62`, `.claude/agents/parallel-planner.md:151`, and their
    byte-identical counterparts under
    `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
  - Adding a `pwsh` host qualifier, a root-anchored module path, `-ErrorAction Stop`, and (where the
    surrounding prose discusses reading `Test-BlastRadiusConflict`'s return value) the corrected
    `$result['conflict']` read pattern at each of the three sites.
  - Documenting, in prose immediately adjacent to each corrected invocation, the PowerShell 5.1
    execution-policy trap that makes `pwsh` mandatory.
- Out of scope / non-goals:
  - `.claude/skills/parallel-plan/SKILL.md:315` (the `parallel_lane_assertion` Python invocation).
    This is owned by Feature D (issue placeholder 904, wave 2,
    `remove-remaining-python-invocations`), which depends on this feature specifically because both
    features edit `.claude/skills/parallel-plan/SKILL.md`. This spec's edits must leave line 315 and
    its surrounding prose textually unchanged.
  - `.claude/skills/parallel-orchestrate/SKILL.md` and `.claude/skills/epic-orchestrate/SKILL.md` in
    their entirety — not touched by this feature at all.
  - Editing or regressing the two existing truthiness-warning passages
    (`.claude/lib/blast-radius/BlastRadius.psm1:432-441` and
    `.claude/skills/parallel-plan/SKILL.md:307-311`). Both are confirmed correct by the research
    pass and are cited by this spec as the pattern the corrected call sites must follow, not as
    material to be edited.
  - JSON date-coercion / `-DateKind` handling. This belongs to Feature A (issue placeholder 901,
    wave 0, `blast-radius-powershell-calling-convention`), which this feature depends on per the
    epic manifest (`docs/features/epics/claude-runtime-portability/epic.md`). As of this research
    pass, Feature A has not fanned in on this branch — no
    `docs/features/active/**blast-radius-powershell-calling-convention**` folder exists yet (research
    §4). None of the three call sites, nor `BlastRadius.psm1`, nor any module under
    `.claude/lib/blast-radius/**` calls `ConvertFrom-Json`, so no JSON date-coercion concern arises
    at these sites regardless. This spec independently justifies its own `-ErrorAction Stop` /
    `pwsh` / root-anchoring correction at these three prose call sites without citing an
    as-yet-nonexistent Feature A spec, while still recording the dependency relationship from the
    epic manifest above.
- Explicitly excluded systems, integrations, or datasets:
  - Any change to TaskMaster-repository code. The TaskMaster framing in the originating bug report
    is motivating consumer-repository evidence, not the target of the fix.
  - Porting `scripts/dev_tools/parallel_drift_detection_cli.py` (Feature D non-goal, not this
    feature's concern at all).

## Root Cause Analysis
Part of the `claude-runtime-portability` epic (`docs/features/epics/claude-runtime-portability/epic.md`),
Feature C (issue placeholder 903, wave 1). Depends on Feature A (issue placeholder 901, wave 0,
`blast-radius-powershell-calling-convention`), which establishes the fail-fast import convention for
`.claude/lib/**` modules themselves (i.e., inside the `.psm1`/library files that import their own
sibling modules) — a related but distinct call-site class from the prose skill/agent invocation
instructions this feature corrects. Feature A has not fanned in on this branch as of the research
pass dated 2026-08-29T16-30 (no matching feature folder exists under `docs/features/active/**`), so
this spec cites the epic manifest's description of Feature A's scope rather than a fanned-in spec,
and treats its own `-ErrorAction Stop` / `pwsh` / root-anchored-path correction as independently
justified at these three prose call sites.

The three defects share one root cause: the instruction text was authored assuming an ambient
PowerShell host already running from the repository root with a permissive execution policy — an
assumption that does not hold on a destination runtime receiving the `.claude/**` push-down payload,
which guarantees only `pwsh` (PowerShell 7+), not `powershell.exe` (Windows PowerShell 5.1) with a
relaxed policy, and does not guarantee the caller's working directory is the repository root.

Cross-cutting constraint: every edit to a `.claude/**` file must be mirrored byte-identically into
`extensions/drm-copilot/resources/claude-customizations/.claude/**`, per
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(lines 101-126), which performs a whole-file byte-equality comparison, not a line-scoped one. Each of
the three corrections therefore requires an identical mirrored edit, six files total, landed in the
same change, or this test fails.


## Proposed Fix

### Design summary (what changes where):
At each of the three call sites, replace the bare `Import-Module .claude/lib/blast-radius/BlastRadius.psm1
-Force` instruction with a `pwsh`-qualified, root-anchored, fail-fast form, and add adjacent prose
documenting the PowerShell 5.1 execution-policy trap. The two fenced-code-block sites
(`parallel-plan/SKILL.md:183`, `parallel-planner.md:151`) receive the corrected multi-line `pwsh`
snippet; the inline-parenthetical site (`parallel-add/SKILL.md:62`) receives the same three
corrections expressed as a prose sentence fragment, preserving its existing sentence structure. Each
edit is duplicated byte-identically into the corresponding bundle mirror under
`extensions/drm-copilot/resources/claude-customizations/.claude/**`.

### Boundaries and invariants to preserve:
- The two existing truthiness-warning passages (`BlastRadius.psm1:432-441`,
  `parallel-plan/SKILL.md:307-311`) are cited as the pattern to follow and must remain textually
  unchanged.
- `parallel-plan/SKILL.md:315` (the out-of-scope `parallel_lane_assertion` Python invocation) and its
  surrounding prose must remain textually unchanged.
- `parallel-orchestrate/SKILL.md` and `epic-orchestrate/SKILL.md` must not be touched at all.
- The `parallel-add/SKILL.md:62` site's parenthetical sentence structure must be preserved; the fix
  must not replace it with a multi-line fenced code block.

### Dependencies or blocked work:
- Depends on Feature A (901, wave 0) per the epic manifest's dependency declaration (`depends_on:
  [901]`), though Feature A's own scope (fail-fast guards inside `.claude/lib/**` library modules) is
  distinct from and does not block this feature's independently justified prose-invocation
  correction.
- Blocks Feature D (904, wave 2), which depends on this feature specifically because both edit
  `.claude/skills/parallel-plan/SKILL.md`.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
1. `.claude/skills/parallel-plan/SKILL.md` (line 183, inside the fenced ```powershell block opened
   at 182, closed at 184).
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
   (mirror of #1, same relative line).
3. `.claude/skills/parallel-add/SKILL.md` (line 62, inline parenthetical prose).
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
   (mirror of #3, same relative line).
5. `.claude/agents/parallel-planner.md` (line 151, inside the fenced ```powershell block opened at
   150, closed at 152).
6. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`
   (mirror of #5, same relative line).

#### Functions/classes/CLI commands impacted:
None. This is a prose/instruction-text correction; no production PowerShell, TypeScript, or Python
function signature changes.

#### Data flow and validation changes:
None beyond the invocation text itself. No JSON parsing, schema, or data-shape change is introduced
(confirmed by research §5: none of the three sites, nor any module under
`.claude/lib/blast-radius/**`, calls `ConvertFrom-Json`).

#### Error handling and logging updates:
Adding `-ErrorAction Stop` to each corrected invocation changes the caller-visible failure mode from
"silent continuation past a broken import" to "immediate terminating error," consistent with the
fail-fast principle this epic establishes for the `.claude/**` runtime surface.

#### Rollback/feature-flag considerations (if applicable):
None. This is a textual instruction correction with no runtime feature flag; rollback is a plain
revert of the six file edits.

### Technical specifications (interfaces/contracts):

**Root-anchored path design decision (locked; not re-opened by this spec).** The research artifact
(§6) found no existing hardened root-anchored `Import-Module` convention in this repository for
markdown prose call sites — only `$PSScriptRoot`-relative forms exist, and those apply only inside
`.ps1`/`.psm1` script files, which is not the situation at these three prose sites. The concrete form
for this feature is: derive the repository root at invocation time via `git rev-parse
--show-toplevel` and join it to the module's repo-relative path, then import with `-ErrorAction
Stop`. The corrected invocation for the two fenced-block sites
(`parallel-plan/SKILL.md:183`, `parallel-planner.md:151`, and their bundle mirrors) reads:

```powershell
$repoRoot = git rev-parse --show-toplevel
Import-Module (Join-Path $repoRoot '.claude/lib/blast-radius/BlastRadius.psm1') -Force -ErrorAction Stop
```

...run via `pwsh -NoProfile -Command "..."` or as a multi-line `pwsh` block, since the surrounding
prose at both sites already establishes a `pwsh` code fence. Prose immediately adjacent to each
snippet must state the PowerShell 5.1 execution-policy trap as an environment-constraint explanation
(not a code-behavior change): under the default PS5.1 execution policy, `Import-Module` of a `.psm1`
file is blocked, so `pwsh` is mandatory.

For the `parallel-add/SKILL.md:62` inline-parenthetical site (and its bundle mirror), the same three
corrections (`pwsh` qualifier, root-anchored path via `git rev-parse --show-toplevel`,
`-ErrorAction Stop`) are expressed in prose form suitable for a parenthetical sentence, since
research explicitly warns against disrupting that site's sentence structure by substituting a
fenced block.

Where the surrounding prose at a site discusses reading `Test-BlastRadiusConflict`'s return value
(distinct from the `Import-Module` line itself), the corrected reading is `$result['conflict']`, not
a bare `if ($result)` truthiness check — matching the existing warnings at
`BlastRadius.psm1:432-441` and `parallel-plan/SKILL.md:307-311`, which this spec cites as the pattern
to follow and does not modify.

#### Inputs/outputs and formats:
N/A — instruction text only, no data format change.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
The corrected invocation is a strict hardening of the existing one (adds host qualifier, path
anchoring, and fail-fast error handling); it does not change the module's exported function surface
or its callers' expected return shape.

#### Performance constraints (latency/throughput/memory):
None applicable; the change adds one `git rev-parse --show-toplevel` subprocess call per invocation
of the corrected instructions, which is negligible relative to the module import itself.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The destination runtime executing these instructions has `pwsh` (PowerShell 7+) available and a
    working `git` executable on `PATH` (required for `git rev-parse --show-toplevel`).
  - The instructions are always executed from within a clone of this repository (so `git rev-parse
    --show-toplevel` resolves to the correct root).
- Constraints (budget, performance, compatibility):
  - The mirror-parity test (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`)
    requires the six file edits to land together, byte-identical between repo and bundle copies.
- External dependencies (services, libraries, releases):
  - None beyond `pwsh` and `git`, both already assumed elsewhere in the `.claude/**` runtime surface.

## Data / API / Config Impact
- User-facing or API changes: None.
- Data or migration considerations: None.
- Logging/telemetry updates (if any): None.
- Compatibility notes (CLI flags, config schemas, versioning): None.
- Cross-cutting test constraint:
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  (lines 101-126) performs a whole-file byte-equality assertion between every repo `.claude/**` file
  and its mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/**`. All six
  files identified in this spec (three repo sites + three mirror sites) must be edited identically in
  the same change, or this test fails. This test is named as an explicit acceptance criterion below.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: N/A for production code (prose-only instruction-text correction); verify
      via a literal-token search for the corrected invocation pattern at each of the three sites and
      their bundle mirrors, plus the existing `BlastRadius.Conflict.Tests.ps1` / bundle-parity test
      suite remaining green.
- [x] Integration scenario to retest: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- [ ] Manual verification notes: N/A.

- Regression tests to add or update: None new. This is a documentation/instruction-text-only
  correction; no production PowerShell, TypeScript, or Python source changes.
- Unit tests (pytest) for the fixed behavior and boundaries: N/A — no executable production code
  changes at these three sites.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): N/A for the
  prose correction itself; the existing `BlastRadius.Conflict.Tests.ps1` regression pair
  (`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:87-118`) already pins the
  `$result['conflict']` truthiness hazard at the library level and must remain green, unmodified.
- Error handling and logging verification: Confirm the corrected `-ErrorAction Stop` text is present
  at each of the six files via literal-token search.
- Coverage impact and targets for changed lines/modules: No coverage impact; no executable code is
  added or changed.
- Toolchain commands to run (format → lint → test): N/A for markdown prose edits; no PowerShell,
  TypeScript, or Python source file is modified by this feature.
- Manual validation steps (if required): Literal-token search confirming, at each of the six files,
  the presence of `pwsh`, the `git rev-parse --show-toplevel` / `Join-Path` root-anchored form,
  `-ErrorAction Stop`, and (where applicable) the `$result['conflict']` read pattern; and confirming
  the two existing truthiness warnings and line 315 of `parallel-plan/SKILL.md` are unchanged.


## Acceptance Criteria
- [x] `.claude/skills/parallel-plan/SKILL.md:183` (fenced ```powershell block, opened at 182, closed
      at 184) is corrected to a `pwsh`-qualified, root-anchored `Import-Module` invocation using
      `$repoRoot = git rev-parse --show-toplevel` + `Join-Path` + `-ErrorAction Stop`, with adjacent
      prose documenting the PowerShell 5.1 execution-policy trap.
- [x] `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
      is byte-identical to the corrected repo file above.
- [x] `.claude/skills/parallel-add/SKILL.md:62` (inline parenthetical prose fragment) is corrected to
      express the `pwsh` qualifier, the root-anchored `git rev-parse --show-toplevel` path, and
      `-ErrorAction Stop` in prose form, preserving the existing parenthetical sentence structure
      (not replaced with a fenced code block), with adjacent prose documenting the PowerShell 5.1
      execution-policy trap.
- [x] `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
      is byte-identical to the corrected repo file above.
- [x] `.claude/agents/parallel-planner.md:151` (fenced ```powershell block, opened at 150, closed at
      152) is corrected identically to the `parallel-plan/SKILL.md` form above, with adjacent prose
      documenting the PowerShell 5.1 execution-policy trap.
- [x] `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md` is
      byte-identical to the corrected repo file above.
- [x] Where the surrounding prose at a corrected site discusses reading
      `Test-BlastRadiusConflict`'s return value, the documented read pattern is `$result['conflict']`,
      not a bare `if ($result)` truthiness check.
- [x] `.claude/lib/blast-radius/BlastRadius.psm1:432-441` (the existing truthiness warning) is
      unchanged.
- [x] `.claude/skills/parallel-plan/SKILL.md:307-311` (the sibling truthiness warning) is unchanged.
- [x] `.claude/skills/parallel-plan/SKILL.md:315` (the out-of-scope `parallel_lane_assertion` Python
      invocation) and its surrounding prose are unchanged.
- [x] `.claude/skills/parallel-orchestrate/SKILL.md` and `.claude/skills/epic-orchestrate/SKILL.md`
      are not modified.
- [x] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      passes after all six file edits land in the same change, confirming byte-identical repo/bundle
      mirror pairs.
- [x] `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` (the existing
      `$result['conflict']` truthiness regression pair) remains green and unmodified.

## Risks & Mitigations
- Technical or operational risks:
  - Editing only the repo copy and forgetting a bundle mirror (or vice versa) fails the
    whole-file byte-equality test; six files must be edited together in one change.
  - Editing the `parallel-add/SKILL.md:62` parenthetical site with a fenced code block would disrupt
    its surrounding sentence and is explicitly disallowed by this spec.
  - Touching `parallel-plan/SKILL.md:315` or the two truthiness warnings while editing nearby lines
    in the same file would silently regress out-of-scope content.
- Mitigations and rollbacks:
  - Verify all six files via literal-token search before considering the change complete.
  - Run `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and the
    `BlastRadius.Conflict.Tests.ps1` suite as the final verification gate.
  - Rollback is a plain revert of the six file edits; no data migration or feature flag is involved.

## Rollout & Follow-up
- Release/rollout steps: Land all six file edits in a single change; no phased rollout or feature
  flag is required for a prose-only correction.
- Post-fix monitoring or clean-up tasks: None beyond the standard CI gate
  (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`).
- Links: Issue #597
  (https://github.com/drmoisan/drm-copilot/issues/597); epic
  `docs/features/epics/claude-runtime-portability/epic.md`; research
  `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/research/caller-site-invocation-correctness.2026-08-29T16-30.md`.
