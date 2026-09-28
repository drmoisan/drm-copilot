# Research — ConflictResult truthiness is unconditionally True (Issue #576)

- **Issue:** #576
- **Work Mode:** full-bug
- **Branch:** `bug/conflictresult-truthiness-always-true-576`
- **Timestamp:** 2026-08-28T10-05
- **Author:** task-researcher

## Research Method and Its Limits

Every claim below is grounded in a file read or a content search performed in this session, and each
carries a file-and-line citation. Two limits apply and are stated here rather than buried:

1. **No shell was available in this session.** The agent's tool set was Read, Grep, Glob, Write, and
   Edit only; there was no Bash or PowerShell execution tool. No command in this document was
   executed. Question 9's instruction to "verify the dotted `--cov` form actually collects data by
   running it once" could NOT be carried out. Section 9 records what the repository's configuration
   files establish about the command and marks the runtime verification as **outstanding, to be
   performed at plan-execution time**.
2. **File hashing was therefore also unavailable.** Section 5's byte-parity question is answered from
   structural evidence plus the identity of the enforcing test, and the residual uncertainty is
   stated explicitly.

One external source was consulted: the Microsoft PowerShell `about_Booleans` reference, cited in
section 4.

---

## 1. Exact Defect Confirmation

### 1.1 `ConflictResult` defines neither `__bool__` nor `__len__`

`ConflictResult` is declared at `scripts/dev_tools/_blast_radius_conflicts.py:94-134`:

- `scripts/dev_tools/_blast_radius_conflicts.py:94` — `@dataclass(frozen=True)`
- `scripts/dev_tools/_blast_radius_conflicts.py:95` — `class ConflictResult:`
- `scripts/dev_tools/_blast_radius_conflicts.py:111-112` — the two fields, `conflict: bool` and
  `reasons: tuple[ConflictReason, ...]`
- `scripts/dev_tools/_blast_radius_conflicts.py:114-134` — `__post_init__`, the class's **only**
  method

The class body spans lines 94 through 134 and ends where `def conflicts(` begins at line 137. The
only `def` inside that span is `__post_init__` at line 114. There is no `__bool__` and no `__len__`.

The same holds for `ConflictReason` at `scripts/dev_tools/_blast_radius_conflicts.py:61-91`: its only
method is `__post_init__` at line 80.

### 1.2 `@dataclass(frozen=True)` supplies neither

The decorator on line 94 is `@dataclass(frozen=True)` with no other arguments. The `dataclasses`
machinery generates `__init__`, `__repr__`, and `__eq__` by default, and `__hash__` plus the
`__setattr__`/`__delattr__` blockers under `frozen=True`. It generates **no** `__bool__` and **no**
`__len__`, and there is no `dataclass` keyword that would request either. This is a property of the
standard library, not of this repository's configuration; nothing in `pyproject.toml` alters it.

### 1.3 Consequence

With neither dunder defined, `bool(instance)` falls through to `object.__bool__`, which returns
`True` for every non-`None` instance. Therefore:

```python
result = conflicts(a, b, config)   # -> ConflictResult
bool(result)                        # -> True, always
if result: ...                      # -> branch always taken
```

This is independent of the verdict the object actually carries. The relation itself is correct:
`scripts/dev_tools/_blast_radius_conflicts.py:177` returns
`ConflictResult(conflict=bool(reasons), reasons=tuple(reasons))`, and
`scripts/dev_tools/_blast_radius_conflicts.py:124-125` enforces at construction that `conflict`
equals `bool(reasons)`. The verdict field is always right; only its boolean *projection* is wrong.

### 1.4 The re-export carries the defect unchanged

`scripts/dev_tools/compute_blast_radius.py:35-39` imports `ConflictReason`, `ConflictResult`, and
`conflicts` from the private module, and `scripts/dev_tools/compute_blast_radius.py:64-75` lists all
three in `__all__` (lines 66, 67, 69). The re-export binds the same class object, so a fix applied in
`_blast_radius_conflicts.py` propagates to the facade with **no edit to the facade required**. The
facade is therefore not in the fix's write set (see section 10).

---

## 2. Design-Choice Analysis and Recommendation

### 2.1 The two candidate remedies

The issue (`docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/issue.md:33`)
offers two mutually exclusive remedies:

- **(a) Agreeing `__bool__`** — define `__bool__(self) -> bool: return self.conflict`, so
  `bool(result)` equals the verdict.
- **(b) Refusing `__bool__`** — define `__bool__` to raise (for example `TypeError`), so a caller in
  a boolean context gets a loud error and is forced to read `result.conflict`.

### 2.2 What the repository's stated policy actually requires

Three policy sources bear on the choice.

**`.claude/rules/general-code-change.md`, "Error Handling and Logging":** the rule is *"Fail fast and
explicitly: raise or return clear, specific errors when invariants are violated."* The operative
scope is **invariant violation**. Asking a `ConflictResult` whether it represents a conflict violates
no invariant: the object holds a total, unambiguous, already-validated answer in `self.conflict`
(validated at `scripts/dev_tools/_blast_radius_conflicts.py:124-125`). Remedy (b) would convert a
well-defined query into an error. That is not what the rule directs, and reading the rule as a
general licence to raise on any ambiguous-looking call form over-extends it.

**The module's own fail-closed doctrine, `scripts/dev_tools/_blast_radius_conflicts.py:17-23`:**
*"The relation fails closed: a glob pair that cannot be proven disjoint counts as overlapping,
because radius under-reporting is the dominant risk of the parallel design."* Under remedy (a) the
natural call form `if conflicts(a, b, config):` yields exactly the fail-closed verdict, including
`True` for the undecidable glob pairs the doctrine exists to protect. Remedy (a) makes the inviting
call form *correct*; it does not merely make it *loud*.

**`.claude/rules/parallel-orchestration.md`, "Blast-Radius Contention Doctrine":** the doctrine's
governing concern throughout is that a *wrong edge* — in either direction — is the failure mode. The
issue's own impact statement
(`docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/issue.md:51`) records
that miscomputed edges *"do not corrupt state ... but they silently destroy concurrency."* The harm
is availability and throughput, not correctness of persisted state.

### 2.3 The fail-closed argument, stated symmetrically

The delegation prompt frames this as "under (a), a caller who forgets to check gets a *correct*
answer; under (b), a silent-wrong-answer becomes a loud error." Both halves are true, and **both
outcomes are safe with respect to state**. Neither remedy can produce a wrong conflict edge:

- Under (a), the boolean form returns the verdict, so the edge is right.
- Under (b), the boolean form raises, so no edge is produced at all.

The fail-closed doctrine therefore does not discriminate between them on the safety axis. It
discriminates on a different axis: (a) *satisfies* the doctrine at the call site, whereas (b)
*defers* it to a crash and an operator. Since a scheduler that raises mid-admission halts a parallel
run, remedy (b) converts a Medium-severity throughput defect into an availability defect. That is a
worse trade for a bug the issue itself classifies as non-corrupting.

### 2.4 Four differentiators, in decreasing order of weight

**D1 — Cross-runtime parity, which is the repository-specific and decisive point.** The issue
requires the choice to be mirrored in the PowerShell port
(`.../issue.md:33`). Section 4 establishes that PowerShell can express *neither* remedy as coercion
behaviour. The two remedies therefore leave different residual divergences:

