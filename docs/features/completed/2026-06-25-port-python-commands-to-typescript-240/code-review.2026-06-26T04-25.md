# Code Review: F7 ts-potential-to-issue (Issue #240)

**Review Date:** 2026-06-26
**Base:** `main` @ merge-base `cfba7414203f8abff8be3a038e8df32f1f95d73e`
**Head:** `f45cb5ea67e9fb677ed2c9c9e247ebafb3f73997`
**Scope:** Full branch diff. TypeScript only (5 production + 6 test files; one modified service file).

## Executive Summary

The F7 change is a faithful, well-documented in-process TypeScript port of the bundled Python `potential_to_issue.py` and `potential_to_issue_content.py`. The reviewer compared `promotion.ts`, `gh-client.ts`, and `content.ts` against the bundled Python sources and confirmed byte-identical control flow, error messages, emitted lines, argument vectors, the `--json` field list, the label color/description, and the missing-`gh` message. The missing-label recovery — the regression scenario this feature must preserve — is correctly ported: it matches only the specific `could not add label: '<label>' not found` fragment (case-insensitive), calls `ensureLabel` exactly once, retries `issueCreate` only when the ensure exit code is `0`, and lets all other gh errors fall through to the failure path with their original output. Tests are hermetic and cover this path in both the recover-and-retry and no-retry-on-non-zero-ensure directions.

The service wiring is a clean single-delegation replacement following the established F4/F5/F6 precedent. `repo-automation-service.ts` shrank from 500 to 496 lines, satisfying the 500-line watch. The service-call helper preserves the byte-identical `summary` string and the prior non-zero-exit failure surface (`Command exited with code <n>.`), additively enriching the result with `destinationPath` and the created issue URL.

No blocking or material findings. The two findings below are informational.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Informational | `src/lib/potential-to-issue/promotion.ts` | `computeRelativePath` (lines 146-154) | The `try/catch` around `nodePath.relative` is dead in practice: `node:path.relative` does not throw on cross-drive inputs the way Python `os.path.relpath` raises `ValueError`. The catch is retained for documented parity but is unreachable, contributing to the uncovered branch lines (151-153). | Acceptable as-is; the inline comment already explains the parity intent. Optionally annotate the branch as parity-only if branch-coverage headroom becomes tight. | The catch cannot execute under Node, so the parity guarantee it documents is structural rather than behavioral. | `promotion.ts:146-154`; coverage report uncovered lines `151-153`. |
| Informational | `src/lib/potential-to-issue/potential-to-issue-service-call.ts` | `parseIssueReference(outcome.messages)` (line 181) | The created issue URL is re-parsed from the aggregated `messages` array rather than from the gh create output directly. This works because the success path emits the create output lines into `messages`, but it couples the artifact-enrichment to message emission ordering. | No change required. If the emit contract changes in a future feature, revisit this re-parse. | The current emit path guarantees the create output is present in `messages`, so the re-parse is correct today. | `potential-to-issue-service-call.ts:181`; `promotion.ts:391-393` (success-path emit). |

## Detailed Observations

### Parity correctness (verified against bundled Python)

- `promotion.ts` `promotePotential` reproduces the Python `promote_potential` step order exactly: validate type/mode → auth check → resolve/exists/empty checks (with the not-found message using the ORIGINAL path arg and the empty message using the RESOLVED path, matching Python) → title/body construction → emit → create → missing-label recovery → non-zero handling → metadata update → move. Confirmed line-by-line against `resources/scripts/dev_tools/potential_to_issue.py:210-372`.
- `gh-client.ts` argument vectors match the Python `_run` builders byte-for-byte: `issue create --title <t> --body-file - --label <type>` (body on stdin), `label create <label> --color 0e8a16 --description "Feature work"`, `issue view <n> --json number,title,url,author,updatedAt`, and `auth status`. The missing-`gh` message `gh CLI not found on PATH. Install gh and authenticate first.` is byte-identical.
- The stdin requirement is met without widening the shared F1 `CommandRunner`: a port-local `GhCommandRunner` seam adds an optional `input?: string`, and the service-call adapter routes the single body-bearing `issue create` call through the stdin-capable `SpawnSyncGhCommandRunner` while routing auth/label/view through the injected F1 runner with `allowError: true`. This matches the plan's Parity Note choice (b).
- `splitCombinedOutput` correctly emulates Python `str.splitlines()` (splits on `\n`/`\r\n`/`\r`, drops a single trailing empty element).

### Separation of concerns and seams

- Pure parse/build logic is isolated in `content.ts` with no I/O. The filesystem seam (`PotentialFileSystem`) and gh seam (`GhClient`) are port-local interfaces with injectable production defaults, keeping `node:fs`/`node:child_process` out of the domain workflow. The shared F1 `file-system.ts`, `subprocess-runner.ts`, and `prompt-mode-contract.ts` interfaces are unmodified.

### Documentation quality

- Module, class, and function docstrings are present and contract-oriented, with branch decision comments on the body-routing table and the missing-label recovery. This satisfies the commenting policy.

### Tests

- 908/908 pass across 78 suites. The new suites cover content helpers, the gh client arg vectors and stdin handling, the full promotion workflow, and the missing-label regression. The extension suite's Python-spawn assertions were correctly inverted to `expectNoPythonSpawn()` (asserts no `.py` spawn), and the missing-python-runtime case was inverted to assert success without Python.

## Conclusion

No blocking findings. The port is accurate, well-tested, and within scope. Recommend proceeding to PR readiness.
