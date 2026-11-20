# Code Review: parallel-planner-time-based-edge-rule (#1164)

**Review Date:** 2026-11-13
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/parallel-planner-time-based-edge-rule-1164`
**Feature Folder Selection Rule:** named by the caller; matches the branch issue number 1164
**Base Branch:** `main` (merge base `1d62aa292161035aec8058e6c370f133e10a04db`, equal to `origin/main` at review time)
**Head Branch:** `feature/parallel-planner-time-based-edge-rule-1164` (head `e6391c3b91e530ad5a54d1a000a3196b639571af`)
**Review Type:** Remediation cycle 2 re-audit (exit review). Inputs `remediation-inputs.2026-11-13T14-14.md` (R5, R6); plan `remediation-plan.2026-11-13T14-14.md` (19 of 19 tasks checked); prior review `code-review.2026-11-13T14-04.md`.

---

## Executive Summary

The cycle 1 exit review graded the branch Go and recorded two related Info rows: irregular write forms, and control-character `repr` escaping. Under owner directive OD-7 the orchestrator opened cycle 2 to fix both inside the item. The cycle commits are `0350f024e` (R5), `73038e57d` (R6 code), `9f40e884e` (six corpus stems), and `a152b14ba` (rule text). A further commit, `e0851033f`, applies a whitespace-only Prettier reformat to both `config/blast-radius.json` copies, required by orchestrator decision D-1164-C2-FMT. The reviewer read the full branch diff against the merge base again for anything new.

**Cycle findings, verified at head:**
- R5 resolved. `$script:WriteTitleIrregularForm` (`BlastRadiusAccess.psm1` lines 62 to 66) adds `Wrote`, `Written`, `Rewrote`, `Rewritten`, `Overwrote`, and `Overwritten` to the case-insensitive set after the inflection loop. Of the 25 listed write verbs, only `Write`, `Rewrite`, and `Overwrite` are irregular, so the list is complete. The set only grows, so the change is fail-safe. The six new `-ForEach` rows each start with `Run`, so each fails against the pre-cycle set. Real-process probe: `access-paths` excluded the paths named with `written`, `wrote`, and `overwritten`, and kept `Read` and the noun `writer` as read-only.
- R6 resolved. `escapeReprCodePoint` (`parallel-state-shared.ts` lines 104 to 148) applies, per code point and in order: delimiter escape, the four named escapes, the printable pass-through (`\p{C}` and `\p{Z}` minus the space), then the shortest `\x`/`\u`/`\U` lowercase hex form. `Array.from` walks code points, so a supplementary character is one unit and a lone surrogate is escaped as `\udXXX`, as in CPython.
  - Full sweep: the esbuild bundle of the head helper was compared with CPython 3.13 `repr` for all 1114112 code points plus 12 multi-character strings (both quotes, backslash with apostrophe, NUL, lone surrogate, combining mark, emoji, the U+007F to U+00AD range). Every multi-character string matched. The 9988 differing code points are all category `Cn` in Python UCD 15.1.0 and all assigned in Node Unicode 17.0, which is the residual class the rule now states.
  - Stems: the six new stems carry CPython's own strings (reviewer Python check). Five of them fail against the pre-cycle helper; the backslash stem pins a behavior the old helper already had.
- Rule text: class (1) of `## Enforcement` in both copies names the escaping rule and the residual Unicode-version divergence. The copies are byte-equal.
- `e0851033f`: both copies parse to identical JSON before and after the commit. The commit is whitespace only.

**Top 3 risks:**
1. Default scheduling behaviour changes for every run planned after merge (owner-directed, OD-1164-1). The committed minutes rest on a small sample (spec D2). Recorded estimates make each verdict auditable, and destinations can override weights.
2. `access-paths` remains a title-word heuristic. Drift detection is the backstop for any write it misclassifies.
3. Cross-runtime string parity depends on each runtime's Unicode database for code points assigned after Unicode 15.1 (finding row 2). This is documented and does not affect the committed corpus.