| Remedy | Python `if result:` | PowerShell `if ($result)` | Nature of divergence |
| --- | --- | --- | --- |
| (a) agreeing `__bool__` | correct verdict | always `$true` | difference of **strictness** — Python is right, PowerShell is permissive |
| (b) raising `__bool__` | raises | always `$true` | difference of **kind** — identical caller code raises in one runtime and silently returns the wrong answer in the other |

Under (b), the runtime that silently returns the wrong answer is precisely the one the planner
actually runs. `.claude/agents/parallel-planner.md:147-156` routes radius derivation, validation, and
the contention relation through `.claude/lib/blast-radius/BlastRadius.psm1`, explicitly so the
planner needs "no Python interpreter and no repository checkout"
(`.claude/agents/parallel-planner.md:142-145`). Remedy (b) would hard-fail the runtime that is *not*
on the incident path while leaving the runtime that *is* on the incident path unchanged.

**D2 — A raising `__bool__` is a well-established footgun with a broad blast radius of its own.** It
does not only break `if result:`. It also breaks `assert result`, `result or default`,
`x if result else y`, `any(...)`/`all(...)` over results, `filter(None, ...)`, and truthiness inside
comprehensions — including in third-party code, debuggers, and REPL display paths that the
repository does not control. The inventory in section 3 shows none of these forms exists in-repo
*today*, so (b) has no immediate migration cost; but it installs a permanent trap that fires the
first time any future caller writes an ordinary Python idiom.

**D3 — Zero migration cost for (a), verified.** Section 3 establishes that no in-repo caller relies
on unconditional truthiness. Remedy (a) is therefore **behaviour-preserving for every existing
caller** — the sole production caller
(`scripts/dev_tools/parallel_drift_detection.py:499`) reads `.conflict` and is unaffected, and every
test caller reads `.conflict` or `.reasons`.

**D4 — Discoverability.** The result type's docstring
(`scripts/dev_tools/_blast_radius_conflicts.py:96-109`) already instructs the reader that *"A
scheduler reads `conflict` to decide cohort membership"* (lines 100-101). That instruction was
present and was not enough to prevent the #559 incident, because the incident occurred on the
PowerShell/agent path where no Python docstring is read. Neither remedy improves discoverability on
that path; only documentation and a pinned test do (section 4.4).

### 2.5 Recommendation

**Adopt remedy (a): define `__bool__` on `ConflictResult` returning `self.conflict`.**

Add it to `scripts/dev_tools/_blast_radius_conflicts.py` inside the `ConflictResult` body, after
`__post_init__` (which ends at line 134). Suggested shape, matching the module's existing docstring
convention:

```python
def __bool__(self) -> bool:
    """Report the verdict, so a boolean context agrees with ``conflict``.

    Without this method Python's default object truthiness makes every result
    truthy, and the inviting call form ``if conflicts(a, b, config):`` reads
    every item pair as contending (issue #576).

    Returns:
        bool: ``self.conflict``.
    """
    return self.conflict
```

**Do NOT also define `__len__`.** `__bool__` takes precedence over `__len__`, so defining both is
redundant; and a `__len__` would additionally make `ConflictResult` look sized and iterable-adjacent,
which it is not.

**Critical scoping caveat the spec author must not lose:** remedy (a) is **defence in depth, not the
fix for the observed incident**. The #559 incident occurred on the PowerShell/agent path (section 4,
section 6), where the Python `__bool__` is never evaluated. A Python-only change closes the class of
defect for future Python callers and closes nothing on the path where the incident actually happened.
The spec must pair remedy (a) with the PowerShell documentation-and-test remedy of section 4.4 and
the skill-prose correction of section 4.5, or it will ship a fix that does not touch the incident
surface.

### 2.6 Consequence for each existing caller under remedy (a)

| Call site | Current form | Consequence under (a) |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py:499` | `conflicts(...).conflict` | None. Unchanged behaviour; no edit required. |
| `tests/scripts/dev_tools/test_blast_radius_invariants.py:132-133,141,150,176-177,207-208` | `.conflict` / `.reasons` | None. |
| `tests/scripts/dev_tools/test_blast_radius_conflicts.py:83-243` | `.conflict` / `.reasons` | None. |
| `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py:149,167,225,249` | `.conflict` inside comprehension conditions | None. |
| `tests/scripts/dev_tools/test_blast_radius_config.py:368,414,429,449` | helper accessors over `.reasons` | None. |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py:136,164` | helper accessors over `.reasons` | None. |
| `tests/scripts/dev_tools/test_blast_radius_parity.py:432,461` | `.conflict` / `.reasons` | None. |
| `tests/scripts/dev_tools/test_blast_radius_normalization.py:339,355` | compared verdicts | None. |
| `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py:43-47` | constructs `ConflictResult` literals as test doubles | None. Construction is unaffected. |

Aggregate: **zero caller edits required**. Under remedy (b) the aggregate would also be zero today,
which is why the caller inventory does not by itself decide the question; D1, D2, and D4 do.

### 2.7 Does `ConflictReason` need the same treatment?

**No, and adding `__bool__` to it would be an error.** `ConflictReason`
(`scripts/dev_tools/_blast_radius_conflicts.py:61-91`) carries no verdict. Its own docstring is
explicit: *"The record holds no verdict of its own; `ConflictResult` carries that"*
(`scripts/dev_tools/_blast_radius_conflicts.py:66-68`). Both its fields, `kind` and `detail`
(lines 77-78), are non-empty by construction — `kind` must be in `CONFLICT_KINDS` (line 89-90) and
`detail` passes `require_text` (line 91) — so there is no state a boolean could distinguish. Any
`__bool__` would either be a constant `True` (no information) or invent a meaning the type does not
have. `bool(reason)` is also not an inviting-but-wrong call form the way `bool(result)` is, because a
reason answers no yes/no question.

One dependency to preserve: `scripts/dev_tools/_blast_radius_conflicts.py:124` evaluates
`bool(self.reasons)` — the truthiness of the **tuple**, not of any `ConflictReason`. Adding
`__bool__` to `ConflictReason` would not change that expression's meaning, but leaving
`ConflictReason` alone keeps the reasoning trivially local.

**Adjacent, out of scope, worth recording:** `BlastRadius`
(`scripts/dev_tools/compute_blast_radius.py:101-218`) is also a `@dataclass(frozen=True)` with no
`__bool__` or `__len__`, so `bool(radius)` is likewise unconditionally `True`. Unlike
`ConflictReason`, an "empty radius" *does* have a meaning the relation acts on — two empty radii do
not conflict (`scripts/dev_tools/_blast_radius_conflicts.py:151-152`). This is a latent instance of
the same API-design class. It is **not** part of issue #576 and adding it would widen the blast
radius to the facade module. Recommend filing it as a separate potential entry rather than folding it
in.

### 2.8 Rejected alternative

