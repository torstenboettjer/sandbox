# Operator Sandbox

The operator sandbox addresses operation engineers with an environment for the design and optimization of systems that should be migrated to a hybrid cloud. Cloud engineers usually employ a combination of applications like Terraform, Ansible and Kubernetes to automate system configurations, topology designs and container deployments. Yet configuration management systems, infrastructure-as-code and container platforms overlap significantly in functionality, these tools were developed with a different platform design in mind but serve a similar purpose. The focus is merely on provisioning and deployment automation not on process automation for operators. This works well, when all applications follow cloud-native design patterns and the entire platform is operated by a single provider. It rises complexity, when service operator manage large quantities of applications that do not adhere to a common design standard and when only a subset of an entire software portfolio can be migrated for technical, commercial or regulatory reasons. With code interpreters that do not separate system definitions and execution instructions, a separation of duties between design, implementation and operation, required to scale organizations with technology specialists is hardly possible. And a division between command and control, required to ensure regulatory compliance, security and commercial justification is very doubtful. The benefits of infrastructure as code are out of question, but a one-size-fits-all approach doesn't appear feasible in an enterprise environment. A integrated toolchain is required that delivers on the promise of continuous integrations and deployments by sharing system definitions through a common datamodel and separating execution modules along the delivery milestones like operational readiness, fulfillment and assurance. This sandbox adresses the first step and enables engineers to write code that ensures operational readiness without prescribing how and where the service will run.

## Host System

A application neutral delivery model should be based on system templates that trigger to changes match the topology and the lifecycle of an application without prescribing specific communication patterns, packaging mechanisms or orchestration services. The development of cloud controllers was originally derived from the idea that every system can be virtualized. Nevertheless, today evolving technologies raise the question, whether this is still the only way to deliver programmable infrastructure. The package managers like [Nix](https://github.com/NixOS/nix), [Guix](https://guix.gnu.org/) or [Lix](https://lix.systems/) enable engineers to compose operating systems declaratively, without abstracting the runtime environment, network and storage interfaces. A functional prgramming language allows to write templates that enable engineering teams to provide purpose build operating systems. Distributing configuratons via git allows to centralize management tasks, to track and roll back system configurations. For the sandbox, the foundation is a strip down version of a Linux system that covers the most essential components for basic functionality and is extended with two main components:

* **[Nix Package Manager](https://nixos.org/)**: A configuration manager that enables reproducible and declarative builds of a server.
* **[Process-compose](https://f1bonacc1.github.io/process-compose/)**: Command-line utility to facilitate the management of processes without further abstraction.

Engineers need a git account and access to a virtual machine, running Linux. The simplest option is the subsystem provided with [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux). The recommendation for the size is *80 to 120GB* but this varies with the use case. The package mananger is installed via command line interface. MacOS can use [nix-darwin](https://github.com/LnL7/nix-darwin) community project to arrive at the same point. 

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```

Nix enables functional deployments and provides features like reproducibility, isolation, and atomic upgrades. Key features is ensuring a consitent package deployments through precise specification of dependencies and build instructions. To activate the package manager, a reference is added to the shell configuration (e.g. ~/.bashrc), hence after the installation, the shell session requires a restart.

```sh
exec bash && source ./.bashrc
```

Nix was introduced in [2003 by Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. Configuration scripts trigger provisioning processes for systems that host modern containers and traditional enterprise applications. The language employed for system configuration allows engineers to manage dependencies on operating system level and the process composer enables them to orchestrate services on mutable hosts. Configuration files can be used to define dedicated server or produce artifacts that run as a node in a distributed system.

### Toolset

The operator sandbox is meant to support engineers developing and sharing configurations. It runs on a local desktop or an a server. Given the flexibility of the nix package manager, there are more than one possible configuration for such an environment. This proposal is focussed on ease of use and combines three tools:

![Alt text](./img/techStack.drawio.svg)

The sandbox is build with a layered architecture in mind, separating development tools from platform components and service configurations. It avoids any dependencies on platform tools like orchestrator or packaging. It does not touch on the topology design, what helps to re-introduces the necessary seperation of duties for technology and service management. 

* **[Home-manager](https://nixos.wiki/wiki/Home_Manager)**: A nix extension that pre-configures user environments with the Nix package manager and allows teams or organizations to define a standard toolset.
* **[Direnv](https://direnv.net/)**: A shell extension to load and unload system software and configurations automatically, moving in and out a directory, which enables system engineers to provide purpose build systems for multiple projects.
* **[Devenv.sh](https://devenv.sh/)**: A configuration tool that allows engineers to define development environments declaratively by toggling basic options for nix and process-compose.

Storing declaration files in one repository together with the application code fosters the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations. 

### System Configuration

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

### Service Configurations

Devenv is a tool that leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. A development environment is defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github.

```sh
devenv init
```

Will create the following files in a given repository: `.envrc, devenv.nix, devenv.yaml, .gitignore`. The nix file contains the system software and platform components, required to build an applications. Because the configuration is declarative, the entire system configuration is replicated over git repositories, which allows match the lifecycle and the technical requirements of the application code or binaries. Instantiation is triggered through "actions", configurations are shared accross teams.

## Contribution
This is a setup script for use a nix based development sandbox to foster the adoption in the operator community. Contributions are highly welcome, e.g.:
* *Add features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
