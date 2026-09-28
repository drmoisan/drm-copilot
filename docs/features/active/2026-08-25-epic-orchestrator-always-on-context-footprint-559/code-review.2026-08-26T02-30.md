# Code Review — Issue #559 (epic-orchestrator always-on context footprint)

- Timestamp: 2026-08-26T02-30
- Reviewer: `feature-review`
- Review type: **REAUDIT — remediation cycle 1 exit gate**
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- HEAD: `684592a8`
- Merge base: `b36179b2`
- Prior review: `code-review.2026-08-26T01-11.md`

## Blocking Count

**Total Blocking findings: 0**

## Review Scope

Full branch diff against the merge base: 86 files, 10162 insertions, 49 deletions. By extension:
83 Markdown, 3 Python. No PowerShell, TypeScript, or C# source.

Cycle 1 (commit `684592a8`) changed 32 files: one source hunk in one test module, one hunk in
`CLAUDE.md`, the remediation plan, and 29 evidence artifacts.

## Cycle 1 Delta Review

### R1 — `EXCLUDED_CLAUDE_SUBDIRS` (Blocking fix)

`tests/scripts/dev_tools/test_claude_rules_frontmatter.py:35-37`

```python
# `.claude/agent-memory/`, `.claude/worktrees/`, and `.claude/state/` are gitignored,
# machine-local subtrees excluded here for determinism.
EXCLUDED_CLAUDE_SUBDIRS = frozenset({"agent-memory", "worktrees", "state"})
```

**Correctness — good.** The filter in `claude_markdown_files()` (lines 322-326) tests
`candidate.relative_to(CLAUDE_ROOT).parts[0]`, which is the right operand: the three gitignored
subtrees are immediate children of `.claude/`, so a first-segment test is exact. It neither
under-matches (a nested `worktrees/` directory deeper in the tree is correctly *not* excluded, since
such a directory would be committed content) nor over-matches.

**Data structure — good.** `frozenset` for a membership-tested constant is the right choice:
immutable, so no test can mutate it for another; O(1) membership.

**Naming — good.** `EXCLUDED_CLAUDE_SUBDIRS` says what it holds and where it applies. The plural
and the `CLAUDE_` qualifier both carry information.

**Comment quality — adequate, with a reservation.** The comment states the *category* (gitignored,
machine-local) rather than enumerating a reason per name, which is the right level: it tells a
future reader the admission criterion for a fourth entry. The reservation is that it states the
criterion without pointing at where the criterion is checkable — the three names correspond exactly
to `.gitignore:21`, `:67`, and `:68`, and a cross-reference would make the coupling visible. This is
the readable half of finding C1-N1; the enforcement half is the missing guard test.

**Line-neutrality — deliberate and worth noting.** The fix replaced three lines with three lines,
holding the module at exactly 499 of its 500-line ceiling. That is a correct response to the
constraint, but it means the constraint is now shaping the code: the comment was compressed from two
sentences to one to make room for the third name. A module with zero headroom will keep forcing that
trade. See C1-N8.

**Docstring drift — minor.** `claude_markdown_files()`'s inline comment at lines 320-321 still reads
"skipping the machine-local memory tree whose content is not committed" (singular, memory-specific),
while the constant now excludes three trees. The docstring itself (lines 311-313) was written
generically and correctly refers to "the gitignored, machine-local subdirectories named in
``EXCLUDED_CLAUDE_SUBDIRS``". Non-blocking; recorded as C1-N16 below.

**Efficiency — unchanged, and not addressed.** `CLAUDE_ROOT.rglob("*.md")` still descends into
`.claude/worktrees/` and yields every nested worktree's Markdown before the filter discards it. The
correctness defect is fixed; the cost characteristic cycle 0 recorded as impact 2 is not. On the
primary checkout that means walking sixteen repository copies to produce 108 files. An `os.walk`
with in-place `dirnames` pruning would fix it in about the same number of lines. Non-blocking: the
cost is borne only on a developer's primary checkout, never in CI, and it did not cause a timeout in
this review's own cross-checkout probe. Recorded as C1-N17.

### R2 — `CLAUDE.md` tone-authority wording (non-blocking fix)

Single hunk, `CLAUDE.md` `## Tone Policy`:

