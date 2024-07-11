# Engineering Sandbox

Building cloud services for enterprises starts with an environment that enables system engineers to develop, maintain and execute system configurations. While cloud provider offer managed infrastructure and plaform services, mainly for web service developers, enterprise operator need to preserve the capability to provision purpose build systems for third party applications. For Cloud services, Infrastructure-as-Code (IaC) has replaced runbook automation with applications like Terraform to streamline the provisioning processes of immutable artifacts employing a cloud controller like Kubernetes that orchestrates workloads in large infrastructure pools. But enterprise can usually not rely exclusively on managed infrastructure. The scope of a service delivery platform expands beyond cloud-native applications and micro-service designs with software that requires dedicated infrastructure. Applications that translate system definitions into api calls are not sufficient, a framework is needed that allows to capture dependencies on operating system level and automate deployment processes on mutable hosts, in order to ensure the uptime, security and performance of more traditional or monolothic designed systems. A declarative package manager and and process composer provides a better foundation to develop configurations that trigger system changes and match the lifecycle stage of an application without creating dependencies for application developer on specific programming languages, integration frameworks or platform services.

## Technology Stack

Developing deployment instructions for applications that run on dedicated hosts demands for declarative configurations that do not abstract the runtime environment, network and storage interface. The nix package manager solves this problem for Linux systems. Nix was introduced in [2003 by Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. 

* **[Linux OS](https://chromeos.dev/en/linux)**: Debian VM or Container that allows developers to run Linux apps for development alongside the usual desktop and applications.
* **[Nix Package Manager](https://nixos.org/)**: A Linux configuration manager that enables reproducible and declarative builds for virtual machines.
* **[Process-compose](https://f1bonacc1.github.io/process-compose/)**: Command-line utility to facilitate the management of processes without further abstraction.

The nix package manager allows engineers to compose purpose build operating systems and store the configuratons in a git repository to centralize management tasks, to track and roll back system configurations. Sharing configurations in a repository fosters the development of platforms with advanced compliance and security requirements without burdening application owners or development teams.

![Alt text](./techStack.drawio.svg)

* **[Home-manager](https://nixos.wiki/wiki/Home_Manager)**: Shell extension to configure user environments with the Nix package manager.
* **[Direnv](https://direnv.net/)**: Shell extension to load and unload devenv environments automatically moving in and out of a directory.
* **[Devenv.sh](https://devenv.sh/)**: Configuration tool to define development environment declaratively by toggling basic options for nix and process-compose.

Using these files for development, test and production enables the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations. 

## Setup

Setting up a sandbox engineers need access to a git repository and a Linux VM or container. The typical desktop systems like [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux) let developers to run a Linux environment without installing a second operating system. MacOS can use the Nix package manager directly and refer to  [nix-darwin](https://github.com/LnL7/nix-darwin) community project. The default recommendation for a new development environment is an avialable disk size of *80 to 120GB*, however, the size really varies from use case to use case. The package mananger is installed via command line interface. 

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```

Nix enables functional deployments and provides features like reproducibility, isolation, and atomic upgrades. Key features is ensuring a consitent package deployments through precise specification of dependencies and build instructions. To activate the package manager, a reference is added to the shell configuration (e.g. ~/.bashrc), hence after the installation, the shell session requires a restart.

```sh
exec bash && source ./.bashrc
```

With nix being active, building a sandbox becomes a three step process: 

### Tools and Services

A standard toolset in system engineering is key for long term quality and maintainability for system administrators. The [Home-Manager](https://nix-community.github.io/home-manager/) defines user environments that provide the look and feel for an engineers accross Linux machines. Replicating the configuration via git administrators rely on the same set of tools, regardless where they login. Organizations use the home manager to define a default configuration that is confirmed by security, compliance and purchasing. The [example script](./setup) uses Github for replication and contains some basic open source tools like VS-Code, gh and jq to be deployed on either a `x86_64-linux` or `aarch64-linux` based Chromebooks. 

```sh
curl -L https://raw.githubusercontent.com/hcops/sandbox/main/setup | sh -s -- <x86_64-linux or aarch64-linux>
```

The github client is used to load the default parameter into the configuration. The home configuration is defined with the [home.nix](./home.nix) file. Beside the development tools it also sets up direnv and devenv.sh. Independent from the application layer, the system layer is defined in the [flake.nix](./flake.nix). Flakes are still classified as experimental feature in Nix, a respective flag is appended to `/etc/nix/nix.conf`. It should be mentioned that there are others options defining a standardized set of tools and services, e.g. [Flakey](https://github.com/lf-/flakey-profile), which provides less automation but more control.

### Platform Components

Direnv is a nix based application that enables engineers to support multiple development projects effectively. It isolates system configurations their dependencies in a directory and automatically loads and unloads the components, switching from one directory to another. This helps to adopt agile processes effectvely, because it addresses one of the complexity driver in developing enterprise services. The divergent structure in application development and service operation often leads to massive workload in operation. While development teams are organized around solutions to focus on the delivery of business functionality, operation teams are organized around technologies with specialists managing systems. Hence, operators required for 24x7 operation have to join multiple SCRUM teams with little time left to fulfill their day to day tasks. A tool like direnv allows operations enigneers to ceate per-project environments and relieve system specialists. Nix supports multiple concepts of separating environment definitions. E.g. flake.nix file can be extended with nix packages, However, devenv comes with an on devenv.nix files, which in most cases serves the purpose. More advanced requirements might require the definition of overlays or a a specific package.nix, which is not covered here.  

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

Will create the following files in a given repository: `.envrc, devenv.nix, devenv.yaml, .gitignore`. The nix file contains the system software and platform components, required to build an applications.

## Contribution
We welcome contributions to this project! Here are some ways you can contribute:
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
* *Add new features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
