"""Protect the shared development baseline and preserved platform compatibility."""

import json
import re
from pathlib import Path
from typing import cast

import pytest


def _text(path: str) -> str:
    """Read a repository-relative committed input as UTF-8; propagate read errors."""
    return (Path(__file__).resolve().parents[3] / path).read_text(encoding="utf-8")


def _minimums() -> dict[str, str]:
    """Return the manifest minimum map after the independently tested shape contract."""
    manifest = cast(
        "dict[str, object]", json.loads(_text("scripts/host-tools.manifest.json"))
    )
    return cast("dict[str, str]", manifest["minimumVersions"])


def test_host_manifest_selects_current_runtime_and_module_minimums() -> None:
    """Host bootstrap consumes the selected minima without unrelated app installs."""
    assert _minimums() == {
        "node": "26.13.0",
        "poetry": "2.5.1",
        "pwsh": "7.6.9",
        "python": "3.13.18",
    }
    manifest = json.loads(_text("scripts/host-tools.manifest.json"))
    assert manifest["powershellModules"] == [
        {"minimumVersion": "6.2.0", "name": "Pester"},
        {"minimumVersion": "1.25.0", "name": "PSScriptAnalyzer"},
    ]


@pytest.mark.parametrize("environment", ["local", "codespaces"])
def test_container_installations_match_managed_host_minimums(environment: str) -> None:
    """Both images retain the pinned base runtime and the selected current tools."""
    source = _text(f".devcontainer/{environment}/Dockerfile")
    arguments = dict(re.findall(r"^ARG ([A-Z_]+)=(\S+)$", source, re.MULTILINE))
    minimums = _minimums()

    assert arguments["NODE_VERSION"] == minimums["node"]
    assert arguments["POWERSHELL_VERSION"] == minimums["pwsh"]
    assert tuple(map(int, arguments["POETRY_VERSION"].split("."))) >= tuple(
        map(int, minimums["poetry"].split("."))
    )
    assert 'pipx install "poetry==${POETRY_VERSION}"' in source
    assert (
        source.count("FROM mcr.microsoft.com/devcontainers/python:3.3.2-3.13-bookworm")
        == 2
    )
    assert 'test "$(python --version)" = "Python 3.13.18"' in source
    assert "COPY --from=python-runtime" not in source
    assert 'PATH="/usr/local/bin:' in source
    assert arguments["SHFMT_VERSION"] == "3.14.1"
    assert arguments["SHELLCHECK_VERSION"] == "0.11.0"
    assert arguments["ACTIONLINT_VERSION"] == "1.7.12"
    expected = {
        "GIT_VERSION": "2.56.0",
        "POETRY_VERSION": "2.5.1",
        "GH_VERSION": "2.103.3",
        "DOTNET_SDK_VERSION": "10.0.403",
        "PESTER_VERSION": "6.2.0",
        "PSSA_VERSION": "1.25.0",
        "UV_VERSION": "0.13.7",
        "CLAUDE_CODE_VERSION": "2.1.318",
        "CLAUDE_SWAP_VERSION": "0.29.0",
        "CODEX_VERSION": "0.166.0",
    }
    assert {key: arguments[key] for key in expected} == expected
    assert (
        'npm install -g --include=optional "@openai/codex@${CODEX_VERSION}"' in source
    )
    assert 'cli_auth_credentials_store = "file"' in source
    assert "PYTHONPYCACHEPREFIX=/tmp/pycache" in source


@pytest.mark.parametrize(
    ("tool", "version"),
    [
        ("node", "26.13.0"),
        ("npm", "11.20.0"),
        ("pwsh", "7.6.9"),
        ("poetry", "2.5.1"),
        ("gh", "2.103.3"),
        ("dotnet", "10.0.403"),
        ("uv", "0.13.7"),
        ("claude", "2.1.318"),
        ("cswap", "0.29.0"),
        ("codex", "0.166.0"),
        ("pester", "6.2.0"),
        ("pssa", "1.25.0"),
        ("gt", "1.7.14"),
        ("copilot", "0.0.377"),
        ("kcov", "43"),
        ("shfmt", "3.14.1"),
        ("shellcheck", "0.11.0"),
        ("actionlint", "1.7.12"),
    ],
)
def test_shared_predicate_declares_each_selected_pin(tool: str, version: str) -> None:
    """A pinned CLI cannot drift independently from the declared container baseline."""
    source = _text("scripts/bash/container_versions.sh")
    match = re.search(rf"\b{tool}\)\s*expected=([0-9.]+)", source)
    assert match is not None, f"Missing {tool} pin in the shared predicate"
    assert match.group(1) == version


def test_verifier_uses_repository_relative_predicate_and_selected_configuration() -> (
    None
):
    """Resolve verification inputs and select the actual config subdirectory."""
    source = _text(".devcontainer/verify-container.sh")
    assert 'source "$REPO_ROOT/scripts/bash/container_versions.sh"' in source
    assert '"$REPO_ROOT/.devcontainer/$config/devcontainer.json"' in source
    assert (
        "for tool in python git node npm pwsh poetry gh dotnet uv claude cswap codex "
        "shfmt shellcheck actionlint gt copilot kcov pester pssa" in source
    )
    assert "container_tool_version_supported python" in source


