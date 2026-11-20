# Code Review — cycle 4 exit re-audit (Issue #500)

**Authored:** 2026-08-23T04-45 by feature-review.
**Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `8db37795`
**Base:** `main` @ `bee15c06` (merge-base). Review scope is the full branch diff.
**Cycle-4 commits under primary scrutiny:** `71641d9c` (R1-R5 fix), `8db37795` (artifact relocation).

## Summary

The cycle-4 change is small, well-targeted, and does what it claims. The central item — R1, replacing a
membership assertion with a consumption assertion — is a real strengthening, verified by construction
rather than by reading, in both languages. The four stale rule-document pointers are gone and both
copies are byte-identical. AC11's text is now true of the files it names, case by case.

Two defects of the same class the cycle was fixing were introduced by the cycle itself, both in the
header of the file it edited most heavily. Neither affects behaviour; both are stale prose left behind
by a rename and an added read. They are Minor.

**blocking_count: 0.** Recommendation: **Go**.

## R1 — the consumption gate

### What was built

`tests/scripts/dev_tools/blast_radius_parity_test_support.py` replaces the bare key tuples with two
registries mapping each class key to the *name of the test function* that is supposed to consume it:

```python
CLASS_TWO_KEY_ASSERTIONS = {
    "shared_surfaces": "test_class_two_bundled_shared_surfaces_are_the_portable_set",
    "shared_surface_globs": "test_class_two_bundled_shared_surface_globs_are_empty",
}
CLASS_THREE_KEY_ASSERTIONS = {
    "modules": "test_class_three_bundled_modules_are_payload_modules_only",
}
CLASS_TWO_KEYS = tuple(CLASS_TWO_KEY_ASSERTIONS)
CLASS_THREE_KEYS = tuple(CLASS_THREE_KEY_ASSERTIONS)
```

Deriving the tuples from the registries is the load-bearing move: it makes the registry the only way to
add a class key, so the consumption check cannot be bypassed by editing a tuple. `DECLARED_TOP_LEVEL_KEYS`
is in turn derived from the three classes, so the pre-existing exhaustiveness gate is unaffected by the
introduction — a genuinely additive change, as the docstring claims.

The checker itself is a pure helper with no I/O beyond `inspect.getsource`:

```python
for key, assertion_name in registry.items():
    candidate = namespace.get(assertion_name)
    if not callable(candidate):
        unresolved.append((key, assertion_name)); continue
    if key not in inspect.getsource(candidate):
        unresolved.append((key, assertion_name))
```

It reports *all* unresolved pairs rather than the first, and returns them rather than asserting, keeping
the support module's stated "no assertion lives here" contract intact. Both design choices are correct.

### Independent verification — I do not accept the orchestrator's reproduction

I reproduced the residual my own way rather than rerunning the executor's steps. Recorded hashes of all
six candidate files were taken to `/tmp/rev500/pre-hashes.txt`, *outside the repository*, before
touching anything.

Perturbation: `"invented_key": []` added to **both** committed configs, and `"invented_key"` registered
against `test_class_two_bundled_shared_surfaces_are_the_portable_set` — a real, existing assertion that
does not read the key. This is the harder variant: registering against a nonexistent name would be
caught by the `callable` check alone, so I chose the case that exercises the source-text check. Mirrored
on the PowerShell side against `BlastRadius.TruthTable.Tests.ps1`.

Result, against a baseline re-verified immediately beforehand at 17 passed / 384 passed:

- Python: **1 failed, 16 passed**. `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion`
  with `AssertionError: … unresolved pairs (('invented_key', 'test_class_two_bundled_shared_surfaces_are_the_portable_set'),).`
- Pester: **383 passed, 1 failed**. `requires every Class 2 and Class 3 key to be indexed by name in its
  registered consumer file` with `Expected $null or empty, but got 'invented_key -> BlastRadius.TruthTable.Tests.ps1'.`

Two details worth stating because they are the actual proof:

1. The **exhaustiveness gate passed**. `test_every_top_level_key_is_classified_and_shared_by_both_copies`
   did not fire, because the perturbed key *is* classified and *is* present in both copies. That is
   precisely the silent-pass path CR-3 named, and only the new consumption gate caught it. Had the
   exhaustiveness gate fired instead, the new gate would have been redundant and I could not have
   concluded anything about it.
