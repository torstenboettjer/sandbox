# Engineering Sandbox

The engineering sandbox addresses system administrators, building cloud services for enterprises, with a development environment for system configurations and provisioning scripts. Cloud engineers employ applications like Terraform for Infrastructure-as-Code (IaC), and while this addresses the need for many cloud service provider, these tools do not address the typical requirements of enterprise operator in it's entire. IaC tools deploy immutable artifacts, relying on a cloud controller orchestrating workloads in an infrastructure pool. This limits the portfolio of applications that are feasible to migrate from a technical, commercial and/or regulatory perspective. Some services may not run on managed infrastructure, other require purpose build systems or communication patterns demand physical interfaces. The scope of a service delivery platform in enterprise IT expands beyond "Platform-as-a-Service" offerings. Cloud-native applications with a micro-service design only represent a subset of a typical software portfolio. An orchestration framework is required that can interface with cloud controllers but does not exclusively depend on it. To fill this gap, engineers require technologies that manage dependencies on operating system level and orchestrate services on mutable hosts. A declarative package manager is able to fill this gap with functional deployments and provisioning templates that trigger system changes, matching the scope and the lifecycle stage of an application without prescribing specific programming languages, integration frameworks or platform services.

## Technology Stack

The nix package manager enables engineers to compose operating systems declaratively, without abstracting the runtime environment, network and storage interface. Configuration scripts trigger provisioning processes for systems that host traditional enterprise applications. Nix was introduced in [2003 by Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. A nix host configruation compromises the following components:

* **[Linux Host]**: A strip down version of an the operating system that includes only the most essential components for basic functionality. 
* **[Nix Package Manager](https://nixos.org/)**: A configuration manager that enables reproducible and declarative builds of a server.
* **[Process-compose](https://f1bonacc1.github.io/process-compose/)**: Command-line utility to facilitate the management of processes without further abstraction.

The nix package manager allows engineers to assemble purpose build operating systems and store the configuratons in a git repository to centralize management tasks, to track and roll back system configurations. The sandbox is meant to support engineers developing and sharing configurations on a local desktop. Given the flexibility there are more than on configuration for a development environment, combining the following three tools is merely a suggestion, that might need a review when nix further matures.

![Alt text](./img/techStack.drawio.svg)

* **[Home-manager](https://nixos.wiki/wiki/Home_Manager)**: Nix extension that pre-configures user environments with the Nix package manager.
* **[Direnv](https://direnv.net/)**: Shell extension to load and unload system software and configurations automatically, moving in and out a directory.
* **[Devenv.sh](https://devenv.sh/)**: Configuration tool to define development environments declaratively by toggling basic options for nix and process-compose.

Developing declaration files fosters the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations. Separating system definitions from the execution of deployment plans re-introduces the seperation of duties for technology and service management, necessary to address the demand for compliant use of cloud infrastructure.

## Setup

For the sandbox, system engineers need a git account and a Linux VM or container. Linux subsystems on [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux) are sufficient. MacOS can use the Nix package manager directly and refer to  [nix-darwin](https://github.com/LnL7/nix-darwin) community project. In this example, ChromeOS is used in combination with a Github account. The default recommendation for the size of the VM is *80 to 120GB*. However, this may vary per use case. The package mananger is installed via command line interface. 

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```

Nix enables functional deployments and provides features like reproducibility, isolation, and atomic upgrades. Key features is ensuring a consitent package deployments through precise specification of dependencies and build instructions. To activate the package manager, a reference is added to the shell configuration (e.g. ~/.bashrc), hence after the installation, the shell session requires a restart.

```sh
exec bash && source ./.bashrc
```

After activation, building a sandbox a three step process: 

### Tools and Services

A standard toolset in system engineering is key for long term quality and maintainability for system administrators. The [Home-Manager](https://nix-community.github.io/home-manager/) defines user environments that provide the look and feel for an engineers accross Linux machines. Replicating the configuration via git administrators rely on the same set of tools, regardless where they login. Organizations use the home manager to define a default configuration that is confirmed by security, compliance and purchasing. The [example script](./setup) uses Github for replication and contains some basic open source tools like VS-Code, gh and jq to be deployed on either a `x86_64-linux` or `aarch64-linux` based Chromebooks. 

```sh
curl -L https://raw.githubusercontent.com/hcops/sandbox/main/setup | sh -s -- <x86_64-linux or aarch64-linux>
```

The github client is used to load the default parameter into the configuration. The home configuration is defined with the [home.nix](./home.nix) file. Beside the development tools it also sets up direnv and devenv.sh. Independent from the application layer, the system layer is defined in the [flake.nix](./flake.nix). Flakes are still classified as experimental feature in Nix, a respective flag is appended to `/etc/nix/nix.conf`. It should be mentioned that there are others options defining a standardized set of tools and services, e.g. [Flakey](https://github.com/lf-/flakey-profile), which provides less automation but more control.

### Platform Components

Direnv is a nix based application that enables engineers to support multiple development projects effectively. It isolates system configurations their dependencies in a directory and automatically loads and unloads the components, switching from one directory to another. This helps to adopt agile processes, because it addresses one of the complexity driver in developing enterprise services. The divergent structure in application development and service operation often leads to massive workload in operation. While development teams are organized around solutions to focus on the delivery of business functionality, operation teams are organized around technologies with specialists managing systems. Hence, operators required for 24x7 operation have to join multiple SCRUM teams with little time left to fulfill their day to day tasks. A tool like direnv allows operations enigneers to ceate per-project environments and relieve system specialists. Nix supports multiple concepts of separating environment definitions. E.g. the default [flake.nix](./flake.nix) file can be extended with nix packages and stored in a new package directory. However, devenv comes offers additional features to streamline the development process and comes an on devenv.nix. In most cases, this file serves the purpose, for more advanced requirements might require the definition of overlays or a a specific package.nix, which is not covered here.  

```sh
# uncomment when adding flake.nix to an existing configuration
# echo "use flake" >> .envrc
direnv allow
```

Files ending on *.nix are activated by appending the use command to a environment file inside a project directory. Direnv automatically reads files called default.nix or shell.nix, what might be usefull to configure the appeearance of the shell and add tools like [starship](https://starship.rs/). The 'allow' flag authorizes direnv to automatically load and unload environment variables, when the directory is changed. It checks for the existence of a .envrc file and if the file exists, the defined variables are captured and made available in the current shell.  

### Service Configuration

Devenv is a tool that leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. A development environment is defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github.

```sh
devenv init
```

Will create the following files in a given repository: `.envrc, devenv.nix, devenv.yaml, .gitignore`. The nix file contains the system software and platform components, required to build an applications. Because the configuration is declarative, the entire system configuration is replicated over git repositories, which allows match the lifecycle and the technical requirements of the application code or binaries. Instantiation is triggered through "actions", configurations are shared accross teams.

## Contribution
This is a small community project, that should help system administrators to onboard nix into the tool chain. We welcome any contribution, here are some ways you can contribute:
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
* *Add new features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
