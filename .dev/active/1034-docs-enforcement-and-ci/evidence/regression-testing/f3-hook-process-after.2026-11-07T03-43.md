# F3 Hook Process Table After the Fix - Issue 1034 Remediation Cycle 2 (P2-T6)

Timestamp: 2026-11-07T03-43
Command: sh SCRATCH/issue-1034-c2-f3.sh After (one real PowerShell 7 hook process per row against a fresh consumer copy under SCRATCH/consumer that includes the helper; the envelope arrives on standard input)
EXIT_CODE: 0
Output Summary: PASS. 66 rows, 0 failures. With an enabled profile each of the 21 Group D commands prints deny with PR_UNRESOLVED and the clause 'does not name one pull request', which proves no lookup ran, at exit 0. With a disabled profile and with an absent profile each prints allow at exit 0. Both quoted Group E commands print allow at exit 0 with the gate enabled. With the helper removed from the consumer copy, gh pr merge 12 --merge prints deny with text naming enforce-docs-complete-gate-target.ps1.

| Command | Profile | Decision | Exit | Reason | Row |
|---|---|---|---|---|---|
| `if gh pr checks 12; then gh pr merge 12 --merge; fi` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `for n in 12; do gh pr merge "$n" --merge; done` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `! gh pr merge 12` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `exec gh pr merge 12` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `while true; do gh pr merge 12 --merge; break; done` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `if false; then echo x; else gh pr merge 12; fi` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `until gh pr merge 12; do sleep 1; done` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `sudo gh pr merge 12` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `nice gh pr merge 12` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `coproc gh pr merge 12` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `find . -maxdepth 0 -exec gh pr merge 12 \;` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `gh pr checks 12 && gh pr merge 12 --merge` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `case x in x) gh pr merge 12;; esac` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `f() { gh pr merge 12; }; f` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `time gh pr merge 12` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `nohup gh pr merge 12` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `(gh pr merge 12)` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `{ gh pr merge 12; }` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `if true; then gh api -X PUT repos/o/r/pulls/12/merge; fi` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `! gh api graphql -f query='mutation{mergePullRequest(x)}'` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `gh api -X PUT repos/{owner}/{repo}/pulls/12/merge` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: PR_UNRESOLVED: The command does not name one pull request the gate can resolve; the gate fails closed. Run one plain gh pr merge with its selector and repository, as the only command in the call. | pass |
| `if gh pr checks 12; then gh pr merge 12 --merge; fi` | disabled | allow | 0 |  | pass |
| `for n in 12; do gh pr merge "$n" --merge; done` | disabled | allow | 0 |  | pass |
| `! gh pr merge 12` | disabled | allow | 0 |  | pass |
| `exec gh pr merge 12` | disabled | allow | 0 |  | pass |
| `while true; do gh pr merge 12 --merge; break; done` | disabled | allow | 0 |  | pass |
| `if false; then echo x; else gh pr merge 12; fi` | disabled | allow | 0 |  | pass |
| `until gh pr merge 12; do sleep 1; done` | disabled | allow | 0 |  | pass |
| `sudo gh pr merge 12` | disabled | allow | 0 |  | pass |
| `nice gh pr merge 12` | disabled | allow | 0 |  | pass |
| `coproc gh pr merge 12` | disabled | allow | 0 |  | pass |
| `find . -maxdepth 0 -exec gh pr merge 12 \;` | disabled | allow | 0 |  | pass |
| `gh pr checks 12 && gh pr merge 12 --merge` | disabled | allow | 0 |  | pass |
| `case x in x) gh pr merge 12;; esac` | disabled | allow | 0 |  | pass |
| `f() { gh pr merge 12; }; f` | disabled | allow | 0 |  | pass |
| `time gh pr merge 12` | disabled | allow | 0 |  | pass |
| `nohup gh pr merge 12` | disabled | allow | 0 |  | pass |
| `(gh pr merge 12)` | disabled | allow | 0 |  | pass |
| `{ gh pr merge 12; }` | disabled | allow | 0 |  | pass |
| `if true; then gh api -X PUT repos/o/r/pulls/12/merge; fi` | disabled | allow | 0 |  | pass |
| `! gh api graphql -f query='mutation{mergePullRequest(x)}'` | disabled | allow | 0 |  | pass |
| `gh api -X PUT repos/{owner}/{repo}/pulls/12/merge` | disabled | allow | 0 |  | pass |
| `if gh pr checks 12; then gh pr merge 12 --merge; fi` | absent | allow | 0 |  | pass |
| `for n in 12; do gh pr merge "$n" --merge; done` | absent | allow | 0 |  | pass |
| `! gh pr merge 12` | absent | allow | 0 |  | pass |
| `exec gh pr merge 12` | absent | allow | 0 |  | pass |
| `while true; do gh pr merge 12 --merge; break; done` | absent | allow | 0 |  | pass |
| `if false; then echo x; else gh pr merge 12; fi` | absent | allow | 0 |  | pass |
| `until gh pr merge 12; do sleep 1; done` | absent | allow | 0 |  | pass |
| `sudo gh pr merge 12` | absent | allow | 0 |  | pass |
| `nice gh pr merge 12` | absent | allow | 0 |  | pass |
| `coproc gh pr merge 12` | absent | allow | 0 |  | pass |
| `find . -maxdepth 0 -exec gh pr merge 12 \;` | absent | allow | 0 |  | pass |
| `gh pr checks 12 && gh pr merge 12 --merge` | absent | allow | 0 |  | pass |
| `case x in x) gh pr merge 12;; esac` | absent | allow | 0 |  | pass |
| `f() { gh pr merge 12; }; f` | absent | allow | 0 |  | pass |
| `time gh pr merge 12` | absent | allow | 0 |  | pass |
| `nohup gh pr merge 12` | absent | allow | 0 |  | pass |
| `(gh pr merge 12)` | absent | allow | 0 |  | pass |
| `{ gh pr merge 12; }` | absent | allow | 0 |  | pass |
| `if true; then gh api -X PUT repos/o/r/pulls/12/merge; fi` | absent | allow | 0 |  | pass |
| `! gh api graphql -f query='mutation{mergePullRequest(x)}'` | absent | allow | 0 |  | pass |
| `gh api -X PUT repos/{owner}/{repo}/pulls/12/merge` | absent | allow | 0 |  | pass |
| `git commit -m 'gh pr merge 12'` | enabled | allow | 0 |  | pass |
| `echo "gh pr merge 12"` | enabled | allow | 0 |  | pass |
| `gh pr merge 12 --merge (HELPER removed)` | enabled | deny | 0 | DOCS_COMPLETE_GATE_BLOCKED: the dependency 'enforce-docs-complete-gate-target.ps1' failed to load (The term 'SCRATCH/consumer/.claude/hooks/enforce-docs-complete-gate-target.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.); the gate fails closed. | pass |
