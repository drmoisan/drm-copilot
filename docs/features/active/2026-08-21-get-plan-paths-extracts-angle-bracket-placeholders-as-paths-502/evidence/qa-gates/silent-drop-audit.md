# QA Gate — Silent-Drop Audit — [P8-T14]

Timestamp: 2026-08-23T05-38

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T14]
Run: revision-6 re-run, over a diff that has changed by one removed fixture and two edited test files.

Command: `git add -A` (at the repository root)

Command: `git diff main`

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

EXIT_CODE: 0

## Why staging is required

A finding rule added inside a newly created file is invisible to an unstaged diff, which is exactly the
case this audit must catch: the two new leaf modules are where a new diagnostic channel would most
plausibly be introduced. `git add -A` was run at the repository root before the diff was taken.

Ref-position note: `main` is not an ancestor of `HEAD`, so the audit reads the merge-base-anchored diff
`bee15c0660d382ed74c642d2e028fd136051046f`. Both anchors were resolved and recorded.

## Diff file-list completeness

The staged name-status list contains **all eight** created paths, including both new leaf modules. The
full table is at [P8-T5].

## No new finding rule

A sweep of every added line under `scripts`, `.claude`, and the bundled resources tree for
finding-construction and severity tokens returned a match count of **0**:

- no finding-record construction,
- no append or add to a findings collection,
- no Blocking, Warning, or Advisory severity literal.

**No new finding rule was added.** **PASS.** Confirmed structurally by [P8-T13], whose sweep for quoted
rule identifiers over the same diff also returned no matches: there is no rule identifier for a new
finding to be reported under.

## No new warning or advisory emission

The same sweep covered every diagnostic channel available in either runtime, with a combined match count
of **0**:

| Channel | Runtime | Added occurrences |
| --- | --- | --- |
| the five PowerShell `Write-` diagnostic cmdlets | PowerShell | **0** |
| the Python warnings facility | Python | **0** |
| logging module and logger calls | Python | **0** |
| console print | Python | **0** |
| raise | Python | **0** |

**No warning, advisory, log line, console write, or exception was added.** **PASS.**

## The rejection is silent by design, and this is what that means concretely

The guard returns the **same no-classification value the four sibling rejections already return** in
each runtime. There is no diagnostic channel, no new finding rule, and no signature change, so a
marker-bearing token is dropped by exactly the mechanism that already drops a directory-shaped token, a
cross-corpus documentation glob, a separator-free non-surface token, and an absolute or scheme-prefixed
token.

The design reason is recorded in the amended description block of the PowerShell classifier and is worth
restating: a shape citation is not an error on the plan author's part. Every well-formed plan in this
repository quotes the mandated evidence-path shape, because the evidence-path scheme is non-overridable.
A diagnostic on that citation would fire on almost every plan, which would make the channel useless and
train readers to ignore it. Drift detection, which compares the declared radius against the paths a diff
actually touched, is the mechanism that catches an item that really wrote a path it expressed as a shape.

## Expected-findings blocks of all pre-existing fixtures are unchanged

The name-status output for the fixture tree contains **3 added and 0 modified** entries, so no
pre-existing fixture file was modified at all — expected-findings blocks included.

The corpus at the merge base contains **33** JSON files under the fixture directory, of which **32** are
top-level parity fixtures and one is the nested verification-integrity capture consumed by a dedicated
Describe in each parity suite. The plan's phrase "all 32 pre-existing fixtures" refers to the top-level
set; the nested capture is likewise unmodified, so the stronger statement holds: **all 33 pre-existing
fixture files are byte-unchanged.**

This is the load-bearing half of the audit. A change that quietly relaxed an existing fixture's expected
block to accommodate the new guard would be invisible to both parity suites, because each suite reads the
fixture as its own source of truth and neither can detect that the truth moved. The zero-modified-entry
observation forecloses that, and it is corroborated three ways:

| Observation | Task |
| --- | --- |
| zero modified entries under the fixture tree in the staged whole-tree anchored diff | this task |
| union of a porcelain status and an anchored diff carries zero modified entries | [P5-T12] |
| dedicated zero-exit diff against the anchor for the reused negative control | [P5-T7] |

## Corollary: all three added fixtures declare empty findings lists

Verified by parsing each file rather than by reading it:

```text
derivation-placeholder-token-rejected:    findings=[]
derivation-placeholder-marker-variants:   findings=[]
validation-placeholder-self-consistent:   findings=[]
```

That is not a formality. It is the positive statement that a placeholder-citing plan produces **no**
finding, which is the fixture-level expression of the silent-drop constraint, and it is asserted by both
parity suites on every run. Had the guard emitted a diagnostic, all three fixtures would fail.

## The two [P5-T3] tests do not introduce a diagnostic channel

Both are assertion-only test functions in existing test files. They add no production code, and the
production-path sweep above covers `scripts`, `.claude`, and the bundled resources tree, none of which
they touch. Their own assertions are on the conflict verdict and the reason list, not on any diagnostic
output, which is consistent with there being none to observe.

## Output Summary

`git add -A` was run at the repository root and the staged, whole-tree anchored diff was audited. The
diff adds **no** new finding rule, **no** severity literal, and **no** warning, advisory, log, console
write, or exception in either runtime. The rejection returns the same no-classification value the four
sibling rejections return, so it is silent by the same mechanism they are. Zero pre-existing fixture
files were modified, so the expected-findings blocks of all 32 top-level fixtures and of the nested
verification-integrity capture are unchanged, and all three added fixtures declare empty findings lists.
