# project_runner

A small, self-contained project runner for Neovim.

It detects the project in Neovim's current working directory, works out how to
build and run it, and executes the commands in a built-in terminal split.

No external plugin is required. The only dependencies are Neovim itself and the
language/build tool that your project already uses.

```text
<leader>rp  ->  detect project -> build if needed -> run
```

---

## Features

- **Build-tool detection at the project root.** Cargo, CMake, Meson, Go modules,
  Make, npm/Node, Deno, Maven, Gradle, .NET, Mix, Stack, Cabal, Dune, Gleam,
  Shards, sbt, Python packaging files, and more.
- **Works without a build tool.** If no marker is found, the entry point is
  discovered from the current buffer's language or by scanning the project.
- **Many languages.** C, C++, Rust, Go, Zig, Swift, Java, Kotlin, C#, F#,
  Fortran, Nim, Crystal, D, Python, JavaScript, TypeScript, Lua, Ruby, PHP,
  Perl, R, Julia, Elixir, Haskell, Scala, shell, HTML, and others.
- **Compiled builds go to `<root>/.build/`.**
- **Direct-compiler executables use the root directory name**, e.g.
  `/path/to/my-project/.build/my-project`.
- **No plugin dependencies.** Terminal handling, selection UI, and file search
  use only Neovim's built-in API.
- **Inspectable.** `:ProjectInfo` shows exactly what was detected and the exact
  commands that will be executed.

---

## Loading

The plugin is loaded from `init.lua`:

```lua
load_sources {
  -- ...
  "custom.statusline",
  "custom.project_runner",
}
```

Requiring the module automatically configures it with the defaults below, so
just adding it to `init.lua` is enough to get `<leader>rp`.

If you prefer explicit configuration, call `setup()`:

```lua
require("custom.project_runner").setup {
  keymap = "<leader>rp",
}
```

`setup()` may be called more than once. Each call starts from the defaults and
applies the options you pass.

---

## Commands and keymaps

| Command            | Keymap                | Description                                      |
| ------------------ | --------------------- | ------------------------------------------------ |
| `:ProjectRun`      | `<leader>rp` (default) | Build (if needed) and run the project            |
| `:ProjectBuild`    | disabled by default   | Build only                                       |
| `:ProjectRunOnly`  | disabled by default   | Run without invoking the build step              |
| `:ProjectStop`     | none                  | Stop the running project process                 |
| `:ProjectInfo`     | disabled by default   | Show detected tools, entry point, and commands   |

When more than one provider is possible (for example a `Cargo.toml` and a
`Makefile` in the same root), a `vim.ui.select` picker is shown. With a single
candidate the project is run immediately.

The process is launched in a terminal split. The project root is the working
directory for the job. Use `:ProjectStop` to stop a long-running process.

---

## Configuration

Defaults:

```lua
require("custom.project_runner").setup {
  -- Relative to the project root, or an absolute path.
  build_dir = ".build",

  -- Defaults to the basename of the root directory.  May also be a function:
  -- executable_name = function(root) return "my-app" end,
  executable_name = nil,

  -- Main mapping.  Set to false to disable.
  keymap = "<leader>rp",

  -- Optional extra mappings.
  build_keymap = false,
  info_keymap = false,

  -- Show an informational notification before launching.
  notify = true,

  -- Terminal window used for build/run output.
  terminal = {
    direction = "botright split", -- e.g. "botright vertical split", "tabnew"
    height = 15,
  },

  -- Extra flags for direct-compiler builds.
  build_args = {
    -- c = "-Wall -Wextra",
    -- cpp = "-Wall -Wextra",
  },

  -- Environment variables for the build/run process.
  env = {
    -- RUST_BACKTRACE = "1",
  },

  -- Directories skipped while searching for source files and entry points.
  ignored_dirs = {
    ".git", ".hg", ".svn", ".build", "node_modules", "target", "dist",
    "build", "out", "bin", "obj", "vendor", "venv", ".venv", "__pycache__",
    ".mypy_cache", ".pytest_cache", ".cache", "zig-cache", "zig-out",
    "CMakeFiles", "_build", "deps",
  },
}
```