```diff
-- Be concise, direct, and literal.
-- Do not use jokes, humor, metaphors, playful analogies, banter, emojis, GIF references, sarcasm, or conversational filler.
-- Do not use motivational hype, celebratory phrasing, or grandiose narration.
-- If a sentence could read as casual, playful, or informal, rewrite it in neutral business language.
+The specific tone rules are stated once in `.claude/rules/tonality.md`, which the runtime loads as a mirror of the authoritative source defined below; they are not restated here.
```

**The contradiction is gone.** The three paragraphs now read as a coherent precedence chain:

1. "Use a strictly professional, factual, and neutral tone in all responses." — the standing rule.
2. The added line — where the specific rules live at runtime, and their relationship to the
   authority ("a mirror of the authoritative source defined below").
3. The pre-existing line — "`.github/copilot-instructions.md` and
   `.github/instructions/tonality.instructions.md`. Those files are authoritative." — unchanged.

Only one document is called authoritative. The forward reference "defined below" ties the two
paragraphs together explicitly rather than leaving the reader to infer the relation. This is also
consistent with the pre-existing architecture statement later in the same file: "`.claude/` files
mirror or reference their content."

**Nothing else in `CLAUDE.md` moved.** The full `git diff b36179b2..684592a8 -- CLAUDE.md` is one
hunk at lines 8-14. The `## Policy Compliance Reading Order` section is byte-identical, and the diff
contains no added or removed line matching `80%`, `85%`, `75%`, `90%`, `four-step`, `four steps`,
`seven-stage`, or `seven stages` (verified: zero matches over the diff text).

**One consequence, worth flagging as a documentation finding rather than a defect.** The delivered
wording no longer matches the acceptance criterion at `spec.md:631-632`, which asks that `CLAUDE.md`
"names `.claude/rules/tonality.md` as the runtime-loaded **authoritative** source." That adjective
is precisely what cycle 0's N2 identified as false. The right resolution is to amend the criterion,
not to revert the text. Recorded as C1-N5 in the policy audit and reflected in the AC table of the
feature audit.

**Tone of the new line itself — compliant.** Literal, declarative, no hedging, no hype. It is a long
single line (~180 characters), consistent with the surrounding prose in the file, which is not
wrapped at a fixed column.

### R3 — evidence schema corrections (non-blocking fix)

Three artifacts gained an explicit `## Evidence Schema Classification (Remediation R3, Issue #559)`
section, and the reconciliation artifact's overstated conformance claim was corrected.

**No `Command:` line was invented.** This is the important property and it holds. Each of the three
artifacts states *why* it carries no command, in terms specific to what the artifact is:

- `evidence/qa-gates/coverage-delta.2026-08-26T00-00.md` — "a derived comparison record: it compares
  two prior command-step artifacts ... and runs no command of its own." It then names the two source
  artifacts and quotes the underlying command those two record, which is the honest form: it gives
  the reader the command without claiming to have run it.
- `evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md` — "a narrative record ... It runs no
  single command of its own and therefore carries no `Command:` or `EXIT_CODE:` field."
- `evidence/other/ac-reconciliation.2026-08-26T00-00.md` — same classification, plus the corrected
  count and an explicit supersession clause: "Of the 29 evidence artifacts this feature produced, 26
  conform to the full four-field schema ... This paragraph supersedes any earlier statement in this
  feature's evidence claiming uniform four-field conformance across all 29 artifacts."

**The correction is accurate.** 26 + 3 = 29, and the three named non-conformers are exactly the
three cycle 0 identified. The supersession clause is the right mechanism: it corrects the record
without rewriting the superseded text out of existence, so the audit trail survives.

**The disposition is policy-correct.** `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:108`
scopes the schema conditionally — "When evidence artifacts are used for automated checking or plan
reconciliation, include: `Timestamp:`, `Command:`, `EXIT_CODE:`". A narrative record that runs no
command is not in that class, so documenting the classification is a better remedy than fabricating
fields would have been. Cycle 0 offered relocation to `evidence/other/` as an alternative; two of the
three remain under `qa-gates/`. That is acceptable (C1-N15) — the collector drops non-conforming
rows rather than failing — but a reader scanning `qa-gates/` for command records will still meet two
that are not. Optional cleanup, no action required.

**Minor:** `ac-reconciliation.2026-08-26T00-00.md` now carries two `Timestamp:` lines (line 3,
`2026-08-26T01-12`; and line 11 inside the added section, `2026-08-26T01-11`). A first-occurrence-wins
parser handles this deterministically, and the second timestamp legitimately dates the correction
rather than the artifact. Not a finding; noted so it is not mistaken for a copy error later.

