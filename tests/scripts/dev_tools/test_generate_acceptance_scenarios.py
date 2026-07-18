"""Unit tests for the deterministic acceptance-scenario generator.

Covers positive generation, determinism, negative/malformed input, the
schema-location seam, the CLI surface, and the domain-neutrality invariant. No
temporary files are used; the in-memory ``mem_fs_path`` fixture from
``tests/conftest.py`` backs all read/write. Each test uses Arrange-Act-Assert.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

import pytest

from scripts.dev_tools import generate_acceptance_scenarios as gen

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping


def _feature_doc(
    *,
    feature_ref: str = "F-001",
    title: str = "Preserve source behavior",
    given: list[str] | None = None,
    when: list[str] | None = None,
    then: list[str] | None = None,
) -> dict[str, Any]:
    return {
        "feature_ref": feature_ref,
        "title": title,
        "given": given if given is not None else ["a configured environment"],
        "when": when if when is not None else ["the operation runs"],
        "then": then if then is not None else ["the result is produced"],
        "evidence_refs": ["ev-feat"],
    }


def _parity_doc(rows: list[dict[str, Any]] | None = None) -> dict[str, Any]:
    if rows is None:
        rows = [
            {
                "parity_ref": "P-001",
                "feature_ref": "F-001",
                "then": ["target matches source"],
                "evidence_refs": ["ev-parity"],
            }
        ]
    return {"rows": rows}


def _characterization_doc(
    scenarios: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    if scenarios is None:
        scenarios = [
            {
                "characterization_ref": "C-001",
                "feature_ref": "F-001",
                "given": ["observed precondition"],
                "when": ["observed action"],
                "evidence_refs": ["ev-char"],
            }
        ]
    return {"scenarios": scenarios}


def _write_json(path: Path, document: Mapping[str, Any]) -> None:
    path.write_text(json.dumps(document), encoding="utf-8")


def _cli_args(feature: Path, parity: Path, characterization: Path) -> list[str]:
    return [
        "--feature-contract",
        str(feature),
        "--parity-matrix",
        str(parity),
        "--runtime-characterization",
        str(characterization),
    ]


def _seed_inputs(root: Path) -> tuple[Path, Path, Path]:
    feature = root / "feature.json"
    parity = root / "parity.json"
    characterization = root / "characterization.json"
    _write_json(feature, _feature_doc())
    _write_json(parity, _parity_doc())
    _write_json(characterization, _characterization_doc())
    return feature, parity, characterization


def _out_args(
    paths: tuple[Path, Path, Path], output: Path, *, check: bool
) -> list[str]:
    argv = _cli_args(*paths) + ["--output", str(output)]
    return [*argv, "--check"] if check else argv


def test_seam_raises_naming_convention_when_tree_absent(mem_fs_path: Path) -> None:
    with pytest.raises(FileNotFoundError) as exc_info:
        gen.resolve_discovery_schema("feature-contract", root=mem_fs_path)
    message = str(exc_info.value)
    assert "schemas/v" in message
    assert "feature-contract" in message


def test_seam_keyword_only_parameters() -> None:
    with pytest.raises(TypeError):
        gen.resolve_discovery_schema("feature-contract", Path("/x"))  # type: ignore[misc]


def test_seam_downstream_calls_resolver(monkeypatch: pytest.MonkeyPatch) -> None:
    sentinel = Path("schemas/v9/acceptance-scenario-set.schema.json")
    calls: list[str] = []

    def _fake_resolver(schema_name: str, *, root: Path, version: str | None = None):
        calls.append(schema_name)
        return sentinel

    monkeypatch.setattr(gen, "resolve_discovery_schema", _fake_resolver)
    result = gen.resolve_schema_self_ref(Path("/repo"))
    assert calls == ["acceptance-scenario-set"]
    assert result == sentinel.as_posix()


def test_seam_falls_back_to_convention_when_absent(mem_fs_path: Path) -> None:
    result = gen.resolve_schema_self_ref(mem_fs_path)
    assert result == gen.SCHEMA_SELF_REF
    assert "schemas/v" in result


def test_seam_returns_path_when_schema_present(mem_fs_path: Path) -> None:
    schema = mem_fs_path / "schemas" / "v1" / "feature-contract.schema.json"
    schema.parent.mkdir(parents=True, exist_ok=True)
    schema.write_text("{}", encoding="utf-8")
    result = gen.resolve_discovery_schema("feature-contract", root=mem_fs_path)
    assert result == schema


def test_projection_feature_contract_positive() -> None:
    doc = _feature_doc(given=["g1"], when=["w1"], then=["t1"])
    projection = gen.project_feature_contract(doc)
    assert projection.feature_ref == "F-001"
    assert projection.title == "Preserve source behavior"
    assert projection.given == ("g1",)
    assert projection.when == ("w1",)
    assert projection.then == ("t1",)


def test_projection_parity_matrix_positive() -> None:
    doc = _parity_doc(
        rows=[
            {"parity_ref": "P-1", "feature_ref": "F-001", "then": ["ok"]},
            {"parity_ref": "P-2", "feature_ref": "F-002"},
        ]
    )
    projection = gen.project_parity_matrix(doc)
    assert [row.parity_ref for row in projection.rows] == ["P-1", "P-2"]
    assert projection.rows[0].then == ("ok",)
    assert projection.rows[1].then == ()


def test_projection_runtime_characterization_positive() -> None:
    doc = _characterization_doc(
        scenarios=[
            {
                "characterization_ref": "C-1",
                "feature_ref": "F-001",
                "given": ["pre"],
                "when": ["act"],
            }
        ]
    )
    projection = gen.project_runtime_characterization(doc)
    assert projection.scenarios[0].characterization_ref == "C-1"
    assert projection.scenarios[0].given == ("pre",)
    assert projection.scenarios[0].when == ("act",)


def test_projection_non_list_string_field_ignored() -> None:
    projection = gen.project_feature_contract(
        {"feature_ref": "F", "title": "T", "given": "not-a-list"}
    )
    assert projection.given == ()


@pytest.mark.parametrize(
    ("call", "document", "expected"),
    [
        (gen.project_parity_matrix, {"rows": {}}, "must be an array"),
        (gen.project_parity_matrix, {"rows": [1]}, "must be an object"),
        (gen.project_runtime_characterization, {"scenarios": {}}, "must be an array"),
        (gen.project_runtime_characterization, {"scenarios": [1]}, "must be an object"),
    ],
)
def test_projection_structural_errors_raise(
    call: Callable[[dict[str, Any]], object],
    document: dict[str, Any],
    expected: str,
) -> None:
    with pytest.raises(gen.GenerationError) as exc_info:
        call(document)
    assert expected in str(exc_info.value)


def test_projection_adapters_ignore_unknown_fields() -> None:
    feature = _feature_doc()
    feature["future_9002_field"] = {"nested": True}
    parity = _parity_doc(
        rows=[{"parity_ref": "P-1", "feature_ref": "F-001", "extra_9002": 1}]
    )
    char = _characterization_doc(
        scenarios=[{"characterization_ref": "C-1", "feature_ref": "F-001", "x": [1]}]
    )
    fp = gen.project_feature_contract(feature)
    pp = gen.project_parity_matrix(parity)
    cp = gen.project_runtime_characterization(char)
    assert not hasattr(fp, "future_9002_field")
    assert not hasattr(pp.rows[0], "extra_9002")
    assert not hasattr(cp.scenarios[0], "x")


def test_positive_generation_maps_given_when_then(mem_fs_path: Path) -> None:
    feature = _feature_doc(given=["g0"], when=["w0"], then=["t0"])
    parity = _parity_doc(
        rows=[{"parity_ref": "P-001", "feature_ref": "F-001", "then": ["t-parity"]}]
    )
    char = _characterization_doc(
        scenarios=[
            {
                "characterization_ref": "C-001",
                "feature_ref": "F-001",
                "given": ["g-char"],
                "when": ["w-char"],
            }
        ]
    )
    document = gen.build_document(feature, parity, char, root=mem_fs_path)
    scenario = document["scenarios"][0]
    assert scenario["given"] == ["g0", "g-char"]
    assert scenario["when"] == ["w0", "w-char"]
    assert scenario["then"] == ["t0", "t-parity"]
    assert scenario["title"] == "Preserve source behavior"


def test_positive_generation_derives_stable_id(mem_fs_path: Path) -> None:
    document = gen.build_document(
        _feature_doc(), _parity_doc(), _characterization_doc(), root=mem_fs_path
    )
    scenario = document["scenarios"][0]
    assert scenario["id"] == gen.derive_scenario_id("F-001", "P-001", "C-001")
    assert scenario["id"].startswith("scn-")


def test_positive_generation_top_level_fields(mem_fs_path: Path) -> None:
    document = gen.build_document(
        _feature_doc(), _parity_doc(), _characterization_doc(), root=mem_fs_path
    )
    assert set(document) == {
        "$schema",
        "schema_version",
        "generator",
        "source_digest",
        "scenarios",
    }
    assert document["generator"] == "dev.discovery.acceptance-scenarios"


def test_positive_generation_null_refs_when_none_match(mem_fs_path: Path) -> None:
    document = gen.build_document(
        _feature_doc(), {"rows": []}, {"scenarios": []}, root=mem_fs_path
    )
    scenario = document["scenarios"][0]
    assert scenario["parity_ref"] is None
    assert scenario["characterization_ref"] is None


def test_determinism_byte_identical_repeat(mem_fs_path: Path) -> None:
    feature = _feature_doc()
    parity = _parity_doc()
    char = _characterization_doc()
    first = gen.format_document(
        gen.build_document(feature, parity, char, root=mem_fs_path)
    )
    second = gen.format_document(
        gen.build_document(feature, parity, char, root=mem_fs_path)
    )
    assert first == second
    assert first.endswith("\n")
    assert not first.endswith("\n\n")


def test_determinism_invariant_to_input_ordering(mem_fs_path: Path) -> None:
    feature = _feature_doc()
    rows = [
        {"parity_ref": "P-002", "feature_ref": "F-001", "then": ["b"]},
        {"parity_ref": "P-001", "feature_ref": "F-001", "then": ["a"]},
    ]
    scenarios = [
        {"characterization_ref": "C-002", "feature_ref": "F-001", "given": ["y"]},
        {"characterization_ref": "C-001", "feature_ref": "F-001", "given": ["x"]},
    ]
    ordered = gen.build_document(
        feature,
        {"rows": list(reversed(rows))},
        {"scenarios": list(reversed(scenarios))},
        root=mem_fs_path,
    )["scenarios"]
    shuffled = gen.build_document(
        feature, {"rows": rows}, {"scenarios": scenarios}, root=mem_fs_path
    )["scenarios"]
    assert ordered == shuffled
    keys = [
        (
            s["feature_ref"],
            s["parity_ref"] or "",
            s["characterization_ref"] or "",
            s["id"],
        )
        for s in shuffled
    ]
    assert keys == sorted(keys)


def test_determinism_source_digest_stable(mem_fs_path: Path) -> None:
    feature = _feature_doc()
    parity = _parity_doc()
    char = _characterization_doc()
    baseline = gen.build_document(feature, parity, char, root=mem_fs_path)
    repeat = gen.build_document(feature, parity, char, root=mem_fs_path)
    changed = gen.build_document(
        _feature_doc(title="Different"), parity, char, root=mem_fs_path
    )
    assert baseline["source_digest"] == repeat["source_digest"]
    assert baseline["source_digest"] != changed["source_digest"]
    digest = baseline["source_digest"]
    assert len(digest) == 64 and digest == digest.lower()


def test_domain_neutrality_module_source_and_output_fields(mem_fs_path: Path) -> None:
    prohibited = ["taskmaster", "tmw", "outlook", "vsto", "email", "task-management"]
    module_source = Path(gen.__file__).read_text(encoding="utf-8").lower()
    document = gen.build_document(
        _feature_doc(), _parity_doc(), _characterization_doc(), root=mem_fs_path
    )

    def _field_names(obj: object) -> list[str]:
        names: list[str] = []
        if isinstance(obj, dict):
            for key, value in cast("dict[str, object]", obj).items():
                names.append(str(key))
                names.extend(_field_names(value))
        elif isinstance(obj, list):
            for item in cast("list[object]", obj):
                names.extend(_field_names(item))
        return names

    field_names = " ".join(_field_names(document)).lower()
    for token in prohibited:
        assert token not in module_source, f"module has prohibited id: {token}"
        assert token not in field_names, f"output has prohibited id: {token}"


def _mutate_missing_file(paths: tuple[Path, Path, Path], root: Path) -> list[str]:
    return _cli_args(root / "does-not-exist.json", paths[1], paths[2])


def _mutate_non_object_root(paths: tuple[Path, Path, Path], root: Path) -> list[str]:
    paths[0].write_text(json.dumps(["not", "object"]), encoding="utf-8")
    return _cli_args(*paths)


def _mutate_parse_error(paths: tuple[Path, Path, Path], root: Path) -> list[str]:
    paths[1].write_text("{not valid json", encoding="utf-8")
    return _cli_args(*paths)


def _mutate_missing_field(paths: tuple[Path, Path, Path], root: Path) -> list[str]:
    paths[0].write_text(json.dumps({"title": "no ref"}), encoding="utf-8")
    return _cli_args(*paths)


@pytest.mark.parametrize(
    ("mutate", "expected"),
    [
        (_mutate_missing_file, "not found"),
        (_mutate_non_object_root, "root must be an object"),
        (_mutate_parse_error, "invalid JSON"),
        (_mutate_missing_field, "feature_ref"),
    ],
)
def test_negative_inputs_return_one_with_message(
    mem_fs_path: Path,
    capsys: pytest.CaptureFixture[str],
    mutate: Callable[[tuple[Path, Path, Path], Path], list[str]],
    expected: str,
) -> None:
    seeded = _seed_inputs(mem_fs_path)
    exit_code = gen.main(mutate(seeded, mem_fs_path))
    assert exit_code == 1
    assert expected in capsys.readouterr().err


def test_cli_parse_args_defaults_and_flags() -> None:
    base = ["--feature-contract", "f", "--parity-matrix", "p"]
    base = [*base, "--runtime-characterization", "c"]
    defaults = gen.parse_args(base)
    flagged = gen.parse_args([*base, "--output", "out.json", "--check"])
    assert defaults.feature_contract == "f"
    assert defaults.parity_matrix == "p"
    assert defaults.runtime_characterization == "c"
    assert defaults.output is None and defaults.check is False
    assert flagged.output == "out.json" and flagged.check is True


def test_cli_collect_input_paths_sorted() -> None:
    result = gen.collect_input_paths(["z/last.json", "a/first.json", "m/mid.json"])
    assert [p.as_posix() for p in result] == [
        "a/first.json",
        "m/mid.json",
        "z/last.json",
    ]


def test_cli_main_success_writes_output(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    paths = _seed_inputs(mem_fs_path)
    output = mem_fs_path / "scenarios.json"
    exit_code = gen.main(_out_args(paths, output, check=False))
    assert exit_code == 0
    assert "wrote" in capsys.readouterr().out
    expected = gen.format_document(
        gen.build_document(
            _feature_doc(), _parity_doc(), _characterization_doc(), root=mem_fs_path
        )
    )
    assert output.read_text(encoding="utf-8") == expected


def test_cli_main_success_stdout(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    paths = _seed_inputs(mem_fs_path)
    exit_code = gen.main(_cli_args(*paths))
    out = capsys.readouterr().out
    assert exit_code == 0
    assert '"generator": "dev.discovery.acceptance-scenarios"' in out


def test_cli_check_matches(mem_fs_path: Path) -> None:
    paths = _seed_inputs(mem_fs_path)
    output = mem_fs_path / "scenarios.json"
    assert gen.main(_out_args(paths, output, check=False)) == 0
    assert gen.main(_out_args(paths, output, check=True)) == 0


def test_cli_check_mismatch(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    paths = _seed_inputs(mem_fs_path)
    output = mem_fs_path / "scenarios.json"
    output.write_text("{}\n", encoding="utf-8")
    exit_code = gen.main(_out_args(paths, output, check=True))
    assert exit_code == 1
    assert "mismatch" in capsys.readouterr().err


def test_cli_check_requires_output(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    paths = _seed_inputs(mem_fs_path)
    exit_code = gen.main(_cli_args(*paths) + ["--check"])
    assert exit_code == 1
    assert "--check requires --output" in capsys.readouterr().err


def test_cli_check_target_absent(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    paths = _seed_inputs(mem_fs_path)
    output = mem_fs_path / "absent.json"
    exit_code = gen.main(_out_args(paths, output, check=True))
    assert exit_code == 1
    assert "does not exist" in capsys.readouterr().err
