# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Bridgetown 1.3.1 static site documenting a Gloomhaven campaign ("Croaky's Waste Management Services"). Built with Ruby 3.2.1, ERB templates, esbuild for frontend assets, and SCSS for styling.

## Common Commands

```bash
# Install dependencies
bundle install && yarn install

# Development server (http://localhost:4000, live reload)
bin/bridgetown start

# Production build
rake deploy

# Clean output
rake clean

# Interactive console with site context
bin/bridgetown console
```

## Architecture

**Data flow:** YAML data files + Markdown content → Bridgetown build → static HTML in `output/`

**Template hierarchy:**
- `src/_layouts/default.erb` — base HTML shell (head, navbar, main, footer)
  - `src/_layouts/page.erb` — wraps standard pages (chapters listing, scenarios, clues, about)
  - `src/_layouts/chapter.erb` — wraps individual chapter pages (adds scenario info)

**ViewComponents** (`src/_components/`): Ruby class + ERB template pairs.
- `ScenarioTree` / `ScenarioTreeEntry` — recursive rendering of the scenario tree from YAML data
- `Shared::Navbar` — site navigation

**Data files** (`src/_data/`): YAML, accessible in templates as `site.data.<filename>`.
- `scenarios.md` — YAML with numeric keys, each scenario has `name`, `state` (success/not_doable/not_tried), `treasures`, `links` (child scenario IDs)
- `characters.yml` — party members with `name`, `class`, `avatar`, `story`
- `clues.yml` — puzzle clues with `origin` and `text`
- `site_metadata.yml` — site title, tagline, description

**Collections:** `src/_chapters/` — numbered markdown files (1.md–27.md) with front matter: `layout`, `day`, `scenario`, `title`.

**Frontend:** `frontend/javascript/index.js` (entry point), `frontend/styles/` (SCSS). Built by esbuild, output to `output/_bridgetown/static/`. Import aliases: `$styles`, `$javascript`, `$components` (defined in `jsconfig.json`).

## Key Configuration

- `bridgetown.config.yml` — permalink: pretty, template_engine: erb, chapters collection
- `esbuild.config.js` — asset bundling (JS + Sass compilation)
- `postcss.config.js` — autoprefixer, flexbugs-fixes, preset-env
- `config/puma.rb` — dev server on port 4000 (env var `BRIDGETOWN_PORT`)
