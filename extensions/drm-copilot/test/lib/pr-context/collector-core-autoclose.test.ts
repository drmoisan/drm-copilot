import { afterEach, describe, expect, it, jest } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { collectAndWrite } from "../../../src/lib/pr-context/collector-output";
import { GhClient } from "../../../src/lib/pr-context/gh-client-core";
import {
  AUTOCLOSE_PENDING_NOT_OPEN_TEXT,
  AUTOCLOSE_UNVERIFIED_ANNOTATION,
  type IssueDetails,
  type PullRequestDetails,
} from "../../../src/lib/pr-context/models";

/**
 * Collector-level autoclose derivation tests (issue #622), mirroring the
 * Python C1-C6 scenarios. `collectAndWrite` runs against a tree-backed
 * in-memory filesystem and a scripted runner; the three GitHub lookups the
 * scenarios vary are replaced with `jest.spyOn` doubles. No real process,
 * network, or disk is used.
 */

const ROOT = "/repo";
const GH_PATH = "/usr/bin/gh";
const FEATURE_DIR = "docs/features/active/2026-09-25-autoclose-fixture-622";
const CHANGED = `${FEATURE_DIR}/spec.md`;
const AUTOCLOSE_TITLE = "Issues to autoclose (verified or pending)";
const VERIFIED_LABEL = "Auto-close issues (verified from GitHub PR metadata):";
const AUTHOR_LABEL = "Auto-close issues (author asserted):";
const DETECTED_LABEL = "Referenced issues (detected):";
const NO_REFS = "No references.\n";

type Entity = "issue" | "pull" | null;

const ok = (stdout: string): CommandResult => ({ stdout, stderr: "", code: 0 });
const fail = (stderr: string): CommandResult => ({
  stdout: "",
  stderr,
  code: 1,
});

/** Scripted runner honoring the SubprocessRunner throw-on-nonzero contract. */
class ScriptRunner implements CommandRunner {
  constructor(
    private readonly handler: (args: readonly string[]) => CommandResult,
  ) {}

  run(args: readonly string[], options?: CommandRunOptions): CommandResult {
    const result = this.handler(args);
    if (!(options?.allowError ?? false) && result.code !== 0) {
      const joined = (result.stdout + "\n" + result.stderr).trim();
      throw new Error(`${args.join(" ")} failed (${result.code}): ${joined}`);
    }
    return result;
  }
}

/** True when the argv is a gh invocation (executable is the resolved gh path). */
function isGh(args: readonly string[]): boolean {
  return args[0] === GH_PATH || args[0] === "gh";
}

/** Answer gh argv; authentication succeeds only when `ghAvailable` is true. */
function ghHandler(
  args: readonly string[],
  ghAvailable: boolean,
): CommandResult {
  const sub = args.slice(1).join(" ");
  if (sub.startsWith("auth status")) {
    return ghAvailable ? ok("Logged in") : fail("offline");
  }
  if (sub.startsWith("repo view --json nameWithOwner")) {
    return ok('{"nameWithOwner": "owner/repo"}');
  }
  if (args.includes("pr") && args.includes("view") && !args.includes("api")) {
    return fail("no pull request");
  }
  if (sub.startsWith("run list")) {
    return ok(JSON.stringify([{ status: "success" }]));
  }
  return ok("{}");
}

/** Answer git argv for the comparison range and the fixture spec change. */
function gitHandler(args: readonly string[]): CommandResult {
  const sub = args.slice(1).join(" ");
  if (sub.startsWith("rev-parse --abbrev-ref HEAD")) {
    return ok("feature/docs");
  }
  if (sub.includes("@{u}")) {
    return ok("upstream/feature/docs");
  }
  if (sub.startsWith("remote -v")) {
    return ok("upstream https://example/repo (fetch)");
  }
  if (sub.startsWith("status -sb")) {
    return ok("## feature/docs");
  }
  if (sub.startsWith("ls-files")) {
    return ok("");
  }
  if (sub.startsWith("rev-parse --verify")) {
    return ok("resolved-sha");
  }
  if (sub.startsWith("merge-base")) {
    return ok("base-sha");
  }
  if (sub.startsWith("log")) {
    return ok("");
  }
  if (sub.startsWith("diff --name-status")) {
    return ok(`M\t${CHANGED}`);
  }
  if (sub.startsWith("diff --numstat")) {
    return ok(`1\t0\t${CHANGED}`);
  }
  return ok("");
}

