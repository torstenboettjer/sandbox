# Configurable Sandbox for Hybrid Cloud Development

Developing services for a hybrid cloud is challenging. The high volume of interdependencies, complex network configurations, and granular security settings make it extremely difficult to reliably replicate production backing services for local development. This project introduces a configurable development sandbox designed to solve this replication problem and significantly speed up your development cycle.

## Key Features

The sandbox creates a reproducible, isolated copy of all necessary service components. This environment is intentionally decoupled:

* **No Orchestrator Dependencies:** It operates without requiring predefined networks or complex orchestrators.
* **Operating System Isolation:** Isolation is achieved at the operating system level, ensuring all service components are kept separate to avoid interference with the host system.
* **Guaranteed Reproducibility:** Built on NixOS and leveraging the Nix package manager, the environment is guaranteed to be consistent across machines.

While natively utilizing the power of NixOS, the sandbox is flexible and can be adapted to run on major platforms, but with minimal configuration, it also runs on [Windows (via WSL)](https://learn.microsoft.com/en-us/windows/wsl/about), [ChromeOS (via CROSH)](https://chromeos.dev/en/linux) or [macOS](https://github.com/LnL7/nix-darwin).

## Architectural Objectives

The sandbox is built upon the following criteria to ensure that the services developed within it are reproducible and reliable in the production environment:

* **Avoid Vendor Lock-in:** It must be independent of specific production tools or hosting services (like Kubernetes or a particular cloud provider), ensuring the operating model can be freely chosen for deployment.
* **Portable System Configurations:** It features a flexible system configuration to allow the service to be deployed and run on diverse hardware platforms.
* **Secure Distribution:** It uses a package cache for distribution, providing supply chain control and enabling secure, non-interactive, unattended updates.
* **Reliable Rollbacks:** The system configurations are declarative, which allows for fast, easy rollbacks if any malfunction occurs.

This development environment is designed to be a portable, secure, and easily reversible system that doesn't dictate your final production setup.

## Technology Stack

Relying on the programmable nix package manager gives engineers architectural freedom and provides a clean separation of concerns, making the path from code to compliant, optimized production deployment faster and simpler. It doesn't force developers to adhere to specific design rules, like microservices or three-tier architecture. Instead, it uses a functional system-configuration language to easily handle complex hybrid cloud setups, rapidly accelerating the transition from development to testing and production. The package manager handles system configuration, making separate tools like Ansible, Script Runner, or Rundeck unnecessary. This also avoids the need for heavy hypervisors or container clusters when simple virtualization is better. After development is finished, the Operations team remains flexible to choose the best way to deliver a service component, focusing only on the application's actual needs. Unlike traditional automation that mixes everything together, this system keeps application requirements separate from the underlying system and cloud-provider details. This clear separation allows operators to easily enforce security policies and validate regulatory compliance before the service is even launched.

| Layer | Scope |  Purpose |
| :------- | :------- | :------- |
| Base System | Hardware drivers, core operating system needs, and low-level security/monitoring agents | A system flake captures where the service is running (e.g., cloud mobility settings) but is kept separate from the actual application code to prevent platform lock-in. |
| Development Tools | IDE, Git, diagramming apps and individual service configurations | The user flake maintains a consistent shell across environments to ensure that all developer environments share the same user-level applications at the command line, incl. dotfiles and shell settings. |
| Backend Services | Databases or messaging systems | An environment flake links developer machines to backend components, ensuring everyone across teams is working with an identical, homogeneous development environment. |

The default setup for a sandbox is a local machine, engineers can easily override any default settings without requiring security approval or breaking the standardized lower layers. By defining the entire stack from hardware to developer tools in nix flakes, architects and security teams can launch fully isolated machines to test the functional model before it moves to staging or production. This system eliminates the need for high-level management tools and provider-specific orchestrators. The configurations are shared via Git, which enables a decentralized development process. The programmatic assembly of the server ensures that deployments are reproducible, isolated, and allow for atomic upgrades across any vendor or solution. Separating dependencies and build instructions into different files creates a clear separation of duties—operators can manage system compliance and security without needing to touch the application requirements defined by developers.

### Base System
The System Flake defines the core OS and is typically located at */etc/nixos*. It uses the nixosConfigurations output to build the host machine, including core system-level services and users. The location is root-owned, meaning only administrators can change it, which keeps the base system secure and stable.

| Directory | Location | Purpose |
| :------- | :------ | :------- |
| flake.nix  |  /etc/nixos/flake.nix |  Defines the host output and imports the core NixOS config.  |
| configuration.nix |  /etc/nixos/configuration.nix |  Imports base modules, enables direnv and core services.  |
| default.nix |  /etc/nixos/system/default.nix |  Sets up users, networking, and security.  |

Separate flakes are the standard way to define reproducible developer shells (nix develop). Engineers can simply run nix develop within the flake directory to instantly load the required tools, environment variables, and pre-commit hooks, without needing a full nixos-rebuild switch. If one environment needs to test an overlay that modifies a core system package (e.g., overriding the global Python or adding an unstable patch to gcc), it can do so within its own flake's inputs without risking the host system or other environments. Each environment becomes a standalone unit that can be checked out, built, and used anywhere Nix is installed (NixOS, macOS, WSL, etc.). This is ideal for sharing via a version control system.

```sh
// /etc/nixos/flake.nix

{
  description = "Host OS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # No user or environment flakes needed here, keeping it clean.
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.devserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./system/default.nix
      ];
    };
  };
}
```

System engineering often involves maintaining old systems or testing against specific historical library versions (e.g., a specific compiler, a known-bug version of a database). System modules allow developers to pin the exact nixpkgs version needed for that environment without affecting any other environment or the base operating system.

```sh
// /etc/nixos/system/default.nix (System Module Example)

{ config, pkgs, ... }:

{
  # Core System Modules
  imports = [
    ./users.nix # Defines 'alice', 'bob'
    ./security.nix
  ];

  # System-wide settings
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  # Base service installation
  services.openssh.enable = true;

  # Enable direnv globally for all users
  programs.direnv = {
    enable = true;
    enableFlakes = true;
  };
}
```

### Development Tools
The User Flake defines a consistent set of user-level applications and dotfiles via Home Manager modules. It's stored in a user-owned directory like *~/.config* and is reusable across different systems.

| Directory | Location | Purpose |
| :------- | :------ | :------- |
| flake.nix | ~/.config/flake.nix | Exports the shared Home Manager module (homeManagerModules.common). |
| default.nix | ~/.config/profiles/default.nix | Defines common set of developer tools. |

The User Flake is the single source of truth for an individual developer's personal setup. By storing the entire Home Manager configuration, this single file ensures that the development toolset are identical across all the machines and environments.

```sh
// ~/.config/flake.nix

{
  description = "Shared Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, ... }: {
    # Exports the reusable module
    homeManagerModules.common = import ./shell.nix;
  };
}
```

Environment Flakes import this user flakes as an input (e.g., inputs.my-home.url = "path:~/.config"). For system engineering environments, the isolation, portability, and independence offered by separate flakes are worth the management overhead.

```sh
// ~/.config/profiles/default.nix (Application Module Example)

{ config, pkgs, ... }:

{
  # Consistent application settings and packages
  home.packages = with pkgs; [
    # Core tools for every environment
    tmux
    ripgrep
    fd
  ];

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    # Ensure all users have the same prompt settings
    shellAliases = {
      ll = "ls -lh";
      gc = "git checkout";
    };
  };

  # Common version for dotfiles
  home.stateVersion = "24.05";
}
```

By making the *~/.config* flake an input to all environment flakes, we ensure that all environments receive the consistent set of applications and configuration defined in *default.nix*, while still allowing each environment to manage its own core dependencies and specific NixOS settings.

* *Dedicated Flakes for Nix Shells* Define each environment as a separate flake (or a subdirectory containing a flake) that primarily exposes the devShells output. Engineers use the nix develop command, which is non-invasive to the host system.

```sh
nix develop path/to/env-A/
```

* *Dedicated Flakes for Virtual Machines/Containers* Define each environment as a separate flake that exposes nixosConfigurations intended to be built as a VM or container. This is the ultimate isolation for system engineers.

```sh
nix build path/to/env-A/#nixosVM
```

### Backend Services
The Environment Flake defines the specific tools and settings for a single project, keeping development environments separate and consistent for the entire team. It is stored within the project's code directory, typically at *~/projects/myproject*.

| Directory | Location | Purpose |
| :------- | :------ | :------- |
| flake.nix | ~/projects/myproject/flake.nix | Defines the devShells.default output and pins specific versions. |
| services.nix | ~/projects/myproject/services.nix | Defines environment-specific tools. |

The Environment Flake is the entry point for a project or specialized task. It uses the devShells output and imports the User Flake's shared modules. This configuration achieves project isolation and ensures every team member is using the exact same project-specific tools, backend services, and dependencies.

```sh
// ~/projects/myproject/flake.nix

{
  description = "Legacy Project Development Environment";

  inputs = {
    # Pinned legacy nixpkgs version for isolation
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

    # Import the consistent user setup
    user-home.url = "path:~/dotfiles";
  };

  outputs = { self, nixpkgs, user-home, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    # Bring in the shared user configuration
    commonHomeModule = user-home.homeManagerModules.common;
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      # Environment-specific tools and the shared user config
      imports = [
        commonHomeModule # Shared apps (tmux, zsh aliases, etc.)
        ./services.nix   # Project-specific services
      ];
    };
  };
}
```

*direnv* is used as an utlity to automaticly setup project-specific development environments. It loads and unloads environment variables automatically based on the current directory. On NixOS direnv is installed by default, other operating systems might need a manual installation and requires the use_nix or use_flake functionality to be made available. The services.nix references the services that are loaded automatically.

```sh
// ~/projects/myproject/services.nix

{ config, pkgs, serviceModulesPath, ... }:
{
  # This is the main service composition file for the project environment.
  # It now imports modules from the centralized dotfiles directory.
  imports = [
    # Use string interpolation to reference the module in the modules location
    "${serviceModulesPath}/metabase.nix"
    # Future services (e.g., "${serviceModulesPath}/redis.nix")
    # can be added here easily.
  ];
}
```

direnv is activated through the use_flake function. In the root of that same directory (~/projects/myproject), create a .envrc file with a single line:

```sh
# ~/projects/myproject/.envrc
use flake
```

When the directoruy is entered for the first time, direnv will ask for permission. this is a security measure to prevent arbitrary code execution:

```sh
cd ~/projects/myproject
# direnv: error .envrc is blocked. Run `direnv allow` to approve its contents
direnv allow
```

Now, every time a developer *cd* into ~/projects/myproject:
* direnv reads .envrc.
* use flake tells direnv to find the nearest flake.nix file.
* direnv calls nix develop --command bash (or equivalent) for the default devShells output.
* The specified packages (docker, kubectl, go) and the shellHook are loaded into your current shell session.

## Usage Tips

Setting up the developer maschine
```sh
sudo nixos-rebuild switch --flake /etc/nixos#myserver
```

Changing shared user tools, edit `~/.config/modules/common/default.nix` and run:
```sh
home-manager switch --flake ~/.config#<username>.
```
Working on a project
```sh
cd ~/projects/myproject
```
direnv automatically loads the project's specific shell, which imports the consistent user packages defined in the Environment Flake.

### Gnome Navigation

* Navigating between windows: `super` + 0 ... 9 for the app in the dock

### Ghostty Navigation
To create a new split window in Ghostty, you can use the keybindings `Ctrl`+`Shift`+`O` (or Cmd+D on macOS) to create a horizontal split, and `Ctrl`+`Shift`+`E` (or Cmd+Shift+D on macOS) to create a vertical split. To navigate between splits, use `Ctrl`+`Super`+`[` (or Cmd+[ on macOS) to focus the previous split, and `Ctrl`+`Super`+`]` (or Cmd+] on macOS) to focus the next split. [More Details](https://www.youtube.com/watch?v=zjUAUqcmZ3w&t=589s)

## Links

* [NixOS](https://nixos.org/)
* [Home Manager](https://nix-community.github.io/home-manager/)
* [Direnv](https://direnv.net/)

## Contribution
* *Add features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