**Remedy (b), a raising `__bool__`,** is rejected on D1 (it creates a divergence of *kind* rather than
of *strictness* between the two runtimes, and hard-fails the runtime that is not on the incident
path) and D2 (it installs a permanent trap for ordinary Python idioms, including idioms in code this
repository does not control). Its one genuine advantage — that a future careless caller is told
loudly rather than served quietly — is worth less than those costs given that under remedy (a) the
careless caller is served *correctly*.

---

## 3. Caller Inventory

### 3.1 Search method

Establishing an empty result requires stating how it was established. Three content searches were run
across the whole repository with no path filter, so Python, PowerShell, TypeScript, bash, hook
scripts, Markdown, and JSON were all in scope:

1. Pattern `conflicts\s*\(|ConflictResult|ConflictReason` — 200 matches, all reviewed.
2. Pattern `Test-BlastRadiusConflict|conflictResult|conflict_result` — all matches reviewed.
3. Pattern `if \(Test-BlastRadiusConflict|if conflicts\(|if \(\$.*conflict\)|while conflicts|not conflicts`
   — targeted at the boolean-context forms specifically.

Search 3 returned **nine** matches. Four are the issue and spec documents restating the defect
(`.../issue.md:16,28`, `.../spec.md:11,31`), one is the promoted lifecycle record
(`docs/features/potential/promoted/2026-08-28-conflictresult-truthiness-always-true.md:14,26`), and
three are genuine call sites that read the explicit field
(`tests/scripts/dev_tools/test_blast_radius_verification_integrity.py:149,167,225`). **None is a
boolean-context use of the result object.**

### 3.2 Production call sites of `conflicts(...)`

There is exactly **one** production caller in the repository:

| # | File and line | Form | Classification |
| --- | --- | --- | --- |
| 1 | `scripts/dev_tools/parallel_drift_detection.py:499` | `return conflicts(observed_radius, peer, config).conflict` | **(i) already correct** — reads `.conflict` |

The enclosing function `_observed_contends`
(`scripts/dev_tools/parallel_drift_detection.py:473-499`) is annotated `-> bool` and its docstring
(lines 485-488) documents the fail-closed `True` return for an unevaluable peer. The `.conflict`
access is on line 499.

Two further production modules reference the relation **only in prose** and never call it:

- `scripts/dev_tools/parallel_cohort_computation.py:29` — module docstring naming `conflicts(a, b)`
  as the upstream producer of the edges it consumes. It accepts pre-normalized
  `conflict_edges` (lines 218, 232, 257, 352, 374, 398) and never invokes the relation.
  **Classification (iii) not applicable.**
- `scripts/dev_tools/parallel_mutation_protocol.py:35,151` — docstring references. Line 151 states
  verbatim that the function *"never calls it."* **Classification (iii) not applicable.**

### 3.3 Test call sites of `conflicts(...)`

All are classification **(i) already correct**; each reads `.conflict`, `.reasons`, or compares whole
results. Enumerated for completeness:

- `tests/scripts/dev_tools/test_blast_radius_conflicts.py:83,93,104,115,126,137,147,158,169,182,195,204,216,229,243`
- `tests/scripts/dev_tools/test_blast_radius_invariants.py:132,133,141,150,176,177,207,208`
- `tests/scripts/dev_tools/test_blast_radius_config.py:368,414,429,449`
- `tests/scripts/dev_tools/test_blast_radius_config_parity.py:136,164`
- `tests/scripts/dev_tools/test_blast_radius_parity.py:432,461`
- `tests/scripts/dev_tools/test_blast_radius_normalization.py:339,355`
- `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py:149,167,225,249`
- `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py:43,47,54,70,111,168,251` —
  constructs `ConflictResult` literals as substitutes; does not evaluate truthiness.

### 3.4 Non-Python surfaces

- **PowerShell.** The only callers of `Test-BlastRadiusConflict` outside the module itself are test
  files, all of which index `['conflict']` or `['reasons']`:
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` (numerous, e.g. lines
  62-66, 75-78, 302-303, 380-381, 395-396),
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:281-285,297-301,341,398`,
  `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1:316`,
  `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1:392,407`,
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1:471` (export-surface assertion only).
  **All classification (i).**
- **TypeScript.** No call site exists; see section 6.
- **bash.** No call site exists. Searching `.claude/lib/bash/` for `conflict` returns only files that
  *consume* an already-computed edge list — `parallel-cohorts.sh:135-150,203`,
  `compute-cohorts.sh:12,41,46`, and `parallel-manifest-validate.sh:13,58,204,209` (the M8
  `expected_conflict_components` assertion). None computes the relation.
  **Classification (iii) not applicable.**
- **Hook scripts.** `.claude/hooks/enforce-parallel-cohort-barrier.ps1` and its helper sibling appear
  in the coverage allow-list (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:219`) but
  do not appear in any search for `Test-BlastRadiusConflict` or `conflicts(`. The barrier hook reads
  the checkpoint's already-computed cohort table, consistent with the design note at
  `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/research/2026-08-07T12-30-parallel-cohort-scheduler-research.md:120`.
  **Classification (iii) not applicable.**

### 3.5 Verdict

**The boolean-form inventory is EMPTY.** No in-repo call site — production, test, hook, or script, in
any language — evaluates the contention relation's result in a boolean context. Established by the
three repository-wide searches in section 3.1, each reviewed match by match.

This has a direct consequence for the spec: **remedy (a) is behaviour-preserving for the entire
repository as it stands today.** The fix is purely preventive of a recurrence of the #559 incident,
which occurred in orchestrator/agent code that is generated at run time and is not committed to the
repository. That is why the durable remedy must include the documentation and pinned-test work of
sections 4.4 and 4.5, not only the Python dunder.

---

## 4. PowerShell Mirror — `Test-BlastRadiusConflict`

### 4.1 What the function returns

`Test-BlastRadiusConflict` is defined at `.claude/lib/blast-radius/BlastRadius.psm1:404-474`.

- **Declared output type:** `[OutputType([hashtable])]` at
  `.claude/lib/blast-radius/BlastRadius.psm1:433`.
- **Documented contract:** the `.OUTPUTS` block at
  `.claude/lib/blast-radius/BlastRadius.psm1:428-430` states *"System.Collections.Hashtable. Keys
  conflict (a boolean) and reasons (an array of hashtables with keys kind and detail)."*
- **Actual return statement,** `.claude/lib/blast-radius/BlastRadius.psm1:470-473`:

```powershell
return @{
    conflict = ($reason.Count -gt 0)
    reasons  = @($reason.ToArray())
}
```

So it returns a **`[hashtable]` with exactly two keys** — not a `PSCustomObject` and not a bare
boolean. The `conflict` value is a genuine `[bool]` computed from the reason count. The frozen
contract is restated in the feature spec at
`docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md:135` as
`@{ conflict = <bool>; reasons = @(@{ kind; detail }) }`, and is pinned by the shape test at
`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:65-66`, which asserts the
sorted key set is exactly `@('conflict', 'reasons')`.

### 4.2 PowerShell's truthiness rules produce the identical defect

Verified against the Microsoft `about_Booleans` reference (PowerShell 7.6). The documented rules are:

**Scalar / non-collection types.** `$false` for empty strings, `$null`, and any numeric zero;
`$true` for *"Non-empty strings"* and *"Instances of any other non-collection type."* The
documentation's own worked example for the `$true` case is a hashtable:

