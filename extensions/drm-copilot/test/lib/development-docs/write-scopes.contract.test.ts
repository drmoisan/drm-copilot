/**
 * Write-scope checker (issue #1035, spec "Checker test (three directions)").
 *
 * Forward coverage: every literal a rule expands to is present on its surface.
 * Reverse coverage: every development-docs Write/Edit entry on a surface is
 * produced by a rule (Codex variant files map to their base agent).
 * Root coverage: a sample path under each known root is matched by a rule's
 * literals through `compileGlob`, and each required-artifact pattern accepts
 * sample paths under both roots.
 *
 * Side effects:
 *     Read-only access to committed repository files through an injected
 *     reader with forward-slash repository-relative paths; no temporary file.
 */
import * as fs from "node:fs";
import * as path from "node:path";
import { compileGlob } from "../../../src/lib/file-system";
import {
  DevelopmentDocsRoot,
  KNOWN_DEVELOPMENT_DOCS_ROOTS,
} from "../../../src/lib/development-docs/root";
import {
  REQUIRED_ARTIFACT_RULES,
  SETTINGS_ALLOW_RULES,
  WRITE_SCOPE_RULES,
  WriteScopeArea,
  expandRequiredArtifactPattern,
  expandWriteScopeLiterals,
} from "../../../src/lib/development-docs/write-scopes";

/** Read access to repository files by forward-slash relative path. */
interface RepositoryReader {
  readText(relative: string): string;
  listFiles(folder: string, suffix: string): string[];
}

/** Repository root, five levels above this file's folder. */
const REPO_ROOT = path.join(__dirname, "..", "..", "..", "..", "..");

const fileReader: RepositoryReader = {
  readText: (relative) =>
    fs.readFileSync(path.join(REPO_ROOT, ...relative.split("/")), "utf8"),
  listFiles: (folder, suffix) =>
    fs
      .readdirSync(path.join(REPO_ROOT, ...folder.split("/")))
      .filter((name) => name.endsWith(suffix))
      .sort()
      .map((name) => `${folder}/${name}`),
};

const SETTINGS_FILE = ".claude/settings.json";
const CLAUDE_AGENTS = ".claude/agents";
const CODEX_AGENTS = ".codex/agents";

/** Base Codex agents that carry write-scope text (spec rule-table note). */
const CODEX_SURFACE_AGENTS: ReadonlyArray<string> = [
  "atomic-planner",
  "prd-feature",
  "feature-review",
  "status-updater",
  "epic-review",
];

const CODEX_VARIANT_SUFFIX = /-(?:c[1-4]|c3-elevated)$/;
const LIST_LITERAL = /^\s*-\s*"?((?:Write|Edit)\([^)]*\))"?\s*$/;
const DEVELOPMENT_DOCS_PATH =
  /^(?:docs\/features(?:\/|$)|docs\/research(?:\/|$)|docs\/\*\*|\.dev(?:\/|$))/;

/** Sample paths per area, one per known root, in root order. */
const AREA_SAMPLES: Readonly<
  Record<WriteScopeArea, readonly [string, string]>
> = {
  root: ["docs/features/active/x/spec.md", ".dev/active/x/spec.md"],
  active: ["docs/features/active/x/spec.md", ".dev/active/x/spec.md"],
  potential: ["docs/features/potential/x.md", ".dev/potential/x.md"],
  epics: ["docs/features/epics/e/epic.md", ".dev/epics/e/epic.md"],
  parallel: ["docs/features/parallel/r/run.json", ".dev/parallel/r/run.json"],
  "feature-research": [
    "docs/features/active/x/research/r.md",
    ".dev/active/x/research/r.md",
  ],
  "one-off-research": ["docs/research/r.md", ".dev/research/r.md"],
  "docs-broad": ["docs/features/active/x/plan.md", ".dev/active/x/plan.md"],
};

/** Return the frontmatter lines of an agent Markdown file. */
function frontmatterLines(text: string): string[] {
  const lines = text.split(/\r?\n/);
  const end = lines.indexOf("---", 1);
  if (lines[0] !== "---" || end < 0) {
    throw new Error("agent file has no frontmatter");
  }
  return lines.slice(1, end);
}

/** Return the Write/Edit list entries of a block of lines. */
function scopeLiterals(lines: ReadonlyArray<string>): string[] {
  return lines.flatMap((line) => {
    const match = LIST_LITERAL.exec(line);
    return match?.[1] === undefined ? [] : [match[1]];
  });
}

