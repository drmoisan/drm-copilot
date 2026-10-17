# Corpus Rule Changes (P4-T4)

Timestamp: 2026-10-12T00-18
CorpusSha: 2ef8d361e978ca8b7733a545d76a87e8418005ce
InitialArtifact: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-run.initial.2026-10-12T00-11.md
FIX-CLASSES: 4
BlockedReason: EXEMPLAR-UNREPRESENTABLE
CorpusGate: BLOCKED

Derivation of k: the P4-T2 initial run printed four `CORPUS-FORM:` lines whose `classes=` value contains `FALSE-POSITIVE`, in this order: `rule1|docs/features/active/<F>/audit/9999-99-99T99-99/<stem>.md` (folders=3, rejections=24), `rule3|PowerShell|NARROWING|sanctioned` (folders=15, rejections=17), `rule3|Python|NARROWING|sanctioned` (folders=2, rejections=2), `rule3|TypeScript|NARROWING|sanctioned` (folders=2, rejections=2). Their rejections total 45, which equals `CORPUS-FALSE-POSITIVE: 45`.

OutOfCorpusObservation: conflict. `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:71` names the remediation inputs `docs/features/active/<slug>/remediation/<entry-ts>/remediation-inputs.md`: the file name carries no timestamp, the folder is `<slug>/remediation/<entry-ts>`, and `<entry-ts>` is the cycle-entry timestamp, which `SKILL.md:81-82` distinguishes from the audit `<exit-ts>`. The H1 comparison at base lines 417-429 requires `remediation-inputs-path` to match `docs/features/active/.../remediation-inputs.<timestamp>.md` and to share the policy audit's feature folder and timestamp. A path that follows the skill is therefore rejected as outside the required location, and a skill-conformant remediation folder would also fail the folder and timestamp comparison. Recorded for the orchestrator; no change is made (D8).

## FIX-1

FormKey: rule1|docs/features/active/<F>/audit/9999-99-99T99-99/<stem>.md
Rule: rule1
Basis: SANCTIONED-S3 (folders=3)
Governing: `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:69-82` (D6 S3: review artifacts at `docs/features/active/<slug>/audit/<yyyy-MM-ddTHH-mm>/<stem>.md`)
Rejections: 24
Exemplar: docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/code-review.md
TargetFile: .claude/hooks/validate-feature-review-coverage-rules.ps1
TargetFunction: Get-ReviewArtifactInfo
Change: Accept, as a second pattern, `^docs/features/active/(?<Folder>[^/]+)/audit/(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}-\d{2})/<Stem>\.md$`, taking the folder from the slug segment and the timestamp from the audit folder segment.
Rationale: the remediation-handoff skill names review artifacts this way, so the location rule rejects artifacts that follow a governing skill.
PolicyEditRequired: no
NewFunctionRequired: no
CodexParity: no equivalent rule. H5 locates the latest audit by `Get-ChildItem -Filter 'policy-audit.*.md'`, which does not match a file named `policy-audit.md`; H5 has no `Get-ReviewArtifactInfo`. Informational only (C5).
Tests: not added (BLOCKED procedure)
Rows: 0
Status: PENDING

## FIX-2

FormKey: rule3|PowerShell|NARROWING|sanctioned
Rule: rule3
Basis: SANCTIONED-S1-S2
Governing: S1 `.claude/rules/general-unit-test.md:25`, `.claude/rules/quality-tiers.md:38`, `.claude/skills/feature-review-workflow/SKILL.md:111`; S2 `.claude/skills/feature-review-workflow/SKILL.md:180`
Rejections: 17
Exemplar: docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md (first qualifying candidate in output order; the three earlier candidates failed: `docs/features/archive/2026-03-11-expose-placeholder-commands-92/policy-audit.2026-03-14T21-22.md` non-ASCII; `docs/features/completed/2026-06-16-bump-and-publish-task-191/policy-audit.2026-06-17T01-05.md` non-ASCII and 42 lines; `docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T15-30.md` non-ASCII and 59 lines; the exemplar line set has 37 lines)
TargetFile: .claude/hooks/validate-feature-review-coverage-rules.ps1
TargetFunction: Test-LanguageCoverageRow
Change: Exclude from the narrowing check every PowerShell coverage line that matches `(?i)\bbranch\b` and does not match `(?i)\bline\s+coverage\b` (S1), and every line inside a `## Rejected Scope Narrowing` section (S2).
Rationale: Pester measures no branch coverage, so a PowerShell branch row marked N/A is the governed form; and caller narrowing text is required to be recorded verbatim in the Rejected Scope Narrowing section.
PolicyEditRequired: no
NewFunctionRequired: no
CodexParity: yes. H5 `Test-LanguageCoverageRow` (lines 178-186) applies the same narrowing pattern with no S1 or S2 exclusion. Informational only (C5).
Tests: not added (BLOCKED procedure)
Rows: 0
Status: PENDING

## FIX-3

