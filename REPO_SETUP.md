# Project Setup Using Google Repo

This document provides detailed instructions for cloning and setting up this project with the Google Repo tool.

## What is Google Repo?

Google Repo is a multi-repository tool that simplifies the management of multiple Git repositories. It uses a manifest file to track and synchronize multiple projects.

## Installation

### Linux/macOS

```bash
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# Add ~/bin to your PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Verify Installation

```bash
repo --version
```

## Project Setup

### 1. Create a workspace directory

```bash
mkdir -p ~/yocto-workspace
cd ~/yocto-workspace
```

### 2. Initialize the Repo Manifest

```bash
repo init -u https://github.com/JohnBlue-git/HowToYocto.git -b main
```

Options:
- `-u`: URL of the manifest repository
- `-b`: Branch to check out (main, develop, etc.)
- `--repo-url`: Custom git-repo clone URL (optional)

### 3. Synchronize All Projects

```bash
repo sync
```

This command will:
- Clone the Poky repository from Yocto
- Clone/update the meta-application layer from this project
- Set up all projects according to `default.xml`

## Project Structure After Setup

After running `repo sync`, your workspace will have:

```
~/yocto-workspace/
├── .repo/                          # Repo metadata and configuration
│   ├── manifests/                 # Manifest repository (this project)
│   │   └── default.xml            # Main manifest file
│   ├── projects/                  # Working directories snapshot
│   └── repo                        # Repo tool
├── poky/                          # Yocto Poky project
│   ├── bitbake/
│   ├── meta/
│   ├── meta-poky/
│   ├── meta-yocto-bsp/
│   └── ...
└── meta-application/              # Your custom layer
    ├── conf/
    │   └── layer.conf
    ├── recipes-hello/
    └── COPYING.MIT
```

## Building the Project

### 1. Initialize Build Environment

```bash
cd ~/yocto-workspace
cd poky
source oe-init-build-env build
```

### 2. Build an Image

```bash
bitbake core-image-minimal
```

### 3. Generated Artifacts

Images are available at: `build/tmp/deploy/images/qemux86-64/`

## Common Repo Commands

### Check Project Status

```bash
# Show all projects and their branches
repo branches

# Show all projects
repo project-list

# Show changes in all projects
repo status
```

### Update Projects

```bash
# Pull latest changes from all projects
repo sync

# Update only a specific project
repo sync meta-application
```

### View Project Information

```bash
# Show information about a project
repo info meta-application

# Show the manifest content
repo manifest -r -o manifest.xml
```

### Switch Branches

```bash
# Switch Poky to a different branch
cd poky
git checkout dunfell

# Update manifest to track new branch
# (Edit .repo/manifests/default.xml and change revision)
```

## Modifying the Manifest

The manifest file is located at `.repo/manifests/default.xml`

### To Add a New Project

Edit `.repo/manifests/default.xml`:

```xml
<project name="your-new-project" path="path/to/new-project" remote="origin" revision="main" />
```

Then run:

```bash
repo sync
```

### To Change Poky Branch

Edit `.repo/manifests/default.xml` and change:

```xml
<project name="poky" path="poky" remote="yocto" revision="kirkstone" />
```

To use a different branch (e.g., dunfell, honister, honister, master):

```xml
<project name="poky" path="poky" remote="yocto" revision="dunfell" />
```

Then run:

```bash
repo init -u <manifest-url>
repo sync
```

## Contributing Changes

### In meta-application

```bash
cd meta-application
git checkout -b feature/my-feature
# Make your changes
git commit -am "Add my feature"
git push origin feature/my-feature
# Create a pull request on GitHub
```

### Tracking Changes Across Projects

```bash
# See what changed across all projects
repo diff

# Show all modified projects
repo status
```

## Troubleshooting

### Manifest Issues

```bash
# Verify manifest syntax
repo manifest -r -o manifest.xml

# Reinitialize repo if there are issues
repo forall -c 'git status'
```

### Permission Denied Issues

If you encounter permission issues with SSH:

```bash
# Use HTTPS instead of SSH
# Edit ~/.ssh/config or use https:// URLs in manifest
repo remote -l
```

### Cleaning Up

```bash
# Remove all changes and reset to manifest state
repo forall -c 'git reset --hard'

# Clean up untracked files
repo forall -c 'git clean -fdx'
```

## References

- [Google Repo Official Documentation](https://gerrit.googlesource.com/git-repo/+/refs/heads/master/README.md)
- [Android Repo Command Reference](https://source.android.com/setup/build/downloading#using-a-repo-client)
- [Yocto Project Documentation](https://docs.yoctoproject.org/)