2. Only **one** test failed in each language. A perturbation that breaks many gates proves little about
   the specific one under review; a perturbation that breaks exactly the one under review proves a lot.

**I agree that R1 is closed.** The verdict is mine, from my own construction.

### The residual, and why it is not a defect

I then probed the boundary. On top of the above, I added a comment
`# invented_key is mentioned here but never read.` inside the registered Python assertion, and a comment
containing `$config['invented_key']` to `BlastRadius.TruthTable.Tests.ps1`. Result: Python **17 passed**,
Pester **384 passed** — with `"invented_key": []` sitting in both committed configs and read by nothing.

So the check is a *textual mention* check, not a real-read check. This matters for how much the gate
should be trusted, and it is worth being precise about the size of the remaining hole:

- Before cycle 4, closing the gap required appending a string to a tuple. That is a one-token edit a
  careless maintainer makes without noticing.
- After cycle 4, it requires writing the key's exact name inside the body of an existing assertion (or
  its `['key']` indexer anywhere in the consumer file). That is not something one does by accident while
  adding a config key.

The gate therefore converts an accident into a deliberate act, which is what a gate of this kind can
reasonably achieve. A stronger form — parsing the assertion's AST for a subscript or literal in an
executed expression — would buy little and cost real complexity in a test-support module already
constrained by the file-size limit. **Accepted residual, recorded as I1, not a finding against the
change.**

### Asymmetry between the two mirrors (I2)

The Python check is function-scoped: it resolves the registered name to a callable and searches *that
function's* source. The PowerShell check is file-scoped: it maps the key to a file name and searches the
whole file for `['key']`. The PowerShell form is strictly the weaker of the two — a key whose indexer
literal appears anywhere in `BlastRadius.TruthTable.Tests.ps1`, including its comment header, resolves.

