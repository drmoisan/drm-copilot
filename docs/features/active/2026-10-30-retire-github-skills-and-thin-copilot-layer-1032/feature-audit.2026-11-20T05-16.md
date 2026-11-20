# Feature Audit: retire `.github/skills` and thin the Copilot layer (#1032)

---

**Audit Date:** 2026-11-20
**Feature Folder:** `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032`
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/retire-github-skills-and-thin-copilot-layer-1032`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review (S7) and post-remediation acceptance verification of cycles 1 and 2

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (commit `0cf0dd629c51e74d84298e3c8c98b01044c4ec3d`, the integration tip; the head is 0 commits behind it)
- **Head branch/commit:** `feature/retire-github-skills-and-thin-copilot-layer-1032` (commit `6a0b4b3f7da7d98629be3fa3c695834e9b514406`, equal to the remote branch head)
- **Merge base:** `0cf0dd629c51e74d84298e3c8c98b01044c4ec3d`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-20 05:02:56 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/evidence/**`
  - Additional evidence: reviewer commands listed in `policy-audit.2026-11-20T05-16.md` Appendix B; reviewer Jest record `evidence/qa-gates/review-jest-root-coverage.2026-11-20T05-09.md`
- **Feature folder used:** `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` (22 AC) and `user-story.md` (12 AC) are authoritative. The `issue.md` early-draft checklist is not an AC source in this mode.
- **Scope note:** diff scope is the integration merge base (orchestrator decision AD-7). Where an AC command names `origin/main`, it is evaluated against the merge base, and the literal result is noted. Plans in scope: `plan.2026-10-30T18-39.md`, `plan-h3-sync-writer-retirement.md`, `plan-agents-branch-b.md`, `remediation-plan.2026-11-19T12-09.md`, `remediation-plan.2026-11-19T19-58.md`; `plan-agents-branch-a.md` was not selected and not executed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/spec.md` — primary source (AC1 to AC22)
- `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/user-story.md` — secondary source (US-AC1 to US-AC12)

### From spec.md

1. AC1 — `.github/skills/` does not exist in the tree.
2. AC2 — the Copilot bundle `.github/skills/` does not exist, and `test_copilot_bundle_mirrors_every_scoped_github_file` passes with `.github/skills` removed from `COPILOT_ROOTS`.
3. AC3 — U1 to U5 dispositions recorded with reasons and references.
4. AC4 — exactly one agents branch plan executed per E3, H3 after main plan, order recorded.
5. AC5 — branch outcome (Branch B: each `.github/agents` file no-drift or `native` with reason).
6. AC6 — every prompt `agent:` binding and handoff target resolves, recorded.
7. AC7 — `.github/copilot-instructions.md` exists, no duplicated tone policy, bundle copy identical.
8. AC8 — `.github/prompts` and `.github/hooks` unchanged except child 5 changes.
9. AC9 — collision controls per AD-3, kept-default keys absent, `settings_required.json` absent, two workspace-settings tests pass.
10. AC10 — remaining brief copies byte-identical; no source wording; targets present; `BRIEF-PIN-TESTS` pass.
11. AC11 — named contract suites pass; no `.github/skills` sweep root; docs-authoring suites assert no `.github/skills` location.
12. AC12 — push-down contract tests and engine Jest suite pass; no pack manifest lists a retired path.
13. AC13 — every remaining `.github/skills` hit outside `docs/features/` is classified (not `example`); `COPILOT-AGENT-FILES` have zero matches.
14. AC14 — parity matrix entries carry disposition, `reason`, `decision_ref`; repo gate passes.
15. AC15 — current-fact documents no longer state `.github/skills` is canonical or present.
16. AC16 — toolchain and coverage gates green; edited production files at least 85% lines and 75% branches with no changed-line regression.
17. AC17 — tests pass in `PARALLEL-GATES` only.
18. AC18 — no new Python; no added TypeScript or Python under a pushed-down tree.
19. AC19 — no edited file past 800 lines; no baseline file grows.
20. AC20 — `AGENTS.md` sync writer retired across all named files; suites pass; CHANGELOG `### Removed` entry.
21. AC21 — remaining writer references classified `historical` or `example`.
22. AC22 — ledger chain tests pass; no retired revert blocks or patch sections; same-commit and `reduction:` token rules; `ProcessReductionChain.psm1` unchanged.

### From user-story.md