**PR readiness recommendation:** **Go.** No Blocker, Major, or Minor finding. CI on the PR head and the PR-body statements of US-AC13 remain with the orchestrator.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`, `python-native-corpus.json`, `python-surface-corpus.json` | root `npm run format:check` | The root Prettier check exits 1 on these three issue-1022 golden fixtures. Unrelated to this item: none is in the branch diff, and each has the same blob id on `origin/main` and at head. | None inside this item (orchestrator decision D-1164-C2-FMT). The owner may file a separate issue for the root format check. | Pre-existing on `main` and not CI-gated per the decision. Every branch-changed ts/tsx/js/mjs/cjs/json file passes Prettier. | `phase-gate.P1.2026-11-13T16-15.md` stage 1; reviewer `git rev-parse origin/main:<path>` and `HEAD:<path>` per file. |
| Info | `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts` | `NON_PRINTABLE_CODE_POINT` | Related to this item, because it is in a file this branch changes and the behavior was introduced by R6. The printable test uses Node's Unicode database. 9988 code points that are unassigned in Python 3.13 (UCD 15.1.0) and assigned in Node (Unicode 17.0) render unescaped in TypeScript and as hex escapes in Python. | No change. The divergence is stated as the residual of class (1) in both rule copies. | Closing it would require shipping a Unicode-version-pinned table in TypeScript, which is disproportionate. Planner paths and reason codes do not carry such code points, and the committed corpus uses long-assigned code points. | Reviewer sweep `cmp.cjs`/`chk.py` (SCRATCH): every difference is `Cn` in Python and assigned in Node. |
| Info | `extensions/drm-copilot/src/lib/validate/` (nine other files, for example `epic-planner-state-core.ts` and `orchestrator-state-human-interaction.ts`) | local `pythonRepr` copies | Unrelated to this item: none of the nine files is in the branch diff, and their behavior predates the item. These copies still always single-quote and do not escape control or non-printable characters. The potential entry `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md` describes only the quote-selection half. | Outside this item: extend that potential entry, or the issue that promotes it, to cover escaping. The shared `escapeReprCodePoint` approach can be reused. | Those validators are outside the parallel family, and the Python side is authoritative. | Reviewer search for `function pythonRepr` and `const pythonRepr` under `extensions/drm-copilot/src` (10 files, one of them changed by this branch). |
| Info | `.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1` | tolerated entry without estimates | Related to this item (introduced by this branch). Carried from the prior reviews and accepted as out of scope by both cycle inputs. A hand-written tolerated entry without `cost`/`benefit` produces the message "merge time 0 min does not exceed parallel gain 0 min". | None required. | Message quality only; the engine always returns both estimates. | `remediation-inputs.2026-11-13T14-14.md` `## Out of scope (accepted, no change)`. |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | `Invoke-ParallelAdmissionPrecedenceTest` | Related to this item (introduced by this branch). Carried and accepted as out of scope. `test-precedence` resolves `config/blast-radius.json` relative to the current location and fails loudly elsewhere. | None required. | Matches the helper's existing convention. | Same inputs section. |

No Blocker, Major, or Minor finding. No covered file reaches 700 logical lines (largest: `Invoke-ParallelAdmission.ps1`, 687; `parallel-state-shared.ts` 538), so no file-size Warning row applies.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- No Python file changed in cycle 2 (OD-10). CPython `repr` remains the reference that the TypeScript port now matches, and the Python parity test consumes the six new stems unchanged.

#### Typing and API notes

- Unchanged since the cycle 1 review; Pyright 0 errors in the phase gate.

#### Error handling and logging

- No Python production change in this cycle.

### PowerShell implementation audit (if applicable)

#### What changed well

- The irregular forms are a named module-scope list next to the verb list. The comment states why only three verbs need entries and why the change is fail-safe.
- `Test-WriteTitleWord` and `Test-ReadOnlyWindowSet` are unchanged, so the only behavior change is set membership.

#### API and safety notes

- The title splitter (`-split '[^A-Za-z]+'`) yields whole words, so `writer` and `written` are distinct tokens. The probe confirmed that the noun control stays read-only.
- The module `.DESCRIPTION` and `Get-BlastRadiusReadOnlyPath` `.DESCRIPTION` name `written` as an example.

#### Error handling and logging

- No new error path.

### TypeScript implementation audit (if applicable)

