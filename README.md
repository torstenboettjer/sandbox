# Cloud Engineering Workspace

Creating local development environments for operation engineers that enables teams to build and maintain cloud services with a shared, homogenous operating system configuration ensures consistency, reduces deployment issues, and streamlines the development process. Having the right toolset within application development teams, significantly enhances productivity, code quality, and collaboration, hence the system configuration toolchain needs to avoid any impact on the selection of programming languages or frameworks involved in the application development process. Instead, configuration tools need to support production grade deloyments to empower a continous integration and deployment pipeline that is managed in a version control system. Today, common CL/CD toolchains work under the assumption, that applications will be deployed against a cloud controller that orchestrates workloads on highly abstracted infrastructure. For enterprise applications this is a sginifcant constraint and limits the ability to migrate applications effectively. Moving software-based provisioning to the operating system level allows to overcome this limitation and allows to introduce DevOps processes in enterprise IT with less friction.

## Nix-based Toolset

The nix package manager enables a declarative configuration of the operating system without abstracting the runtime environment, the network and the storage interface. It allows engineers to compose the operating system for different pusposes differently and enables operators to centralize the extension of golden images, track and rollback configuration changes. Managing the configuration of the operating system through the configuration files, shared in a git repository, fosters the centralization of system designs without becoming a burden to decentral development teams and enables smooth transition from development to production throuch a joined deployment process. Engineers developing infrastructure blueprints, need access to the following tools on their local desktops:

* **[Linux Environment](https://chromeos.dev/en/linux)**: Debian VM or Container that allows developers to run Linux apps for development alongside the usual desktop and applications.
* **[Nix](https://nixos.org/)**: Linux package manager that enables reproducible and declarative builds for virtual machines, the home manager ensures a homogenous toolset.
* **[Direnv](https://direnv.net/)**: Shell extension to load and unload environment variables depending on the current directory.
* **[Process-compose](https://f1bonacc1.github.io/process-compose/)**: Command-line utility to facilitate the management of processes without further abstraction.
* **[Devenv](https://devenv.sh/)**: Configuration tool to define development environment declaratively by toggling basic options for nix, direnv and process-compose.

## Linux Environment

The foundation for service engineering is a local Linux sandbox. A sub-system like the ChromeOS [Linux Development environment](https://chromeos.dev/en/linux) is sufficient. It is easy to set up and addresses development needs.

* Name: torsten
* Size: 85 GB

## Packet Manager

The [Nix package manager](https://nixos.org/) allows engineers to build and manage software packages. It enables functional deployments and provides features like reproducibility, isolation, and atomic upgrades. Key features is ensuring that a package is built in the same way every time, regardless of the environment, which is achieved through precise specification of dependencies and build instructions.

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```
### Home-Manager

Use `gh` nix package to clone the github repository

```sh
nix-shell -p gh
```

Log into github

```sh
gh auth login
```

Clone home manager repository

```sh
gh repo clone hcops/home_manager
```

#### Enable Flakes

Flakes are still classified as experimental feature in NixOS. Enabling flakes requires to append the following line to `/etc/nix/nix.conf`:

```sh
echo -e "experimental-features = nix-command flakes\ntrusted-users = root torsten" | sudo tee -a /etc/nix/nix.conf
```

Run functional test

```sh
nix run nixpkgs#hello
```

#### Select the home-manager channel

Add and than update the appropriate channel, e.g. to follow the Nixpkgs master channel run:

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

#### Installation

Create the first home-manager generation

```sh
nix-shell '<home-manager>' -A install
```

Add the nix path to `.bashrc`

```sh
echo -e '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >> $HOME/.profile
```

Test the installation

```sh
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
home-manager --version
```

Make sure that the right system is active in *~/home_manager/flake.nix*

```nix
  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      # system = "x86_64-linux";
      system = "aarch64-linux";
```

Link the home manager configruation files to the repository

```sh
rm ~/.config/home-manager/home.nix ~/.config/home-manager/flake.nix
for file in home.nix flake.nix; do ln -s "$HOME/home_manager/$file" "$HOME/.config/home-manager/$file"; done
```

Run the Makefile to update the minimal configuration

```sh
cd ~/home_manager
make update
```

## Shell Extension

Activating direnv, an environment switcher for the shell that automatically loads and unloads environment variables, when the directory is changed

```sh
echo -e 'eval "$(direnv hook bash)"' >> $HOME/.bashrc
```

## Development Environments

Devenv is a tool that leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. A development environment is defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github.

```sh
devenv init
```

Will create the following files{subdirectories in a given repository: `.envrc, devenv.nix, devenv.yaml, .gitignore`. The nix file contains the system software and platform components, required to build an applications.