23. US-AC1 to US-AC12 — each restates a group of spec AC (mapping given in the evaluation table).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 `.github/skills/` absent | PASS | 0 tracked files; directory absent | `git ls-files .github/skills` | Guard `CLR-SKILL-TREES-ABSENT` passes |
| 2 | AC2 bundle tree absent; mirror test passes | PASS | 0 tracked files; `test_discovery_publication_contracts.py` passes in the cycle-2 pytest gate | `git ls-files extensions/drm-copilot/resources/customizations/.github/skills` | Cycle 2 also removed the incoming `push-down-integration` Copilot copy and its bundle copy |
| 3 | AC3 U1 to U5 dispositions | PASS | `evidence/other/unique-section-dispositions.2026-11-19T08-13.md` | Read of the record | No owner override, nothing ported |
| 4 | AC4 one branch plan, order recorded | PASS | `evidence/other/agents-branch-selection.2026-11-19T07-48.md`, `plan-order.2026-11-19T19-54.md` | Read of the records | E3 deferred, Branch B only; order main, H3, Branch B |
| 5 | AC5 Branch B outcome | PASS | `evidence/other/agents-branch-outcome.2026-11-19T18-21.md`; 50 `copilot:agent:` entries all `native` with `reason` and `decision_ref` | Node read of `config/harness-parity-matrix.json` | 0 removed, 0 added agent files |
| 6 | AC6 bindings resolve | PASS | `evidence/other/agent-binding-resolution.2026-11-19T18-20.md`: 106 bindings, 0 unresolved | Read of the record | `.github/prompts` and handoffs unchanged since |
| 7 | AC7 Copilot instructions | PASS | File holds five Copilot-only bullets; `cmp` with bundle copy identical | `cmp .github/copilot-instructions.md <bundle copy>` | Guard `CLR-COPILOT-INSTRUCTIONS` passes |
| 8 | AC8 prompts and hooks unchanged | PASS | No path under `.github/prompts` or `.github/hooks` in the diff | `git diff --name-status 0cf0dd629..HEAD -- .github/prompts .github/hooks` | |
| 9 | AC9 collision controls | PASS | `README.md` `### Copilot collision controls` names all four keys and values; `.vscode/settings.json` has no `chat.` key; `settings_required.json` absent; `evidence/other/collision-controls.2026-11-19T10-12.md` | `grep -n chat\. .vscode/settings.json`; read of README section | User-scope case (E4 `no`) |
| 10 | AC10 brief copies and count statements | PASS | Four brief copies share blob `a566b17e4`; source wording 0 matches; targets present in all copies; `BRIEF-PIN-TESTS` pass | `git ls-files -s '*execution-environment/SKILL.md'`; `git grep -F` of the source wordings | Contract copies form two pre-existing pairs (AD-8) |
| 11 | AC11 named contract suites | PASS | `c2-pester-final.2026-11-20T04-55.md` and `c2-pytest-final.2026-11-20T04-43.md`: 0 failures including ledger chain suite | Read of gate records | |
| 12 | AC12 push-down contracts; manifests | PASS | `PUSH-DOWN-CONTRACT-TESTS` 0 failures; engine Jest suite 15 passed; 0 retired-path matches in 18 pack manifests | `git grep -c -F .github/skills -- 'extensions/drm-copilot/resources/*/pack-manifests/*.json'` | Cycle-1 F1 resolved |
| 13 | AC13 stale references classified | PASS | 61 files, file-and-count list identical to `stale-reference-classification.2026-11-20T04-37.md`; 0 unclassified; 0 `example`; 0 hits in `COPILOT-AGENT-FILES` | `git grep -c -F .github/skills -- . ':!docs/features/'` compared by sorted diff | |
| 14 | AC14 parity matrix | PASS | Both `copilot:skill-frontmatter-field:` entries and all 50 agent entries carry disposition, `reason`, `decision_ref`; repo gate 7 passed | Node read of the matrix; `c2-pester-final` | |
| 15 | AC15 current-fact documents | PASS | Guard `CLR-CURRENT-DOCS` passes over the seven documents | Read of gate record; `git grep` | |
| 16 | AC16 toolchain and coverage | PASS | Static loops clean; per-file coverage 98.17% to 100.00% lines and 90.00% to 100.00% branches; no changed-line regression | Node read of `coverage/coverage-summary.json` and pytest JSON | See policy audit 1.2.1 |
| 17 | AC17 parallel gates | PASS | One `Invoke-PoshQCParallelTest`, one `pytest -n auto`, Jest workers per cycle | Read of `evidence/regression-testing/` | |
| 18 | AC18 no new Python | PASS | 0 `.py` added from the merge base; no TS or Python added under a pushed-down tree | `git diff --name-only --diff-filter=A 0cf0dd629..HEAD` | Literal `origin/main...HEAD` shows one sibling #1035 test file (CR-4) |
| 19 | AC19 file sizes | PASS | Largest edited covered file 676 logical lines; baseline file unchanged | Node logical line count of 49 files | |
| 20 | AC20 writer retired | PASS | Three writer files absent; 0 writer tokens in the six named files; suites pass; CHANGELOG `### Removed` under `## [Unreleased]` | `git grep -c -e syncAgentsFromInstructions -e sync-agents-from-instructions` | |
| 21 | AC21 writer references classified | PASS | 6 files at head, all in `writer-reference-classification.2026-11-19T16-55.md` as `historical` or `example` | Same search | |
| 22 | AC22 ledger records | PASS | 0 matches of the three retired header strings; deleting commit `720b4ec7d` modifies every affected record; all five ledger commits carry the tokens; `ProcessReductionChain.psm1` not in diff; chain suites pass | `git grep -F` over `docs/engineering/process-reductions/`; `git log --first-parent 0cf0dd629..HEAD -- docs/engineering/process-reductions/` | Entry 0012 token recorded as a deviation |
| 23 | US-AC1 (AC1, AC2) | PASS | Rows 1 and 2 | | |
| 24 | US-AC2 (AC3) | PASS | Row 3 | | |
| 25 | US-AC3 (AC4, AC5, AC6) | PASS | Rows 4 to 6 | | |
| 26 | US-AC4 (AC7, AC8) | PASS | Rows 7 and 8 | | |
| 27 | US-AC5 (AC9) | PASS | Row 9 | | |
| 28 | US-AC6 (AC10) | PASS | Row 10 | | |
| 29 | US-AC7 (AC11, AC12) | PASS | Rows 11 and 12 | | |
| 30 | US-AC8 (AC13, AC15) | PASS | Rows 13 and 15 | | |
| 31 | US-AC9 (AC14) | PASS | Row 14 | | |
| 32 | US-AC10 (AC16 to AC19) | PASS | Rows 16 to 19 | | |
| 33 | US-AC11 (AC20, AC21) | PASS | Rows 20 and 21 | | |
| 34 | US-AC12 (AC22) | PASS | Row 22 | | |