## Full-Branch Code Quality Review

The following assessments cover the whole branch diff, not only the cycle 1 delta.

### `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (new, 499 lines)

**Structure — good.** Constants, then eight pure helpers, then eight tests. The helpers are all
side-effect-honest: every docstring carries an explicit `Side Effects:` line, and the ones that read
disk say so. `normalize_whitespace`, `parse_frontmatter`, `string_sequence`, `globs_cover`, and
`is_unconditional` are pure functions of their arguments.

**Separation of concerns — good.** `parse_frontmatter` isolates the untyped `yaml.safe_load`
boundary and returns `dict[str, object] | None`, so no caller handles `Any`. `string_sequence`
drops non-string members rather than coercing them, with the reason stated in the docstring: "so a
malformed entry cannot masquerade as a declared glob or skill name." That is defensive in the right
direction — it makes a malformed frontmatter entry fail the test rather than silently satisfy it.

**Error handling — fails in the correct direction throughout.** `parse_frontmatter` returns `None`
for a missing fence, an unterminated fence, a YAML error, or a non-mapping body, and
`is_unconditional` maps `None` to `True`. So a rule file with broken frontmatter is classified
*unconditional* and fails `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`. The
module docstring (lines 10-14) states this classification rule and the reason for it: "Counting only
explicit `**` entries would let an unscoped file hide inside a four-file expectation and would make
this module pass before the fix landed." That is exactly the reasoning a fail-first structural test
needs, and it is written down rather than left to be re-derived.

**Assertion messages — good.** Every assertion accumulates all defects and names them, rather than
failing on the first. `assert_rule_paths_reach` states this intent explicitly: "The message names
every unreached target, so one run reports the whole gap rather than only its first entry."

**A documented approximation, correctly disclosed.** `globs_cover` uses `fnmatch.fnmatchcase`, whose
`*` crosses path separators. The docstring states this is "slightly permissive at a segment
boundary" and gives the reason for accepting it: "the alternative is reimplementing the runtime's own
glob engine, which the repository does not expose." Disclosing a known approximation with its
rationale is the right handling. The practical risk is low here because the criteria the helper
serves assert *reachability* (a false negative would be the dangerous direction, and permissiveness
produces false positives only in the boundary case).

**Reusability — good.** `assert_rule_paths_reach` is shared by the three scope-coverage tests, which
differ only in the rule read and the target tuple. No copy-paste.

**Reservation — the target tuples are hand-maintained.** `CHECKPOINT_WRITER_SURFACES` lists ten
paths as literals. If an eleventh checkpoint-writing surface is added, this tuple does not notice.
The comment at lines 62-64 states the invariant the tuple encodes, which is the mitigation available
without a discovery mechanism. Not a finding; inherent to a structural pin.

### `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py` (new, 437 lines)

Seven tests, all reading committed text. Same docstring discipline. The tests assert placeholder-free
literal fragments, which is the form `.claude/rules/plan-acceptance-gates.md` recommends for a
checkable assertion.

The defaulted test parameter at lines 237-254, motivated only by line length, remains the one style
reservation (C1-N14, carried from cycle 0). The alternatives the executor rejected — retaining an
unauthorized `E501` suppression, or dropping the return annotation — were correctly rejected; a
defaulted parameter is the least-bad of the three. Optional cleanup.

### `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (modified, 339 lines)

25 lines changed: two pinned SHA-256 digest constants and their adjacent comment. Nothing else. The
file is owned by concurrently active feature 441; the change is the minimum required to keep that
feature's consuming test passing after this branch edits the two hashed files.

The re-pin is verified by execution rather than by reading the artifact: the consuming module
`test_parallel_orchestrator_surface_contracts.py` recomputes both digests from the committed bytes
and passes. This matters — a pinned-hash evidence artifact can record a hash that matches no commit,
and the passing test is the check that catches that class.

The assertion message in the consuming module still reads "pre-feature state" after the re-baseline
(C1-N9). That is a stale message in feature 441's file, not in this branch's file, and correctly
left alone.

### Markdown surfaces — the five rules files and the two epic surfaces

