# Contributing to SomaHub

Community-contributed protocols, muscles, skills, and templates for Soma agents. This content is loaded into AI agent context at runtime — treat it like code.

## Quick Path (Soma Users)

```
/share muscle my-pattern
```

Soma validates, strips private data, and opens a PR. Trusted contributors auto-merge. New contributors get reviewed.

## Manual Path (GitHub)

1. **Fork** this repository
2. **Add content** to the right directory (`protocols/`, `muscles/`, `skills/`, `templates/`)
3. **Validate** frontmatter against [FRONTMATTER.md](FRONTMATTER.md)
4. **Test** by copying into a real `.soma/` directory and booting Soma
5. **Open a PR** — CI runs six automated checks

## Tier Rules

| Tier | Who | CI Enforcement |
|------|-----|----------------|
| `community` | Anyone | Default — always allowed |
| `official` | Gravicity team | Verified via MAINTAINERS.json |
| `core` | Gravicity team | Verified via MAINTAINERS.json |
| `pro` | Gravicity premium | Separate repo (future) |

Claiming a tier you're not authorized for **fails CI**. If `tier:` is missing, it defaults to `community`.

## Attribution

Your `author:` field must match your GitHub identity:

- **Registered members** (in MAINTAINERS.json): must use your `display_name`
- **New contributors**: use your GitHub username or a consistent display name
- **Impersonation**: claiming another member's display name fails CI

To register a display name, ask a maintainer or contribute a few accepted PRs.

## What Gets Checked

Every PR runs through six automated checks:

| Check | What It Does |
|-------|--------------|
| **Frontmatter** | Required fields present, valid values |
| **Privacy** | No emails, file paths, secrets, API keys |
| **Injection** | No prompt injection, system overrides, hidden text |
| **Format** | Required sections (TL;DR for protocols, digest for muscles) |
| **Tier guard** | Claimed tier authorized for your role |
| **Attribution** | Author matches GitHub identity mapping |

All six must pass. Trusted contributors auto-merge. New contributors are labeled `needs-review` for maintainer approval.

## Content Types

### Protocols

```yaml
---
type: protocol
name: my-protocol           # kebab-case, unique
status: active              # draft | active | stable | dormant | archived | deprecated
heat-default: warm          # cold | warm | hot
applies-to: [always]        # [always] | [git] | [writing] | custom
breadcrumb: "One-sentence summary loaded when warm."
author: Your Name
tier: community
tags: [relevant, searchable]
license: MIT
version: 1.0.0
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Required sections: `## TL;DR`, `## When to Apply`

### Muscles

```yaml
---
type: muscle
name: my-muscle
status: active
heat-default: warm
breadcrumb: "What this muscle teaches."
topic: [broad, categories]
keywords: [specific, search, terms]
heat: 0                     # always 0 in community repo
loads: 0                    # always 0 in community repo
author: Your Name
tier: community
license: MIT
version: 1.0.0
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Required: `<!-- digest:start -->` / `<!-- digest:end -->` markers near the top

### Skills

```
skills/your-skill/
├── SKILL.md          # frontmatter + instructions (see FRONTMATTER.md for full schema)
└── (supporting files)
```

### Templates

```
templates/your-template/
├── template.json     # manifest: name, description, requires, tier
├── identity.md       # agent identity with {{PLACEHOLDERS}}
├── settings.json     # tuned thresholds
└── README.md         # hub display page
```

## Naming

- **kebab-case only**: `code-review`, not `codeReview` or `Code Review`
- **Be specific**: `vitest-coverage-gates`, not `testing`
- **No collisions**: first-merge wins — check existing content before submitting

## Quality Bar

Before submitting, ask:

- [ ] Would I want this loaded into my agent's context every session?
- [ ] Is the digest/breadcrumb useful on its own (without reading the body)?
- [ ] Have I removed all project-specific paths and personal references?
- [ ] Does it work when dropped into a fresh `.soma/` directory?

## For AI Agents

If you're an AI agent submitting content:

1. Run pre-submit validation before opening a PR
2. Include the validation report in the PR description
3. Do **not** modify: `MAINTAINERS.json`, `CONTRIBUTING.md`, `CODEOWNERS`, `.github/`
4. Do **not** claim `tier: core` or `tier: official` unless your principal is authorized
5. Set `heat: 0` and `loads: 0` — users control their own usage stats

## Updates

To update an existing contribution: open a PR against the file, bump the `version` field, explain what changed in the PR description.

## License

By contributing, you agree your submission is MIT licensed (unless specified otherwise in frontmatter). Soma always attributes the author.
