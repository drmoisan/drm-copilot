# Remediation Inputs — 2026-08-10T21-03

Canonical issue number for this feature is 462.

Source: direct user feedback on PR #463 after the feature-review pass returned FULLY COMPLIANT.
These are user-directed changes, not review findings. All five are treated as Blocking for this
cycle because the user asked for each explicitly.

## RI-1 — BLOCKING — Remove the unwritable sixth test scenario from the spec

`spec.md`, `## Seeded Test Conditions`, first bullet:

> bats unit coverage for the bash cohort computation: empty graph, single item, disjoint items,
> fully connected items, deterministic tie-breaking, and generation handling.

Five of the six clauses are delivered. `generation` is caller-owned state that `compute_cohorts`
never accepts as a parameter, so the sixth clause has no testable surface inside the function.
Implementing it would require adding a parameter, which acceptance criterion AC17 forbids.

**Required change.** Delete the words `, and generation handling` from that bullet so the line
describes only the five delivered scenarios, then check the box. Apply the identical edit to
`user-story.md` if the same bullet appears there. Do not add a test.

## RI-2 — BLOCKING — Narrow the Bash allowlist grant to the three entry points

The current grant is a single prefix wildcard:

```
Bash(bash .claude/lib/bash/*)
```

The trailing `*` matches across `/`, so it also admits nested subdirectories and relative-traversal
paths such as `bash .claude/lib/bash/../../../anything.sh`. Only three of the nine files are
command-line entry points; the other six are sourceable libraries never invoked directly.

**Required change.** Replace the single entry with exactly three entries:

```
Bash(bash .claude/lib/bash/compute-cohorts.sh*)
Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)
Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)
```

Apply in all six locations, keeping the repo copy and the bundled mirror byte-identical:

- `.claude/settings.json:8` and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json:8`
- `.claude/agents/parallel-planner.md:17` (frontmatter) and `:154` (prose) plus its bundled mirror
- `.claude/agents/parallel-orchestrator.md:18` (frontmatter) and `:72` (prose) plus its bundled mirror

Also update the disclosure artifact
`evidence/other/permission-surface-callout.2026-08-10T17-08.md`: the narrowing is now applied, so
the "recommended follow-up, not applied here" section must be rewritten to describe the delivered
three-entry grant and state the residual scope accurately (each entry is still a prefix wildcard on
a specific filename, which permits trailing arguments — that is the intent — but no longer permits
directory traversal).

The user asked for a re-audit after this change.

## RI-3 — BLOCKING — Do not suppress linting file-wide; the exception is not warranted

Two file-wide suppressions were added during execution:

- `scripts/bash/shell_qc_lib.sh:13` — `# shellcheck disable=SC2015`
- `scripts/bash/cleanup_worktrees_lib.sh:16` — `# shellcheck disable=SC2015`

The orchestrator investigated whether an exception is defensible and concluded it is not. Evidence:

1. **The justification text is factually wrong.** Both suppression comments claim the
   `<test> && <assign> || true` idiom is one that `.claude/rules/shell.md` "mandates". It does not.
   That rule mandates `|| rc=$?` for capturing the exit code of tools that legitimately return
   non-zero. It says nothing about `A && B || true`. The suppressions cite a rule that does not
   support them.

2. **A rewrite removes the finding entirely, on every shellcheck version.** SC2015 fires only on the
   `A && B || C` construct. An `if` statement contains no such construct, so no version of
   shellcheck can emit SC2015 for it. This is not a version-dependent workaround.

3. **The rewrite is semantically identical.** The `|| true` exists solely to stop `set -e` aborting
   when the test is false. An `if` condition that evaluates false does not trigger `set -e`, so the
   guard becomes unnecessary rather than merely relocated.

4. **A narrower suppression was also available** (per-line `# shellcheck disable=SC2015` at each of
   the eight sites) and would have satisfied the rule's "justified inline" wording. The file-wide
   form was chosen when a narrower one existed, which is what makes it a policy violation rather
   than a judgment call.

**Required change.** Delete both file-wide suppression directives and their justification comment
blocks, and rewrite the eight sites as `if` statements:

`scripts/bash/shell_qc_lib.sh` lines 92, 115, 191, 197, 247, 347, 356:

```bash
# from
[[ -d $root ]] && roots+=("$root") || true
((rc > exit_code)) && exit_code=$rc || true
# to
if [[ -d $root ]]; then roots+=("$root"); fi
if ((rc > exit_code)); then exit_code=$rc; fi
```

`scripts/bash/cleanup_worktrees_lib.sh` line 479: same treatment for
`((crc > rc)) && rc=$crc || true`.

Add no replacement suppression of any scope. Preserve each site's existing intent comment. Match
shfmt default formatting; if shfmt expands the single-line `if` form, accept its output.

**Verification note.** Local shellcheck is 0.11.0, which does not flag these sites at all (verified:
zero findings at `-S style` with the suppressions removed). CI installs the apt-packaged shellcheck,
which does flag them — that version divergence is why the finding appeared only in CI. Correctness
of the rewrite therefore must be confirmed by a CI dispatch, not by the clean local run.

## RI-4 — BLOCKING — Anchor the `.gitignore` build-artifact rule

`.gitignore:20` is `lib/`, unanchored, so it matches a directory named `lib` at any depth. It
silently excluded a checked-in test fixture during execution; the tests passed locally and failed in
CI because the file was never committed. Eight negation lines (22-25, 29-32, 36-37) exist purely to
undo this overreach.

**Required change.** Anchor the rule to the repository root, where the Python build artifact
actually appears:

- `lib/` becomes `/lib/`
- `lib64/` (line 38) becomes `/lib64/`

Then delete the negation lines that exist only to counteract the unanchored form, and verify with
`git check-ignore -v` that each of these remains tracked and unignored:
`extensions/drm-copilot/src/lib/`, `extensions/drm-copilot/test/lib/`, `.claude/lib/`,
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/`, and
`tests/fixtures/shell_qc/.claude/lib/bash/lib_entry.sh`. Confirm `git status` reports no newly
untracked files as a result.

## RI-5 — BLOCKING — Open GitHub issues for the two silent-failure defects

Both were found during this orchestration, are pre-existing, and are out of scope to fix here. The
user asked that each be filed.

1. **`validate_orchestrator_state.py` has no entry point.** The module has no `__main__` guard, no
   `argparse`, and no `main()`. The command documented in `.claude/rules/orchestrator-state.md` and
   `.claude/skills/orchestrate/SKILL.md` —
   `python -m scripts.dev_tools.validate_orchestrator_state <path> --require-complete` — exits 0
   with no output even when `<path>` does not exist. Any orchestrator that runs the documented
   preflight and reads exit 0 believes a gate passed that never ran.

2. **`poetry run python -c` silently no-ops on multi-line strings.** In Git Bash on Windows with
   Poetry 2.3.2, a multi-line `-c` string produces no output and exits 0. Single-line works, and
   plain `python -c` with a multi-line string works. This matters because
   `.claude/skills/parallel-plan/SKILL.md` (lines ~150 and ~208) instructs agents to reach
   `compute_blast_radius` and `compute_cohorts` through exactly that invocation form.

Issue creation is orchestrator work (`gh issue create`), not a delegated task. No plan task is
required for RI-5; it is recorded here so the cycle's scope is complete.

## Out of scope for this cycle

- The 35 SC2015 findings in the new `.claude/lib/bash/**` files from CI run 31405454023 were fixed
  properly in those files during execution and carry no suppression. Only the eight in the two
  pre-existing files were suppressed. Do not revisit the new files.
- No parallel-surface schema field, enum member, or validator invariant may change (AC17).
