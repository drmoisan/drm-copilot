"""Verify the thin acceptance adapter and safe historical utility contracts.

Placeholder generation now refuses missing authoritative context; actual v2
projection remains covered by the unchanged seven-case companion module.
All artifact effects use memory fixtures, and runtime command execution is faked
except malformed arguments rejected by the public parser before workspace I/O.
"""

from __future__ import annotations

import inspect
import json
from dataclasses import FrozenInstanceError, fields
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import generate_acceptance_scenarios as gen

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence


@pytest.mark.parametrize("present", [False, True])
@pytest.mark.parametrize("version", [None, "v1", "2.0.0"])
def test_schema_path_refuses_checkout_authority(
    mem_fs_path: Path, present: bool, version: str | None
) -> None:
    """Refuse existing/absent memory schemas for each str-or-None version.

    Args are a memory Path, bool presence and optional str version. Returns None;
    only the memory fixture is seeded. GenerationError must precede lookup.
    """
    schema = (
        mem_fs_path / "schemas" / (version or "v1") / "feature-contract.schema.json"
    )
    if present:
        schema.parent.mkdir(parents=True, exist_ok=True)
        schema.write_text("{}", encoding="utf-8")
    with pytest.raises(gen.GenerationError, match="--workspace-root"):
        gen.resolve_discovery_schema(
            "feature-contract", root=mem_fs_path, version=version
        )
    assert schema.is_file() is present


def test_schema_self_reference_never_fabricates_fallback() -> None:
    """Require GenerationError for a Path hint; return None without I/O."""
    with pytest.raises(gen.GenerationError, match="configured v2"):
        gen.resolve_schema_self_ref(Path("untrusted-checkout"))


def test_seam_keyword_only_parameters() -> None:
    """Retain root/version keyword-only metadata; return None without effects."""
    signature = inspect.signature(gen.resolve_discovery_schema)
    assert signature.parameters["root"].kind is inspect.Parameter.KEYWORD_ONLY
    assert signature.parameters["version"].kind is inspect.Parameter.KEYWORD_ONLY


@pytest.mark.parametrize(
    "project",
    [
        gen.project_feature_contract,
        gen.project_parity_matrix,
        gen.project_runtime_characterization,
    ],
)
@pytest.mark.parametrize(
    "document",
    [
        {},
        {
            "feature_ref": "F",
            "title": "Preserve behavior",
            "given": ["g"],
            "when": ["w"],
            "then": ["t"],
        },
        {"rows": [{"parity_ref": "P", "feature_ref": "F"}]},
        {"scenarios": [{"characterization_ref": "C", "feature_ref": "F"}]},
        {"rows": {}},
        {"rows": [1]},
        {"scenarios": {}},
        {"scenarios": [1]},
        {"feature_ref": "F", "given": "not-a-list", "future_field": {"approved": True}},
    ],
)
def test_placeholder_projections_refuse_without_mutation(
    project: Callable[[dict[str, object]], object], document: dict[str, object]
) -> None:
    """Reject positive, malformed and unknown-field legacy data uniformly.

    Args are a projection Callable and untrusted dict. Returns None; expected
    GenerationError supplies migration guidance and leaves the input unchanged.
    """
    original = gen.format_document(document)
    with pytest.raises(gen.GenerationError, match="generate-acceptance-scenarios"):
        project(document)
    assert gen.format_document(document) == original


@pytest.mark.parametrize("populated", [False, True])
def test_assembly_cannot_turn_historical_carriers_into_readiness(
    populated: bool,
) -> None:
    """Refuse empty/populated bool-selected carriers; return None without effects."""
    feature = gen.FeatureContractProjection("F", "Behavior", ("g",), ("w",), ("t",))
    row = gen.ParityRow("P", "F", ("target result",), ("unverified",))
    observed = gen.CharacterizationScenario("C", "F", ("observed",), ("action",))
    parity = gen.ParityMatrixProjection((row,) if populated else ())
    characterization = gen.RuntimeCharacterizationProjection(
        (observed,) if populated else ()
    )
    with pytest.raises(gen.GenerationError, match="configured v2"):
        gen.assemble_scenarios(feature, parity, characterization)
    assert feature.then == ("t",)
    assert parity.rows == ((row,) if populated else ())


