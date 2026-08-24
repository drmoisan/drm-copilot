# Final Bash QC via CI Dispatch (Issue #479, [P7-T12])

Timestamp: 2026-08-17T03-05

Command:
```
git add -A && git commit && git push
git ls-remote origin refs/heads/bug/parallel-lane-scale-and-barrier-semantics-479
gh workflow run _shell-coverage.yml --ref bug/parallel-lane-scale-and-barrier-semantics-479
gh run watch 31998496925 --exit-status
gh run view 31998496925 --json conclusion,url,headSha,status
gh run view 31998496925 --log
```

EXIT_CODE: 0 (all commands)

## Output Summary

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/31998496925
- Conclusion: **success** (status `completed`)
- headSha: **`14b5cdd766b0bea78be44f9946c377a4c8afe930`** — verified EQUAL to the local
  `git rev-parse HEAD` and to `git ls-remote` for the branch before dispatch, so the run
  exercised the full change set at the branch head.
- Job: `Shell Coverage (Bats + kcov)` (ID 95294365990).

### Both required steps green

| Step | Result |
|---|---|
| `Run shell-qc check (shfmt diff + shellcheck)` | **green** — the edited `.claude/lib/bash/parallel-manifest-validate.sh` passes shfmt in diff mode and shellcheck with no suppression added |
| `Run shell-qc test with coverage` | **green** |

### Bats results

- TAP plan `1..251`; **251** `ok` lines and **zero** `not ok` lines.
- Baseline was 245 tests; net **+6**, exactly the six M8 cases added to
  `tests/shell/parallel_manifest_validate.bats` by `[P3-T8]`:

```
ok 110 M8 accepts a named block-sequence expected_conflict_components entry
ok 111 M8 accepts an unnamed block-sequence entry, since name is optional
ok 112 M8 contributes no error when the key is absent
ok 113 M8 rejects a non-list expected_conflict_components value
ok 114 M8 rejects a component whose members key is missing
ok 115 M8 rejects a member that resolves to no items[] issue_num
```

Test 110 is the block-sequence acceptance case AC27 requires: the bash YAML subset parser
accepts the mandated block-sequence form.

### The bash-lane parity corpus (AC27 bash half, AC38 bash half)

Two `parallel_manifest_parity.bats` cases are the operative discharge and both passed:

```
ok  87 the manifest parity corpus meets the declared floor
ok  89 the bash lane reproduces every manifest corpus fixture
```

Test 89 runs the WHOLE 54-fixture shared corpus — including the 13 M8 fixtures added by
`[P3-T7]` and the 6 D2 fixtures migrated by `[P2-T8]` — through the bash implementation and
compares each emitted error list against the fixture's recorded `expected_errors`. Its passing
is the byte-identical two-runtime demonstration; test 87 confirms the corpus was not silently
truncated. The cohort-parity floor (`ok 38`) also passed.

### Numeric bash coverage

`Bash coverage (lines): 92.6%`

| Metric | Value | Baseline | Threshold | Result |
|---|---|---|---|---|
| Line | **92.6%** | 92.3% | >= 85% | PASS, +0.3 |
| Branch | `N/A — kcov does not measure branch coverage; PowerShell/bash are exempt from the branch threshold only` | N/A | n/a | n/a |

The kcov include pattern covers `.claude/lib/bash/`, so the edited
`parallel-manifest-validate.sh` is measured, not merely discovered. Coverage improved because
the six new bats cases exercise the new M8 code paths.

## Prior local corroboration

Before this dispatch, the same bash library was probed locally under Git Bash by sourcing
`.claude/lib/bash/parallel-manifest-validate.sh` and running `pm_validate_text` over all 54
corpus fixtures: `corpus fixtures compared: 54; mismatches: 0`. That probe covered the library
only; this CI run additionally covers the bats harness, the CLI entry point under `bats run`,
shfmt, shellcheck, and kcov measurement.
