# Cloud Engineering Workspace

Building cloud services starts with a desktop environment for operation engineers that supports the efficient development, maintainance and execution of system configurations. Automating the deployment of a common toolset for teams ensures consistency, reduces deployment issues, and streamlines the collaboration with application owners and software developer. Today, most continous integration and deployment pipelines help manage the application lifecycle, but work under the assumption, that applications will be deployed against a cloud controller that orchestrates workloads on highly abstracted infrastructure. While this works for cloud-native services, the scope of programmable infrastructure enhances with applications that do not adhere to a micro-service system design. Enterprise operator need to provision of purpose build systems to accomodate the design of third party applications. Hence, effective provisioning tools ensure productivity and code quality for system engineers, but avoid dependencies on programming languages, frameworks or orchestration tools involved in the application development process. Instead package management and orchestration capabilities on operating system level enable engineers to automate the configuration of application hosts together with the deployment process and and build development environments that match the provisioning process for production server. 

## Toolset

Adopting functional deployments for applications that run on dedicated hosts demands for declarative configurations that do not abstract the runtime environment, network and storage interface. The nix package manager solves this problem for Linux systems. Nix was introduced in [2003 by Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. The nix package manager allows engineers to compose purpose build operating systems and store the configuratons in a git repository to centralize management tasks, to track and roll back system configurations. Sharing configurations in a repository fosters the development of platforms with advanced compliance and security requirements without burdening application owners or development teams. Using these files for development, test and production enables the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations. A local development environment compromises the following tools:

* **[Linux Sandbox](https://chromeos.dev/en/linux)**: Debian VM or Container that allows developers to run Linux apps for development alongside the usual desktop and applications.
* **[Nix Package Manager](https://nixos.org/)**: A Linux configuration manager that enables reproducible and declarative builds for virtual machines.
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

The [Home Manager](https://nix-community.github.io/home-manager/) is a Nix-powered tool for the definition of user environment settings and applications on a linux system. Sharing the configurations through git makes it easy to deploy and maintain a common toolset for system administrators and operation engineers. Adding the home-manager with a common configuration is simplified using the nix-shell that allows temporarily load and use packages. 

```sh
nix-shell -p gh --run "gh auth login"
```

The github client is used to load a default configuration and ensures the use of a homogenous toolset accross of development and production environments in a team. The configuration is splitted between two files, the set of applications is defined in `home.nix`, system configurations are stored in a file called ´flake.nix´. Flakes are still classified as experimental feature in Nix, enabling flakes requires to append a flag `/etc/nix/nix.conf`. After that the the appropriate nix package channel is added and updated.

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

## Project Environments

While operation teams are organized around palform services, development teams are organized around solutions. 

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