```powershell
# a non-collection type
PS> [bool]@{value = 0}
True
```

**Collection types.** *"These rules apply to any collection-like types that implement the `IList`
interface"* — empty collections are `$false`, single-element collections take the truthiness of their
one element, and multi-element collections are `$true`.

`System.Collections.Hashtable` implements `IDictionary` and `ICollection` but **not `IList`**, so the
collection rules do not apply to it. It falls under *"Instances of any other non-collection type"* and
is therefore `$true`. The returned value is additionally a two-key hashtable, so it would be `$true`
under any reading of the rules.

**Conclusion: the analogous defect exists, and it is exact.**

```powershell
$r = Test-BlastRadiusConflict -RadiusA $a -RadiusB $b -Config $cfg
if ($r) { ... }        # always taken, whatever the verdict
[bool]$r               # always $true
if (-not $r) { ... }   # never taken
```

**On unrolling.** The delegation prompt correctly flags PowerShell's single-element array unrolling
as a thing to check. It does not rescue this case. `Test-BlastRadiusConflict` emits one hashtable, so
`$r` is a `Hashtable`, not an array. Even if the value were pipeline-wrapped as `@($r)`, the
single-element rule evaluates to the truthiness of the one element — which is the hashtable — and
that is `$true`. There is no path by which the PowerShell result is falsy for a disjoint pair.

Note the asymmetry the skill already documents for the *sibling* function:
`.claude/skills/parallel-plan/SKILL.md:189-191` warns that `Test-BlastRadius` writes findings to the
pipeline and must be wrapped in `@(...)` because a zero-element result writes nothing. That warning
exists precisely because `Test-BlastRadius` returns an `IList`-shaped result where emptiness *is*
falsy. `Test-BlastRadiusConflict` returns a hashtable, where emptiness is not expressible. The skill
warns about the first and is silent about the second.

### 4.3 Can PowerShell express either remedy? Precisely, no.

This is the load-bearing part of the answer.

**Remedy (b) — "refuse boolean coercion" — is NOT expressible in PowerShell.** The `about_Booleans`
rules are **total**: the reference opens with *"PowerShell can implicitly treat any type as a
Boolean"* and then enumerates a complete decision procedure over scalars and `IList` collections with
no residual case and no extension point. There is no user hook — no overridable method, no operator,
no attribute — by which a type can decline the conversion or raise from it. A .NET type carrying a
throwing `op_Implicit` to `bool` does not help, because `if`/`[bool]` dispatch through
`LanguagePrimitives.IsTrue`, whose documented behaviour for an arbitrary non-null non-`IList`
instance is to return `$true` without consulting any user-defined conversion. **Refusal is
unrepresentable.**

**Remedy (a) — "agreeing truthiness" — is also NOT expressible while preserving the frozen
contract.** The only lever the documented rules expose is the `IList` branch: a return value that
implements `IList` is falsy when its `Count` is `0`. Exploiting it would require
`Test-BlastRadiusConflict` to return an `IList` whose length encodes the verdict — for example `@()`
for no conflict and a populated array otherwise. That would:

- violate the declared `[OutputType([hashtable])]` at
  `.claude/lib/blast-radius/BlastRadius.psm1:433`;
- violate the `.OUTPUTS` contract at `.claude/lib/blast-radius/BlastRadius.psm1:428-430`;
- break the frozen public contract recorded at
  `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md:135`;
