# R5 documentation Batch A green gate

Timestamp: 2026-08-12T16:13:31.9049774Z

## Ordered toolchain pass

Command: `poetry run black scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py tests/scripts/dev_tools/test_parallel_resume_truth.py tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py`

EXIT_CODE: 0

Output Summary: Black left all four owned files unchanged.

Command: `poetry run ruff check scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py tests/scripts/dev_tools/test_parallel_resume_truth.py tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py`

EXIT_CODE: 0

Output Summary: Ruff reported all checks passed.

Command: `poetry run pyright scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py tests/scripts/dev_tools/test_parallel_resume_truth.py tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py`

EXIT_CODE: 0

Output Summary: Pyright reported 0 errors, 0 warnings, and 0 informations.

Command: `poetry run pytest -o "addopts=" -q tests/scripts/dev_tools/test_parallel_resume_truth.py tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py`

EXIT_CODE: 0

Output Summary: 26 tests passed in 0.11 seconds.

## Exact R5 checker

Command:

```powershell
$R5Checker = @'
import ast
import hashlib
import sys
from pathlib import Path

CONTRACT_FIELDS = ("Args:", "Returns:", "Raises:", "Side Effects:")
ADJACENCY_NODES = (
    ast.For,
    ast.AsyncFor,
    ast.While,
    ast.ListComp,
    ast.DictComp,
    ast.SetComp,
    ast.GeneratorExp,
)
READINESS_PATH = "scripts/dev_tools/validate_parallel_codex_readiness.py"
READINESS_GUARD = 'any(part in (".", "..") for part in path.parts)'


def is_docstring_statement(node: ast.stmt) -> bool:
    return (
        isinstance(node, ast.Expr)
        and isinstance(node.value, ast.Constant)
        and isinstance(node.value.value, str)
    )


class StripDocstrings(ast.NodeTransformer):
    def strip(self, node: ast.AST) -> ast.AST:
        self.generic_visit(node)
        body = getattr(node, "body", None)
        if isinstance(body, list) and body and is_docstring_statement(body[0]):
            body.pop(0)
        return node

    visit_Module = strip
    visit_ClassDef = strip
    visit_FunctionDef = strip
    visit_AsyncFunctionDef = strip


paths: list[str] = []
owners: list[str] = []
allow_guard = False
for argument in sys.argv[1:]:
    if argument.startswith("--owner="):
        owners.append(argument.removeprefix("--owner="))
    elif argument == "--allow-readiness-guard-adjudication":
        allow_guard = True
    else:
        paths.append(argument)

findings: list[str] = []
guard_seen = False
for path_text in paths:
    path = Path(path_text)
    source = path.read_text(encoding="utf-8")
    source_lines = source.splitlines()
    tree = ast.parse(source, filename=path_text)
    callables = sorted(
        (
            node
            for node in ast.walk(tree)
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
        ),
        key=lambda node: (node.lineno, node.col_offset),
    )
    contract_failures = 0
    for node in callables:
        docstring = ast.get_docstring(node, clean=False) or ""
        missing = [field for field in CONTRACT_FIELDS if field not in docstring]
        if missing:
            contract_failures += 1
            findings.append(
                f"CALLABLE {path_text}:{node.name}@{node.lineno} missing={','.join(missing)}"
            )

    adjacency_nodes = sorted(
        (node for node in ast.walk(tree) if isinstance(node, ADJACENCY_NODES)),
        key=lambda node: (node.lineno, node.col_offset, type(node).__name__),
    )
    adjacency_failures = 0
    adjudicated = 0
    for node in adjacency_nodes:
        segment = " ".join((ast.get_source_segment(source, node) or "").split())
        is_guard = (
            path.as_posix() == READINESS_PATH
            and isinstance(node, ast.GeneratorExp)
            and segment == READINESS_GUARD
        )
        if is_guard and allow_guard:
            guard_seen = True
            adjudicated += 1
            print(
                "ADJUDICATED "
                f"{path_text}:audit-line-231/current-line-{node.lineno} GeneratorExp "
                "reason=trivial generator guard is a policy false positive; no R5 change authorized"
            )
            continue
        previous = source_lines[node.lineno - 2].strip() if node.lineno > 1 else ""
        if not previous.startswith("#") or not previous.removeprefix("#").strip():
            adjacency_failures += 1
            findings.append(
                f"ADJACENCY {path_text}:{type(node).__name__}@{node.lineno} missing=immediate-intent-comment"
            )

    semantic_tree = StripDocstrings().visit(ast.parse(source, filename=path_text))
    semantic_dump = ast.dump(ast.fix_missing_locations(semantic_tree), include_attributes=False)
    semantic_sha = hashlib.sha256(semantic_dump.encode("utf-8")).hexdigest().upper()
    print(
        f"SUMMARY {path_text} callables={len(callables)} "
        f"contract_failures={contract_failures} adjacency_nodes={len(adjacency_nodes)} "
        f"adjacency_failures={adjacency_failures} adjudicated={adjudicated}"
    )
    print(f"SEMANTIC_SHA256 {path_text} {semantic_sha}")

for owner_text in owners:
    owner = Path(owner_text)
    owner_sha = hashlib.sha256(owner.read_bytes()).hexdigest().upper()
    print(f"OWNER_SHA256 {owner_text} {owner_sha}")

if allow_guard and not guard_seen:
    findings.append("ADJUDICATION readiness audit-line-231 guard was not found exactly")
for finding in findings:
    print(f"FAIL {finding}")
raise SystemExit(1 if findings else 0)
'@
$R5Checker | poetry run python - scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py --owner=tests/scripts/dev_tools/test_parallel_resume_truth.py --owner=tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py
```

EXIT_CODE: 0

Output Summary:

- `scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py`: 11 callables, 0 contract failures, 14 adjacency nodes, 0 adjacency failures, 0 adjudications.
- `scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py`: 12 callables, 0 contract failures, 17 adjacency nodes, 0 adjacency failures, 0 adjudications.
- `SEMANTIC_SHA256 scripts/dev_tools/_parallel_orchestrator_state_resume_truth.py 6BA8CA044417E215896FBBD426F15915EE8389AD8A23971F38A7103E5CBFBC06`, equal to P13-T8.
- `SEMANTIC_SHA256 scripts/dev_tools/_parallel_orchestrator_state_receipt_cohort.py 17C3B3BE4E01D0B8552FA4CC2AA20610F5D3FF241315B86E7E81BD006DC2CE28`, equal to P13-T8.
- `OWNER_SHA256 tests/scripts/dev_tools/test_parallel_resume_truth.py BECB0A7CD0D85D8A4832F41DF1CA3095B5014429AB2B4F80F560942C819F6176`, equal to P13-T8.
- `OWNER_SHA256 tests/scripts/dev_tools/test_parallel_receipt_bound_cohort.py EA6A38F6DAC07311E6D83F287020EE456629C9700C1F340043A0CC8BF5F39F98`, equal to P13-T8.

Acceptance result: PASS. Black, Ruff, Pyright, focused Pytest, and the exact R5 checker completed in one uninterrupted pass; semantic and read-only owner digests remained unchanged.
