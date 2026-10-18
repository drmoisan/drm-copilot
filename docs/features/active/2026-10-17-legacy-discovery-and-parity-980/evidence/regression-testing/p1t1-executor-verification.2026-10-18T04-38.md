# P1-T1 independent executor verification

Timestamp: 2026-10-18T04-38
Command: poetry run python SCRATCH/issue-980-verify-p1t1.py; git diff --cached --check; staged source and recorded gate review
EXIT_CODE: 0
Output Summary: P1-T1 verified: 26 owned paths, 37 public-object identity checks, 13 coverage records, 31/31 changed executable lines and 2/2 changed branch arcs covered; maximum 452 physical lines.

The staged implementation matches the exact approved task scope. The working tree has no unstaged change to those paths. Independent fingerprints, relocation diffs, and measured coverage-counter comparisons are in [executor checks](p1t1-executor-checks.2026-10-18T04-38.json).

Reviewed the actual pass4 format, lint, full Pyright, focused 532-test coverage, reversed 268-test, dependency-install/lock, and tracked 26-project classification records linked from [the specialist handoff](../other/p1t1-package-extraction.2026-10-18T04-36.md). The final ordered pass contains no intermediate code change or failed step. No broad test suite was rerun during verification.

The canonical runtime is installed as drm-copilot-discovery 2.0.0, declares Python >=3.10, and contains the single implementations. Public legacy imports resolve to the same objects. Source comparison confirms preserved v1 parser/value behavior, byte-identical artifact I/O, and a type-only rendering boundary change. The checkout-specific template resolver correctly remains in its old adapter; installed resource lookup is the next task.

All existing lockfile name/version pairs, including parallel Python-constrained versions, remain present; the only new package is the local runtime. An initial verifier-helper comparison incorrectly collapsed duplicate names to one version; the corrected multiset comparison passed without any repository change. No v1 schema/example/fixture path changed. Existing tier assignments and exclusions are preserved; the new package is the sole new T2 entry.

Profile coverage is 189/190 lines (99.473684%) and 77/78 branches (98.717949%). Other changed production files are fully covered where measurable. All 13 coverage records match the raw coverage JSON and have nonnegative baseline deltas. The protocol-stub denominator difference is explained in the specialist proof and does not change coverage configuration.

Task acceptance passes. This verification checks P1-T1 only. The 66 feature criteria remain unchecked because package extraction alone does not establish the complete discovery/parity capability or final repository QA.
