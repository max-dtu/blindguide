// Browser test: loads the page, runs an accessibility audit (axe, WCAG 2.x A/AA),
// and checks one main action. Needs Chromium: `npx playwright install chromium`.
import { test, before, after } from "node:test";
import assert from "node:assert/strict";
import http from "node:http";
import { readFile } from "node:fs/promises";
import { extname, join, normalize, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";
import AxeBuilder from "@axe-core/playwright";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const types = { ".html": "text/html", ".css": "text/css", ".js": "text/javascript" };

let server;
let browser;
let baseUrl;

before(async () => {
  server = http.createServer(async (req, res) => {
    const path = req.url === "/" ? "/index.html" : req.url.split("?")[0];
    const file = normalize(join(root, path));
    if (!file.startsWith(root)) {
      res.writeHead(403).end();
      return;
    }
    try {
      const body = await readFile(file);
      res.writeHead(200, { "Content-Type": types[extname(file)] ?? "application/octet-stream" });
      res.end(body);
    } catch {
      res.writeHead(404).end();
    }
  });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
  // CHROME_PATH lets a local run use an installed Chromium-based browser.
  // CI uses Playwright's bundled Chromium.
  browser = await chromium.launch({ executablePath: process.env.CHROME_PATH || undefined });
});

after(async () => {
  await browser?.close();
  await new Promise((resolve) => server?.close(resolve));
});

test("main page has no WCAG 2.x A/AA accessibility violations", async () => {
  const context = await browser.newContext();
  try {
    const page = await context.newPage();
    await page.goto(baseUrl);
    const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"]).analyze();
    const summary = results.violations.map((v) => `${v.id}: ${v.help} (${v.nodes.length} node(s))`);
    assert.deepEqual(summary, []);
  } finally {
    await context.close();
  }
});

test("Read text shows the honest 'not sure' answer instead of guessing", async () => {
  const context = await browser.newContext();
  try {
    const page = await context.newPage();
    await page.goto(baseUrl);
    await page.getByRole("button", { name: "Read text" }).click();
    await page.waitForFunction(() => document.getElementById("output").textContent.length > 0);
    const text = await page.textContent("#output");
    assert.match(text, /^I'm not sure\./);
  } finally {
    await context.close();
  }
});
