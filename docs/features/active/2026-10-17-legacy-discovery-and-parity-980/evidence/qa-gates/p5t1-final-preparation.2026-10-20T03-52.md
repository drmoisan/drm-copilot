# P5-T1 final verification preparation

Timestamp: 2026-10-20T03-52
Command: `poetry run python SCRATCH/issue-980-p5t1-final-preparation.py`
EXIT_CODE: 0
Output Summary: Prepared only; no suites or source/test mutations. Execution is not released.

The remaining scope is eight files: runtime coverage_report.py, coverage_population.py and validation.py, plus test_coverage_report.py, test_coverage_report_contract.py, test_validation_modes.py, test_agent_output.py and test_mutation_plan.py. The adjacent JSON records exact paths and observed hashes; these are not a frozen execution candidate.

The five committed helper/legacy files match their retained 114-case proof, with 179/179 statements and 68/68 branches. Their checks are reused while exact bytes and the recorded dependency closure remain valid.

The proposed sequence is scoped Black, scoped Ruff, whole-repository Pyright, static architecture/size/isolation, two isolated reversed graph/caller batches with three-module coverage, four exact package/tier contract cases, then 14 bounded public capture/load/report/render/recompute checks. Graph and caller node counts remain explicitly unresolved until their owner receipts are frozen.

The original validation baseline is 133/133 statements and 42/42 branches. Coverage will retain separate AST-range and coverage.py qualified-unit summaries, enforce no-loss/changed-line gates, and make no repository-wide coverage claim.

Execution requires completed PR1-PR4 repair confirmation, exact frozen caller/graph manifests, a final hash-bound candidate and coordinator release. Native composition additionally requires prepared outside-workspace fixtures with actual repository pins. It proves read-only Windows/Git composition, not publication or installed coding-agent host behavior.

Exact scope, commands, contract selectors, composition assertions, prerequisite references and evidence rules: `p5t1-final-preparation.2026-10-20T03-52.json`.