def test_local_workspace_uses_live_source_and_isolated_linux_dependencies() -> None:
    """Local source stays current while dependency mounts never copy host packages."""
    config = cast(
        "dict[str, object]", json.loads(_text(".devcontainer/local/devcontainer.json"))
    )
    assert config["workspaceFolder"] == "/workspaces/drm-copilot"
    assert config["workspaceMount"] == (
        "source=${localWorkspaceFolder},"
        "target=/workspaces/drm-copilot,type=bind,consistency=cached"
    )
    assert config["mounts"] == [
        "source=${localWorkspaceFolderBasename}-local-venv,target=/workspaces/drm-copilot/.venv,type=volume,volume-nocopy",
        "source=${localWorkspaceFolderBasename}-local-node-modules,target=/workspaces/drm-copilot/node_modules,type=volume,volume-nocopy",
        "source=${localWorkspaceFolderBasename}-local-extension-node-modules,target=/workspaces/drm-copilot/extensions/drm-copilot/node_modules,type=volume,volume-nocopy",
        "source=${localWorkspaceFolderBasename}-local-mcp-node-modules,target=/workspaces/drm-copilot/packages/mcp-server/node_modules,type=volume,volume-nocopy",
        "source=${localWorkspaceFolderBasename}-workspace-bg,target=/workspaces/drm-copilot-bg,type=volume",
    ]
    features = cast("dict[str, object]", config["features"])
    assert features == {
        "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {
            "version": "latest"
        }
    }
    environment = cast("dict[str, str]", config["containerEnv"])
    assert environment["GIT_CONFIG_COUNT"] == "1"
    assert environment["GIT_CONFIG_KEY_0"] == "core.fsmonitor"
    assert environment["GIT_CONFIG_VALUE_0"] == "false"


@pytest.mark.parametrize("environment", ["local", "codespaces"])
def test_containers_share_setup_and_verify_before_reporting_success(
    environment: str,
) -> None:
    """Neither environment can report setup complete before checking runtime pins."""
    config = cast(
        "dict[str, object]",
        json.loads(_text(f".devcontainer/{environment}/devcontainer.json")),
    )
    assert config["postCreateCommand"] == "bash .devcontainer/post-create.sh"
    source = _text(".devcontainer/post-create.sh")
    assert source.index("bash .devcontainer/verify-container.sh") < source.index(
        "Dev Container Setup Complete!"
    )


def test_codespaces_resources_and_image_managed_clis_are_preserved() -> None:
    """Codespaces keeps resources without floating features replacing image pins."""
    config = cast(
        "dict[str, object]",
        json.loads(_text(".devcontainer/codespaces/devcontainer.json")),
    )
    assert config["hostRequirements"] == {
        "cpus": 16,
        "memory": "64gb",
        "storage": "64gb",
    }
    assert "features" not in config


@pytest.mark.parametrize(
    ("path", "engine"),
    [("package.json", "^1.118.0"), ("extensions/drm-copilot/package.json", "^1.138.0")],
)
def test_consumer_engines_remain_independent_of_development_runtime(
    path: str, engine: str
) -> None:
    """Development runtime updates preserve published compatibility."""
    package = cast("dict[str, object]", json.loads(_text(path)))
    assert package["engines"] == {"vscode": engine}


def test_python_compatibility_matrix_is_preserved() -> None:
    """The new Python development patch does not remove older compatibility jobs."""
    assert 'python = ">=3.11,<4.0"' in _text("pyproject.toml")
    assert 'python-version: ["3.11", "3.12", "3.13"]' in _text(
        ".github/workflows/_quality-checks.yml"
    )


@pytest.mark.parametrize(
    "workflow",
    [
        "_root-typescript-tests.yml",
        "_drm-copilot-extension-tests.yml",
        "_npm-audit-gate.yml",
    ],
)
def test_development_node_workflow_matches_host_baseline(workflow: str) -> None:
    """Development Node jobs execute the same explicit runtime as both containers."""
    source = _text(f".github/workflows/{workflow}")
    match = re.search(r"node-version:\s*[\"']?([0-9.]+)", source)
    assert match is not None
    assert match.group(1) == _minimums()["node"]


@pytest.mark.parametrize(
    "workflow", ["_quality-checks.yml", "_build-check.yml", "_security-scan.yml"]
)
def test_development_poetry_workflow_matches_host_baseline(workflow: str) -> None:
    """Pin development Poetry across the compatibility matrix."""
    source = _text(f".github/workflows/{workflow}")
    match = re.search(r"snok/install-poetry@v1\s+with:\s+version:\s*([\w.]+)", source)
    assert match is not None
    assert match.group(1) == _minimums()["poetry"]


def test_shell_workflow_pins_match_container_format_and_lint_tools() -> None:
    """Shell CI cannot silently use another formatter or distro-default linter."""
    source = _text(".github/workflows/_shell-coverage.yml")
    assert 'SHFMT_VERSION="3.14.1"' in source
    assert 'SHELLCHECK_VERSION="0.11.0"' in source