FormKey: rule3|Python|NARROWING|sanctioned
Rule: rule3
Basis: SANCTIONED-S1-S2 (S2 only applies; S1 is PowerShell-only)
Governing: S2 `.claude/skills/feature-review-workflow/SKILL.md:180`
Rejections: 2
Exemplar: NONE QUALIFIES. Candidates in output order: `docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md` (line set 77 lines; contains non-ASCII characters); `docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T08-00.md` (line set 80 lines). Both exceed the 40-line limit of P4-T4 (b).
TargetFile: .claude/hooks/validate-feature-review-coverage-rules.ps1
TargetFunction: Test-LanguageCoverageRow
Change: none applied. The S2 exclusion described under FIX-2 would cover this form key.
Rationale: caller narrowing text recorded verbatim inside `## Rejected Scope Narrowing` is required by the governing skill and is not a scope narrowing by the audit.
PolicyEditRequired: no
NewFunctionRequired: no
CodexParity: yes (same narrowing rule in H5, no S2 exclusion). Informational only.
Tests: not added
Rows: 0
Status: PENDING
BlockedReason: EXEMPLAR-UNREPRESENTABLE

## FIX-4

FormKey: rule3|TypeScript|NARROWING|sanctioned
Rule: rule3
Basis: SANCTIONED-S1-S2 (S2 only applies; S1 is PowerShell-only)
Governing: S2 `.claude/skills/feature-review-workflow/SKILL.md:180`
Rejections: 2
Exemplar: NONE QUALIFIES. Candidates in output order: `docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md` (line set 40 lines; one line contains U+2014, which fails the ASCII-only condition); `docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T08-00.md` (line set 57 lines, over the 40-line limit).
TargetFile: .claude/hooks/validate-feature-review-coverage-rules.ps1
TargetFunction: Test-LanguageCoverageRow
Change: none applied. The S2 exclusion described under FIX-2 would cover this form key.
Rationale: as FIX-3.
PolicyEditRequired: no
NewFunctionRequired: no
CodexParity: yes (same narrowing rule in H5, no S2 exclusion). Informational only.
Tests: not added
Rows: 0
Status: PENDING
BlockedReason: EXEMPLAR-UNREPRESENTABLE

## BLOCKED procedure

Trigger: P4-T4 (b), "When no `CORPUS-REJECT:` line with this form key qualifies, set `BlockedReason: EXEMPLAR-UNREPRESENTABLE` in the section and follow the BLOCKED procedure." FIX-3 and FIX-4 have no qualifying exemplar, so the loop cannot complete for j = 3 and j = 4.

Exemplar derivation method (mechanical, per P4-T4 (b)): for each `CORPUS-REJECT:` line carrying the form key, in the P4-T2 output order, the line set is the lines of `git show 2ef8d361e978ca8b7733a545d76a87e8418005ce:<artifact>` that match the CR-CORPUS `Get-LabelRe` value for the language or `^##\s`, in file order, trailing whitespace trimmed. A candidate qualifies only when every character is ASCII, no line matches any `$forbiddenPatterns` entry of `.claude/hooks/check-powershell-test-purity.ps1` (17 patterns, read from that file), no line contains `New-TemporaryFile`, `GetTempFileName`, `TestDrive`, or `$env:TEMP`, no line starts with `'@`, and the set has at most 40 lines.

Actions taken: no policy file edited; no production or test file changed in this phase (FIX-1 and FIX-2 were not applied because the BLOCKED procedure restores `.claude/hooks`, `tests/scripts/claude-hooks`, and the Claude bundle hooks to HEAD); `git restore --source=HEAD -- .claude/hooks tests/scripts/claude-hooks extensions/drm-copilot/resources/claude-customizations/.claude/hooks` run; evidence and plan committed with `docs(896): record corpus gate BLOCKED` and pushed. No Phase 5 task is started.

Decision needed from the planner or operator (not chosen here): how FIX-3 and FIX-4 are to be represented in a test, given that their only rejections come from line sets that exceed the 40-line here-string limit or contain non-ASCII text.

## Exemplar derivation output (scratch analysis; candidate and exemplar lines)

```
PURITY-PATTERNS: 17
CANDIDATE: rule3|PowerShell|NARROWING|sanctioned | docs/features/archive/2026-03-11-expose-placeholder-commands-92/policy-audit.2026-03-14T21-22.md | lines=37 | non-ascii
CANDIDATE: rule3|PowerShell|NARROWING|sanctioned | docs/features/completed/2026-06-16-bump-and-publish-task-191/policy-audit.2026-06-17T01-05.md | lines=42 | non-ascii,lines=42
CANDIDATE: rule3|PowerShell|NARROWING|sanctioned | docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T15-30.md | lines=59 | non-ascii,lines=59
CANDIDATE: rule3|PowerShell|NARROWING|sanctioned | docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md | lines=37 | QUALIFIES
EXEMPLAR: rule3|PowerShell|NARROWING|sanctioned | docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md | lines=37
CANDIDATE: rule3|Python|NARROWING|sanctioned | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | lines=77 | non-ascii,lines=77
CANDIDATE: rule3|Python|NARROWING|sanctioned | docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T08-00.md | lines=80 | lines=80
EXEMPLAR: rule3|Python|NARROWING|sanctioned | NONE
CANDIDATE: rule3|TypeScript|NARROWING|sanctioned | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | lines=40 | non-ascii
CANDIDATE: rule3|TypeScript|NARROWING|sanctioned | docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T08-00.md | lines=57 | lines=57
EXEMPLAR: rule3|TypeScript|NARROWING|sanctioned | NONE
PROCESS_EXIT: 0
```
