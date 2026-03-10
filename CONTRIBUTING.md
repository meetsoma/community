# Contributing to Soma Community

Thanks for sharing your agent knowledge. Here's how to contribute.

## What We Accept

- **Protocols** that encode useful behavioral rules
- **Muscles** that capture repeatable workflows
- **Skills** that teach domain expertise
- **Templates** that bundle a complete agent personality

## What We Don't Accept

- Anything that requires proprietary tools or paid APIs to function
- Content that's just a wrapper around a single product/service
- Protocols/muscles with project-specific hardcoded paths
- Low-effort submissions (a muscle that says "run tests" with no detail)

## Submission Process

1. **Fork** this repository
2. **Create** your contribution in the appropriate directory
3. **Validate** frontmatter against the format below
4. **Test** by copying into a real `.soma/` directory and booting Soma
5. **Open a PR** with:
   - What it does (1-2 sentences)
   - Why it's useful (who benefits)
   - How you've used it (real context, not hypothetical)

## Format Reference

### Protocol Frontmatter

```yaml
---
type: protocol
name: your-protocol-name        # kebab-case, unique
status: active
heat-default: warm               # cold | warm | hot
applies-to: [always]             # domain signals
breadcrumb: "One-sentence summary shown when warm."
author: Your Name
license: MIT
version: 1.0.0
---
```

### Muscle Frontmatter

```yaml
---
type: muscle
status: active
topic: [broad, categories]
keywords: [specific, search, terms]
created: 2026-01-01
updated: 2026-01-01
heat: 0                          # always 0 in community — users control their own heat
author: Your Name
license: MIT
version: 1.0.0
---
```

### Skill Format

```
skills/your-skill/
├── SKILL.md          # Required — name, description, version, instructions
└── (supporting files) # Optional — examples, templates, etc.
```

SKILL.md frontmatter:
```yaml
---
name: your-skill
type: skill
description: "What this skill teaches the agent to do."
version: 1.0.0
author: Your Name
license: MIT
keywords: [searchable, terms]
---
```

### Template Format

```
templates/your-template/
├── README.md         # What this template sets up
└── .soma/
    ├── identity.md
    ├── settings.json
    ├── protocols/    # Bundled protocols
    ├── memory/
    │   └── muscles/  # Bundled muscles
    └── skills/       # Bundled skills
```

## Quality Bar

Before submitting, ask:

- [ ] Would I use this in a real project?
- [ ] Is the digest/breadcrumb good enough to be useful on its own?
- [ ] Are there clear "when to apply" and "when not to apply" sections?
- [ ] Have I removed all project-specific paths and references?
- [ ] Does it work when dropped into a fresh `.soma/` directory?

## Naming

- Use kebab-case: `code-review`, not `codeReview` or `Code Review`
- Be descriptive: `docker-multi-stage-build`, not `docker`
- Avoid generic names: `testing` is too broad, `vitest-coverage-gates` is specific

## Updates

To update an existing contribution, open a PR against the file. Bump the `version` field. Explain what changed and why in the PR description.

## License

By contributing, you agree your submission is MIT licensed (unless you specify otherwise in the file's frontmatter). Soma will always attribute the author.
