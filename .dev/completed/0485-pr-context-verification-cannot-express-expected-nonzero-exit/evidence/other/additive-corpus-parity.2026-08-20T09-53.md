# Layer 2 — additive corpus parity and cross-runtime comparison (AC9, AC10, AC11, AC17)

Timestamp: 2026-08-20T09-53

Task: [P7-T6] (records the runs of [P7-T2], [P7-T3], [P7-T4], [P7-T5])

Command: poetry run python <scratchpad>/corpus_differential.py <scratchpad>/py_rows.json ; (from `extensions/drm-copilot`) npm run test:unit -- test/lib/pr-context/corpus-differential.tmp.test.ts ; poetry run python <scratchpad>/cross_runtime_compare.py <scratchpad>/py_rows.json <scratchpad>/ts_rows.json ; git grep --untracked -n -E "ExpectedExitCode|expected_exit|expectedExit|expected_nonzero|EXPECTED_EXIT" -- docs/features ; git grep --untracked -n -E "^[[:space:]]*ExpectedExitCode[[:space:]]*:" -- "docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence"
EXIT_CODE: 0

All four commands are recorded on the single `Command:` line above, and the per-run exit codes are
listed in the table below, because a duplicated required key resolves differently in the two parsers
and this artifact is itself inside the corpus the comparison reads.

## Per-run exit codes

| Run | Task | EXIT_CODE | Expectation |
| --- | --- | --- | --- |
| Python corpus differential | [P7-T2] | 0 | zero rendered-row differences |
| TypeScript corpus differential (throwaway Jest harness) | [P7-T3] | 0 | zero rendered-row differences |
| Cross-runtime comparison over single-`EXIT_CODE` artifacts | [P7-T4] | 1 | see the finding recorded below; a non-zero exit is the script reporting differences, not a tooling error |
| AC11 namespace search over `docs/features` | [P7-T5] | 0 | matches found, all inside this feature folder |
| SC7 anchored key-form search over this feature's `evidence` tree | [P7-T5] | 1 | zero matches; the search exits `1` on zero matches, which is the passing condition |

## Resolved module paths reported by the Python leg

The Python leg prints its resolved modules before doing any work and exits non-zero with a
`WRONG_CHECKOUT` message if either resolves outside the working directory. Observed:

```
RESOLVED_PARSER   C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad8da196d6247bdf4\scripts\dev_tools\pr_context\verification_evidence.py
RESOLVED_RENDERER C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad8da196d6247bdf4\scripts\dev_tools\pr_context\collector.py
```

Both paths contain the worktree segment `agent-ad8da196d6247bdf4`, which proves the differential
exercised THIS worktree's post-change parser and renderer and not another checkout's unmodified code.
The TypeScript leg resolves its imports relatively from the harness file inside
`extensions/drm-copilot/test/`, and Jest `rootDir` is this worktree's `extensions/drm-copilot`, so its
scope is likewise this worktree.

## Counts

| Measure | Python leg | TypeScript leg |
| --- | --- | --- |
| Artifacts discovered by `CANONICAL_GLOBS` under `docs/features/active/*` | **1293** | **1293** |
| Rows rendered (records whose result is `pass` or `fail`) | 760 | 767 |
| Records dropped as `unparseable` (never rendered, before or after) | 533 | 526 |
| Artifacts carrying two or more line-anchored `EXIT_CODE:` lines | 165 | 165 |
| **Rendered-row differences, pre-change reference vs post-change output** | **0** | **0** |

The research-time reference was 968 artifacts carrying a line-anchored `EXIT_CODE:`; the 1293 figure
here is every artifact `CANONICAL_GLOBS` discovers in the current working tree (the corpus has grown
since research, and the discovery count includes artifacts with no `EXIT_CODE:` line at all, which
parse as `unparseable` and are dropped). AC9 asserts a diff count of zero over the set discovered at
run time, which is what both legs report.