/** One collector scenario: gh availability, spec prose, and GitHub answers. */
interface Scenario {
  readonly ghAvailable: boolean;
  readonly specText: string;
  readonly classifications?: Readonly<Record<string, Entity>>;
  readonly states?: Readonly<Record<string, string>>;
}

/** Build issue details whose state comes from the scenario map. */
function issueDetailsFor(numberRef: string, state: string): IssueDetails {
  return {
    number: `#${numberRef}`,
    title: `Issue ${numberRef}`,
    state,
    labels: [],
    assignees: [],
    author: "alex",
    createdAt: "2026-01-01",
    updatedAt: "2026-01-02",
    body: "Body",
    comments: [],
    userStoryPath: null,
    userStoryContent: null,
  };
}

/** Fixed pull request details returned for every `prDetails` call. */
function prDetailsFor(numberRef: string): PullRequestDetails {
  return {
    number: `#${numberRef}`,
    title: "PR",
    state: "open",
    author: "alex",
    baseRef: "main",
    headRef: "feature/docs",
    createdAt: "2026-01-01",
    updatedAt: "2026-01-02",
    mergedAt: null,
    labels: [],
    assignees: [],
    body: "PR body",
    closingIssues: [],
    filesChanged: ["file.py"],
  };
}

/**
 * Seed the fixture feature, install the GitHub spies, and run the collector.
 *
 * @returns The summary text and every number passed to `issueDetails`.
 */
function runScenario(scenario: Scenario): {
  summary: string;
  issueDetailCalls: string[];
} {
  const classifications = scenario.classifications ?? {};
  const states = scenario.states ?? {};
  const issueDetailCalls: string[] = [];
  jest
    .spyOn(GhClient.prototype, "classifyEntity")
    .mockImplementation(
      (numberRef: string) => classifications[numberRef] ?? null,
    );
  jest
    .spyOn(GhClient.prototype, "issueDetails")
    .mockImplementation((numberRef: string) => {
      issueDetailCalls.push(numberRef);
      return issueDetailsFor(numberRef, states[numberRef] ?? "(unknown)");
    });
  jest
    .spyOn(GhClient.prototype, "prDetails")
    .mockImplementation((numberRef: string) => prDetailsFor(numberRef));

  // Seed the repo marker, the promoted folder, and the fixture feature files.
  const fs = new TreeFileSystem();
  fs.addFile(`${ROOT}/.git`, "");
  fs.addDir(`${ROOT}/docs/features/potential/promoted`);
  fs.addFile(`${ROOT}/${FEATURE_DIR}/spec.md`, scenario.specText);
  fs.addFile(`${ROOT}/${FEATURE_DIR}/issue.md`, "- Issue: #622\n");
  fs.addFile(
    `${ROOT}/${FEATURE_DIR}/feature-audit.2026-01-01T00-00.md`,
    "Readiness: PASS\n",
  );
  const runner = new ScriptRunner((args) =>
    isGh(args) ? ghHandler(args, scenario.ghAvailable) : gitHandler(args),
  );

  const result = collectAndWrite({
    base: "main",
    head: "feature/docs",
    repoRoot: ROOT,
    includeUntracked: false,
    fs,
    runner,
    clock: () => new Date(Date.UTC(2026, 8, 25, 23, 29, 0)),
    whichGh: () => GH_PATH,
    out: `${ROOT}/artifacts/pr_context.summary.txt`,
    appendixOut: `${ROOT}/artifacts/pr_context.appendix.txt`,
    append: false,
    log: () => undefined,
  });
  return { summary: result.summaryText, issueDetailCalls };
}

/** Return the `===== title =====` banner and its lines up to the next banner. */
function section(summary: string, title: string): string {
  const header = `===== ${title} =====`;
  const lines = summary.split("\n");
  const collected = [header];
  // Walk forward from the banner until the next section banner begins.
  for (const line of lines.slice(lines.indexOf(header) + 1)) {
    if (line.startsWith("=====")) {
      break;
    }
    collected.push(line);
  }
  return collected.join("\n");
}

/** Return the lines after the first `label` line, up to the first blank line. */
function linesAfter(summary: string, label: string): string[] {
  const lines = summary.split("\n");
  const collected: string[] = [];
  // Collect the label's list block, which ends at the first blank line.
  for (const line of lines.slice(lines.indexOf(label) + 1)) {
    if (!line.trim()) {
      break;
    }
    collected.push(line);
  }
  return collected;
}

