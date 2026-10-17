# Evidence

Timestamp: 2026-10-09T08-18
Command: git -C WT diff origin/main --stat -- package.json package-lock.json extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary: Baseline equals post-change for root (97.76/91.42/97.76) and extension (97.16/91.66/97.16); 0 executable lines changed.

## Printed output

```text
Package   | Metric     | Baseline | Post-change | Delta
root      | Statements | 97.76    | 97.76       | 0
root      | Branches   | 91.42    | 91.42       | 0
root      | Lines      | 97.76    | 97.76       | 0
root      | Tests      | 3923     | 3923        | 0
extension | Statements | 97.16    | 97.16       | 0
extension | Branches   | 91.66    | 91.66       | 0
extension | Lines      | 97.16    | 97.16       | 0
extension | Tests      | 3906     | 3906        | 0
Changed-code coverage: 0 executable lines changed (JSON manifests and lockfiles only)

git diff origin/main --stat:
 extensions/drm-copilot/package-lock.json | 8 ++++----
 extensions/drm-copilot/package.json      | 1 +
 package-lock.json                        | 8 ++++----
 package.json                             | 1 +
 4 files changed, 10 insertions(+), 8 deletions(-)
```
