# Phase 0 Policy-Read Evidence

Timestamp: 2026-07-18T14-13

Policy Order: The policy files were read in the repository-mandated order defined by
`CLAUDE.md` "Policy Compliance Reading Order" and the `policy-compliance-order` skill.

Files read (in order):

1. `.github/copilot-instructions.md` — repository tone and communication policy.
2. `.claude/rules/general-code-change.md` — cross-language code change policy (design
   principles, mandatory toolchain loop, 500-line file limit, error handling, I/O boundaries).
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy (coverage
   requirements line >= 85% / branch >= 75%, no temporary files, test-tree mirroring).
4. `.claude/rules/python.md` — Python toolchain (Black, Ruff, Pyright, Pytest) and coding
   standards (frozen dataclasses, `__post_init__` invariants, strong typing, no broad
   `except Exception`).
5. `.claude/rules/python-suppressions.md` — pre-authorized suppression patterns; suppressions
   require pre-authorization or explicit approval.
6. `.claude/rules/quality-tiers.md` — module rigor tiers and uniform coverage thresholds.

Output Summary: All six policy files were read prior to any code or test change. Key
constraints internalized for this feature: (a) full Python toolchain loop in order
format -> lint -> type-check -> test, restart on any failure/file change; (b) 500-line
file-size limit for every production and test file; (c) no runtime temp files in tests
(use `mem_fs_path`); (d) coverage line >= 85% and branch >= 75% with no regression on
changed lines; (e) suppressions (`# type: ignore` / `# noqa`) require pre-authorization,
prefer refactoring; (f) isolate the untyped `yaml.safe_load` boundary in one helper with
no `cast` chains and no `# type: ignore`.