/** Return the autoclose section and both auto-close label blocks as text. */
function autocloseSurfaces(summary: string): string[] {
  return [
    section(summary, AUTOCLOSE_TITLE),
    linesAfter(summary, VERIFIED_LABEL).join("\n"),
    linesAfter(summary, AUTHOR_LABEL).join("\n"),
  ];
}

/** Scenario rows for T4: a pending primary that is not an open issue. */
const NOT_OPEN_CASES: [string, Entity, string][] = [
  ["closed", "issue", "closed"],
  ["(unknown)", "issue", "(unknown)"],
  ["pull", "pull", "open"],
  ["null", null, "open"],
];

describe("collector autoclose derivation", () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("excludes scraped tokens from autoclose when gh is unavailable", () => {
    // Arrange
    const specText =
      "Timestamps use #ISO-8601 and ISO-8601; finding #CR-1 (CR-1); see #468.\n";

    // Act
    const { summary } = runScenario({ ghAvailable: false, specText });

    // Assert: no scraped token reaches any autoclose surface.
    for (const surface of autocloseSurfaces(summary)) {
      for (const token of ["ISO-8601", "CR-1", "#468"]) {
        expect(surface).not.toContain(token);
      }
    }
    const autocloseLines = section(summary, AUTOCLOSE_TITLE).split("\n");
    const entryIndex = autocloseLines.indexOf("- #622");
    expect(autocloseLines[entryIndex + 1]).toBe(
      AUTOCLOSE_UNVERIFIED_ANNOTATION,
    );
    const classified = section(summary, "Referenced issues (classified)");
    expect(classified).toContain("#468");
    expect(classified).toContain("NOTE: Unverified (GitHub unavailable)");
  });

  it("excludes a prose-cited closed issue from autoclose", () => {
    // Arrange
    const scenario: Scenario = {
      ghAvailable: true,
      specText: "See #468.\n",
      classifications: { "468": "issue", "622": "issue" },
      states: { "468": "closed", "622": "open" },
    };

    // Act
    const { summary } = runScenario(scenario);

    // Assert
    for (const surface of autocloseSurfaces(summary)) {
      expect(surface).not.toContain("#468");
    }
  });

  it("excludes a prose-cited open out-of-scope issue from autoclose", () => {
    // Arrange
    const scenario: Scenario = {
      ghAvailable: true,
      specText: "Related to #584.\n",
      classifications: { "584": "issue", "622": "issue" },
      states: { "584": "open", "622": "open" },
    };

    // Act
    const { summary } = runScenario(scenario);

    // Assert
    for (const surface of autocloseSurfaces(summary)) {
      expect(surface).not.toContain("#584");
    }
    expect(linesAfter(summary, DETECTED_LABEL)).toContain("- #584");
  });

  it.each(NOT_OPEN_CASES)(
    "excludes a closed pending primary without printing it (%s)",
    (_label, classification, state) => {
      // Arrange
      const scenario: Scenario = {
        ghAvailable: true,
        specText: NO_REFS,
        classifications: { "622": classification },
        states: { "622": state },
      };

      // Act
      const { summary } = runScenario(scenario);

      // Assert
      const sectionText = section(summary, AUTOCLOSE_TITLE);
      const nonEmpty = sectionText.split("\n").filter((line) => line.trim());
      expect(nonEmpty[nonEmpty.length - 1]).toBe(
        AUTOCLOSE_PENDING_NOT_OPEN_TEXT,
      );
      expect(sectionText).not.toContain("#622");
    },
  );

  it.each(["open", "OPEN"])("keeps an open pending primary (%s)", (state) => {
    // Arrange
    const scenario: Scenario = {
      ghAvailable: true,
      specText: NO_REFS,
      classifications: { "622": "issue" },
      states: { "622": state },
    };

    // Act
    const { summary } = runScenario(scenario);

    // Assert
    const sectionText = section(summary, AUTOCLOSE_TITLE);
    expect(sectionText).toContain("- #622");
    expect(sectionText).not.toContain("Unverified:");
  });

  it("fetches each issue once", () => {
    // Arrange
    const scenario: Scenario = {
      ghAvailable: true,
      specText: "Cites #468, #584, and #7.\n",
      classifications: {
        "468": "issue",
        "584": "issue",
        "7": "pull",
        "622": "issue",
      },
      states: { "468": "closed", "584": "open", "622": "open" },
    };

    // Act
    const { issueDetailCalls } = runScenario(scenario);

    // Assert
    expect([...issueDetailCalls].sort()).toEqual(["468", "584", "622"]);
  });
});
