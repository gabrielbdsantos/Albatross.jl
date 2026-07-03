# Contributing to Albatross.jl

First off, thanks for taking the time to contribute. This guide explains how to
ask questions, report problems, suggest improvements, and prepare pull requests
for Albatross.jl.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [I Have a Question](#i-have-a-question)
- [I Want To Contribute](#i-want-to-contribute)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Your First Code Contribution](#your-first-code-contribution)
- [Improving The Documentation](#improving-the-documentation)
- [Styleguides](#styleguides)
- [Commit Messages](#commit-messages)
- [Join The Project Team](#join-the-project-team)

## Code of Conduct

This project and everyone participating in it is governed by the
[Code of Conduct](./CODE_OF_CONDUCT.md). By participating, you are expected to
uphold this code. For Code of Conduct concerns, contact the project maintainer
privately through their GitHub profile rather than opening a public issue.

## I Have a Question

> If you want to ask a question, we assume that you have read the available
> [Documentation](https://gabrielbdsantos.github.io/Albatross.jl/).

Before you ask a question, it is best to search the existing
[Discussions](https://github.com/gabrielbdsantos/Albatross.jl/discussions) and
[Issues](https://github.com/gabrielbdsantos/Albatross.jl/issues) that might
help you. Use Discussions for questions, usage help, design conversations, and
other topics that are not yet actionable bug reports or feature requests. Use
Issues for confirmed bugs, reproducible errors, and concrete enhancement
requests that maintainers can track to completion.

If you find a related discussion, add your question there. If you find a
related issue, only comment if you can add information that helps reproduce,
diagnose, or resolve the tracked problem. It is also advisable to search the
internet for answers first.

If you then still feel the need to ask a question and need clarification, we
recommend the following:

- Open a
  [Discussion](https://github.com/gabrielbdsantos/Albatross.jl/discussions/new).
- Provide as much context as you can about what you're running into.
- Provide project and platform versions, including your Julia version and any
  relevant package versions.

We will then take care of the discussion as soon as possible. If the discussion
identifies a confirmed bug or concrete enhancement, a maintainer may ask you to
open an issue or may open one to track the work.

## I Want To Contribute

### Legal Notice

When contributing to this project, you must agree that you have authored 100%
of the content, that you have the necessary rights to the content and that
the content you contribute may be provided under the project license.

### Reporting Bugs

#### Before Submitting a Bug Report

A good bug report shouldn't leave others needing to chase you up for more
information. Therefore, we ask you to investigate carefully, collect
information and describe the issue in detail in your report. Please complete
the following steps in advance to help us fix any potential bug as fast as
possible.

- Make sure that you are using the latest version.
- Determine if your bug is really a bug and not an error on your side e.g.
  using incompatible environment components/versions (Make sure that you have
  read the [documentation](https://gabrielbdsantos.github.io/Albatross.jl/). If
  you are looking for support, you might want to check
  [this section](#i-have-a-question)).
- To see if other users have experienced (and potentially already solved) the
  same issue you are having, check if there is not already a bug report
  existing for your bug or error in the
  [bug tracker](https://github.com/gabrielbdsantos/Albatross.jl/issues?q=label%3Abug).
- Search public forums and package discussions to see if users outside of the
  GitHub issue tracker have discussed the issue.
- Collect information about the bug:
  - Stack trace (Traceback)
  - OS, Platform and Version (Windows, Linux, macOS, x86, ARM)
  - Version of the interpreter, compiler, SDK, runtime environment, package
    manager, depending on what seems relevant
  - Possibly your input and the output
- Can you reliably reproduce the issue? And can you also reproduce it with
  older versions?

#### How Do I Submit a Good Bug Report?

> [!IMPORTANT]
> Do not report security-related issues, vulnerabilities, or bugs containing
> sensitive information in the public issue tracker. If GitHub private
> vulnerability reporting is enabled for this repository, use that channel.
> Otherwise, contact the project maintainer privately through their GitHub
> profile before sharing details.

We use GitHub issues to track bugs and errors. If you run into an issue with
the project:

- Open an [Issue](https://github.com/gabrielbdsantos/Albatross.jl/issues/new).
  Describe the problem neutrally and let maintainers apply labels after review.
- Explain the behavior you would expect and the actual behavior.
- Please provide as much context as possible and describe the
  *reproduction steps* that someone else can follow to recreate the issue on
  their own. This usually includes your code. For good bug reports you should
  isolate the problem and create a reduced test case.
- Provide the information you collected in the previous section.

Once it's filed:

- The project team will label the issue accordingly.
- A team member will try to reproduce the issue with your provided steps. If
  there are no reproduction steps or no obvious way to reproduce the issue, the
  team will ask you for those steps and mark the issue as `needs-repro`. Bugs
  with the `needs-repro` tag will not be addressed until they are reproduced.
- If the team is able to reproduce the issue, it will be marked `needs-fix`, as
  well as possibly other tags (such as `critical`), and the issue will be left
  to be [implemented by someone](#your-first-code-contribution).

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for
Albatross.jl, **including completely new features and minor improvements to
existing functionality**. Following these guidelines will help maintainers and
the community to understand your suggestion and find related suggestions.

#### Before Submitting an Enhancement

- Make sure that you are using the latest version.
- Read the [documentation](https://gabrielbdsantos.github.io/Albatross.jl/)
  carefully and find out if the functionality is already covered, maybe by an
  individual configuration.
- Perform a [search](https://github.com/gabrielbdsantos/Albatross.jl/issues) to
  see if the enhancement has already been suggested. If it has, add a comment
  to the existing issue instead of opening a new one.
- Find out whether your idea fits with the scope and aims of the project. It's
  up to you to make a strong case to convince the project's developers of the
  merits of this feature. Keep in mind that we want features that will be
  useful to the majority of our users and not just a small subset. If you're
  targeting a specialized use case, consider whether it belongs in a separate
  Julia package.

#### How Do I Submit a Good Enhancement Suggestion?

Enhancement suggestions are tracked as
[GitHub issues](https://github.com/gabrielbdsantos/Albatross.jl/issues).

- Use a **clear and descriptive title** for the issue to identify the
  suggestion.
- Provide a **step-by-step description of the suggested enhancement** in as
  many details as possible.
- **Describe the current behavior** and
  **explain which behavior you expected to see instead** and why. At this point
  you can also tell which alternatives do not work for you.
- **Explain why this enhancement would be useful** to most Albatross.jl users.
  You may also want to point out the other projects that solved it better and
  which could serve as inspiration.

### Your First Code Contribution

Albatross.jl is a Julia package under active development. Before starting a
larger change, open an issue or comment on an existing one so the scope and
approach can be discussed.

1. Install [Julia](https://julialang.org/downloads/) 1.11 or later.
1. Fork and clone the repository:

   ```sh
   git clone https://github.com/YOUR-USERNAME/Albatross.jl
   cd Albatross.jl
   ```

1. Start Julia in the repository and instantiate the project:

   ```julia-repl
   julia> import Pkg
   julia> Pkg.activate(".")
   julia> Pkg.instantiate()
   ```

1. Make the smallest focused change that solves the issue. Keep unrelated
   formatting, refactors, and generated files out of the pull request.
1. Add or update tests when behavior changes. Unit tests live in
   `test/unittests/`, and reference data lives in `test/data/`.
1. Run the test suite before opening a pull request:

   ```sh
   julia --project=. -e 'import Pkg; Pkg.test()'
   ```

The tests include standard unit tests, Aqua.jl quality checks, and JET.jl
analysis. If a check fails for a reason unrelated to your change, mention that
in the pull request description.

When useful, run examples locally as an additional smoke test:

```sh
julia --project=examples examples/example01.jl
```

Before opening a pull request, make sure:

- Tests pass, or any unrelated failures are explained.
- Relevant documentation or docstrings are updated.
- Julia code is formatted with Runic.jl.
- The pull request includes a clear summary, relevant issue links, and the
  commands you ran to verify the change.

### Improving The Documentation

Documentation improvements are welcome, including typo fixes, clearer examples,
API explanations, and additions to the theory pages.

- Public documentation source files live in `docs/src/`.
- API docstrings live next to the code they document.
- Docstring style guidance lives in `docs/templates/docstring-template.md`.
- Bibliography entries live in `docs/src/references.bib`.

Build the documentation locally with:

```sh
julia --project=docs docs/make.jl
```

When documenting behavior, prefer concise explanations of inputs, outputs,
units, assumptions, side effects, and limitations. Keep examples small enough
to run locally, and make sure names and links match the current public API.

## Styleguides

### Code Style

Format Julia code with [Runic.jl](https://github.com/fredrikekre/Runic.jl)
before opening a pull request. Prefer lines no longer than 92 columns for code,
comments, and prose. Longer lines are acceptable when wrapping would make the
code less readable.

To format Julia files in place, run:

```sh
runic --inplace src test examples docs
```

To check formatting without modifying files, run:

```sh
runic --check --diff src test examples docs
```

### Docstrings

Docstrings should follow the template in
[`docs/templates/docstring-template.md`](docs/templates/docstring-template.md).
Keep docstrings concise and focused on behavior, inputs, outputs, units,
assumptions, side effects, and limitations.

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) for commit
messages:

```text
<type>(<scope>): <title>
```

The scope is optional, so `<type>: <title>` is also valid. Prefer the following
types:

- `feat`: add a user-facing feature
- `fix`: fix a bug
- `refactor`: restructure code without changing behavior
- `perf`: improve performance
- `test`: add or update tests
- `docs`: update documentation only
- `build`: update build system or dependencies
- `ci`: update CI pipeline configuration
- `chore`: update maintenance files not covered above

Additional recommendations:

- Keep the title short, specific, present tense, and written in active voice.
- Prefer titles under 56 characters and body lines under 72 columns.
- Prefer describing changes using bullet list rather than prose. Start each
  bullet with lower case.
- If a commit changes behavior, mention the user-facing effect in the commit
  body.
- If a commit fixes an issue, reference it using `Closes #123`. For related
  discussions, include a plain reference such as `See #123`.
- For breaking changes, append `!` after the type or scope and describe changes
  in the body. Do not use a dedicated `BREAKING CHANGE:` or
  `BREAKING CHANGES:` body section.

Example:

```text
feat(geometry)!: change coordinate convention

- express blade section coordinates in the local chord frame instead of the
  global rotor frame
- add tests for the added transformation

Closes #1 and #2.
```

For pull requests, a clean history is helpful but not required. Maintainers may
ask you to split very large commits, combine noisy fixup commits, or clarify a
message before merging.

## Join The Project Team

Project team membership is based on sustained, constructive contribution.
Regular contributors may be invited to help triage issues, review pull
requests, maintain documentation, or guide specific parts of the package.

If you would like to take a more active role, start by helping with open
issues, reviewing documentation, reproducing bugs, or improving tests.
Maintainers will reach out when there is a good fit for deeper access or
responsibilities.