- break the key-set assertion at
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:65`;
- break every `['conflict']` / `['reasons']` indexing caller listed in section 3.4; and
- discard the `reasons` payload that the cohort audit depends on
  (`.claude/rules/parallel-orchestration.md`, invariant 15, requires a `reason` on every conflict
  edge).

That price is not worth paying to make one idiom work. **Neither remedy is mirrorable as coercion
behaviour in PowerShell.**

### 4.4 What parity therefore requires — the closest faithful mirror

Since the *behaviour* cannot be mirrored, parity must be achieved by **recording and pinning the
divergence** rather than by eliminating it. This is exactly the pattern the repository already uses
for its other cross-runtime gap: `.claude/rules/parallel-orchestration.md` enumerates three named
divergence classes for the TypeScript parity port (`pythonRepr` quote selection, integral floats, and
boolean/integer equality) under an explicit "Verified scope ... Three divergence classes are known
outside that verified scope" heading. The precedent is to name the divergence, bound it, and test it —
not to pretend it away.

The closest faithful mirror has three parts:

**M1 — Documented warning in the module.** Extend the `.OUTPUTS` or `.DESCRIPTION` block of
`Test-BlastRadiusConflict` (`.claude/lib/blast-radius/BlastRadius.psm1:405-431`) to state that the
returned hashtable is unconditionally `$true` in a boolean context because PowerShell treats a
hashtable as a non-collection type, that PowerShell cannot narrow this, and that callers **must**
index `['conflict']`. This is the direct analogue of the `@(...)` warning the skill already carries
for `Test-BlastRadius`.

**M2 — A Pester test that pins the language behaviour.** Add to
`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`, in the existing
`Describe 'Test-BlastRadiusConflict result shape'` block (line 54), a case that asserts, for a
provably disjoint pair, that `$result['conflict']` is `$false` **while** `[bool]$result` is `$true`.
This converts an undocumented language surprise into a tested, named property. If a future PowerShell
release ever changed hashtable truthiness, the test would report it rather than silently changing the
planner's behaviour. It is also the artifact a reviewer can cite when asking why the two runtimes
differ.

**M3 — Correct the prose that produced the incident.** See section 4.5. M3 is the part that actually
closes the #559 recurrence path; M1 and M2 make the gap visible and tested.

### 4.5 The prose that produced the incident

`.claude/skills/parallel-add/SKILL.md:59-70`, step 3, instructs the agent to invoke
`Test-BlastRadiusConflict` over item pairs and then says: *"Map each conflicting pair onto an
`(int, int)` conflict edge of `items[].issue_num` values, normalized so `a < b`."* It specifies the
two radius arguments and the config argument in detail (lines 62-65) but **never states how to read
the verdict off the returned hashtable**. An agent following this text must infer "conflicting" from
the returned value, and the natural PowerShell inference — `if ($result)` — is unconditionally
`$true`. This is, on the evidence, the proximate cause of the #559 edge explosion.

`.claude/skills/parallel-plan/SKILL.md:300-305`, the seeding procedure, has the same gap: *"Derive the
conflict edge set by applying `Test-BlastRadiusConflict` to every unordered pair of `declared`
radii"*, with no statement of how the verdict is read. `.claude/skills/parallel-plan/SKILL.md:213-217`
documents the Python contract as `conflicts(a, b, config) -> ConflictResult` and describes the reason
vocabulary, but likewise does not say that the verdict is the `conflict` field.

Both skill files must gain an explicit instruction to read `['conflict']` (PowerShell) / `.conflict`
(Python), with a one-line statement of why the boolean form is wrong. Both have published copies that
must be updated in lockstep (section 5).

---

## 5. Bundled Push-Down Copy

### 5.1 Is the bundled copy identical today?

**Almost certainly yes; verified structurally, not by hash.** No shell was available, so
`Get-FileHash` / `sha256sum` could not be run. Two independent lines of evidence:

**Structural evidence.** A content search for `^function |^\s*return @\{|^Export-ModuleMember|^\$script:`
was run against both files. The two result sets are **identical in every entry and every line
number**, including nineteen anchors spanning the whole file:

| Anchor | Line, both copies |
| --- | --- |
| `$script:FeatureFolderRoot` | 62 |
| `$script:ConflictPathOverlap` | 77 |
| `$script:PairDetailSeparator` | 84 |
| `function Get-FeatureFolderGlob` | 90 |
| `function Get-BlastRadius` | 106 |
| `function Get-NormalizedDeclaredRadius` | 202 |
| `function Get-BlastRadiusFromObservedPaths` | 288 |
| `function Get-SmallestPathOverlap` | 345 |
| `function Get-SmallestCommonEntry` | 379 |
| `function Test-BlastRadiusConflict` | 404 |
| `return @{` (the conflict result) | 470 |
| `Export-ModuleMember -Function` | 476 |

A separate search also placed `Test-BlastRadiusConflict` at lines 18, 36, 404, and 482 in **both**
copies. Line-number agreement at the final export block means no insertion or deletion occurred
anywhere in either file.

**Test evidence.** An enforcing parity test exists and is expected to pass on `main`; see 5.2.

**Residual uncertainty, stated plainly.** Structural anchor agreement does not exclude a
within-line character difference that touches no anchor. A hash comparison at execution time would
settle it. This is the only claim in this document that could not be reduced to a direct observation.

### 5.2 The parity test that enforces it — named exactly

**`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`**
(`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126`).

How it works:

- `SCOPED_ROOTS = (Path(".claude"),)` at
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:20` — the parity scope is the
  entire `.claude` subtree.
- `list_scoped_files` (lines 34-43) enumerates every file under `.claude` at both roots by `rglob`,
  so the test is **discovery-based**: no file needs to be added to a list for it to be covered.
- Lines 113-117 exclude only `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree.
- Lines 123-126 assert `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` with the failure
  message `f"Bundle content differs from repo for: {relative_path}"`.

Because `.claude/lib/blast-radius/BlastRadius.psm1` is under `.claude` and is not excluded, **it is
in scope and its content is asserted equal to the bundled copy.**

**Precision on "byte-identical".** The test compares `read_text(..., encoding="utf-8")`, i.e. Python
text mode, which applies universal-newline translation. It therefore asserts **text equality after
newline normalization**, not raw byte equality. A pure CRLF-versus-LF difference would pass this
test. The module docstring at
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:6-7` nonetheless describes it as
the "byte-identical mirror assertion". For this fix the distinction is immaterial — the edit is
content, not line endings — but the spec should not claim byte-parity enforcement that the assertion
does not literally provide.

### 5.3 The gap in the blast-radius-specific PowerShell test

`tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` has a
`Context 'Bundled payload parity'` block (lines 62-75), but its single `It` — *"ships a bundled
counterpart for every library module"* — asserts only `Test-Path ... -PathType Leaf` (lines 68-70).
**It checks existence, not content.**

This is an asymmetry against the sibling libraries, which *do* hash-compare:

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1:100-101` —
  `Get-FileHash -Algorithm SHA256` on both copies.
- `tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1:82-83` — same.
- `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1:70-71` — same.

The blast-radius library alone lacks the hash comparison. The Python test in 5.2 covers it, so there
is no live exposure, but adding the hash `It` to `BlastRadius.Manifest.Tests.ps1` would restore
symmetry and give the PowerShell suite a self-contained guarantee. **Optional; recorded so the spec
author can choose deliberately.** If adopted it adds one test file to the write set.

### 5.4 Must the fix be applied to both copies?

**Yes, mandatorily, for every file under `.claude` the fix touches.** Concretely, if the fix edits
any of:

- `.claude/lib/blast-radius/BlastRadius.psm1`
- `.claude/skills/parallel-add/SKILL.md`
- `.claude/skills/parallel-plan/SKILL.md`

then the matching path under
`extensions/drm-copilot/resources/claude-customizations/` must receive the identical edit in the same
commit, or the test named in 5.2 fails.

**Operational caveat carried forward.** A prior session recorded that this bundle-parity test can
fail locally on gitignored `.claude` state while passing in CI (repository issue #510). If the test
reports a failure naming a path unrelated to this fix, check whether it is that pre-existing
condition before treating it as a regression introduced here.

**Also note:** a repository-side edit to `extensions/drm-copilot/resources/...` does not change what
an *installed* extension pushes down until the extension is rebuilt and reinstalled. That affects
downstream propagation timing, not the correctness of this fix.

---

## 6. TypeScript Surface — the Issue's Parity Claim Is Out of Scope

The issue asserts the choice *"must be mirrored in the PowerShell port ... and the TypeScript parity
surface so all three runtimes agree"*
(`docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/issue.md:33`, repeated at
`.../spec.md:35`).

**No TypeScript port of the conflict relation exists.** Evidence:

1. A search for `ConflictResult|conflicts\s*\(|function conflicts|export .*[Cc]onflict` across
   `extensions/drm-copilot/src/` returns **exactly one** match:
   `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts:416`,
   `export function validateConflictEdges(`. That function **validates already-computed edge records**
   read from a checkpoint against invariant 15 of `.claude/rules/parallel-orchestration.md`. It does
   not compute the relation, takes no `BlastRadius`, and returns error strings, not a verdict.
2. A case-insensitive search for `conflict` across `extensions/drm-copilot/src/` returns seven files:
   `parallel-state-structures.ts`, `parallel-state-shared.ts`, `parallel-planner-state-core.ts`,
   `parallel-orchestrator-state-core.ts`, `parallel-orchestrator-state-cohort-barrier.ts`,
   `epic-orchestrator-state-core.ts`, and `codex-native-converter/validation.ts`. Every one is a
   **checkpoint validator**, consuming `conflict_edges[]` as data. None derives an edge.
3. `.claude/rules/parallel-orchestration.md` enumerates the TypeScript parity port file by file —
   `parallel-state-shared.ts`, `parallel-state-structures.ts`, `parallel-state-records.ts`,
   `parallel-orchestrator-state-core.ts`, `parallel-planner-state-core.ts` — and scopes it to *"the
   same invariants"* of the **checkpoint validators**. The blast-radius library is not in that list.
4. The rule's own enumeration of published two-language surfaces names Python and PowerShell for the
   blast-radius library; the TypeScript parity work described there concerns
   `assembleModules` in
   `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`, which — as the
   delegation prompt anticipated — derives a **destination module map** from a destination's own
   layout. `.claude/rules/parallel-orchestration.md` states this directly: *"`assembleModules` ...
   computes a destination's module map from the destination's OWN layout ... It never reads the source
   document's `modules` key."* It is not the conflict relation.
5. The original feature spec confirms the two-language intent:
   `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md:137` explains the PowerShell
   mirror exists *"because the Layer 1 enforcement hooks (F7) and the cohort-barrier hook are
   PowerShell."* No TypeScript consumer is named, and
   `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/research/2026-08-07T12-30-parallel-cohort-scheduler-research.md:120`
   records the corresponding reasoning for why only PowerShell got a mirror.

**Finding: the issue's TypeScript parity claim is factually incorrect and is OUT OF SCOPE.** The
contention relation is a two-runtime surface — Python (authoritative) and PowerShell (mirror). The
spec should record this explicitly and strike the TypeScript obligation from the acceptance criteria,
so a later reviewer does not read its absence as an omission. No `extensions/drm-copilot/src/` file
belongs in this fix's blast radius.

---

## 7. Existing Test Surfaces

### 7.1 `tests/scripts/dev_tools/test_blast_radius_conflicts.py`

**Owns:** the relation's behaviour and the two record types' construction invariants. The module
docstring (lines 1-6) states the coverage: the four disjuncts in isolation, glob-versus-concrete
matching, the fail-closed undecidable glob pair, empty-radius cases, the fixed reason order, and
construction invariants.

Current shape:

- Imports from the **facade** `scripts.dev_tools.compute_blast_radius` (lines 15-20), not the private
  module — so a fix in the private module is exercised through the facade, which is correct.
- `CONFIG` (line 29) is a minimal two-key mapping; the relation reads no truth-table key.
- `make_radius` helper (lines 32-47) builds a `declared` radius with empty defaults.
- Construction-invariant tests: lines 50-53 (unknown kind), 56-59 (blank detail),
  **62-65 (verdict/reasons disagreement)**, 68-76 (reason order).
- Behavioural tests: lines 79-243, each reading `.conflict` and `.reasons`.
- Ends with the config-not-a-mapping raise test at lines ~240-243.

**Where a new assertion belongs.** Immediately after the existing `ConflictResult` construction block
(after line 76), add a small group asserting the boolean projection:

- `bool(conflicts(disjoint_a, disjoint_b, CONFIG)) is False`
- `bool(conflicts(radius, radius, CONFIG)) is True`
- `bool(ConflictResult(conflict=False, reasons=())) is False`
- `bool(ConflictResult(conflict=True, reasons=(ConflictReason(...),))) is True`
- the negation form `not conflicts(disjoint_a, disjoint_b, CONFIG)` is `True`

Placing them beside the construction invariants keeps the "what the record type guarantees" material
together and away from the disjunct-behaviour material.

### 7.2 `tests/scripts/dev_tools/test_blast_radius_invariants.py`

**Owns:** the parametrized invariant matrices. Docstring (lines 1-8): conflict symmetry, monotonicity
in the fail-closed direction, self-conflict, determinism and input-order independence, and V1
self-consistency.

- `RADIUS_PAIRS` (lines 62-92) — ten pairs spanning every outcome: disjoint, each level in isolation,
  glob-decided overlap, empty-versus-populated, empty-versus-empty, and all-levels-triggered.
- `NON_EMPTY_RADII` (lines 95-101) — five radii, one per contention level.
- Symmetry over verdicts, lines 128-134; over reasons, lines 137-142.
- Self-conflict, lines 145-150. Monotonicity, lines 176-177 and 207-208.

**Where the property-style assertion belongs.** This is the natural home for the issue's *"property
test over generated radii: boolean form agrees with the explicit field."* Add a
`@pytest.mark.parametrize(("left", "right"), RADIUS_PAIRS)` case asserting
`bool(conflicts(left, right, CONFIG)) is conflicts(left, right, CONFIG).conflict` — reusing the
existing ten-pair matrix, which already covers disjoint, single-level, multi-level, and both
empty-radius cases. No new fixture data is needed.

### 7.3 Property-based testing — `hypothesis` is NOT used and is NOT available

This is a load-bearing constraint on the test strategy. The module docstring of
`tests/scripts/dev_tools/test_blast_radius_invariants.py:3-5` states it verbatim:

> Satisfy the property-test obligation with `pytest.mark.parametrize` matrices rather than a
> property-based framework, because `hypothesis` is not an approved dependency of this repository.

Confirmed independently: a search for `hypothesis` in `pyproject.toml` returns **no matches**. The
repository's other property-style suites use seeded `random` instead, visible in the Ruff per-file
`S311` suppressions at `pyproject.toml:109-111`
(`test_parallel_mutation_protocol_properties.py`, `test_parallel_mutation_contention_properties.py`,
`test_parallel_mutation_pin_stability_properties.py`).

**Consequence for the spec:** the issue's proposed *"Property test over generated radii"*
(`.../issue.md:60`) must be satisfied by a `parametrize` matrix over `RADIUS_PAIRS`, or by a seeded
`random` generator following the `*_properties.py` precedent. **Introducing `hypothesis` is
prohibited** — `.claude/rules/python.md`, "Prohibited Behaviors", forbids adding dependencies without
explicit user instruction.

### 7.4 `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`

**Owns:** the PowerShell relation's behaviour. Docstring (lines 1-18) states it mirrors the Python
contention coverage and the invariant matrix.

- `BeforeAll` (lines 20-52) imports the facade by resolved path (line 26-27), defines
  `$script:TestConfig` (line 31) and the `Get-TestRadius` helper (lines 35-51).
- `Describe 'Test-BlastRadiusConflict result shape'` — **line 54**. Its first `It` (lines 56-67)
  asserts the sorted key set is `@('conflict', 'reasons')` (line 65) and that `$result['conflict']`
  is `$false` for a disjoint pair (line 66).
- `Describe 'Test-BlastRadiusConflict disjuncts in isolation'` — line 89.
- `Describe 'Test-BlastRadiusConflict fail-closed behavior'` — line 186.
- `Describe 'Test-BlastRadiusConflict reason ordering'` — line 245.
- Symmetry (lines 302-303, 317-318), monotonicity (334-335, 349-350), self-conflict (367), and
  determinism/input-order (380-381, 395-396) follow.

**Where the new assertion belongs.** In `Describe 'Test-BlastRadiusConflict result shape'` (line 54),
as a new `It` alongside the existing shape assertions. It is remedy M2 of section 4.4: pin that
`$result['conflict']` is `$false` for a disjoint pair **while** `[bool]$result` is `$true`, with a
comment naming the divergence and citing `about_Booleans`.

### 7.5 Parity tests

**`tests/scripts/dev_tools/test_blast_radius_parity.py`** — fixture-corpus parity, Python side.
`Describe`-equivalent cases: `test_conflict_fixture_reproduces_the_expected_verdict` (lines 416-440),
asserting `result.conflict is expected.get("conflict")`; and
`test_conflict_fixture_reproduces_the_expected_reasons` (lines 443-469). Both are parametrized over
`CONFLICT_CASES` from the shared JSON fixture corpus under `tests/fixtures/blast_radius/`.

**`tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`** — the PowerShell half of the
same corpus. `Describe 'Blast-radius contention parity'` at line 273, with
`Context 'Conflict verdict'` (lines 274-287, asserting `$result['conflict']` against the fixture at
line 285) and `Context 'Conflict reasons'` (lines 289-303). A `Describe 'Verification-integrity
regression (issue #489)'` follows at line 305.

**Assessment: neither parity suite should change.** Both are driven by a shared JSON fixture corpus
whose `expected` blocks record `conflict` and `reasons` values. Adding a truthiness assertion there
would require either extending the fixture schema or asserting a Python-only property in a
cross-language corpus — and since section 4.3 establishes the two runtimes **cannot** agree on
truthiness, a parity assertion on truthiness would be asserting a falsehood. The correct treatment is
the **documented divergence** of section 4.4, recorded in prose and pinned separately in each
runtime's own suite.

**`tests/scripts/dev_tools/test_blast_radius_config_parity.py`** — compares the self-hosted and
bundled `config/blast-radius.json` truth tables (key-partition, portable-surface, and directional
containment gates). Unrelated to truthiness; **no change**.

---

## 8. Tier Classification

### 8.1 `quality-tiers.yml` does not exist

**`quality-tiers.yml` is ABSENT from the repository root.** Established two ways:

1. A glob for `**/quality-tiers.yml` across the workspace returns **no files**.
2. A glob for `quality-tiers*` returns only `.claude/rules/quality-tiers.md`, its bundled mirror
   `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`, and two
   evidence artifacts. No `.yml`.

This is a known, documented, pre-existing repository condition, not something introduced by this
branch. It is recorded at
`docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/other/quality-tiers-classification.2026-08-07T19-58.md`,
which states (lines 39-47) that the file does not exist, that the absence was confirmed at both
baseline and execution time, and that it is *"a pre-existing repository condition documented at
`docs/features/potential/promoted/2026-07-09-quality-tiers-yml-missing-at-repo-root.md`."*

Note the second-order effect: `quality-tiers.yml` is nonetheless listed in **both**
`shared_surfaces` (`config/blast-radius.json:11`) and `mandate_reads`
(`config/blast-radius.json:26`), so the blast-radius machinery treats a path that does not exist as a
high-contention surface. That is consistent with the doctrine in
`.claude/rules/parallel-orchestration.md` (*"`quality-tiers.yml` stays a shared surface"*) and is not
a defect to address here.

### 8.2 Resulting obligations

Following the precedent recorded in the evidence artifact above (lines 52-62), **no T1 or T2
classification applies** to `scripts/dev_tools/_blast_radius_conflicts.py` or to
`.claude/lib/blast-radius/BlastRadius.psm1`, because there is no classification file that assigns
one. Per `.claude/rules/quality-tiers.md`:

| Obligation | Applies? | Value |
| --- | --- | --- |
| Format check | **Yes** — uniform across all tiers | 100% pass |
| Lint errors | **Yes** — uniform | 0 |
| Type errors | **Yes** — uniform | 0 (Pyright; not applicable to PowerShell) |
| Architecture violations | **Yes** — uniform | 0 |
| **Line coverage** | **Yes** — uniform across T1-T4 | **>= 85%** |
| **Branch coverage** | **Yes** for Python | **>= 75%**. **Exempt for PowerShell**: Pester does not measure branch coverage, so no branch gate applies to `BlastRadius.psm1`. |
| No regression on changed lines | **Yes** — uniform | required |
| Property-test density | **No** — T1/T2 only, and no tier is assigned | Exempt. Record the exemption explicitly, per the [P6-T7] precedent. The `parametrize` matrix of section 7.2 should still be added on its merits. |
| Mutation score >= 75% | **No** — T1 only | Exempt |
| Untyped escape hatches (`any`/`dynamic`) | **No** — tier-dependent budget | Unconstrained by tier. `.claude/rules/python.md:61` independently requires avoiding `Any`; the recommended `__bool__` introduces none. |
| Golden/snapshot tests | **No** — T1 classifier-output only | Exempt |
| Contract breaking changes | n/a | Remedy (a) is additive and breaks no caller (section 2.6) |

**The uniform coverage thresholds are unaffected by the absence** and must be met. The recommended
`__bool__` is a single `return` statement with no branches, so it costs one line and zero branches in
the denominator; both true and false cases are covered by the assertions of section 7.1.

---

## 9. Toolchain Commands

**No command in this section was executed** — see the method note at the top of this document.

### 9.1 Python loop (`.claude/rules/python.md:13-18`)

Run in order; restart from step 1 if any step fails or modifies files.

```bash
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

### 9.2 The coverage-reporter caveat is confirmed

The delegation prompt's warning is correct and is verified against the configuration:

**`pyproject.toml:115`** reads exactly

```toml
addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"
```

The project `addopts` therefore supplies an **LCOV reporter only**. A bare `poetry run pytest --cov`
writes `artifacts/python/lcov.info` and prints **no** human-readable table. Any command whose purpose
is to *read* a coverage figure MUST pass `--cov-report=term-missing` explicitly, exactly as
`.claude/rules/python.md:16` does. Supporting configuration:
`pyproject.toml:116` `testpaths = ["tests"]`; `pyproject.toml:118-126`
`[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, `data_file = "artifacts/.coverage"`,
`omit` covering `tests/*` and `__pycache__`/`site-packages`.

### 9.3 The `--cov` value must be an importable dotted module

Also correct, and enforced by the G1-G4 cascade in `.claude/rules/plan-acceptance-gates.md`:

- **G1 (Blocking)** — a `--cov` value ending in `.py` is rejected outright; `coverage.py` will not
  accept a filesystem path.
- **G2 (Blocking)** — a separator-bearing value whose text plus `.py` is a tracked file is rejected,
  because the dotted remedy is known exactly.
- **G4 (Warning)** — the space-separated form `--cov <value>` is reported; always use `--cov=`.

The correct scoped form for this feature is therefore:

```bash
poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py tests/scripts/dev_tools/test_blast_radius_invariants.py --cov=scripts.dev_tools._blast_radius_conflicts --cov-branch --cov-report=term-missing
```

**The dotted name is importable — verified structurally.** Both `scripts/__init__.py` and
`scripts/dev_tools/__init__.py` exist (confirmed by glob), so `scripts.dev_tools` is a real package
and `scripts.dev_tools._blast_radius_conflicts` is a valid dotted module. It is the identical form
used in the production import at `scripts/dev_tools/compute_blast_radius.py:35`.

**Outstanding runtime verification.** The prompt asked that the dotted form be run once and its
output recorded, to prove data is actually collected. **This could not be done: no shell tool was
available.** The plan must carry this as an explicit acceptance step — run the command above once and
confirm the `term-missing` table names `scripts/dev_tools/_blast_radius_conflicts.py` with a non-zero
statement count. A table that reports `No data was collected` would indicate the dotted name did not
resolve and must be treated as a gate failure, not a formatting quirk.

### 9.4 PowerShell loop (`.claude/rules/powershell.md:13-20`)

Run in order: format, analyze, test. Type checking is not applicable to PowerShell.

| Step | MCP tool |
| --- | --- |
| 1. Format (Invoke-Formatter) | `mcp__drm-copilot__run_poshqc_format` |
| 2. Lint (PSScriptAnalyzer) | `mcp__drm-copilot__run_poshqc_analyze` (optional autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix`) |
| 3. Test (Pester 5.x) | `mcp__drm-copilot__run_poshqc_test`, using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |

`.claude/rules/powershell.md:20` adds: *"Use the MCP server functions; do not substitute VS Code task
wrappers."*

### 9.5 The known PoshQC MCP limitation does NOT affect this feature

The limitation is real: the MCP PoshQC test runner reads the **installed extension's** settings, so a
newly added `CodeCoverage.Path` entry in the repository copy of the run settings can be ignored until
the extension is rebuilt and reinstalled. The workaround is to invoke the self-hosted PoshQC module
directly.

**It does not bite here, because this feature adds no new `CodeCoverage.Path` entry.**
`.claude/lib/blast-radius/BlastRadius.psm1` is **already registered** at
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:167`, inside the issue #447 block
(lines 146-169) that registers all seven blast-radius modules. The fix modifies an existing,
already-measured production file and adds assertions to an existing test file, so the installed
extension's settings already include everything this feature needs.

**Corollary for the blast radius:** because no run-settings edit is needed,
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` stays **out** of the write set. That
matters materially — it is a declared **shared surface** (`config/blast-radius.json:13`), so writing
it would create a `shared_surface_overlap` edge against every other item that touches it, exactly the
contention this feature should avoid.

---

## 10. Concrete File List for the Blast Radius

Exact repository-relative paths. No `**/<filename>` leading glob and no bare `tests/*` token is used
anywhere in this list; every entry is a concrete path except the feature-folder glob, which is added
automatically by `derive_blast_radius` and names a directory this feature genuinely owns.

### 10.1 Production files — required

| # | Path | Change |
| --- | --- | --- |
| 1 | `scripts/dev_tools/_blast_radius_conflicts.py` | Add `__bool__` to `ConflictResult` after `__post_init__` (which ends at line 134). Optionally extend the class docstring at lines 96-109. |
| 2 | `.claude/lib/blast-radius/BlastRadius.psm1` | **Documentation only.** Extend the `.OUTPUTS`/`.DESCRIPTION` of `Test-BlastRadiusConflict` (lines 405-431) with remedy M1 of section 4.4. No behavioural change; the return at lines 470-473 is unchanged. |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1` | Identical mirror of #2. **Mandatory** — enforced by the test in section 5.2. |

### 10.2 Production files — strongly recommended (the actual incident surface)

Per section 4.5, these are the artifacts that produced the #559 incident. Omitting them ships a fix
that does not touch the path where the defect occurred.

| # | Path | Change |
| --- | --- | --- |
| 4 | `.claude/skills/parallel-add/SKILL.md` | Step 3 (lines 59-70): state explicitly that the verdict is `$result['conflict']` and that the returned hashtable is unconditionally `$true` in a boolean context. |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` | Identical mirror of #4. **Mandatory if #4 is taken.** |
| 6 | `.claude/skills/parallel-plan/SKILL.md` | Seeding procedure (lines 300-305) and the contention contract (lines 213-217): same explicit verdict-access instruction, alongside the existing `@(...)` warning at lines 189-191. |
| 7 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | Identical mirror of #6. **Mandatory if #6 is taken.** |

### 10.3 Test files — required

| # | Path | Change |
| --- | --- | --- |
| 8 | `tests/scripts/dev_tools/test_blast_radius_conflicts.py` | Add the boolean-projection unit assertions of section 7.1, after line 76. |
| 9 | `tests/scripts/dev_tools/test_blast_radius_invariants.py` | Add the `parametrize` agreement case of section 7.2 over the existing `RADIUS_PAIRS` (lines 62-92). |
| 10 | `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | Add remedy M2 of section 4.4 inside `Describe 'Test-BlastRadiusConflict result shape'` (line 54). |

### 10.4 Optional

| # | Path | Change |
| --- | --- | --- |
| 11 | `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` | Add the `Get-FileHash -Algorithm SHA256` comparison to `Context 'Bundled payload parity'` (lines 62-75), matching the three sibling libraries cited in section 5.3. Closes a real asymmetry; the Python test of section 5.2 already covers the exposure, so this is symmetry work, not a gap fix. |

### 10.5 Explicitly NOT in the write set, with reasons

Recording the exclusions matters as much as the inclusions, because each one avoided is contention
avoided.

| Path | Why excluded |
| --- | --- |
| `scripts/dev_tools/compute_blast_radius.py` | The re-export at lines 35-39 binds the same class object; `__bool__` propagates with no facade edit (section 1.4). |
| `scripts/dev_tools/parallel_drift_detection.py` | Line 499 already reads `.conflict`; behaviour is unchanged under remedy (a) (section 2.6). |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `BlastRadius.psm1` is already registered at line 167 (section 9.5). This file is a declared **shared surface** (`config/blast-radius.json:13`); writing it would create a `shared_surface_overlap` edge against every concurrent item that touches it. |
| Any file under `extensions/drm-copilot/src/` | No TypeScript conflict relation exists (section 6). |
| `tests/scripts/dev_tools/test_blast_radius_parity.py` and `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | Fixture-corpus parity suites; a cross-language truthiness assertion would assert a falsehood (section 7.5). |
| `config/blast-radius.json` and its bundled copy | Declared shared surfaces (`config/blast-radius.json:12`); this fix changes no truth-table content. |
| `.claude/rules/parallel-orchestration.md` | See the note below. |

**On `.claude/rules/parallel-orchestration.md`.** There is a genuine case for recording the
PowerShell truthiness divergence there, next to the three existing TypeScript divergence classes. It
is **not recommended**, for two reasons. First, `.claude/rules/**` is a configured **mandate-read**
path (`config/blast-radius.json:21`), so under the doctrine in `.claude/rules/parallel-orchestration.md`
a plan that genuinely writes it must append that exact concrete path to the declared radius **after
normalization** — an extra obligation on the planner and an extra path in the radius. Second, the
divergence is a property of the *library's* API, not of the *parallel schema* that the rule file
governs; the module docstring and the `.OUTPUTS` block (items 1 and 2) are the closer home. If the
spec author nonetheless chooses to record it there, the mandate-read enumeration obligation and the
bundled mirror at
`extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
both apply.

### 10.6 Contention profile of the recommended radius

Checked against the committed truth table `config/blast-radius.json`:

- **Modules:** the map (lines 32-40) contains `powershell-dev-tools`, `poshqc`, `benchmarks`,
  `codex-runtime`, `mcp-server`, `config`, and `schemas`. **No entry matches** `scripts/dev_tools/**`,
  `.claude/lib/**`, `.claude/skills/**`, `tests/**`, or
  `extensions/drm-copilot/resources/claude-customizations/**` — the umbrella modules were removed by
  issues #472 and #489. The radius resolves to **zero modules**.
- **Shared surfaces:** the exact list (lines 3-14) and the globs (lines 15-19,
  `validate_*.py`, `_orchestrator_state_*.py`, `_epic_orchestrator_state_*.py`) match **none** of the
  eleven paths above. `_blast_radius_conflicts.py` matches no glob. The radius touches **zero shared
  surfaces**.
- **Contracts:** the spec's interface section should avoid letterless tokens; `ConflictResult` and
  `__bool__` are ordinary identifiers and are admitted normally.
- **Mandate reads:** none of the eleven paths is a mandate-read entry, provided
  `.claude/rules/parallel-orchestration.md` stays out (10.5).

**Result: the radius is path-level only, plus the feature-folder glob.** This item contends with
another only if that item writes one of the same eleven concrete files. That is the best available
contention profile for this fix and is a direct reason to hold the boundary described in 10.5.