### Remediation finding resolution

| Cycle | Finding | Status | Evidence |
|-------|---------|--------|----------|
| 1 (`remediation-inputs.2026-11-19T12-09.md`) | F1 pack manifests list retired paths | Resolved | 0 retired-path matches in 18 manifests; guard `CLR-PACK-MANIFESTS` passes |
| 1 | F2 merged engine and sync roots | Resolved | Neither production file lists the retired root; engine Jest suite and the four pytest modules pass |
| 1 | F3 re-run checks on merged head | Resolved | Superseded by the cycle-2 re-runs at the reviewed head |
| 2 (`remediation-inputs.2026-11-19T19-58.md`) | F1 modify/delete conflicts on brief copies | Resolved | Retired copies absent; integration-tip `.github` and `.agents` brief copies were identical, and the head `.agents` copy differs from the tip only by the four-copy rewrites |
| 2 | F2 `core.json` conflict | Resolved | Incoming entries kept minus one retired entry; manifest contract tests pass |
| 2 | F3 merged-head re-verification | Resolved | `c2-*` gate, contract, brief-fact and stale-reference records at the merge head; no later code commit |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 34 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Open the PR into `epic/shared-agent-harness-layer-integration` and run the S9 CI green gate on the PR head; no AC depends on it, but the last CI runs predate the cycle-2 merge.
2. Optionally add the two discriminating negative cases named in code review CR-1.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/spec.md`, `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/user-story.md`
- Total AC items: 34
- Checked off (delivered): 34
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 22 | 22 | 0 | Checkbox-backed; all already checked by executors |
| `user-story.md` | 12 | 12 | 0 | Checkbox-backed; all already checked by executors |

No source-file checkbox change was made by this review: every criterion evaluated PASS and was already checked. No criterion is CI-dependent.
