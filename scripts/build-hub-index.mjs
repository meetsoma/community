#!/usr/bin/env node

/**
 * build-hub-index.mjs — Generate hub-index.json from community content.
 *
 * Parses protocols, muscles, scripts, skills, and templates into a single JSON file
 * that the website can fetch client-side for near-instant content updates.
 *
 * Usage: node scripts/build-hub-index.mjs [--output path]
 * Default output: hub-index.json (repo root)
 */

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const DEFAULT_OUTPUT = path.join(ROOT, "hub-index.json");

// --- Frontmatter parser ---

function parseFrontmatter(content) {
	const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
	if (!match) return { meta: {}, body: content };

	const meta = {};
	for (const line of match[1].split("\n")) {
		const m = line.match(/^(\S[\w-]*)\s*:\s*(.+)$/);
		if (!m) continue;
		let [, key, val] = m;
		val = val.trim();

		// Parse arrays: [a, b, c]
		if (val.startsWith("[") && val.endsWith("]")) {
			val = val
				.slice(1, -1)
				.split(",")
				.map((s) => s.trim().replace(/^["']|["']$/g, ""));
		}
		// Strip quotes
		else if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
			val = val.slice(1, -1);
		}

		meta[key] = val;
	}

	return { meta, body: match[2].trim() };
}

// --- Extract TL;DR / first paragraph as description ---

function extractDescription(body) {
	// Try TL;DR section first
	const tldr = body.match(/## TL;DR\n+([\s\S]*?)(?=\n## |\n---|\n$)/);
	if (tldr) {
		return tldr[1]
			.split("\n")
			.map((l) => l.replace(/^[-*] /, "").trim())
			.filter(Boolean)
			.slice(0, 3)
			.join(" ");
	}

	// Fall back to first paragraph after heading
	const para = body.match(/^(?:#+.*\n+)?([\s\S]*?)(?:\n\n|\n#|\n---)/);
	if (para) return para[1].replace(/\n/g, " ").trim().slice(0, 200);

	return "";
}

// --- Load content directories ---

function loadMarkdownDir(type, dirName) {
	const dir = path.join(ROOT, dirName);
	if (!fs.existsSync(dir)) return [];

	const items = [];

	for (const entry of fs.readdirSync(dir)) {
		const fullPath = path.join(dir, entry);
		const stat = fs.statSync(fullPath);

		if (stat.isFile() && entry.endsWith(".md") && !entry.startsWith("_")) {
			const content = fs.readFileSync(fullPath, "utf-8");
			const { meta, body } = parseFrontmatter(content);
			const slug = entry.replace(/\.md$/, "");

			items.push(buildItem(type, slug, meta, body));
		}
	}

	return items;
}

function loadSkills() {
	const dir = path.join(ROOT, "skills");
	if (!fs.existsSync(dir)) return [];

	const items = [];

	for (const entry of fs.readdirSync(dir)) {
		const skillDir = path.join(dir, entry);
		if (!fs.statSync(skillDir).isDirectory()) continue;

		const skillFile = path.join(skillDir, "SKILL.md");
		if (!fs.existsSync(skillFile)) continue;

		const content = fs.readFileSync(skillFile, "utf-8");
		const { meta, body } = parseFrontmatter(content);

		items.push(buildItem("skill", entry, meta, body));
	}

	return items;
}

function loadScripts() {
	const dir = path.join(ROOT, "scripts");
	if (!fs.existsSync(dir)) return [];

	const items = [];

	for (const entry of fs.readdirSync(dir)) {
		const scriptDir = path.join(dir, entry);
		if (!fs.statSync(scriptDir).isDirectory()) continue;

		const readme = path.join(scriptDir, "README.md");
		if (!fs.existsSync(readme)) continue;

		const content = fs.readFileSync(readme, "utf-8");
		const { meta, body } = parseFrontmatter(content);

		items.push({
			slug: entry,
			name: meta.name || entry,
			type: "script",
			description: meta.description || extractDescription(body),
			author: meta.author || "Unknown",
			version: meta.version || "1.0.0",
			tier: meta.tier || "community",
			tags: Array.isArray(meta.tags) ? meta.tags : undefined,
			language: meta.language || "bash",
			requires: Array.isArray(meta.requires) ? meta.requires : undefined,
			status: meta.status || "active",
			created: meta.created || undefined,
			updated: meta.updated || undefined,
		});
	}

	return items;
}

function loadTemplates() {
	const dir = path.join(ROOT, "templates");
	if (!fs.existsSync(dir)) return [];

	const items = [];

	for (const entry of fs.readdirSync(dir)) {
		const tplDir = path.join(dir, entry);
		if (!fs.statSync(tplDir).isDirectory()) continue;

		const manifest = path.join(tplDir, "template.json");
		if (!fs.existsSync(manifest)) continue;

		const json = JSON.parse(fs.readFileSync(manifest, "utf-8"));

		// Try to read identity content for richer description
		let body = "";
		const soulPath = path.join(tplDir, "soul.md");
		const somaPath = path.join(tplDir, "SOMA.md");
		const identityPath = path.join(tplDir, "identity.md");
		const idFile = fs.existsSync(soulPath) ? soulPath : fs.existsSync(somaPath) ? somaPath : identityPath;
		if (fs.existsSync(idFile)) {
			const { body: idBody } = parseFrontmatter(fs.readFileSync(idFile, "utf-8"));
			body = idBody;
		}

		items.push({
			slug: entry,
			name: json.name || entry,
			type: "template",
			description: json.description || extractDescription(body),
			author: json.author || "Unknown",
			version: json.version || "1.0.0",
			tier: json.tier || "community",
			tags: json.tags || [],
			requires: json.requires || [],
			updated: json.updated || lastCommitDate(manifest) || undefined,
		});
	}

	return items;
}

// A file's mtime is a property of WHEN THE REPO WAS CLONED, not of the file. This used to be
// `fs.statSync(manifest).mtime`, which made every template report the CI checkout date — all 11 of
// them stamped with the same build day, while the same build run locally reported dates months
// earlier. A same-value stamp across a whole class is a broken probe, not a result.
// Git knows when the file actually changed; ask it, and emit NOTHING rather than a fabricated date.
function lastCommitDate(file) {
	try {
		const out = execFileSync("git", ["log", "-1", "--format=%cs", "--", file], {
			cwd: path.dirname(file), encoding: "utf-8", stdio: ["ignore", "pipe", "ignore"],
		}).trim();
		return /^\d{4}-\d{2}-\d{2}$/.test(out) ? out : undefined;
	} catch {
		return undefined;
	}
}

function buildItem(type, slug, meta, body) {
	return {
		slug,
		name: meta.name || slug,
		type,
		description: meta.breadcrumb || extractDescription(body),
		author: meta.author || "Unknown",
		version: meta.version || "1.0.0",
		breadcrumb: meta.breadcrumb || undefined,
		heatDefault: meta["heat-default"] || undefined,
		appliesTo: Array.isArray(meta["applies-to"]) ? meta["applies-to"] : undefined,
		tier: meta.tier || "community",
		tags: Array.isArray(meta.tags) ? meta.tags : undefined,
		topic: Array.isArray(meta.topic) ? meta.topic : undefined,
		keywords: Array.isArray(meta.keywords) ? meta.keywords : undefined,
		status: meta.status || "active",
		created: meta.created || undefined,
		updated: meta.updated || undefined,
	};
}

// --- Main ---

const outputArg = process.argv.indexOf("--output");
const outputPath = outputArg !== -1 ? process.argv[outputArg + 1] : DEFAULT_OUTPUT;

const items = [
	...loadMarkdownDir("protocol", "protocols"),
	...loadMarkdownDir("muscle", "muscles"),
	...loadMarkdownDir("automation", "automations"),
	...loadScripts(),
	...loadSkills(),
	...loadTemplates(),
];

const index = {
	version: 1,
	generated: new Date().toISOString(),
	count: items.length,
	items,
};

fs.writeFileSync(outputPath, JSON.stringify(index, null, 2) + "\n");
console.log(`✅ hub-index.json: ${items.length} items → ${outputPath}`);
