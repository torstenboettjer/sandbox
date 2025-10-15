# Hybrid Cloud Sandbox

Developing new services for a hybrid cloud is difficult and slow because of complex interdependencies between network and security settings and the service's configuration and because it's tough to replicate essential supporting services (like databases) outside the dynamic, container-based part of the cloud. This project offers a configurable sandbox to speed up development by solving the replication problem. It creates a full, reproducible copy of a service's setup, including the service itself and its supporting services. The sandbox is isolated at the operating system level, this means the replicated environment is kept completely separate and won't interfere with your host computer. It is primarily built on NixOS and uses the Nix package manager to guarantee that the environment is reproducible. It can also run on [Windows (via WSL)](https://learn.microsoft.com/en-us/windows/wsl/about), [ChromeOS (via CROSH)](https://chromeos.dev/en/linux), and [macOS](https://github.com/LnL7/nix-darwin) with minor adjustments.

## Key Design Criteria

The sandbox is built with the following criteria to ensure that the services developed within it are reproducible and reliable:

* *No Vendor Lock-in:* It must be independent of specific production tools or hosting services (like Kubernetes or a particular cloud provider). This ensures the operating model can be freely chosen for deployment.
* *Flexible and Portable:* It needs a flexible system configuration to allow the service to be deployed and run on any diverse hardware platform.
* *Secure Distribution:* It must use a package cache for distribution. This provides supply chain control and enables secure, non-interactive, unattended updates.
* *Reliable Rollbacks:* The system configurations must be declarative (describing what the system should look like, not how to build it). This allows for fast and easy rollbacks if any malfunction occurs.

The development environment is designed to be a portable, secure, and easily reversible environment that doesn't dictate your final production setup.

## Technology Stack

Relying on a programmable package manager gives engineers architectural freedom and a clean separation of concerns, making the path from code to compliant, optimized production deployment faster and simpler. It doesn't force developers to adhere to specific design rules, like microservices or three-tier architecture. Instead, it uses a functional system-configuration language to easily handle complex hybrid cloud setups, rapidly accelerating the transition from development to testing and production. The package manager handles system configuration, making separate tools like Ansible, Script Runner, or Rundeck unnecessary. This also avoids the need for heavy hypervisors or container clusters when simple virtualization is better. After development is finished, the Operations team remains flexible to choose the best way to deliver a service component, focusing only on the application's actual needs. Unlike traditional automation that mixes everything together, this system keeps application requirements separate from the underlying system and cloud-provider details. This clear separation allows operators to easily enforce security policies and validate regulatory compliance before the service is even launched.

| Layer | Scope |  Purpose |
| :------- | :------- | :------- |
| Base System | Hardware drivers, core operating system needs, and low-level security/monitoring agents | A system flake captures where the service is running (e.g., cloud mobility settings) but is kept separate from the actual application code to prevent platform lock-in. |
| Backend Services | Databases or messaging systems | An environment flake links developer machines to backend components, ensuring everyone across teams is working with an identical, homogeneous development environment. |
| Developer Tools | IDE, Git, diagramming apps and individual service configurations | The user flake is unique to each engineer, it ensures personal productivity by allowing customizations to the local toolset and override defaults without causing security or system conflicts. |


The default setup for a sandbox is a local machine, engineers can easily override any default setting in their personal User Flake without requiring security approval or breaking the standardized lower layers. By defining the entire stack from hardware to developer tools in these files, architects and security teams can launch fully isolated machines to test the functional model before it moves to staging or production. This system eliminates the need for high-level management tools and provider-specific orchestrators. The configurations are shared via Git, which enables a decentralized development process. The programmatic assembly of the server ensures that deployments are reproducible, isolated, and allow for atomic upgrades across any vendor or solution. Separating dependencies and build instructions into different files creates a clear separation of duties—operators can manage system compliance and security without needing to touch the application requirements defined by developers.

### Base System

The System Flake is the most foundational part—it's the core control file for the entire operating system. It is stored in the traditional, protected spot, */etc/nixos*. This location is root-owned, meaning only administrators can change it, which keeps the base system secure and stable. This configuration manages everything essential for the host to run, including the kernel, core NixOS services, basic user accounts, and all Nix settings. The System Flake is the blueprint for the host machine itself.

| Directory | Location | Purpose |
| :------- | :------ | :------- |
| flake.nix  |  /etc/nixos/flake.nix |  Defines the host machine's configuration output (e.g., nixosConfigurations."myserver").  |
| configuration.nix |  /etc/nixos/configuration.nix |  Imports base modules, sets up users (e.g., users.users.alice), enables direnv and core services.  |

### Backend Services

The Environment Flake defines the specific tools and settings for a single project, keeping development environments separate and consistent for the entire team. It it is stored within the project's code directory, typically at *~/projects/myproject*. It's tied directly to the project code using a tool like direnv. This means as soon as a developer enters that project folder, the correct environment and tools automatically load. This configuration achieves project isolation and ensures every team member is using the exact same project-specific tools, backend services, and dependencies. The Environment Flake makes sure the project's development environment travels with the code.

| Directory | Location | Purpose |
| :------- | :------ | :------- |
| flake.nix | ~/projects/myproject/flake.nix | Defines the devShells.x86_64-linux.default output and pins the specific, potentially older/unstable nixpkgs version needed for the project. |
| shell.nix | ~/projects/myproject/shell.nix | Imported by flake.nix, defines the contents of the shell environment. |
| .envrc | ~/projects/myproject/.envrc | Contains the single line: use flake to enable direnv integration. |
| flake.lock | ~/projects/myproject/flake.lock | Locks the version of nixpkgs used for project dependencies. This is the key to isolation. |

Direnv is an important enabler for project configurations, setting it up, nix flakes have to be enabled. On NixOS direnv should be installed by default, for manual installations, the use_nix or use_flake functionality needs to be made available.

#### The use_flake Method (Recommended)
The best and most modern way to integrate Nix flakes with direnv is by using the use_flake helper function. In the environment flake (e.g., in ~/dev-env-A/flake.nix), devShells outputs should be defined. This is the part that direnv will load.

```sh
# ~/dev-env-A/flake.nix
{
  # ... inputs defined here ...
  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    # 💡 Dev Shells output is what direnv looks for
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        # Environment-specific tools
        docker # System engineer tool
        kubectl
        go
      ];

      # Environment variables for the shell
      shellHook = ''
        echo "Nix Dev Environment A (Legacy) loaded."
        export PROJECT_ROOT="$(pwd)"
      '';
    };
  };
}
```

In the root of that same directory (~/dev-env-A), create a .envrc file with a single line:

```sh
# ~/dev-env-A/.envrc
use flake
```

The first time you do this, direnv will ask for permission (a security measure to prevent arbitrary code execution):

```sh
cd ~/dev-env-A
# direnv: error .envrc is blocked. Run `direnv allow` to approve its contents
direnv allow
```

Now, every time a developer *cd* into ~/dev-env-A:
* direnv reads .envrc.
* use flake tells direnv to find the nearest flake.nix file.
* direnv calls nix develop --command bash (or equivalent) for the default devShells output.
* The specified packages (docker, kubectl, go) and the shellHook are loaded into your current shell session.

#### Alternative: Specifying the Flake Output

If a flake has multiple shell outputs, developers can specify exactly which one to use in your .envrc:

```sh
# ~/dev-env-A/.envrc
# Use a specific shell output named 'backend'
use flake .#backend
```

### Developer Tools
The User Flake is the single source of truth for an individual developer's personal setup. It itis stored in the user's configuration directory, typically at *~/.config/*. It defines all user-level applications and personal settings (called "dotfiles"). By storing the entire Home Manager configuration, this single file ensures that your personal toolset and preferences are identical across all the machines and environments you use. The User Flake is your personalized setup that follows you everywhere.

| Directory | Location | Purpose |
| :------- | :------ | :------- |
| flake.nix  |  ~/.config/flake.nix  |  Defines homeManagerModules.common (your shared config) and pins its own nixpkgs version.  |
| modules/common/default.nix  |  ~/.config/modules/common/default.nix  |  The shared core file. Defines all common packages (tmux, neovim, git config) and modules (your default.nix content).  |
| modules/profiles/desktop.nix  |  ~/.config/modules/profiles/desktop.nix  |  Optional: Contains modules for desktop-only apps (like window manager config).  |
| flake.lock  |  ~/.config/flake.lock  |  Locks the version of Home Manager and nixpkgs used for user configuration.  |

Environment Flakes import this user flakes as an input (e.g., inputs.my-home.url = "path:~/dotfiles").

## Workflow Summary
To boot the machine: Run sudo nixos-rebuild switch --flake /etc/nixos#myserver.
To change your shared user tools: Edit ~/dotfiles/modules/common/default.nix and run home-manager switch --flake ~/dotfiles#<username>.
To work on a project: cd ~/projects/project-X. direnv automatically loads the project's specific shell, which imports the consistent user packages defined in your ~/dotfiles flake.

## Subscribe to a common developer toolset
A shared Home Manager module *shell.nix* in the home directory maintains a consistent developer application set across environments. This ensures that all developer environments share the same user-level applications, dotfiles, and shell settings via the shared Home Manager code. Eventhough each developer environment flake can use a different nixpkgs version (e.g., for specific system libraries).

### Create a Dedicated Home Manager Flake (The Source of Truth)
Create a separate repository or directory (e.g., ~/dotfiles) that houses your user configuration logic.

```sh
# ~/dotfiles/flake.nix This flake's primary job is to expose the shared configuration logic as a reusable module.
{
  description = "Shared Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, ... }: {
    # 💡 The key is defining a reusable module output
    homeManagerModules.common = import ./default.nix;

    # Optionally, expose the standalone configuration for non-NixOS
    homeConfigurations."alice" = home-manager.lib.homeManagerConfiguration {
      # ...
    };
  };
}
~/dotfiles/default.nix (Your shared application set) This file defines all your core user applications and dotfiles.

{ config, pkgs, lib, ... }:

{
  # Define all the user packages you want in ALL environments
  home.packages = with pkgs; [
    git
    tmux
    neovim
    jq
    htop
  ];

  # Define common dotfile configurations
  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.git.userName  = "Alice Engineer";

  # Allow customization based on the environment importing this file
  # Example: Only enable a graphical tool if the environment is a desktop one
  # programs.alacritty.enable = lib.mkIf config.custom.isDesktop;

  home.stateVersion = "24.05";
}
2. Import the Home Flake into Your Environment Flakes
Now, in each of your developer environment flakes (e.g., ~/dev-env-A and ~/dev-env-B), you import the shared Home Flake and use its module output.

~/dev-env-A/flake.nix (The NixOS configuration for a development system)

{
  description = "NixOS Config for Dev Environment A (Legacy)";

  inputs = {
    # Pin a specific, stable nixpkgs version for isolation
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    # Import your shared home configuration
    my-home.url = "path:~/dotfiles"; # Use path: for local file system
    # my-home.url = "github:alice/dotfiles"; # Use github: for remote repo

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # HM follows THIS flake's pkgs
  };

  outputs = { self, nixpkgs, my-home, home-manager, ... }: {
    nixosConfigurations."dev-machine" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # ... Other NixOS modules

        # 💡 Import Home Manager as a module
        home-manager.nixosModules.home-manager {
          home-manager.useUserPackages = true;
          home-manager.users.alice = {
            imports = [
              # 💡 Import the shared module from the 'my-home' input!
              my-home.homeManagerModules.common

              # Add environment-specific overrides/packages here:
              { home.packages = with pkgs; [ specific-tool-v1.0 ]; }
            ];
          };
        }
      ];
    };
  };
}
```

By making the *~/dotfiles* flake an input to all environment flakes, we ensure that all environments receive the consistent set of applications and configuration defined in *default.nix*, while still allowing each environment to manage its own core dependencies and specific NixOS settings.

## Flakes for Developer Environments
For system engineering environments, the isolation, portability, and independence offered by separate flakes are worth the management overhead.


* *Dedicated Flakes for Nix Shells* Define each environment as a separate flake (or a subdirectory containing a flake) that primarily exposes the devShells output. Engineers use the nix develop command, which is non-invasive to the host system.

```sh
nix develop path/to/env-A/
```

* *Dedicated Flakes for Virtual Machines/Containers* Define each environment as a separate flake that exposes nixosConfigurations intended to be built as a VM or container. This is the ultimate isolation for system engineers.

```sh
nix build path/to/env-A/#nixosVM
```

### Advantages of Separate Flakes for Dev Environments
For system engineering environments, the isolation benefits of separate flakes usually outweigh the overhead.

1. True Dependency Pinning and Isolation (Crucial)
System engineering often involves maintaining old systems or testing against specific historical library versions (e.g., a specific compiler, a known-bug version of a database). A separate flake allows you to pin the exact nixpkgs version needed for that environment without affecting any other environment or the base operating system.

2. Self-Contained and Portable
Each environment becomes a standalone unit that can be checked out, built, and used anywhere Nix is installed (NixOS, macOS, WSL, etc.).
This is ideal for sharing: "Here's the flake for the legacy project; it defines everything."

3. Independent System Overrides (Configuration)
If one environment needs to test an overlay that modifies a core system package (e.g., overriding the global Python or adding an unstable patch to gcc), it can do so within its own flake's inputs without risking the host system or other environments.

4. Better for nix develop (Nix Shells)
Separate flakes are the standard way to define reproducible developer shells (nix develop). Engineers can simply run nix develop within the flake directory to instantly load the required tools, environment variables, and pre-commit hooks, without needing a full nixos-rebuild switch.

### Disadvantages of Separate Flakes
1. Management Overhead
You will be managing many small Git repositories and a multitude of flake.lock files, increasing the overhead for updating common security patches (like OpenSSL).

2. Increased Duplication
If 80% of your environments use the same core utilities (e.g., git, neovim, bash), you'll be duplicating the package definitions across many flakes, or you'll need to create a shared "utility flake" input.

3.No Centralized Host System Control
Your /etc/nixos will now only manage the base operating system. You lose the ability to easily audit all packages and services running on the machine from a single configuration file.


## System Configuration

The default deployment method is a minimal Linux operating system, providing only essential hardware communication components. A dynamic package loader, governed by application platform requirements, then adds necessary packages using templates, eliminating the need for external orchestrators, custom packaging, or specific communication patterns. This approach allows operations teams to centrally manage service designs through deployment artifacts, while the deployment itself is delegated to operation. A git repository is employed to track and revert system configurations and immutable artifacts, without impacting coresponding services, network, or storage interfaces. Virtual environments require enough space to cache the platform components, a minimum size of *80 to 120GB* is recommended. Nevertheless, this really depends on the number and the complexity of the service blueprints that are being developed.

```sh
├── configuration.nix
└── modules
    ├── sandbox.nix (configuration)
    └── system (modules)
        ├── powersave.nix
        └── zsh.nix
```

The sandbox provides the configuration files for a nix package manager, such as [Nix](https://github.com/NixOS/nix), [Lix](https://lix.systems/) or [Tvix](https://tvix.dev/). The `configuration.nix` is only required for NixOS and contains minimum information and references configuration modules, captured in under `./modules/system`. Packages load additional software, the functional [programming language](https://nix.dev/tutorials/nix-language.html) defines and automates provisioning processes via executable templates. Available packages are listed at the [package directory](https://search.nixos.org/packages) and the command `nix-env -qaP` provides a list incl. available attributes for sripting. Engineers define [system configurations](https://nix.dev/tutorials/packaging-existing-software.html) using declarative files, ensuring isolated dependencies and creating clean, reproducible systems without the overhead of virtual machines or containers. `Override` functions enable engineers to build packages from source by processing additional attributes.

## Resource Composition

[Direnv](https://direnv.net/) extends a system with service specific configurations and dynamically loads or unloads system configurations based on directory changes. Nix's virtual filesystem ensures dependency isolation between software packages, enhancing stability. Direnv uses the .envrc file to reference configurations that automatically trigger provisioning. Upon entering a directory for the first time, a flag must be set to allow Direnv to monitor configuration changes and load the defined tools. Subsequently, Direnv checks for the .envrc file and, if present, makes the defined variables available in the current shell. While Nix offers various methods for separating environment definitions, Direnv only requires a reference to the configuration file within .envrc.

```sh
├── flake.nix
└── modules
    └── services (modules)
        └── github.nix
```

## Development Tools

[Home-Manager](https://nix-community.github.io/home-manager/) allows to define project specific user profiles and enables the system-wide installations of customized software environments even when these affect the system configuration. Administrators maintain company standards by managing the home directory including environment settings on a developer maschine with declarative configuration files in a git repository. Relying on modules provides a structured way to organize and maintain dotfiles for various applications and enables the installation of solution-specific software packages. It supports two ways of deploying applications, programs and packages. Home managers [option search](https://home-manager-options.extranix.com/) lists available programs with settings. Program modules abstract this difference from the deployment process, each module installs the software and configures system wide features. Service modules represent hosted services. These modules contain configuration options and the secrets to access an external system from the developer maschine.

```sh
├── flake.nix
├── home.nix
├── profiles
|   ├── default.nix (development)
|   └── consult.nix
└── modules
    └── programs (modules)
        ├── gnome.nix
        ├── chrome.nix
        ├── claude.nix
        ├── gephi.nix
        ├── ghostty.nix
        ├── obsidian.nix
        └── zed.nix
```

Home manager profiles encapsulate a set of settings, preferences, data, and permissions, that are specific to a context. Profile switching allows developers to quickly load and use a different set of these configurations. Managed profiles provide security and privacy, as each user's files and settings are isolated. It also prevents accidental changes to system settings by non-admin users.

```sh
sudo nixos-rebuild switch --flake '.#nixbook-default'
```

## Service Configuration

Finally, development environments are defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github. Service development environments combine resource composition with a runtime and are defined with [devenv.sh](https://devenv.sh/), a configuration tool that dynamically combines local processes, representing the backing services with runtimes and containers for services developers. Devenv leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. Processes are scheduled with [process-compose](https://github.com/F1bonacc1/process-compose). The entire environment is launched, calling the process manager with a single command.

```sh
└── user
    └── projects
        ├── .devenv
        └── devenv.nix
```

A developer might have different workspace layouts, tool presets, and shortcut configurations saved as profiles for different tasks during a project. service configuration improve focus and productivity by allowing developers to quickly load the most efficient setup for the task at hand. a specific service compostions is loaded with the devenv command.

```sh
devenv up

```

## Usage

* Navigating between windows: `super` + 0 ... 9 for the app in the dock

### Ghostty Navigation
To create a new split window in Ghostty, you can use the keybindings `Ctrl`+`Shift`+`O` (or Cmd+D on macOS) to create a horizontal split, and `Ctrl`+`Shift`+`E` (or Cmd+Shift+D on macOS) to create a vertical split. To navigate between splits, use `Ctrl`+`Super`+`[` (or Cmd+[ on macOS) to focus the previous split, and `Ctrl`+`Super`+`]` (or Cmd+] on macOS) to focus the next split. [More Details](https://www.youtube.com/watch?v=zjUAUqcmZ3w&t=589s)

## Technologies

* [NixOS](https://nixos.org/)
* [Home Manager](https://nix-community.github.io/home-manager/)
* [Devenv.sh](https://devenv.sh/)
* [Direnv](https://direnv.net/)

## Contribution
* *Add features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
