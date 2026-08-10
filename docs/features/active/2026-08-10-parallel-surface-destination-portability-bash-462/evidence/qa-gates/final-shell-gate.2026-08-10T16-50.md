# Final QA — Shell Gate (pre-final)

Timestamp: 2026-08-10T16-50

Task: [P7-T10]
Command:
```
git push origin HEAD
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-08-10T09-25
gh run view 31410402606 --json status,conclusion,url,headSha
gh run view 31410402606 --log | grep "Bash coverage (lines)"
```
EXIT_CODE: 0

Bash verification is CI-only on this win32 host (binding constraint 1). No local bats, shfmt,
shellcheck, or kcov run was attempted or recorded.

## Output Summary

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/31410402606
- Run ID: 31410402606
- headSha: `90c79fd1ee8d4009f0080eba9c616e219c13de8f`
- Conclusion: **success** (first dispatch; no iteration required)
- `Run shell-qc check (shfmt diff + shellcheck)` — **success**
- `Run shell-qc test with coverage` — **success**
- bats: `1..245`, **245 ok, 0 not ok**
- Printed coverage line: `Bash coverage (lines): 92.4%`
- Threshold check: 92.4% >= 85% (`.claude/rules/quality-tiers.md`). The workflow has no
  coverage-threshold gate, so this value is read from the printed line, not inferred from the
  run conclusion.

The bats count rose from 229 at [P3-T17] to 245 here: the Phase 5 suites
`tests/shell/parallel_bash_manifest_membership.bats` (6 cases) and
`tests/shell/parallel_payload_only.bats` (10 cases) were added between the two dispatches.
`parallel_payload_only.bats` is the AC16 bats half: it runs the three published entry points from
the bundle root under a PATH restricted to the checked-in shim directory
`tests/fixtures/parallel_payload_path/`, which exposes only `sort`, `cut`, `cat`, and `dirname`
and no interpreter, and it asserts positively that `python`, `python3`, and `poetry` are all
unreachable on that PATH.

## Discharge Status

**This is the pre-final gate.** [P7-T11] through [P7-T14] write further files after it, so this
run's head SHA is stale by construction relative to the terminal branch head. [P7-T15] supplies
the head-SHA-matched discharge for the `modified-workflow-needs-green-run` policy rule
(`.claude/skills/feature-review-workflow/SKILL.md:73`) covering the
`.github/workflows/_shell-coverage.yml` diff, and the spec AC13 "against the branch head"
evidence.