- The quote selection of R1 is kept, and the delimiter test runs before the named escapes. A string holding both quote characters therefore escapes only `'`, as in CPython.
- `Number(char.codePointAt(0))` is safe because `Array.from` never yields an empty string. The hex thresholds `0xff` and `0xffff` match CPython's choice of the shortest form.
- `pythonStr`, arrays, objects, booleans, and `None` are unchanged. Object keys pass through `pythonRepr`, so they gain the same escaping, which matches CPython's dict `repr`.
- Every importer of the module is in the parallel validator family: `parallel-state-records.ts`, `parallel-state-structures.ts`, `parallel-orchestrator-state-core.ts`, `parallel-orchestrator-state-cohort-barrier.ts`, `parallel-planner-state-core.ts`, and `parallel-planner-state-routing.ts`. The extension and root Jest runs passed with no expected-string edit outside the six stems.

### C# implementation audit (if applicable)

- N/A: no C# file in the branch diff.

---

## Test Quality Audit

The cycle's new cases discriminate:
- R5: each of the six rows titles a `Run` task, which the pre-cycle set classified as read-only, so the assertion of zero derived paths fails against it.
- R6: the reviewer ran the pre-cycle helper (bundled from `90d84af13`) on the stem values. Its output differs from the expected string for the newline, tab, control, non-printable, and apostrophe-newline stems. The backslash stem guards against a mutant that drops the backslash escape.
- Both runtimes consume the same stems, so a one-sided edit fails at least one case.

The reviewer judged discrimination by running both helper versions in a real Node process and comparing with CPython. Reverted-mutant suite runs were not used, because the owner's parallel-only rule excludes single-file runs.

### Reviewed test and QA artifacts

- `evidence/qa-gates/phase-gate.P1.2026-11-13T16-15.md` (and the superseded `phase-gate.P1.2026-11-13T15-37.md`)
- `evidence/qa-gates/pester-gate.2026-11-13T16-28.md`, `pytest-gate.2026-11-13T16-32.md`, `jest-gate.2026-11-13T16-32.md`, `jest-root-gate.2026-11-13T16-33.md`
- `evidence/qa-gates/powershell-static.2026-11-13T16-16.md`, `typescript-static.2026-11-13T16-16.md`
- `evidence/qa-gates/self-review.2026-11-13T16-33.md`
- `evidence/other/task-check.P1-T1` to `P1-T4`, `evidence/other/preflight-fixes.2026-11-13T14-27.md`
- `evidence/remediation-baseline/*.2026-11-13T14-*.md`

### Quality assessment prompts

- Do the tests discriminate? Yes, as stated above.
- Are legacy inputs covered? The 15 earlier write-form rows and the 24 earlier corpus stems are unchanged and pass. `accept-without-fields.json` and the unchanged `seed-scheduling-record.json` pin remain.

---

## Security / Correctness Checks

- No absolute path or host name in the new fixtures or cycle evidence (scratch locations are recorded as `SCRATCH`).
- Declared radii are never narrowed. R5 can only remove paths from the derived read-only set (validator rule B10.1).
- No agent `tools:` frontmatter line changed (0 `+tools:`/`-tools:` lines in the diff of `.claude/agents/` and its mirror).
- No new suppression in the added lines of the branch diff apart from the pre-existing-pattern `shellcheck disable=SC1091` in the two bash copies.

---

## Research Log

- Read the cycle inputs, plan, final-QA evidence, cycle baselines, self-review, and the prior review set.
- Reviewed the cycle diff `90d84af13..e6391c3b9` outside the feature folder (14 paths) and the full branch diff `1d62aa292..e6391c3b9` (226 paths).
- Parsed the three canonical coverage artifacts for per-file and repo-wide figures, and mapped the missed lines and branches of `parallel-state-shared.ts` onto the changed hunks.
- Bundled the head and pre-cycle `parallel-state-shared.ts` with esbuild. Compared `pythonRepr` with CPython 3.13 `repr` for every code point and for the stem values, and classified each difference by Unicode assignment in both runtimes.
- Ran a real-process `access-paths` probe on a five-title scratch plan.
- Compared the two `config/blast-radius.json` copies as parsed JSON before and after `e0851033f`; ran `cmp` on the 16 changed `.claude/` files against their mirrors.

---

## Verdict

**Go.** Zero blocking findings. R5 and R6 are resolved. Five Info rows remain. Three are related to this item: the documented Unicode-version residual of `pythonRepr`, and the two carried rows that both cycle inputs accepted. None of the three needs a change. Two are unrelated: the pre-existing root Prettier fixtures under D-1164-C2-FMT, and the nine other `pythonRepr` copies outside the branch diff. None requires a remediation cycle.
