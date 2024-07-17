# Operator Sandbox

The operator sandbox addresses operation engineers with an environment for the design and optimization of systems that should be migrated to a hybrid cloud. Cloud engineers usually employ a combination of applications like Terraform, Ansible and Kubernetes to automate system configurations, topology designs and container deployments. Yet configuration management systems, infrastructure-as-code and container platforms overlap significantly in functionality, these tools serve a similar purpose but with a different target platform in mind. The focus is merely on provisioning and deployment automation not on process automation for operators. This works well, when all applications follow cloud-native design patterns and the entire platform is operated by a single provider. It rises complexity, when service operator manage large quantities of applications that do not adhere to a common design or when only a subset of an entire software portfolio can be migrated for technical, commercial or regulatory reasons. The benefits of infrastructure as code are out of question, but a one-size-fits-all approach doesn't appear feasible in an enterprise environment. With code interpreters that do not separate system definitions and execution instructions, scaling an organization with a separation of duties between design, implementation and operation is hardly possible. And ensuring regulatory compliance, security and commercial justification without a separation between command and control is very doubtful. An integrated a toolchain that delivers on the promise of continuous integrations and deployments requires a common source for system definitions with execution modules, separated along delivery milestones like operational readiness, fulfillment and assurance. 

## Target System

A hybrid platform uses cloud services where appropriate without prescribing a complete migration of the entire software portfolio. Cloud infrastructure is a managed service, build on a programmable platform that orchestrates virtual artifacts. Resources are exposed through controller and cannot be accessed by the runtime directly. The implications on the application design are described in the [Twelve-Factor](https://12factor.net/) manifesto. For software that does not meet these criteria or cannot be outsourced, a different delivery model is required. Declarative package managers like [Nix](https://github.com/NixOS/nix), [Guix](https://guix.gnu.org/) or [Lix](https://lix.systems/) enable operators to define the desired system state in configuration files that isolate the dependencies for software packages and ensure a clean and reproducible environment. A functional programming language allows system administrators to write templates for purpose build systems from a strip down version of Linux that only covers the most essential components for basic functionality. System templates trigger changes to the composition of the operating system that match the topology design and the runtime requirements without depending on specific communication patterns, packaging mechanisms or orchestration capabilities. This enables operators to centralize management tasks, to track and to roll back system configurations in a similar way like immutable artifacts but without abstraction of the runtime environment, network- and storage interfaces.

## Development Environment

The sandbox is a development and execution environment for system templates. Deployment workflows are enabled with layered architecture that addresses a separation of concerns, typically found in enterprise IT organizations. Development tools are employed independently from platform components and service configurations. Engineers avoid implicit dependencies on platform orchestrators or packaging mechansims. This allows service operator to retain control over the technology platform even if it is partially outsourced. 

![Technology Stack](./img/techStack.drawio.svg)

The development process is decentralized, configuration templates is shared via git repositories. Engineers need access to a Linux environment to contribute. A subsystem provided by [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux) is sufficient. For the virtual maschine, a minimum size of *80 to 120GB* is recommended to have enough space for caching, however, this really depends on the number and the complexity of the service blueprint that are being developed. The package mananger is installed via command line interface. MacOS can use [nix-darwin](https://github.com/LnL7/nix-darwin) community project to arrive at the same point. 

```sh
curl -L https://raw.githubusercontent.com/hcops/sandbox/main/setup | sh -s
```

The setup script uses Github for replication and contains some common tools like VS-Code, gh and jq. The github client is used to load the default parameter into the configuration. Nix provides features that address requirements like reproducibility, isolation, and atomic upgrades beyond the scope of a cloud controller and is therefor a solid foundation for the development of hybrid services. Key features are ensuring a consistent package deployments through precise specification of dependencies and build instructions. To activate the package manager after installation, the shell session requires a restart.

```sh
exec bash && source ~/.bashrc
```

Automations are based on Nix and uses the *Lix*, a fork from the nix package manager. Nix was introduced in [2003 by Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. Since than the open source initiative has grown to nearly a thousand developers and has gathered several thousands of contributors. It provides access to a [hundrets of thousands of packages](https://search.nixos.org/packages). The nix language allows engineers to manage dependencies on operating system level, which is the foundation to trigger provisioning processes that either configure dedicated server or produce artifacts for a cloud deployment. Storing declaration files in a repository together with the application code fosters the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations.

### Standard Tools

A standard toolset in system engineering is key for long term quality and maintainability for system administrators. **[Home-manager](https://nix-community.github.io/home-manager/)** is a nix extension that pre-configures user environments with the Nix package manager and allows teams or organizations to define a standard toolset. Home-Manager is used to define a standard set of engineering tools accross the organization, direnv automatically loads a set platform components for project related work and devenv.sh adds the service configuration that can vary according to the lifecycle stage and between individuals or teams contributing to a project. 

The default toolset is defined in the [home.nix](./home.nix) file under *home.packages*. Beside the development tools it triggers the deployment of the downstream tools direnv and devenv.sh. The system layer is defined independent from the application layer, in [flake.nix](./flake.nix). This allows to run the same configuration on different host systems. Flakes are still classified as experimental feature, a respective flag is appended to `/etc/nix/nix.conf`. It should be mentioned that there are alternatives to define a default set of tools and services in nix, e.g. [Flakey](https://github.com/lf-/flakey-profile), which provides less automation but more control.  

### Platform Components

A platform is defined adding system software to the host that are required to run all service components. **[Direnv](https://direnv.net/)** is a shell extension to load and unload system software and configurations automatically, moving in and out a directory, which enables system engineers to provide purpose build systems for multiple projects. The configuration is separated from development tools to ease the deployment together with the application code. Direnv is a nix based application that enables engineers to support multiple development projects. It isolates system configurations their dependencies in a directory and automatically loads and unloads the components, switching from one directory to another. This helps to overcome one of the complexity driver for DevOps in an enterprise context. Fast iterations with divergent structures in application development and service operation often leads to massive workload for operators. While development teams are organized around solutions to focus on the delivery of business functionality, operation teams are organized around technologies with specialists managing systems. Hence, operators required for 24x7 operation have to join multiple SCRUM teams with little time left to fulfill their day to day tasks. A tool like direnv allows operations enigneers to ceate per-project environments and relieve system specialists. Nix supports multiple concepts of separating environment definitions. E.g. the default [flake.nix](./flake.nix) file can be extended with nix packages and stored in a new package directory. However, devenv comes offers additional features to streamline the development process and comes an on devenv.nix. In most cases, this file serves the purpose, for more advanced requirements might require the definition of overlays or a a specific package.nix, which is not covered here.  

```sh
# uncomment when adding flake.nix to an existing configuration
# echo "use flake" >> .envrc
direnv allow
```

Files ending on *.nix are activated by appending the use command to a environment file inside a project directory. Direnv automatically reads files called default.nix or shell.nix, what might be usefull to configure the appeearance of the shell and add tools like [starship](https://starship.rs/). The 'allow' flag authorizes direnv to automatically load and unload environment variables, when the directory is changed. It checks for the existence of a .envrc file and if the file exists, the defined variables are captured and made available in the current shell.  

### Service Configuration

**[Devenv.sh](https://devenv.sh/)** is a configuration tool that allows engineers to define development environments declaratively by toggling basic options for nix and process-compose. Devenv leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. A development environment is defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github.

```sh
devenv init
```

Will create the following files in a given repository: `.envrc, devenv.nix, devenv.yaml, .gitignore`. The nix file contains the system software and platform components, required to build an applications. Because the configuration is declarative, the entire system configuration is replicated over git repositories, which allows match the lifecycle and the technical requirements of the application code or binaries. Instantiation is triggered through "actions", configurations are shared accross teams.

## Contribution
This is merely a setup script that helps operators to launch a nix based sandbox. The aim is to ease the adoption of a technology that resolves issues,  system administrators experience, migrating enterprise applications to a cloud provider. Any contribution is highly welcome, e.g.:
* *Add features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