/** Return the entries of the frontmatter `tools:` list. */
function toolsEntries(text: string): string[] {
  const lines = frontmatterLines(text);
  const start = lines.indexOf("tools:");
  const tail = start < 0 ? [] : lines.slice(start + 1);
  const end = tail.findIndex((line) => !line.startsWith("  - "));
  return scopeLiterals(end < 0 ? tail : tail.slice(0, end));
}

/** Return the `permissions.allow` entries of the settings file. */
function settingsAllow(text: string): string[] {
  const parsed: unknown = JSON.parse(text);
  if (
    typeof parsed === "object" &&
    parsed !== null &&
    "permissions" in parsed
  ) {
    const permissions: unknown = parsed.permissions;
    if (
      typeof permissions === "object" &&
      permissions !== null &&
      "allow" in permissions &&
      Array.isArray(permissions.allow)
    ) {
      return permissions.allow.filter(
        (entry: unknown): entry is string => typeof entry === "string",
      );
    }
  }
  throw new Error("settings file has no permissions.allow list");
}

/** Whether a Write/Edit literal names a development-docs path. */
function isDevelopmentDocsLiteral(literal: string): boolean {
  const inner = literal.slice(literal.indexOf("(") + 1, -1).replace(/^\//, "");
  return DEVELOPMENT_DOCS_PATH.test(inner);
}

/** Return the expanded literals of every rule of one agent. */
function agentLiterals(agent: string): string[] {
  return WRITE_SCOPE_RULES.filter((rule) => rule.agent === agent).flatMap(
    (rule) => expandWriteScopeLiterals(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
  );
}

const SETTINGS_LITERALS = SETTINGS_ALLOW_RULES.flatMap((rule) =>
  expandWriteScopeLiterals(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
);
const RULE_AGENTS = [...new Set(WRITE_SCOPE_RULES.map((rule) => rule.agent))];

/** Forward coverage: return `<file>: <literal>` for each missing literal. */
function forwardMissing(reader: RepositoryReader): string[] {
  const missing: string[] = [];
  const report = (file: string, present: string[], expected: string[]) => {
    for (const literal of expected.filter(
      (entry) => !present.includes(entry),
    )) {
      missing.push(`${file}: ${literal}`);
    }
  };
  for (const agent of RULE_AGENTS) {
    const file = `${CLAUDE_AGENTS}/${agent}.md`;
    report(file, toolsEntries(reader.readText(file)), agentLiterals(agent));
  }
  for (const agent of CODEX_SURFACE_AGENTS) {
    const file = `${CODEX_AGENTS}/${agent}.toml`;
    const lines = reader.readText(file).split(/\r?\n/);
    report(file, scopeLiterals(lines), agentLiterals(agent));
  }
  report(
    SETTINGS_FILE,
    settingsAllow(reader.readText(SETTINGS_FILE)),
    SETTINGS_LITERALS,
  );
  for (const rule of REQUIRED_ARTIFACT_RULES) {
    const file = `${CLAUDE_AGENTS}/${rule.agent}.md`;
    const pattern = expandRequiredArtifactPattern(
      rule,
      KNOWN_DEVELOPMENT_DOCS_ROOTS,
    );
    const argument = `-RequiredArtifact '${rule.token}|${pattern}|`;
    const lines = frontmatterLines(reader.readText(file));
    if (
      !lines.some(
        (line) => line.includes("command:") && line.includes(argument),
      )
    ) {
      missing.push(`${file}: ${argument}`);
    }
  }
  return missing;
}

/** Reverse coverage: return `<file>: <literal>` for each unproduced literal. */
function reverseUnproduced(reader: RepositoryReader): string[] {
  const surfaces: Array<[string, string[], string[]]> = [];
  for (const file of reader.listFiles(CLAUDE_AGENTS, ".md")) {
    const agent = path.posix.basename(file, ".md");
    surfaces.push([
      file,
      scopeLiterals(frontmatterLines(reader.readText(file))),
      agentLiterals(agent),
    ]);
  }
  for (const file of reader.listFiles(CODEX_AGENTS, ".toml")) {
    const agent = path.posix
      .basename(file, ".toml")
      .replace(CODEX_VARIANT_SUFFIX, "");
    surfaces.push([
      file,
      scopeLiterals(reader.readText(file).split(/\r?\n/)),
      agentLiterals(agent),
    ]);
  }
  surfaces.push([
    SETTINGS_FILE,
    settingsAllow(reader.readText(SETTINGS_FILE)),
    SETTINGS_LITERALS,
  ]);
  return surfaces.flatMap(([file, present, produced]) =>
    present
      .filter(
        (literal) =>
          isDevelopmentDocsLiteral(literal) && !produced.includes(literal),
      )
      .map((literal) => `${file}: ${literal}`),
  );
}

/** Return an in-memory reader over a copy of the real surfaces. */
function memoryReader(
  edit: (files: Map<string, string>) => void,
): RepositoryReader {
  const files = new Map<string, string>();
  for (const file of [
    ...fileReader.listFiles(CLAUDE_AGENTS, ".md"),
    ...fileReader.listFiles(CODEX_AGENTS, ".toml"),
    SETTINGS_FILE,
  ]) {
    files.set(file, fileReader.readText(file));
  }
  edit(files);
  return {
    readText: (relative) => {
      const text = files.get(relative);
      if (text === undefined) {
        throw new Error(`no in-memory file ${relative}`);
      }
      return text;
    },
    listFiles: (folder, suffix) =>
      [...files.keys()]
        .filter((key) => key.startsWith(`${folder}/`) && key.endsWith(suffix))
        .sort(),
  };
}

describe("write-scope checker: forward coverage", () => {
  it("finds every expanded literal on its agent, Codex, settings and hook surface", () => {
    expect(forwardMissing(fileReader)).toEqual([]);
  });

  it("reports a .dev literal removed from an agent tools list", () => {
    const reader = memoryReader((files) => {
      const file = `${CLAUDE_AGENTS}/prd-feature.md`;
      files.set(
        file,
        (files.get(file) ?? "").replace('  - "Write(/.dev/active/**)"\n', ""),
      );
    });
    expect(forwardMissing(reader)).toEqual([
      `${CLAUDE_AGENTS}/prd-feature.md: Write(/.dev/active/**)`,
    ]);
  });

  it("reports a required-artifact pattern that accepts only one root", () => {
    const reader = memoryReader((files) => {
      const file = `${CLAUDE_AGENTS}/epic-review.md`;
      files.set(
        file,
        (files.get(file) ?? "").replace(
          "^(?:docs/features|\\.dev)/epics/",
          "^docs/features/epics/",
        ),
      );
    });
    expect(forwardMissing(reader)).toHaveLength(1);
  });
});

describe("write-scope checker: reverse coverage", () => {
  it("finds development-docs literals on the scanned surfaces", () => {
    const reader = memoryReader((files) => {
      files.set(
        SETTINGS_FILE,
        '{"permissions":{"allow":["Edit(.dev/extra/**)"]}}',
      );
    });
    expect(reverseUnproduced(reader)).toEqual([
      `${SETTINGS_FILE}: Edit(.dev/extra/**)`,
    ]);
  });

  it("produces every development-docs literal from a rule", () => {
    expect(reverseUnproduced(fileReader)).toEqual([]);
  });

  it("maps a Codex variant file to its base agent", () => {
    const reader = memoryReader((files) => {
      const file = `${CODEX_AGENTS}/atomic-planner-c3-elevated.toml`;
      files.set(
        file,
        `${files.get(file) ?? ""}\n  - "Write(/.dev/active/**)"\n`,
      );
    });
    expect(reverseUnproduced(reader)).toEqual([
      `${CODEX_AGENTS}/atomic-planner-c3-elevated.toml: Write(/.dev/active/**)`,
    ]);
  });
});

describe("write-scope checker: root coverage", () => {
  const rules = [...WRITE_SCOPE_RULES, ...SETTINGS_ALLOW_RULES];

  it.each(rules.map((rule, index) => [index, rule.area, rule] as const))(
    "rule %i (%s) matches a sample path under each known root",
    (_index, area, rule) => {
      const globs = expandWriteScopeLiterals(
        rule,
        KNOWN_DEVELOPMENT_DOCS_ROOTS,
      ).map((literal) =>
        compileGlob(
          literal.slice(literal.indexOf("(") + 1, -1).replace(/^\//, ""),
        ),
      );
      for (const sample of AREA_SAMPLES[area]) {
        expect(globs.some((glob) => glob.test(sample))).toBe(true);
      }
    },
  );

  it.each(
    REQUIRED_ARTIFACT_RULES.map(
      (rule) =>
        [
          rule.token,
          rule,
          rule.token === "spec-path"
            ? "x/spec.md"
            : "e/epic-audit.2026-11-17T09-04.md",
        ] as const,
    ),
  )(
    "the %s pattern accepts sample paths under both roots",
    (_token, rule, tail) => {
      const pattern = new RegExp(
        expandRequiredArtifactPattern(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
      );
      const area = rule.area === "active" ? "active" : "epics";
      const roots: ReadonlyArray<DevelopmentDocsRoot> =
        KNOWN_DEVELOPMENT_DOCS_ROOTS;
      for (const root of roots) {
        expect(pattern.test(`${root}/${area}/${tail}`)).toBe(true);
      }
    },
  );
});
