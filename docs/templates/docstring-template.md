# Docstring Template

Use this template for docstrings across Albatross.jl.

## General Guidelines

- Wrap docstring at a maximum of 79 characters per line.
- Keep wording precise, non-repetitive, and behavior-focused.
- Use a one-line summary first; add an optional second paragraph only when
  needed.
- Prefer SI units and symbols used in the codebase (for example: `θ`, `Δθ`,
  `ρ`, `μ`) and state units explicitly when relevant.
- Start field, argument, and keyword-argument descriptions with uppercase text.
- End field, argument, return, throws, and descriptive note bullets with a
  period. Omit periods for bare interface-method and See Also link lists.
- Use Documenter cross-references for public APIs, e.g. [`solve`](@ref).
- Include only sections that add value for the documented symbol.
- `# Notes` should only be included for non-obvious design decisions,
  constraints, or assumptions.
- Format docstrings with `rumdl`.
- When a signature (method/type) exceeds 79 columns, break lines as:

```julia
"""
    method(argument1, argument2, argument3, argument4, argument5, argument6,
        argument7, argument8; kwarg1 = default1, kwarg2 = default2,
        kwarg3 = default3, ...)
"""

"""
    TypeName{T1, T2, T3,
        T4, T5}
"""
```

## Repository Patterns

- For abstract interfaces, document expected methods under
  `# Interface Methods` using [`name`](@ref) links.
- For struct fields, describe semantics and units even when fields are left
  untyped in code.
- For mutating APIs (`!` methods), document the in-place contract explicitly.
- If a limitation is important for users, use a short `!!! note` block.

## Specific Guidelines

### Abstract Types / Interfaces

Preferred sections:

- `# Interface Methods`
- `# Notes` (usage conventions or extension guidance)
- `# See Also` (optional)

Example:

```julia
"""
    AbstractThing

Abstract supertype for `<domain>` models.

# Interface Methods

- [`required_method`](@ref)
- [`other_required_method`](@ref)

# Notes

- Convention required by downstream solvers.
"""
abstract type AbstractThing end
```

### Functions

#### Out-Of-Place / Non-Mutating

Preferred sections:

- `# Arguments`
- `# Keyword Arguments` (when applicable)
- `# Returns`
- `# Throws` (when applicable)
- `# Notes` (non-obvious decisions only)
- `# See Also` (optional)

Example:

```julia
"""
    function_name(arg1, arg2; kw1=default)

<One-line behavior-focused summary in present tense>.

<Optional second paragraph for context, assumptions, or
non-obvious behavior>.

!!! note "Limitations"

    Optional: include only when a limitation materially affects usage.

# Arguments

- `arg1::Type`: Meaning, units/range, and key constraints.
- `arg2::Type`: Meaning and shape/size expectations.

# Keyword Arguments

- `kw1::Type=default`: Meaning and effect.

# Returns

- `ReturnType`: What is returned, including shape/semantics.

# Throws

- `ExceptionType`: Condition that triggers it.

# Notes

- Assumptions or model-specific conventions.

# See Also

- [`related_fn`](@ref), [`other_fn!`](@ref)
"""
function function_name(arg1, arg2; kw1=default)
    ...
end
```

#### In-Place / Mutating

Preferred sections:

- `# Arguments`
- `# Keyword Arguments` (when applicable)
- `# Throws` (when applicable)
- `# Notes` (non-obvious decisions only)

If a mutating method returns `nothing`, omit `# Returns`.
If it returns a value, include `# Returns`.

Example:

```julia
"""
    function_name!(state, input; ...)

Update `<state>` in-place using `<input>`.

!!! note "Limitations"

    Optional: include only when a limitation materially affects usage.

# Arguments

- `state::Type`: Mutated object. Required shape/size expectations.
- `input::Type`: Input data contract.

# Keyword Arguments

- `...`

# Throws

- `DimensionMismatch`: When input sizes are incompatible.

# Notes

- In-place contract and required preconditions.

# See Also

- [`related_fn`](@ref), [`other_fn!`](@ref)
"""
function function_name!(state, input; ...)
    ...
end
```

### Types/Structs

Preferred sections:

- `# Fields`
- `# Notes` (usage constraints or key relationships)

Do not document constructors in the type docstring.

For structs with inferred/untyped fields, document expected value semantics,
units, and invariants in `# Fields`.

Example:

```julia
"""
    TypeName{...}

<Role of this type in the package>.

# Fields

- `field1`: Meaning, units, and expected value contract.
- `field2`: Meaning and relationship to other fields.

# Notes

- Usage constraints and relationship to key methods.
"""
struct TypeName{T1, T2}
    ...
end
```

#### Constructors

- Document constructors in their own method docstrings.
- For inner constructors, attach docs explicitly with `@doc """ ... """`
  and define the method on the next line.
- Include summaries in constructors only when behavior is non-obvious
  (validation, coercion, normalization, defaults, special errors, etc.). If
  constructor behavior is straightforward, omit generic summaries like
  `Construct <TypeName> ...`.

Example:

```julia
@doc """
    TypeName(arg1, arg2)

Validate `arg1` and `arg2` and normalize stored coefficients.

# Throws

- `DimensionMismatch`: If `arg1` and `arg2` do not have matching lengths.
"""
function TypeName(arg1, arg2)
    ...
end
```