---

## How detection works

### 1. Project root

The project root is Neovim's current working directory:

```vim
:cd /path/to/project
```

or, for a window-local root:

```vim
:lcd /path/to/project
```

Using the current directory makes the build directory and executable name
predictable. It also means the plugin never guesses a parent directory when you
deliberately opened a subdirectory.

### 2. Build tools first

Marker files are checked **only at the project root**. When multiple markers
exist, the provider with the highest priority wins; if several providers can
produce a plan, the picker is shown.

Examples:

| Marker(s)                              | Provider       |
| -------------------------------------- | -------------- |
| `Cargo.toml`                           | Cargo          |
| `CMakeLists.txt`                       | CMake          |
| `build.zig`                            | Zig build      |
| `Package.swift`                        | Swift Package  |
| `go.mod`                               | Go modules     |
| `meson.build`                          | Meson          |
| `package.json`                         | Node / npm     |
| `deno.json`, `deno.jsonc`              | Deno           |
| `pom.xml`                              | Maven          |
| `build.gradle`, `build.gradle.kts`     | Gradle         |
| `*.sln`, `*.csproj`, `*.fsproj`        | .NET           |
| `mix.exs`                              | Mix            |
| `stack.yaml`                           | Stack          |
| `*.cabal`, `cabal.project`             | Cabal          |
| `dune-project`                         | Dune           |
| `gleam.toml`                           | Gleam          |
| `pubspec.yaml`                         | Dart / Flutter |
| `shard.yml`                            | Shards         |
| `build.sbt`                            | sbt            |
| `pyproject.toml`, `requirements.txt`   | Python         |
| `Project.toml`                         | Julia          |
| `DESCRIPTION`                          | R              |
| `Gemfile`, `Rakefile`, `config.ru`     | Ruby           |
| `*.rockspec`                           | Lua            |
| `Makefile`, `makefile`, `GNUmakefile`  | Make           |

### 3. Language fallback

If no build tool produces a runnable plan:

1. The language of the current buffer is tried (e.g. editing `foo.rs` tries
   the Rust provider).
2. Otherwise every language provider is scanned for an entry point. Matches are
   ordered shallowest-first, so `main.py` beats `examples/tools/main.py`.

Entry-point discovery checks, in order:

1. Well-known relative paths (`src/main.rs`, `main.py`, `src/index.ts`, ...).
2. File contents for a language-specific signature (`fn main`, `int main`,
   `public static void main`, `package main`, `fun main`, ...).
3. Common file stems (`main`, `index`, `app`, `run`, `start`, `server`, `init`)
   with the language's extensions.

Directories in `ignored_dirs` (`.git`, `.build`, `node_modules`, ...) are
skipped.

---

## Build artifacts and executable names

For compiled languages:

- The build directory is `<root>/.build`.
- Direct compiler providers write the executable to
  `<root>/.build/<root-directory-name>`.
- Java and Kotlin produce `<root>/.build/<root-directory-name>.jar`.
- When a build tool insists on its own output location, the runner searches the
  tool's output directory and creates a symlink at
  `<root>/.build/<root-directory-name>` before executing it.

Examples:

```text
/path/to/hello-c/.build/hello-c
/path/to/hello-rust/.build/hello-rust
/path/to/hello-java/.build/hello-java.jar
```

Build tools that support an output override are pointed at `.build` directly:

- Cargo: `CARGO_TARGET_DIR=<root>/.build`
- CMake: `-B <root>/.build`
- Meson: `setup <root>/.build`
- Go: `go build -o <root>/.build/<name>`
- Zig: `--prefix <root>/.build`
- Swift: `--scratch-path <root>/.build`
- .NET: `-o <root>/.build`
- Mix: `MIX_BUILD_PATH=<root>/.build`
- Stack: `--work-dir <root>/.build`
- Cabal: `--builddir=<root>/.build`
- Dune: `--build-dir=<root>/.build`
- Maven/Gradle: build normally, then copy the jar to
  `<root>/.build/<name>.jar`

