# Soma Community

Shared protocols, muscles, skills, and templates for [Soma](https://soma.gravicity.ai) agents.

## What's Here

| Directory | What | Format |
|-----------|------|--------|
| `protocols/` | Behavioral rules — how your agent *acts* | Markdown with YAML frontmatter |
| `muscles/` | Learned patterns — reusable workflows | Markdown with digest blocks |
| `skills/` | Domain expertise — task-specific knowledge | `name/SKILL.md` directories |
| `templates/` | Full agent configs — identity + protocols + skills | `.soma/` bundles |

## Install

```bash
# Install a single protocol
soma community install protocol code-review

# Install a muscle
soma community install muscle docker-deploy

# Install a skill
soma community install skill logo-creator

# Bootstrap from a template
soma init --template devops
```

> `soma community` commands are coming soon. For now, copy files manually into your `.soma/` directory.

## Using Manually

```bash
# Protocol → .soma/protocols/
cp community/protocols/code-review.md your-project/.soma/protocols/

# Muscle → .soma/memory/muscles/
cp community/muscles/docker-deploy.md your-project/.soma/memory/muscles/

# Skill → ~/.soma/skills/ (global) or .soma/skills/ (project)
cp -r community/skills/logo-creator ~/.soma/skills/
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for format requirements and submission guidelines.

### Quick Start

1. Fork this repo
2. Add your protocol/muscle/skill/template
3. Ensure frontmatter follows the [format guide](#format-requirements)
4. Open a PR with a description of what it does and why it's useful

### Format Requirements

**Protocols** must have:
- `type: protocol`, `name`, `heat-default`, `breadcrumb`, `applies-to` in frontmatter
- A `## TL;DR` section
- Clear `## When to Apply` and `## When NOT to Apply` sections

**Muscles** must have:
- `type: muscle`, `status: active`, `topic`, `keywords` in frontmatter
- `<!-- digest:start -->` / `<!-- digest:end -->` markers
- `heat` set to `0` (users control their own heat)

**Skills** must have:
- A `SKILL.md` file with `name`, `description`, `version`, `author`, `keywords`
- Self-contained — no external dependencies beyond standard tools

**Templates** must have:
- A `README.md` explaining what the template sets up
- A `.soma/` directory with identity, settings, and any bundled protocols/muscles

## License

Community contributions are MIT licensed unless otherwise specified in the file.