This is a reasonable engineering choice rather than a defect: PowerShell has no `inspect.getsource`
equivalent for a Pester `It` body, and the file-scoped form still closes the practical gap (a brand-new
key's indexer will not already be in the file). I verified the three registered literals resolve to real
assertions and not to comments: `['shared_surfaces']` at lines 171, 180, 209, 227, 259;
`['shared_surface_globs']` at 172, 193; `['modules']` at 72, 85, 112, 137, 147, 280. Worth noting in the
registry comment that the PowerShell binding is file-scoped, so a later reader does not assume parity of
strength.

### Restore integrity

All six perturbed files restored and verified against the externally recorded hashes:
`sha256sum -c /tmp/rev500/pre-hashes.txt` → six `OK`, exit 0; `git status --porcelain` empty; parity
module back to 17 passed. The hash file was written before the first perturbation and lives outside the
repository, so the verification is not circular.

One incidental cross-check fell out of this: the executor's own recorded pre-perturbation hash for
`blast_radius_parity_test_support.py`
(`888CEB51002E9C501E7FC6122028349D7FE629C8E3F501F966E40BF2730FEE12`, in
`evidence/other/r1-pre-perturbation-hashes.2026-08-23T02-59.md`) is byte-identical to the hash I
measured at `HEAD`. That independently corroborates R5's claim that the executor's manual restore was
genuine and complete for that file. The recorded `BlastRadius.KeyPartition.Tests.ps1` hash differs from
`HEAD`, which is expected and correct: R4 and R5 edited that file in later phases, after the P1-T9
restore point.

## R2/R3 — the stale pointers and rule-document parity

Verified directly, not from evidence:

- `grep -rn "BlastRadius.TruthTable.Tests.ps1"` across both copies of
  `.claude/rules/parallel-orchestration.md` → **exit 1, no hits.**
- `grep -rn "BlastRadius.KeyPartition.Tests.ps1"` → exactly **four** hits, two per copy, at lines 310 and
  319 of each.
- `cmp` on the two copies → **exit 0**. `sha256sum` on both →
  `cd5d1a971f838f71cb429ee4a170581bd9bf8cd9ed2142d3f00b92a49219f8e4`, identical.

Both edits landed in the same commit (`71641d9c`), as required. The rule document is amended, not
weakened: the two paragraphs now name the file that actually carries the case, and nothing else in the
Blast-Radius Contention Doctrine section changed.

I also swept the repository for pointers that cycle 4's own edits could have invalidated. Outside this
feature's own historical cycle artifacts, the only live references to `BlastRadius.TruthTable.Tests.ps1`
are the three self-referential comments inside `BlastRadius.KeyPartition.Tests.ps1` (lines 6, 24, 33).
Two of the three are correct. The third is finding M1 below. References in older feature folders (452,
472, 489) are records of past states, not pointers into current reality, and are correctly left alone.

## Cycle 4's own output — same-class defects

The brief asked specifically whether cycle 4 did something analogous to cycle 3's fix-a-size-problem,
create-a-pointer-problem. It did, twice, in the header of the file it edited most.

### M1 (Minor) — a rename without its in-file reference

`tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1:22-24`:

```
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root. Mirrors the file-level BeforeAll of
    # BlastRadius.TruthTable.Tests.ps1, whose Describe this file received.
```

R5 renamed this file's `Describe` from `'Committed blast-radius truth table shape'` to
`'Committed blast-radius truth table cross-copy key partition'` in the same commit. The file no longer
"received" TruthTable's `Describe`; it has its own. The clause is false as of `71641d9c`.

This is structurally identical to R2/R3: a rename lands, an in-file reference to the pre-rename
arrangement does not get updated. The commit rewrote the `.DESCRIPTION` block six lines above and the
`Describe` line 29 lines below, and passed over the line between them. The first sentence of the comment
(the four-levels-up path resolution) is still accurate and worth keeping; only the trailing clause needs
to go. Suggested replacement: "…repo root. Resolves `RepoRoot` and `ConfigPath` the same way
`BlastRadius.TruthTable.Tests.ps1` does, since the split left each file to resolve its own."

### M2 (Minor) — an added read without its inventory update

`BlastRadius.KeyPartition.Tests.ps1:16-18` still closes the `.DESCRIPTION` with:

> The tests read the two committed configurations read-only, invoke no external process, and create no
> temporary files.

The fifth case added by cycle 4 reads a third file, and it is not a committed configuration:

```powershell
$fileText[$fileName] = Get-Content -Raw -Path (Join-Path $PSScriptRoot $fileName)
```

That is `BlastRadius.TruthTable.Tests.ps1`, a test source file, at line 249. The commit extended the
sentence immediately preceding this one to announce the fifth case — "A fifth case, closing the CR-3
key-consumption residual, was added in cycle 4." — and left the read inventory that follows it
unchanged. The claim is now incomplete.

This matters slightly more than a cosmetic comment error, because the read inventory is the file's own
statement of its I/O boundary under `.claude/rules/general-unit-test.md`. A reader auditing test I/O
would trust it and miss the consumer-file read. Suggested fix: "…read the two committed configurations
and, for the key-consumption case, the sibling test file named by the registries, all read-only; they
invoke no external process and create no temporary files."

Both M1 and M2 are prose-only, in the same block, and fixable in one edit.

## Test quality

### Falsifiability of the assertions, checked by construction

The brief asked whether every checked criterion's stated verification can actually fail with respect to
the property it asserts. I perturbed the bundled config in two independent ways and recorded which gates
respond.

Perturbation C (drop `poetry.lock` from bundled `shared_surfaces`; drop `.agents/skills/**` from bundled
`mandate_reads`; reinstate `"claude-runtime": [".claude/**"]` in bundled `modules`):

| Language | Result | Gates that fired |
|---|---|---|
| Python | 6 failed, 11 passed | fail-closed regression (`test_unrelated_claude_citations_do_not_contend_under_the_bundled_table`), Class 1 `[mandate_reads]`, Class 2 portable set, directional invariant, Class 3 payload subset, umbrella denylist `[bundled]` |
| Pester | 4 failed, 380 passed | Class 1 equality (KeyPartition), directional invariant (KeyPartition), umbrella denylist (TruthTable), Class 3 payload subset (TruthTable) |

Perturbation D (drop `package-lock.json` from bundled `shared_surfaces`): 3 failed, including
`test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` — the fail-open
regression test.

The most informative single result is the first row: reinstating `claude-runtime` in the bundled module
map immediately breaks the fail-closed regression test. That test is the one that encodes the actual bug
this whole feature exists to fix, and it fails against the exact defect state. That is the strongest
form of evidence available for a regression test, and it is now established independently of the
executor's fail-before artifacts.

### The one new floor the branch adds is sound

The branch adds a single new `-BeGreaterThan 0` non-vacuity line, in the new separator-free-bundled case:

```powershell
$separatorFree = @(
    $script:BundledConfig['shared_surfaces'] | Where-Object { -not $_.Contains('/') }
)
…
$separatorFree.Count | Should -BeGreaterThan 0
```

This is correct, and the distinction is subtle enough to state explicitly. `@($null).Count` is `1` in
PowerShell, so `@($config['absent']).Count | Should -BeGreaterThan 0` cannot fail. But
`@($null | Where-Object {…})` yields a genuinely **empty** array, so this form *can* fail on an absent or
null key. The pipeline through `Where-Object` is what makes it sound. Verified in pwsh:
`@($h['nope']).Count` → 1, `@($null).Count` → 1, `@(@()).Count` → 0.

### A pre-existing instance of the cannot-fail idiom, out of scope (I3)

`BlastRadius.TruthTable.Tests.ps1` lines 72, 171, and 172 still use the unsound form:

```powershell
@($script:CommittedConfig['shared_surfaces']).Count | Should -BeGreaterThan 0
@($script:CommittedConfig['shared_surface_globs']).Count | Should -BeGreaterThan 0
```

These cannot fail for an absent key or a null value. They are **pre-existing**: at merge-base `bee15c06`
they are lines 72, 139, and 140 of the same file, and this branch does not modify them. They are also
**compensated** — cycle 3's four-state floor at `BlastRadius.KeyPartition.Tests.ps1:167` covers exactly
the four (copy, key) combinations these lines were meant to guard, correctly rejecting absent, null, and
empty, and its comment documents the `@($null).Count == 1` trap in detail. So the effect is a redundant
weaker duplicate of a correct floor, not an unguarded property.

Out of scope for this branch. Worth a separate cleanup issue: delete the three redundant lines so the
unsound idiom stops appearing in a file a future contributor will copy from. Noting also that cycle 3
repaired this idiom in one file and left it in its sibling — the same fix-here-not-there pattern as M1.

### No assertion weakened, removed, or narrowed

I compared the branch's test diffs against their base versions. Every change is an addition or a
behaviour-change update traceable to an acceptance criterion:

- `blast-radius-derive-core.test.ts`: the positive `claude-runtime` pin is gone (correct — the module no
  longer exists), and it is **replaced** by a stronger negative assertion, `expect(names).not.toContain("claude-runtime")`
  plus a `FORBIDDEN_GLOBS` loop, at line 466. The comment explains why the negative form is not redundant
  with the positive pin: "the pin would still pass if a maintainer edited both the constant and the pin
  together." That reasoning is right, and it is the same reasoning R1 applies to the class keys.
- `claude-config-carriage.test.ts`: `poetry.lock` and `package-lock.json` removed from an AC8
  forbidden-substring list, with a rationale comment distinguishing ecosystem-standard root filenames
  from this repository's directory layout. A deliberate scope correction, not a weakening.
- `config-carriage.test-helpers.ts`: `SOURCE_BLAST_RADIUS` updated to mirror the corrected bundled file
  exactly — the 6-entry portable set, empty `shared_surface_globs`, all ten `mandate_reads` entries.
  Fixture fidelity to its source, which is what the earlier CR-4 finding asked for.
- Option B of R1 (removing the three membership assertions) was **not** taken, and the three
  `assert "…" in CLASS_TWO_KEYS` lines remain. Correct: they are now cheap redundancy on top of a real
  gate, and removing them would have been a net loss of clarity for no gain.

## Production code

One production file changed on the whole branch:
`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`, 468 lines, 21 insertions
and 5 deletions. The change removes `"claude-runtime": [".claude/**"]` from `PAYLOAD_MODULES` and adds an
`@remarks` block explaining why.

The doc comment is good. It states the criterion ("a level that always fires carries no contention
information and only suppresses concurrency"), states what is *not* weakened by the removal (path-level
and shared-surface-level contention both survive), and states why `config` is retained — including the
non-obvious second reason, that retaining it keeps the assembled map non-empty so
`assertNoForbiddenGlob` has a non-vacuous input. That last sentence is the kind of thing that gets lost
and then re-litigated; recording it in the code was the right call.

Coverage on this file is 468/468 lines and 46/48 branches (95.83%). No regression is possible at 100%
line coverage.

## Evidence artifacts

Well organised and specific. Three observations:

- `evidence/qa-gates/p5-t12-scope-verification.2026-08-23T02-59.md` is a model of how to record a gate
  that cannot pass: it states the literal output, names the offending commit, gives the substitute
  measurement, states the root cause, and states the disposition. Adjudicated in the policy audit.
- **M3**: the Python coverage artifacts label 90.61% as "Statement coverage (TOTAL row): (14939 - 1105) /
  14939 = 90.61%". That expression evaluates to 92.60%. 90.61% is `percent_covered`, the combined
  statement-and-branch figure. Both numbers clear their thresholds, so nothing is at risk, but the
  arithmetic as written does not produce the number it claims to.
- **M5**: the PowerShell line-coverage figure (96.47%, denominator 5969) did not reproduce under my run
  of the repository's local PoshQC entrypoint (96.18%, denominator 6622), despite an identical test result
  of 3362 passed / 9 skipped over the same 79 source files. Cycles 1-3 recorded a third denominator. The
  threshold verdict is unaffected. Detail in the policy audit.

The artifact relocation in `8db37795` is clean: all three citations in
`remediation-inputs.2026-08-22T17-20.md` now resolve, the duplicate root copy was hash-compared before
removal, and the feature-folder root is back to `issue.md`, `spec.md`, the plan, `evidence/`,
`research/`, and the per-cycle folders. The `<timestamp>-audit/` / `<timestamp>-remediation/` convention
is followed.

## Findings summary

| ID | Severity | Location | Summary |
|---|---|---|---|
| M1 | Minor | `BlastRadius.KeyPartition.Tests.ps1:22-24` | Comment claims the file received TruthTable's `Describe`; R5 renamed it in the same commit |
| M2 | Minor | `BlastRadius.KeyPartition.Tests.ps1:16-18` | Read inventory omits the consumer-file read added by the new fifth case |
| M3 | Minor | `evidence/qa-gates/final-python-pytest-coverage…`, `coverage-delta-verification…` | 90.61% mislabelled as statement coverage; the stated arithmetic yields 92.60% |
| M4 | Minor | `test_blast_radius_config_parity.py:358`; `remediation-plan…:500-501` | Unauthorized `# noqa: E501`; P5-T2 checked against a half-unsatisfied condition |
| M5 | Minor | PowerShell coverage evidence | Recorded 96.47% not reproducible; denominator unstable across sessions |
| I1 | Info | `blast_radius_parity_test_support.py:unconsumed_class_keys` | Consumption check is a textual mention, not a real read — accepted residual |
| I2 | Info | `BlastRadius.KeyPartition.Tests.ps1:235-262` | PowerShell mirror is file-scoped where Python is function-scoped |
| I3 | Info | `BlastRadius.TruthTable.Tests.ps1:72,171,172` | Pre-existing cannot-fail idiom; compensated; recommend separate cleanup issue |
| I4 | Info | `test_blast_radius_config_parity.py` | At 499 of 500 lines; next addition forces a split |
| I5 | Info | `test_the_gate_compares_non_empty_collections` | Floor guards the full list, not the separator-free subset the invariant compares |

**blocking_count: 0. Major: 0. Minor: 5. Info: 5 (plus I6-I10 in the policy audit).**

## Recommendation

**Go.** The change is correct, the central claim is verified by construction rather than assertion, and
nothing found here justifies a fifth cycle. M1 and M2 are two lines of prose in one comment block; they
should be corrected, but they are exactly the kind of item that is cheaper to fold into the next commit
that touches the file than to spend a remediation cycle on. M3, M4, and M5 are evidence-quality and
suppression-policy items, all recorded here, none affecting the code.

If any of M1-M5 is to be fixed before merge, M1 and M2 are the two worth doing, they are the same edit,
and they need no verification beyond re-running the Pester directory (384 passed).
