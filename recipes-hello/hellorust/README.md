# Rust Recipe for Yocto - hellorust

## Overview

This recipe demonstrates how to create and build a Rust project using Yocto/Bitbake. The `hellorust` recipe compiles a Rust binary and integrates it into the Yocto build system.

## Current Status ✓

- ✅ Project directory structure created
- ✅ `hellorust` Rust project initialized  
- ✅ `Cargo.lock` generated
- ✅ `hellorust.bb` recipe file configured
- ✅ `meta-application` layer added to `bblayers.conf`
- ⏳ Ready for building

## Prerequisites

### 1. Install Cargo and Rust

Cargo is required for local Rust development. Install using rustup:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
cargo --version
```

### 2. Install Build Tools

Ensure these required build tools are available:

```bash
sudo apt install -y chrpath cpio diffstat zstd
```

## Recipe Setup Workflow

### Step 1: Directory Structure

Create the following structure under your layer:

```
meta-application/recipes-hello/hellorust/
├── files/
│   └── hellorust/          # Your Rust project
│       ├── Cargo.lock
│       ├── Cargo.toml
│       ├── src/
│       │   └── main.rs
├── hellorust.bb             # Recipe file
└── README.md                # This file
```

### Step 2: Create Rust Project

```bash
cd meta-application/recipes-hello/hellorust/files/
cargo new hellorust
cd hellorust
```

### Step 3: Configure Cargo.toml

Edit `Cargo.toml` to specify your package and dependencies:

```toml
[package]
name = "hellorust"
version = "0.1.0"
edition = "2021"

[dependencies]
# Add crate dependencies as needed
# Example: rand = "0.8.5"
```

### Step 4: Write Your Rust Code

Edit `src/main.rs`:

```rust
fn main() {
    println!("Hello from Yocto!");
}
```

### Step 5: Generate Cargo.lock

```bash
cargo generate-lockfile
```

### Step 6: Create Bitbake Recipe

Create `hellorust.bb`:

```bitbake
SUMMARY = "Simple Hello World Rust application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

S = "${WORKDIR}/hellorust"
SRC_URI = " \
    file://hellorust \
    "

inherit cargo cargo_common
```

## Building the Recipe

### Ensure Layer is Configured

Make sure `meta-application` is included in `build/conf/bblayers.conf`:

```conf
BBLAYERS ?= " \
  /workspaces/HowToYocto/poky/meta \
  /workspaces/HowToYocto/poky/meta-poky \
  /workspaces/HowToYocto/poky/meta-yocto-bsp \
  /workspaces/HowToYocto/poky/meta-application \
  "
```

### Build the Recipe

```bash
cd /workspaces/HowToYocto/poky/build
bitbake hellorust
```

### Verify the Build

After successful build, check the output:

```bash
# Check if binary was installed
find ./tmp/work -name "hellorust*" -type f

# View recipe details
bitbake hellorust --show-recipe
```

### Expected Build Output

Successful build will show:
```
Loading cache: 100% |#################| Time: 0:00:XX
Loaded XXXX entries from dependency cache.
NOTE: Running task 1 of X...
NOTE: hellorust do_fetch
NOTE: hellorust do_unpack  
NOTE: hellorust do_patch
NOTE: hellorust do_configure
NOTE: hellorust do_compile
NOTE: hellorust do_install
```

### Advanced: Using cargo-update-recipe-crates

If you need to generate crate dependencies automatically:

1. Add to recipe:
   ```bitbake
   inherit cargo cargo_common cargo-update-recipe-crates
   ```

2. Generate crate metadata:
   ```bash
   bitbake hellorust -c update_crates
   ```

3. This creates `hellorust-crates.inc`, add to recipe:
   ```bitbake
   require hellorust-crates.inc
   ```

4. Build normally:
   ```bash
   bitbake hellorust
   ```

## Key Concepts

| Concept | Description |
|---------|-------------|
| **S** | Source directory path in build workspace |
| **SRC_URI** | Where to fetch source files (`file://` for local files) |
| **inherit** | Include BitBake classes for build configuration |
| **cargo.bbclass** | Base Rust/Cargo build class |
| **cargo_common.bbclass** | Common Cargo configuration |

## Troubleshooting

| Error | Solution |
|-------|----------|
| `ERROR: Nothing PROVIDES 'hellorust'` | Add `meta-application` to `BBLAYERS` in build/conf/bblayers.conf |
| `Could not inherit file classes/cargo-update-recipe-crates.bbclass` | Remove `cargo-update-recipe-crates` from inherit, or create the class if needed |
| `ERROR: Task do_update_crates does not exist` | This task requires `cargo-update-recipe-crates` class (not in standard Poky) |
| Missing build tools | Install: `chrpath cpio diffstat zstd` |
| `ERROR: hellorust do_prepare_recipe_sysroot` | Ensure `Cargo.toml` and project files exist in `files/hellorust/` |
| Cargo/Rust not found | Run: `. $HOME/.cargo/env` to load Rust environment |

### Debug a Failed Build

```bash
# Clean and rebuild
bitbake hellorust -c clean
bitbake hellorust

# View detailed task output
bitbake hellorust -v

# Check recipe parsing
bitbake hellorust --show-recipe

# View log files
find ./tmp/work -name "*.log" -o -name "log.*"
```

## Common Cargo Commands

```bash
# Create new project
cargo new <project_name>

# Build locally
cargo build --release

# Generate lockfile
cargo generate-lockfile

# Update dependencies
cargo update

# Run tests
cargo test
```

## Files Reference

- [hellorust.bb](hellorust.bb) - Main BitBake recipe file
- [files/hellorust/](files/hellorust/) - Rust project source code
- [files/hellorust/Cargo.toml](files/hellorust/Cargo.toml) - Project manifest
- [files/hellorust/Cargo.lock](files/hellorust/Cargo.lock) - Dependency lockfile
- [files/hellorust/src/main.rs](files/hellorust/src/main.rs) - Rust source code

## References

- [Yocto Project Manual](https://www.yoctoproject.org/docs/)
- [Rust in Embedded Systems](https://docs.rust-embedded.org/)
- [BitBake User Manual](https://docs.yoctoproject.org/bitbake/)
