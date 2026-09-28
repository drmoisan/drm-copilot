# Shared-File Reference State at Cycle Entry — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P0-T11]
HEAD: `bcf2de15`

Command: `sha256sum` over the shared files and bundled mirrors, plus `sed -n` extraction of the
verbatim blocks, plus `git diff c939b5b8..HEAD -- scripts/dev_tools/validate_parallel_orchestrator_state.py`

EXIT_CODE: 0

Output Summary: Nine SHA-256 values recorded, the three mirror pairs confirmed byte-identical at
cycle entry, the two sibling reserved sections captured verbatim with their exact blank-line framing,
the F7 extension seam block captured verbatim and confirmed empty, and the validator's diff against
the base confirmed to be exactly the two lines `bcf2de15` added. Phase 7 verifies confinement against
these recorded values rather than against memory.

## SHA-256 Reference Values

| Path | SHA-256 |
| --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `c154616cf761d033208006405efc6980dbd21249b5a0efb0381cce6f4d233e06` |
| `.claude/settings.json` | `322fc04ef92a56db9615d2766de4483f3480c0dbcf04d33d6cd29ca5fec20677` |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `3ebf24c925dd242235a7c909d74d6e573e3caf95af0a46f3d94ca7f537b6caab` |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | `b412940d73e4e4cc04f2cb6b762f5897d4ba4d3244df02fea721addd37e9a2ad` |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | `e88811ef464cc3195e792d2ad6d359d45851fdf8a8e4121479a21fb09571cf5c` |

Bundled mirrors under `extensions/drm-copilot/resources/`:

| Mirror path | SHA-256 | Equals its source |
| --- | --- | --- |
| `.../claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | `c154616cf761d033208006405efc6980dbd21249b5a0efb0381cce6f4d233e06` | yes |
| `.../claude-customizations/.claude/settings.json` | `322fc04ef92a56db9615d2766de4483f3480c0dbcf04d33d6cd29ca5fec20677` | yes |
| `.../claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1` | `e88811ef464cc3195e792d2ad6d359d45851fdf8a8e4121479a21fb09571cf5c` | yes |
| `.../powershell/PoshQC/settings/pester.runsettings.psd1` | `3ebf24c925dd242235a7c909d74d6e573e3caf95af0a46f3d94ca7f537b6caab` | yes |

All four mirror pairs are byte-identical at cycle entry.

## SKILL.md Structural Reference

- Total lines: **684**.
- Count of `##` headings: **16**.
- The three reserved wave-4 sections and their relative order, which must be preserved:
  `## Mutation Protocol (F6)` at line 435, `## Enforcement Hooks (F7)` at line 439,
  `## Radius Drift Detection (F8)` at line 443 (closing the file).

## Verbatim Text — `## Mutation Protocol (F6)`

Lines 435-437, reproduced byte-for-byte including the blank lines that frame the body. Each source
line ends with a single LF; there is no trailing whitespace on any line.

```
## Mutation Protocol (F6)

Reserved for F6; content is appended by that feature and must not be relocated.
```

Framing: line 434 is blank, line 435 is the heading, line 436 is blank, line 437 is the body
sentence, line 438 is blank.

## Verbatim Text — `## Enforcement Hooks (F7)`

Lines 439-441, reproduced byte-for-byte.

```
## Enforcement Hooks (F7)

Reserved for F7; content is appended by that feature and must not be relocated.
```

Framing: line 438 is blank, line 439 is the heading, line 440 is blank, line 441 is the body
sentence, line 442 is blank.

Neither of these two sections may be modified, relocated, retitled, or reordered by this cycle.

## Verbatim Text — F7 Extension Seam Block

`scripts/dev_tools/validate_parallel_orchestrator_state.py` lines 327-334, reproduced byte-for-byte
including leading indentation. The block contains no helper invocation and is therefore still empty.
Nothing may be added inside it and its comment lines must not be touched.

```python
    # BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
    # F7 (parallel enforcement hooks) owns the retrospective cohort-ordering
    # invariant of design section 9 Layer 2. Its entire edit to this module is
    # one appended `errors.extend(<helper>(state_map, CONTEXT))` call inside
    # this block, plus the helper's import. Nothing else in this function moves,
    # so F7 and F3 cannot contend over the same lines (epic wave-4 rule).
    # Add F7 helper invocations below this line, one per line.
    # END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
```

Surrounding context confirming F8's dispatch sits **above and outside** the seam:

```python
    errors.extend(scan_prohibited_keys(state_map, CONTEXT))
    errors.extend(_validate_collections(state_map))
    errors.extend(validate_drift_gate(state_map, CONTEXT))

    # BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
```

## Validator Diff Reference

`git diff c939b5b8..HEAD -- scripts/dev_tools/validate_parallel_orchestrator_state.py` is exactly two
added lines and zero removed lines:

```diff
+from scripts.dev_tools._parallel_orchestrator_state_drift import validate_drift_gate
+    errors.extend(validate_drift_gate(state_map, CONTEXT))
```

This cycle requires no change to that file, so Phase 7's [P7-T3] must observe this same two-line diff.
