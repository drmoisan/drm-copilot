# Hermeticity: Added Lines in Modified Test Files ([P9-T8])

Timestamp: 2026-09-26T22-35

Command: `git diff -U0 b67453837646fd2dd4f5ac692f76e6f7703fe798 -- extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts extensions/drm-copilot/test/extension.integration.test.ts extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts tests/scripts/dev_tools/test_pr_context_integration.py tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py | grep -E -e "^\+.*(origin/|C:/|C:\\\\|tmpdir|mkdtemp|tmp_path|tempfile)"`

EXIT_CODE: 1

ExpectedExitCode: 1

Command: `git diff -U0 b67453837646fd2dd4f5ac692f76e6f7703fe798 -- extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts extensions/drm-copilot/test/extension.integration.test.ts extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts tests/scripts/dev_tools/test_pr_context_integration.py tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py | grep -c -E -e "^\+[^+]"` (companion input check)

EXIT_CODE: 0

Created-vs-modified: the six TS files and `test_pr_context_integration.py` pre-existed at the sync SHA (only added lines are scanned); `test_render_pr_helpers.py` was created by this plan and is committed, so the diff yields its whole content (it was also scanned by [P9-T7]).

Output Summary: the scan pipeline printed no lines (exit 1). The companion count printed `286`, so the scan had 286 added lines of input. Pre-existing `C:/workspace` literals in `repo-automation-dispatch-pr-context-verification.test.ts` are not on added lines and are outside this plan's scope.
