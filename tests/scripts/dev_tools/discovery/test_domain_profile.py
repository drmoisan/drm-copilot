"""Unit tests for the discovery domain-profile loader.

Covers the pure parser (``parse_domain_profile_text``), the dataclass
``__post_init__`` invariants, the ``load_domain_profile`` I/O wrapper, and the
domain-neutrality contract. All parser tests feed inline YAML strings; the I/O
tests use the in-memory ``mem_fs_path`` fixture. No temporary files are used.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools.discovery import domain_profile as dp_module
from scripts.dev_tools.discovery import domain_profile_models as models_module
from scripts.dev_tools.discovery import profile_cli as cli_module
from scripts.dev_tools.discovery.domain_profile import (
    DEFAULT_PROFILE_FILENAME,
    DomainProfileError,
    load_domain_profile,
    parse_domain_profile_text,
)
from scripts.dev_tools.discovery.domain_profile_models import (
    ArtifactsConfig,
    DomainProfile,
    LegacySourceConfig,
    TargetConfig,
    TechnologyStackConfig,
)

# A valid minimal profile (required fields only), in YAML flow style.
VALID_MINIMAL = (
    "profile_version: 1\n"
    "legacy_source: {root: ../Legacy}\n"
    "target: {root: ../Target}\n"
    "technology_stack: {legacy: [csharp]}\n"
    "artifacts: {root: discovery/}\n"
)

# A valid profile with every optional field present.
VALID_FULL = (
    "profile_version: 1\n"
    "profile_name: my-migration\n"
    "legacy_source:\n"
    "  root: ../Legacy\n"
    "  description: legacy checkout\n"
    "  include: [src/**]\n"
    "  exclude: ['**/bin/**']\n"
    "target:\n"
    "  root: ../Target\n"
    "  description: target checkout\n"
    "technology_stack:\n"
    "  legacy: [csharp]\n"
    "  target: [typescript]\n"
    "artifacts:\n"
    "  root: discovery/\n"
    "  conventions:\n"
    "    feature-contract: contracts/\n"
    "    coverage-ledger: coverage.json\n"
)


def test_default_profile_filename_constant() -> None:
    """The default filename constant matches the documented contract value."""
    assert DEFAULT_PROFILE_FILENAME == "discovery-profile.yaml"


def test_domain_profile_error_is_value_error() -> None:
    """``DomainProfileError`` is a catchable subclass of ``ValueError``."""
    assert issubclass(DomainProfileError, ValueError)


def test_parse_full_profile_populates_every_field() -> None:
    """A full profile with all optional fields parses into a frozen profile."""
    # Arrange / Act
    profile = parse_domain_profile_text(VALID_FULL)

    # Assert
    assert isinstance(profile, DomainProfile)
    assert profile.profile_version == 1
    assert profile.profile_name == "my-migration"
    assert profile.legacy_source.root == "../Legacy"
    assert profile.legacy_source.description == "legacy checkout"
    assert profile.legacy_source.include == ("src/**",)
    assert profile.legacy_source.exclude == ("**/bin/**",)
    assert profile.target.root == "../Target"
    assert profile.target.description == "target checkout"
    assert profile.technology_stack.legacy == ("csharp",)
    assert profile.technology_stack.target == ("typescript",)
    assert profile.artifacts.root == "discovery/"
    assert profile.artifacts.conventions_map == {
        "feature-contract": "contracts/",
        "coverage-ledger": "coverage.json",
    }


def test_parse_minimal_profile_applies_every_default() -> None:
    """A minimal profile resolves each omitted optional field to its default."""
    # Arrange / Act
    profile = parse_domain_profile_text(VALID_MINIMAL)

    # Assert each applied default explicitly.
    assert profile.profile_name is None
    assert profile.legacy_source.description is None
    assert profile.legacy_source.include == ()
    assert profile.legacy_source.exclude == ()
    assert profile.target.description is None
    assert profile.technology_stack.target == ()
    assert profile.artifacts.conventions_map == {}


def test_parse_records_source_label_in_error() -> None:
    """A provided source label appears in the raised error message."""
    with pytest.raises(DomainProfileError) as exc_info:
        parse_domain_profile_text("profile_version: 1\n", source="my-profile.yaml")
    assert "my-profile.yaml" in str(exc_info.value)


# Negative matrix: (yaml text, expected message fragment). Each case raises a
# single ``DomainProfileError`` whose message contains the fragment.
_NEGATIVE_CASES: list[tuple[str, str, str]] = [
    (
        "missing_profile_version",
        "legacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "profile_version: required field is missing",
    ),
    (
        "missing_legacy_source",
        "profile_version: 1\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source: required field is missing",
    ),
    (
        "missing_legacy_source_root",
        "profile_version: 1\nlegacy_source: {description: x}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source.root: required field is missing",
    ),
    (
        "missing_target_root",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {description: x}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "target.root: required field is missing",
    ),
    (
        "missing_technology_stack_legacy",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {target: [c]}\nartifacts: {root: d}\n",
        "technology_stack.legacy: required field is missing",
    ),
    (
        "missing_artifacts_root",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {conventions: {}}\n",
        "artifacts.root: required field is missing",
    ),
    (
        "include_string_where_list",
        "profile_version: 1\nlegacy_source: {root: a, include: src}\n"
        "target: {root: b}\ntechnology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source.include: expected a list of non-empty strings, got str",
    ),
    (
        "root_list_where_string",
        "profile_version: 1\nlegacy_source: {root: [a]}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source.root: expected non-empty string, got list",
    ),
    (
        "profile_version_string",
        "profile_version: '1'\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "profile_version: expected integer 1, got str",
    ),
    (
        "non_mapping_section",
        "profile_version: 1\nlegacy_source: not-a-map\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source: expected a mapping, got str",
    ),
    (
        "empty_string_root",
        "profile_version: 1\nlegacy_source: {root: ''}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source.root: expected non-empty string, got empty string",
    ),
    (
        "empty_legacy_list",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: []}\nartifacts: {root: d}\n",
        "technology_stack.legacy: expected a non-empty list, got empty list",
    ),
    (
        "unsupported_profile_version",
        "profile_version: 2\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "profile_version: unsupported profile_version 2",
    ),
    (
        "unknown_top_level_key",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\nbogus: x\n",
        "bogus: unknown key",
    ),
    (
        "unknown_key_legacy_source",
        "profile_version: 1\nlegacy_source: {root: a, bogus: x}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source.bogus: unknown key",
    ),
    (
        "unknown_key_target",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b, bogus: x}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "target.bogus: unknown key",
    ),
    (
        "unknown_key_technology_stack",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c], bogus: x}\nartifacts: {root: d}\n",
        "technology_stack.bogus: unknown key",
    ),
    (
        "unknown_key_artifacts",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d, bogus: x}\n",
        "artifacts.bogus: unknown key",
    ),
    (
        "convention_non_string_value",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\n"
        "artifacts: {root: d, conventions: {feature-contract: 5}}\n",
        "artifacts.conventions.feature-contract: expected non-empty string, got int",
    ),
    (
        "non_mapping_document",
        "just a scalar string\n",
        "expected a mapping at the top level, got str",
    ),
    (
        "optional_field_wrong_type",
        "profile_version: 1\nprofile_name: 5\nlegacy_source: {root: a}\n"
        "target: {root: b}\ntechnology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "profile_name: expected string, got int",
    ),
    (
        "list_element_wrong_type",
        "profile_version: 1\nlegacy_source: {root: a, include: [5]}\n"
        "target: {root: b}\ntechnology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source.include[0]: expected non-empty string, got int",
    ),
    (
        "non_string_section_key",
        "profile_version: 1\nlegacy_source: {1: a, root: b}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "legacy_source: mapping keys must be strings, got int",
    ),
    (
        "convention_non_string_key",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\n"
        "artifacts: {root: d, conventions: {1: contracts/}}\n",
        "artifacts.conventions: convention keys must be non-empty strings, got int",
    ),
    (
        "non_string_top_level_key",
        "1: x\nprofile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\nartifacts: {root: d}\n",
        "top-level keys must be strings, got int",
    ),
    (
        "convention_empty_key",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\n"
        "artifacts: {root: d, conventions: {'   ': contracts/}}\n",
        "artifacts.conventions: convention keys must be non-empty strings",
    ),
    (
        "conventions_non_mapping",
        "profile_version: 1\nlegacy_source: {root: a}\ntarget: {root: b}\n"
        "technology_stack: {legacy: [c]}\n"
        "artifacts: {root: d, conventions: not-a-map}\n",
        "artifacts.conventions: expected a mapping, got str",
    ),
]


@pytest.mark.parametrize(
    ("text", "expected_fragment"),
    [(text, fragment) for _, text, fragment in _NEGATIVE_CASES],
    ids=[case_id for case_id, _, _ in _NEGATIVE_CASES],
)
def test_parse_invalid_profile_raises(text: str, expected_fragment: str) -> None:
    """Each malformed profile raises ``DomainProfileError`` with the expected path."""
    with pytest.raises(DomainProfileError) as exc_info:
        parse_domain_profile_text(text)
    assert expected_fragment in str(exc_info.value)


def test_parse_malformed_yaml_syntax_reports_source_label() -> None:
    """A YAML syntax error is wrapped with the source label."""
    # Unbalanced flow mapping is a YAML syntax error.
    with pytest.raises(DomainProfileError) as exc_info:
        parse_domain_profile_text("legacy_source: {root: a\n", source="broken.yaml")
    message = str(exc_info.value)
    assert "broken.yaml" in message
    assert "YAML syntax error" in message


def test_parse_empty_document_raises() -> None:
    """An empty document raises a specific ``DomainProfileError``."""
    with pytest.raises(DomainProfileError) as exc_info:
        parse_domain_profile_text("\n")
    assert "profile document is empty" in str(exc_info.value)


def test_parse_collects_multiple_defects_in_single_error() -> None:
    """One invalid profile with three defects raises a single enumerated error."""
    # Arrange: three independent defects across three sections.
    text = (
        "profile_version: 2\n"
        "legacy_source: {root: 7}\n"
        "target: {root: b}\n"
        "technology_stack: {legacy: []}\n"
        "artifacts: {root: d}\n"
    )

    # Act
    with pytest.raises(DomainProfileError) as exc_info:
        parse_domain_profile_text(text)

    # Assert all three dotted paths appear in the single message.
    message = str(exc_info.value)
    assert "profile_version: unsupported profile_version 2" in message
    assert "legacy_source.root: expected non-empty string, got int" in message
    assert (
        "technology_stack.legacy: expected a non-empty list, got empty list" in message
    )


def test_construct_legacy_source_empty_root_raises() -> None:
    """Direct construction with an empty ``root`` raises ``DomainProfileError``."""
    with pytest.raises(DomainProfileError):
        LegacySourceConfig(root="  ")


def test_construct_target_empty_root_raises() -> None:
    """Direct construction with an empty target ``root`` raises."""
    with pytest.raises(DomainProfileError):
        TargetConfig(root="")


def test_construct_technology_stack_empty_legacy_raises() -> None:
    """Direct construction with an empty ``legacy`` tuple raises."""
    with pytest.raises(DomainProfileError):
        TechnologyStackConfig(legacy=())


def test_construct_artifacts_empty_root_raises() -> None:
    """Direct construction with an empty artifacts ``root`` raises."""
    with pytest.raises(DomainProfileError):
        ArtifactsConfig(root="")


def test_construct_artifacts_empty_convention_key_raises() -> None:
    """Direct construction with an empty convention key raises."""
    with pytest.raises(DomainProfileError):
        ArtifactsConfig(root="d", conventions=(("", "value"),))


def test_construct_domain_profile_wrong_version_raises() -> None:
    """Direct construction with ``profile_version`` other than 1 raises."""
    with pytest.raises(DomainProfileError):
        DomainProfile(
            profile_version=2,
            legacy_source=LegacySourceConfig(root="a"),
            target=TargetConfig(root="b"),
            technology_stack=TechnologyStackConfig(legacy=("c",)),
            artifacts=ArtifactsConfig(root="d"),
        )


def test_load_domain_profile_happy_path(mem_fs_path: Path) -> None:
    """``load_domain_profile`` reads and parses a profile from the filesystem."""
    # Arrange
    profile_path = mem_fs_path / DEFAULT_PROFILE_FILENAME
    profile_path.write_text(VALID_MINIMAL, encoding="utf-8")

    # Act
    profile = load_domain_profile(profile_path)

    # Assert
    assert isinstance(profile, DomainProfile)
    assert profile.legacy_source.root == "../Legacy"


def test_load_domain_profile_missing_file_names_path(mem_fs_path: Path) -> None:
    """A missing file raises ``DomainProfileError`` naming the path."""
    # Arrange
    missing = mem_fs_path / "absent-profile.yaml"

    # Act / Assert
    with pytest.raises(DomainProfileError) as exc_info:
        load_domain_profile(missing)
    assert "absent-profile.yaml" in str(exc_info.value)


def test_load_domain_profile_unreadable_path_raises(mem_fs_path: Path) -> None:
    """A non-``FileNotFoundError`` OS error is wrapped as ``DomainProfileError``.

    Reading a directory path raises ``IsADirectoryError`` (an ``OSError`` that
    is not ``FileNotFoundError``), exercising the generic OS-error branch.
    """
    # Arrange: the fixture root is an existing directory, not a file.
    directory_path = mem_fs_path

    # Act / Assert
    with pytest.raises(DomainProfileError) as exc_info:
        load_domain_profile(directory_path)
    assert "could not read domain profile" in str(exc_info.value)


_BANNED_SUBSTRINGS = (
    "taskmaster",
    "tmw",
    "outlook",
    "vsto",
    "email",
    "task-management",
)


@pytest.mark.parametrize(
    "module",
    [dp_module, models_module, cli_module],
    ids=["domain_profile", "domain_profile_models", "profile_cli"],
)
def test_production_modules_are_domain_neutral(module: object) -> None:
    """Production module sources contain no banned domain-specific substrings."""
    # Arrange
    source_file = getattr(module, "__file__", None)
    assert source_file is not None
    source = Path(source_file).read_text(encoding="utf-8").lower()

    # Assert
    for banned in _BANNED_SUBSTRINGS:
        assert (
            banned not in source
        ), f"banned substring {banned!r} found in {source_file}"
