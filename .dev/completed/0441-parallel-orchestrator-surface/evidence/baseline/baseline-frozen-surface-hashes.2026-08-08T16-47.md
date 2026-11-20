# Baseline — Frozen-Surface SHA-256 Content Hashes (P0-T6)

- **Issue:** #441
- **Feature:** 2026-08-07-parallel-orchestrator-surface-441
- **Task:** [P0-T6]
- **Working directory:** repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)
- **Branch:** `feature/parallel-orchestrator-surface-441`
- **HEAD at capture:** `ee0626e8` (merge of PR #454, base `epic/parallel-orchestration-integration`)

Timestamp: 2026-08-08T16-47

Command: `pwsh -NoProfile -Command "Get-FileHash -Algorithm SHA256 '.claude/agents/epic-orchestrator.md','.claude/skills/epic-orchestrate/SKILL.md','.claude/skills/orchestrate/SKILL.md' | Format-List Path,Hash,Algorithm"`

Cross-verification command: `poetry run python -c "import hashlib,pathlib;..."` (SHA-256 over the same raw file bytes)

EXIT_CODE: 0

Output Summary — exactly three path-to-hash pairs (SHA-256, lowercase hex):

| Path (repo-root-relative) | SHA-256 | Size (bytes) |
| --- | --- | --- |
| `.claude/agents/epic-orchestrator.md` | `f4e3589ab53e6a61791f2d31e7506e7e6003ec63fe651f3cec323023d923f250` | 9203 |
| `.claude/skills/epic-orchestrate/SKILL.md` | `3c2e38bd5bdc5e2b7312437d47dc27aa282f2ff24fbaf01590b51e853e788d68` | 17496 |
| `.claude/skills/orchestrate/SKILL.md` | `b4e4c26fc5597af9499e43497ea013cf4780faaac14009e2bcf44946cde3402c` | 36328 |

Both tools produced identical digests for all three files (PowerShell `Get-FileHash` returns uppercase hex; the values above are normalized to lowercase, which is the form `hashlib.sha256(...).hexdigest()` produces). Recording the Python-computed form matters because P4-T6 embeds these values as constants in a Python test that hashes the same file bytes; the two tools were confirmed to agree so the pinned constants will match at test time.

Byte lengths are recorded as a secondary integrity signal. Hashes are computed over raw file bytes, so any line-ending change is detected.

**Pin source declaration:** these three hashes are the authoritative baseline for:

- **P4-T6** — SHA-256 content-hash pinning of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` as embedded test constants (no git dependency in-test).
- **P5-T1** — frozen-surface byte-identity re-verification of all three files against these values, alongside an empty `git diff <merge-base> -- <the three paths>`.

Per the plan's hard constraints, none of these three files may be modified by this feature. Any deviation from the values above at P4-T6 or P5-T1 is a constraint violation, not a hash-refresh event.