@pytest.mark.parametrize(
    "document",
    [
        {},
        {"feature_ref": "F", "title": "Behavior"},
        {"approved": True, "$schema": gen.SCHEMA_SELF_REF},
    ],
)
def test_build_document_refuses_without_schema_or_output(
    mem_fs_path: Path, document: dict[str, object]
) -> None:
    """Reject dict placeholder authority at a memory Path; return None unchanged."""
    before = gen.format_document(document)
    with pytest.raises(gen.GenerationError, match="--check is not --dry-run"):
        gen.build_document(document, {"rows": []}, {"scenarios": []}, root=mem_fs_path)
    assert gen.format_document(document) == before
    assert list(mem_fs_path.iterdir()) == []


@pytest.mark.parametrize(
    ("value", "attribute"),
    [
        (gen.FeatureContractProjection("F", "Behavior"), "title"),
        (gen.ParityRow("P", "F"), "feature_ref"),
        (gen.ParityMatrixProjection(), "rows"),
        (gen.CharacterizationScenario("C", "F"), "feature_ref"),
        (gen.RuntimeCharacterizationProjection(), "scenarios"),
    ],
)
def test_historical_carriers_remain_frozen(value: object, attribute: str) -> None:
    """Keep object carriers immutable; str attribute assignment must fail.

    Returns None; FrozenInstanceError is expected and no mutation succeeds.
    """
    with pytest.raises(FrozenInstanceError):
        setattr(value, attribute, "changed")


@pytest.mark.parametrize(
    ("parity", "observation"), [(None, None), ("P", None), (None, "C"), ("P", "C")]
)
def test_historical_identifier_remains_deterministic(
    parity: str | None, observation: str | None
) -> None:
    """Preserve stable optional-reference hashing; return None without effects."""
    first = gen.derive_scenario_id("F", parity, observation)
    assert first == gen.derive_scenario_id("F", parity, observation)
    assert first != gen.derive_scenario_id("other", parity, observation)
    assert first.startswith("scn-") and len(first) == 20
    # The historical identifier retains its lowercase hexadecimal alphabet.
    assert all(character in "0123456789abcdef" for character in first[4:])


def test_digest_preserves_key_order_independence_and_content_sensitivity() -> None:
    """Retain raw Unicode digest role/order semantics; return None without effects."""
    first: dict[str, object] = {"title": "Café", "feature_ref": "F"}
    reordered: dict[str, object] = {"feature_ref": "F", "title": "Café"}
    parity: dict[str, object] = {"rows": []}
    baseline = gen.compute_source_digest(first, parity, {})
    assert baseline == gen.compute_source_digest(reordered, parity, {})
    assert baseline != gen.compute_source_digest({"title": "Changed"}, parity, {})
    assert baseline != gen.compute_source_digest(parity, first, {})
    assert len(baseline) == 64 and baseline == baseline.lower()
    assert first == {"title": "Café", "feature_ref": "F"}


def test_formatter_preserves_exact_unicode_order_and_single_lf() -> None:
    """Retain exact safe serialization bytes; return None without authority or I/O."""
    document: dict[str, object] = {"z": "Café", "a": ["given", "when", "then"]}
    formatted = gen.format_document(document)
    assert (
        formatted == '{\n  "a": [\n    "given",\n    "when",\n    "then"\n  ],'
        '\n  "z": "Café"\n}\n'
    )
    assert formatted == gen.format_document(document)
    assert not formatted.endswith("\n\n")


def test_serialization_errors_remain_explicit() -> None:
    """Retain TypeError for non-JSON values; return None without partial output."""
    with pytest.raises(TypeError):
        gen.format_document({"invalid": object()})
    with pytest.raises(TypeError):
        gen.compute_source_digest({"invalid": object()}, {}, {})


def test_cli_collect_input_paths_sorted() -> None:
    """Retain sorted POSIX path values and duplicates; return None without I/O."""
    result = gen.collect_input_paths(["z/last.json", "a/first.json", "m/mid.json"])
    assert [path.as_posix() for path in result] == [
        "a/first.json",
        "m/mid.json",
        "z/last.json",
    ]
    assert gen.collect_input_paths([Path("z"), Path("a"), Path("a")]) == [
        Path("a"),
        Path("a"),
        Path("z"),
    ]
    assert gen.collect_input_paths([]) == []


