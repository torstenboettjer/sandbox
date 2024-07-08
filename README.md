# Cloud Engineering Workspace

Developing cloud services starts with providing a desktop environment for operation engineers that automates build and maintainance processes for operating system configurations. An ubiquitous toolset should ensure consistency, reduces deployment issues, and streamline the application development process. Providing the right toolset for application developers, significantly enhances productivity, code quality, and collaboration, hence the system configuration toolchain needs to avoid any impact on the selection of programming languages or frameworks involved in the application development process. Instead, configuration tools used for the development of managed services need to support the provisioning process of production grade systems. Most application developers have moved continous integration and deployment pipelines to a version control system like Github, but common CI/CD toolchains work under the assumption, that applications will be deployed against a cloud controller that orchestrates workloads on highly abstracted infrastructure. For the deployment of enterprise applications this is a sginifcant constraint and limits the ability to operate services efficiently and secure, because many enterprise applications do not adhere to the cloud-native application design. Moving software-based provisioning to the operating system level allows to overcome these limitations and allows to introduce DevOps processes in enterprise IT with less friction.

## Toolset

Adopting functional deployments for applications that run on dedicated hosts demands for declarative configurations that do not abstract the runtime environment, network and storage interface. The nix package manager solves this problem for Linux systems. Nix was introduced in [2003 by Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. The nix package manager allows engineers to compose purpose build operating systems and store the configuratons in a git repository to centralize management tasks, to track and roll back system configurations. Sharing configurations in a repository fosters the development of platforms with advanced compliance and security requirements without burdening application owners or development teams. Using these files for development, test and production enables the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations. A local development environment compromises the following tools:

* **[Linux Environment](https://chromeos.dev/en/linux)**: Debian VM or Container that allows developers to run Linux apps for development alongside the usual desktop and applications.
* **[Nix](https://nixos.org/)**: Linux package manager that enables reproducible and declarative builds for virtual machines, the home manager ensures a homogenous toolset.
* **[Process-compose](https://f1bonacc1.github.io/process-compose/)**: Command-line utility to facilitate the management of processes without further abstraction.
* **[Devenv](https://devenv.sh/)**: Configuration tool to define development environment declaratively by toggling basic options for nix and process-compose.
* **[Direnv](https://direnv.net/)**: Shell extension to load and unload devenv environments automatically moving in and out of a directory.

## Sandbox

Desktop systems like [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux) let developers to run a Linux environment without without installing a second operating system. For MacOS there is a [community project](https://github.com/LnL7/nix-darwin). For a development environment the avialable disk size should be at least *80GB*, after that the Nix package manager can be installed. 

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```

The package manager enables functional deployments and provides features like reproducibility, isolation, and atomic upgrades. Key features is ensuring a consitent package deployments through precise specification of dependencies and build instructions. To activate the package manager, reference is added to the shell configuration, after the installation, the session requires a restart.

```sh
exec bash && source ./.bashrc
```

### Setup a common toolset with home-manager

The home-manager enables nix operators to define and manage local environment settings, applications, and configurations through a common repository. This makes it easy to deploy and maintain a consistent toolsets accross users. The installation is automated using the nix-shell that allows temporarily load and use packages. 

```sh
nix-shell -p gh --run "gh auth login"
```

The system configuration is stored in a file called ´flake.nix´, tools are defined in `home.nix`. Flakes are still classified as experimental feature in NixOS. Enabling flakes requires to append the following line to `/etc/nix/nix.conf` and adding the appropriate Nixpkgs channel.

```sh
# clone the default home-manager configuration 
gh repo clone hcops/workspace

# activating experimental features
echo -e "experimental-features = nix-command flakes\ntrusted-users = root torsten" | sudo tee -a /etc/nix/nix.conf

# add the home-manager package channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

# updte the home manager channel
nix-channel --update

# create the first home-manager generation
nix-shell '<home-manager>' -A install

# add the nix path to `.bashrc`
echo -e '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >> $HOME/.profile

# test the installation
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh && home-manager --version
```

Make sure that the right system is active in *~/workspace/flake.nix*

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
for file in home.nix flake.nix; do ln -s "$HOME/workspace/$file" "$HOME/.config/home-manager/$file"; done
```

Run the Makefile to update the minimal configuration

```sh
cd ~/workspace
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