**AC9 is satisfied in both runtimes: zero rendered-row differences over 1293 discovered artifacts.**

Falsifiability check: the differential compares the post-change six-or-seven-line row against a
pre-change six-line reference computed inline. A negative control confirmed the seventh line does
appear when an expectation is declared — parsing an artifact with an observed code of `1` and a
declared expectation of `1` yields a non-zero `expected_exit_code` and a `pass` result, which would
produce a row difference. The zero-difference result therefore reflects the absence of the key in the
corpus, not an inert comparison.

## Cross-runtime comparison over single-`EXIT_CODE` artifacts (AC10, AC17)

Scope: artifacts carrying exactly ONE line-anchored `EXIT_CODE:` line. The 165 artifacts carrying two
or more are EXCLUDED and counted separately.

```
PY_SINGLE_EXIT_ENTRIES=641
TS_SINGLE_EXIT_ENTRIES=642
ONLY_PY=0
ONLY_TS=1
COMPARED=641 DIFFERENCES=5
```

- Excluded multi-`EXIT_CODE` artifact count: **165**.
- Compared single-`EXIT_CODE` artifacts: **641**.
- Rendered-row differences within that set: **5**, plus **1** artifact rendered by TypeScript and
  dropped by Python.

### Attribution of the excluded 165

The exclusion of the 165 multi-`EXIT_CODE` artifacts is attributable to the DEFERRED
duplicate-`EXIT_CODE` precedence defect, not to this change. Python assigns unconditionally in the
parse loop, so the LAST occurrence wins; TypeScript guards with `!parsed.has(key)`, so the FIRST
occurrence wins. Research measured 156 of 968 affected at research time; the current working tree has
165. No task in this plan alters the `EXIT_CODE` assignment in either parse loop (plan constraint
SC3), and the spec takes Option P2 — defer and file separately.

### Finding — the divergence class is wider than `EXIT_CODE` alone

The 6 remaining anomalies inside the single-`EXIT_CODE` set are NOT caused by this change and are NOT
new. Every one of them is an artifact carrying a duplicated OTHER required key, resolved by the same
last-wins / first-wins asymmetry:

| Artifact | Duplicated key | Effect |
| --- | --- | --- |
| `2026-07-17-legacy-discovery-documentation-371/evidence/qa-gates/r1c1-resources-tree-check.2026-07-19T08-03.md` | `Command` x2 | different `Command` value in the rendered row |
| `2026-07-25-orchestration-state-contract-divergences-412/evidence/qa-gates/remediation1-mirror-parity.md` | `Command` x2 | different `Command` value |
| `2026-07-25-orchestration-state-contract-divergences-412/evidence/regression-testing/phase4-pass-after-powershell-floor.md` | `Command` x2 | different `Command` value |
| `2026-08-07-parallel-enforcement-hooks-440/evidence/other/phase2-invocation-origin-extension.2026-08-08T21-43.md` | `Command` x2 | different `Command` value |
| `2026-08-07-parallel-mutation-protocol-442/evidence/qa-gates/final-py-test-coverage.md` | `Timestamp` x2 | different `Timestamp` value |
| `2026-07-25-orchestrator-completion-hook-false-block-413/evidence/qa-gates/bundle-byte-parity.2026-07-25T17-16.md` | `Command` x2, the second one EMPTY | Python takes the empty last value and reports `unparseable` (row dropped); TypeScript takes the first value and renders the row. This is the single `ONLY_TS` entry. |

The root cause is identical to the deferred defect — the parse loop's duplicate-key precedence
asymmetry (Python `parsed[key] = value` unconditional; TypeScript `!parsed.has(key)` guard) — but it
manifests on the `Command` and `Timestamp` required fields as well as on `EXIT_CODE`. AC10 scopes its
exclusion to artifacts "containing exactly one `EXIT_CODE:` line", which is narrower than the actual
divergence class, so 6 artifacts fall inside the AC10 comparison set while being instances of the
deferred defect. All six differ ONLY in the `Timestamp` or `Command` row value (or, in the last case,
in whether the row renders at all); none differs in `EXIT_CODE`, in `Normalized result`, or in the new
`Expected EXIT_CODE` line.