def test_compatibility_values_remain_domain_neutral() -> None:
    """Check retained public value labels for domain terms; return None, no I/O."""
    # Compare declared carrier field names without producing acceptance artifacts.
    names = " ".join(field.name for field in fields(gen.FeatureContractProjection))
    names += gen.GENERATOR_ID + gen.SCHEMA_SELF_REF
    # Keep legacy neutrality without synthesizing a scenario document.
    for prohibited in (
        "taskmaster",
        "tmw",
        "outlook",
        "vsto",
        "email",
        "task-management",
    ):
        assert prohibited not in names.lower()


def test_cli_parse_args_defaults_and_flags() -> None:
    """Retain inspection-only metadata with no generation claim; return None."""
    base = [
        "--feature-contract",
        "f",
        "--parity-matrix",
        "p",
        "--runtime-characterization",
        "c",
    ]
    defaults = gen.parse_args(base)
    flagged = gen.parse_args([*base, "--output", "out.json", "--check"])
    assert defaults.feature_contract == "f"
    assert defaults.parity_matrix == "p"
    assert defaults.runtime_characterization == "c"
    assert defaults.output is None and defaults.check is False
    assert flagged.output == "out.json" and flagged.check is True


def test_legacy_argument_inspection_uses_process_arguments(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Patch argv through MonkeyPatch; return None with automatic restoration."""
    monkeypatch.setattr(
        "sys.argv",
        [
            "legacy",
            "--feature-contract",
            "f",
            "--parity-matrix",
            "p",
            "--runtime-characterization",
            "c",
        ],
    )
    assert gen.parse_args().feature_contract == "f"


@pytest.mark.parametrize("exit_code", [0, 1, 2, 3])
@pytest.mark.parametrize(
    "argv", [None, [], ["--workspace-root", "workspace", "--write", "--dry-run"]]
)
def test_main_forwards_exact_command_arguments_and_exit(
    monkeypatch: pytest.MonkeyPatch, argv: Sequence[str] | None, exit_code: int
) -> None:
    """Use MonkeyPatch and str Sequence/None to prove exact int status forwarding.

    Returns None; only a local call log changes and the fake performs no I/O.
    """
    calls: list[tuple[str, Sequence[str] | None]] = []

    def installed(command: str, arguments: Sequence[str] | None = None) -> int:
        """Record str command/optional Sequence, return fixed int; log-only effect."""
        calls.append((command, arguments))
        return exit_code

    monkeypatch.setattr(gen, "run_installed_cli", installed)
    assert gen.main(argv) == exit_code
    assert calls == [("generate-acceptance-scenarios", argv)]
    assert calls[0][1] is argv


@pytest.mark.parametrize(
    "argv",
    [
        ["--feature-contract", "missing.json"],
        ["--parity-matrix", "malformed.json"],
        ["--runtime-characterization", "not-object.json"],
        ["--output", "unrestricted.json"],
        ["--check"],
        ["--check", "--output", "existing.json"],
        [
            "--feature-contract",
            "f",
            "--parity-matrix",
            "p",
            "--runtime-characterization",
            "c",
        ],
    ],
)
def test_legacy_generation_arguments_fail_without_effects(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str], argv: list[str]
) -> None:
    """Reject list[str] legacy arguments before I/O using memory Path/capture.

    Returns None; existing memory bytes stay unchanged and exit2 is explicit.
    """
    existing = mem_fs_path / "existing.json"
    existing.write_text("unchanged\n", encoding="utf-8")
    assert gen.main(argv) == 2
    captured = capsys.readouterr()
    result = json.loads(captured.out)
    assert result["ok"] is False and result["exit_code"] == 2
    assert result["runtime"] is None and result["artifacts"] == []
    assert "CLI_ARGUMENTS" in captured.out
    assert captured.err == "Discovery command failed; inspect the JSON findings.\n"
    assert existing.read_text(encoding="utf-8") == "unchanged\n"
    assert list(mem_fs_path.iterdir()) == [existing]
