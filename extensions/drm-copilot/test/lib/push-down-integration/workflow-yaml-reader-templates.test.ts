/**
 * Real-template contract of the workflow subset reader (issue #1051, S20).
 *
 * The #1050 caller is rendered at test time by `renderCiCaller` from the
 * tracked template and job fragments, in reference and copy modes; each
 * bundled `harness-<stem>.yml` is read from the tracked bundle. The test reads
 * tracked files only and asserts no `job.workflow_*` expression value.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

import {
  CI_CALLER_TEMPLATE_SOURCE,
  CI_STEMS,
  ciFragmentSource,
  type CiStem,
  ciWorkflowSource,
  renderCiCaller,
  resolveCiPackJobs,
} from "../../../src/lib/push-down/push-down-ci-workflows";
import { readWorkflowText } from "../../../src/lib/push-down-integration/workflow-yaml-reader";

const RESOURCES = join(__dirname, "..", "..", "..", "resources");

/** Read one tracked bundle file by its resources-relative path. */
function resource(path: string): string {
  return readFileSync(join(RESOURCES, ...path.split("/")), "utf8");
}

/** Render the caller for every language pack in one mode. */
function renderCaller(mode: "reference" | "copy"): string {
  const jobs = resolveCiPackJobs([
    {
      packs: ["core", "python", "powershell", "typescript", "csharp-modern"],
    },
  ]);
  const fragments: Partial<Record<CiStem, string>> = {};
  for (const job of jobs) {
    fragments[job.stem] = resource(ciFragmentSource(job.stem));
  }
  return renderCiCaller({
    mode,
    jobs,
    payloadVersion: "9.8.7",
    template: resource(CI_CALLER_TEMPLATE_SOURCE),
    fragments,
  });
}

describe("readWorkflowText over the #1050 templates", () => {
  it.each(["reference", "copy"] as const)(
    "S20 positive: reads the rendered caller in %s mode with name CI and the gate job",
    (mode) => {
      const text = renderCaller(mode);
      expect(text).toContain('"epic/**"');
      expect(text).toContain("${{ toJSON(needs) }}");
      expect(text).toContain("run: |");

      const result = readWorkflowText(text);

      expect(result.status).toBe("ok");
      if (result.status !== "ok") {
        return;
      }
      expect(result.name).toBe("CI");
      expect(result.triggers).toContain("pull_request");
      const gate = result.jobs.find((job) => job.id === "ci-required-gate");
      expect(gate?.name).toBe("CI Required Gate");
      expect(gate?.if).toBe("always()");
      expect([...(gate?.needs ?? [])].sort()).toEqual(
        ["dotnet", "powershell", "python", "typescript"].sort(),
      );
    },
  );

  it.each(CI_STEMS)(
    "S20 positive: reads the bundled harness-%s.yml with status ok",
    (stem) => {
      const result = readWorkflowText(resource(ciWorkflowSource(stem)));

      expect(result.status).toBe("ok");
    },
  );

  it("S20 negative: a rendered caller altered with an anchor is not read as ok", () => {
    const altered = renderCaller("reference").replace(
      "permissions:",
      "permissions: &perms",
    );

    expect(readWorkflowText(altered).status).toBe("unsupported");
  });
});
