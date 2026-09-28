# AC 20 Availability Parameter (P10-T10)

Timestamp: 2026-09-26T20-37
Branch: N588
Base: ae8d2ce32c95cf03d55ffb544f2514d83ebfc620

Command: grep -c -F -e "gh_available: bool = True" scripts/dev_tools/pr_context/render_pr_helpers.py
EXIT_CODE: 0
Output Summary: Printed `1`. One keyword-only `gh_available` parameter defaulting to True on the Python builder.

Command: grep -c -F -e "ghAvailable?: boolean" extensions/drm-copilot/src/lib/pr-context/autoclose.ts
EXIT_CODE: 0
Output Summary: Printed `1`. One optional `ghAvailable` parameter on the TypeScript builder.

Command: grep -c -F -e "ghAvailable = true" extensions/drm-copilot/src/lib/pr-context/autoclose.ts
EXIT_CODE: 0
Output Summary: Printed `1`. The TypeScript parameter defaults to true.

Command: git merge-base --is-ancestor ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 HEAD
EXIT_CODE: 0
Output Summary: No output. The scope anchor is an ancestor of HEAD, so the parameter was introduced by this branch (N588; #622 introduced it).

Overall: `Branch: N588` and `Base: ae8d2ce32c95cf03d55ffb544f2514d83ebfc620` are taken from `evidence/baseline/588-detection.2026-09-25T23-29.md` ([P0-T2]). Collector-level evidence that both call sites pass availability: C1 (`tests/scripts/dev_tools/pr_context/test_autoclose_collector.py::test_collector_excludes_scraped_tokens_from_autoclose_when_gh_unavailable`) PASSED in [P5-T1] (`evidence/regression-testing/py-pass-after.2026-09-25T23-29.md`, EXIT_CODE 0, `71 passed`), and T1 (`excludes scraped tokens from autoclose when gh is unavailable`) passed in [P5-T2] (`evidence/regression-testing/ts-pass-after.2026-09-25T23-29.md`, EXIT_CODE 0, `67 passed, 67 total`).