**Frontmatter insertions are top-only, verified mechanically.** The diff for all five rules files
consists solely of `@@ -1,3 +1,N @@` hunks containing only added lines. No body line was added,
removed, or reflowed in any of the five. That is the property `spec.md:607-609` asserts, and it is
what makes the change safe against the risk the spec records (frontmatter insertion invalidating
downstream line-number citations).

**Glob sets are justified, not guessed.** `evidence/other/f3-glob-justification.2026-08-26T00-00.md`
quotes each rule's own `## Enforcement` or `## Scope` section for each glob. The
`benchmark-baselines.md` case is handled honestly: `scripts/benchmarks/**` matches zero current
files because `scripts/benchmarks/` does not exist in this repository (independently verified:
`ls scripts/benchmarks` → no such file or directory), and the artifact records that this is the
correct outcome under that rule's own scope statement rather than narrowing the glob to make it
match something.

**`orchestrator-state.md` names the ten writer surfaces literally rather than relying on activation
via the checkpoint artifact.** This is the mitigation `spec.md:714` commits to, and it is the right
call: path-scoped activation on a runtime-written JSON file is undocumented behaviour, so depending
on it would make the rule silently absent where it matters most.

**A deliberate consequence, correctly disclosed.** Scoping `parallel-orchestration.md` means it is no
longer auto-injected for the epic surface that cites it for the cache doctrine (C1-N13). This is
consistent with the change's whole purpose — the point is to stop injecting rules that are not in
scope — and it is recorded so a later reader does not mistake it for an oversight.

### Always-on footprint reduction — the substantive outcome

`evidence/baseline/always-on-line-count-comparison.2026-08-26T00-00.md` records before 2,158 lines
over 17 files, after 984 lines, a reduction of 1,174 lines (54.4%). The measurement is
component-broken-down and both totals are traceable to their own timestamped artifacts (`[P0-T9]`
before, post-change after). This is the bug's actual remedy and it is measured rather than asserted.

## Best-Practice Assessment Summary

| Dimension | Verdict | Note |
|---|---|---|
| Simplicity first | PASS | The B1 fix is a three-name frozenset, not a mechanism. Correct instinct. |
| Reusability | PASS | `assert_rule_paths_reach` shared across three tests; no duplication. |
| Extensibility | PASS | Adding a rule surface is a tuple entry; adding an exclusion is a set entry. |
| Separation of concerns | PASS | Pure helpers separated from disk-reading helpers; YAML boundary isolated. |
| Fail fast and explicitly | PASS | Broken frontmatter classifies as unconditional and fails loudly. |
| Assertion message quality | PASS | Every failure names the full offending set. |
| Naming | PASS | Descriptive throughout; no non-standard abbreviations. |
| Error handling | PASS | No broad catch-all; `yaml.YAMLError` caught narrowly and converted to a documented "absent" result. |
| Comments explain *why* | PASS, one drift | Consistently rationale-oriented. One stale inline comment (C1-N16). |
| File size | PASS | 499 / 437 / 339 against a 500 ceiling. Zero headroom on the first (C1-N8). |
| Suppressions | PASS | None in any changed Python file. |
| I/O boundaries | PASS | Tests read committed text only; no writes, no subprocess, no network. |
| Dependencies | PASS | No new dependency. `yaml`, `fnmatch`, `re`, `pathlib` are already in use. |

## Findings

**Blocking: none.**

Non-blocking findings introduced by this review, in addition to those tabulated in
`policy-audit.2026-08-26T02-30.md`:

| ID | Summary | Location | Suggested disposition |
|---|---|---|---|
| C1-N16 | Inline comment in `claude_markdown_files()` still reads "skipping the machine-local memory tree" (singular) after the constant grew to three subtrees. The function docstring is already generic and correct. | `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:320-321` | One-word edit at the next touch of this module. No behavioural effect. |
| C1-N17 | `rglob` still descends into `.claude/worktrees/` before filtering, so scan cost still scales with live worktree count. Correctness is fixed; the cost characteristic recorded as cycle 0 impact 2 is not. | `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:322` | Optional: `os.walk` with in-place `dirnames` pruning. Cost is borne only on a developer primary checkout, never in CI. |

Carried forward unchanged from cycle 0: C1-N9 (N3), C1-N10 (N4), C1-N11 (N5), C1-N12 (N6),
C1-N13 (N9), C1-N14 (N10). Resolved this cycle: N1 (as R3), N2 (as R2), and B1.