Two artifacts of THIS feature were initially in this set because they recorded two `Command:` lines;
both were rewritten to carry a single `Command:` line before the runs recorded here, so every
remaining anomaly is in a pre-existing artifact authored by an earlier feature. Verified by scanning
this feature's `evidence` tree for duplicated required keys: only
`evidence/baseline/ts-format.2026-08-20T09-53.md` (outside `CANONICAL_GLOBS`, so outside the corpus)
and the two multi-command pass-after artifacts (which carry three `EXIT_CODE:` lines and are therefore
in the excluded 165) still carry duplicates.

**Consequence for AC10 and AC17.** Rendering parity for the new key is demonstrated: zero differences
in any `EXIT_CODE` row, any `Normalized result` row, or any `Expected EXIT_CODE` row across all 641
compared artifacts. The literal AC10 wording "0 differences across artifacts containing exactly one
`EXIT_CODE:` line" is NOT met, at 5 content differences plus 1 presence difference, and every one is
an instance of the deferred duplicate-key precedence defect acting on a required field other than
`EXIT_CODE`. This is recorded rather than worked around: narrowing the comparison set to
"artifacts with no duplicated required key" would have produced a clean zero, but that is a different
assertion from the one AC10 states, and substituting it silently would hide a real, measured
divergence. The recommended follow-up is to widen the deferred defect's scope from
duplicate-`EXIT_CODE` precedence to duplicate-REQUIRED-KEY precedence when it is promoted.

## AC11 — namespace re-verification, post-change

The first search returned **123 matching lines across 16 files**, and every file is under
`docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/`.
The count of matching files OUTSIDE this feature folder is **0**. The matches are this feature's
`issue.md`, `spec.md`, `plan.2026-08-17T15-00.md`, its research document, and twelve of its own
evidence artifacts that name the token in prose.

`--untracked` is load-bearing: the evidence artifacts this gate searches are newly created and
untracked when the gate runs, so a search of tracked content alone would not see them and the gate
could pass vacuously.

## SC7 — anchored key-form search

The second search, anchored to the PARSEABLE key form
`^[[:space:]]*ExpectedExitCode[[:space:]]*:`, returned **zero matches** over this feature's `evidence`
tree and therefore exited `1`, which is its passing condition. No evidence artifact produced by this
plan carries a parseable expectation key line. The anchored form is required because [P0-T6] and this
artifact are both obliged to name the token in prose; a bare-token search would falsely match them.

Output Summary: 1293 artifacts discovered by `CANONICAL_GLOBS`; Python-leg rendered-row diff count 0;
TypeScript-leg rendered-row diff count 0; cross-runtime comparison over the 641 single-`EXIT_CODE`
artifacts reports 5 content differences plus 1 presence difference, with 165 multi-`EXIT_CODE`
artifacts excluded and that exclusion attributed to the deferred duplicate-`EXIT_CODE` precedence
defect (SC3, spec Option P2). All 6 remaining anomalies are pre-existing artifacts carrying a
duplicated `Command:` or `Timestamp:` line, which is the SAME last-wins/first-wins precedence
asymmetry acting on a required field other than `EXIT_CODE`; none differs in `EXIT_CODE`, in
`Normalized result`, or in the new expectation row, so rendering parity for this change's behavior is
clean. Resolved Python parser and renderer paths both lie inside `agent-ad8da196d6247bdf4`, proving the
differential exercised the post-change code. The AC11 search found 123 matches in 16 files, all inside
this feature folder and 0 outside it. The SC7 anchored key-form search found zero matches and exited
`1`, its passing condition.