Some tools (Make, Shards, Gleam, sbt) choose their own build directories and do
not expose a reliable output override. Their commands are used as-is; when they
produce a native binary, the runner normalises the run path to `.build/<name>`
with a symlink. This keeps the run side consistent without making the build
command invalid.

---

## Direct-compiler languages

These providers build straight to `.build` when no build tool is present:

| Language   | Build command (simplified)                     | Run              |
| ---------- | ---------------------------------------------- | ---------------- |
| C          | `cc -O2 ... -o .build/<name>`                  | `.build/<name>`  |
| C++        | `c++ -O2 ... -o .build/<name>`                 | `.build/<name>`  |
| Rust       | `rustc -O ... -o .build/<name>`                | `.build/<name>`  |
| Go         | `go build -o .build/<name> <package>`          | `.build/<name>`  |
| Zig        | `zig build-exe ... -femit-bin=.build/<name>`   | `.build/<name>`  |
| Swift      | `swiftc -O ... -o .build/<name>`               | `.build/<name>`  |
| Java       | `javac ... && jar --create ...`                | `java -jar ...`  |
| Kotlin     | `kotlinc ... -include-runtime -d <name>.jar`   | `java -jar ...`  |
| Fortran    | `gfortran -O2 ... -o .build/<name>`            | `.build/<name>`  |
| Nim        | `nim c -d:release --out:.build/<name>`         | `.build/<name>`  |
| Crystal    | `crystal build --release -o .build/<name>`     | `.build/<name>`  |
| D          | `dmd/ldc2 -O -of=.build/<name>`                | `.build/<name>`  |
| Assembly   | `nasm -f elf64 ... && ld ...`                  | `.build/<name>`  |

C/C++ direct builds compile all source files with the matching extensions under
the root, excluding `ignored_dirs`. Projects with several independent targets
should use a real build tool.

Interpreted languages (Python, JS/TS, Ruby, PHP, Perl, R, Julia, Elixir, Lua,
shell, ...) run the discovered entry point directly. Virtual environments are
used automatically for Python when `.venv/bin/python`, `venv/bin/python`, or
`env/bin/python` exists. JavaScript/TypeScript prefer `bun`, then `deno`, then
`tsx`/`ts-node`/`node` as appropriate.

---

## Inspecting before running

```vim
:ProjectInfo
```

opens a floating window containing:

- the project root and build directory,
- every build-tool marker found at the root,
- each candidate provider and its entry point,
- the exact build and run commands.

---

## File layout

```text
lua/custom/project_runner/
├── init.lua                 # setup, commands, keymaps, public API
├── config.lua               # defaults and option merging
├── util.lua                 # path, file, glob, shell, and project helpers
├── runner.lua               # built-in terminal process runner
├── ui.lua                   # vim.ui.select wrapper and info popup
├── providers/
│   ├── init.lua             # detection order and plan resolution
│   ├── languages.lua        # language fallbacks and entry-point rules
│   └── tools.lua            # build-tool providers
└── README.md
```

Adding a language means adding an entry to `providers/languages.lua`. Adding a
build tool means adding an entry to `providers/tools.lua` with markers and a
`plan(ctx, util)` function. Neither file requires another plugin.

---

## Limitations

- The root is the current working directory. If `<leader>rp` detects the wrong
  project, `:cd` into the project root first.
- The plugin never installs dependencies or toolchains. Missing compilers or
  build tools are reported by the terminal command.
- Make and other build tools that hard-code their output paths are used as-is;
  only the final executable is normalised into `.build`.
- Building all C/C++ sources from the root is intentionally simple. Use CMake,
  Meson, or Make for multi-target projects.
- Linux, macOS, and Termux are the primary targets. Windows support uses
  `cmd.exe` and the tool's own output paths; the `find`-based artifact discovery
  used on Unix is skipped there.
- The plugin does not pass command-line arguments to the project. Add an
  `env`-based wrapper or a small build-tool script if you need fixed arguments.
