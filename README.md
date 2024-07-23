# Operator Sandbox

The operator sandbox provides an development and execution environment for operation engineers, migrating applications to a hybrid cloud. It introduces an alternative approach towards "Infrastructure as Code (IaC)" that is determined by open specification and the use common programming language rather than proprietary tools that translate resource description into API calls. Today, many cloud engineers employ a combination of Terraform, Ansible and Kubernetes to automate application deployments. Yet, provisioning tools, configuration management systems and container platforms overlap significantly in functionality and the scope of automations is rather limited. Designed for deployments, these tools integrate with orchestrators to automate resource provisioning from a shared infrastructure pool. Physical infrastructure and process automations that centralize control functions or simplify ongoing management, are out of scope. Just the opposite, the approach simplifies cloud-native application management but introduces complexity for operators, responsible for a mix of third-party applications with different requirements. The tools require engineers to combine system definitions and execution instructions in a common code base, resulting in fragmented design decisions and a lack of control, which makes it difficult to address technical, commercial, or regulatory requirements in operation. The sandbox enables developers to write configurations in a language of their choice that are executed in an isolated environment. System definitions are pulled from an external data source, relying on common API standards. Decoupling system definitions from the application deployment allows service operators to test and confirm regulatory compliance, security policies, and infrastructure pricing before launching a new service instance.

## Host System

Instead of utilizing virtual artifacts, the operator uses a declarative package managers like [Guix](https://guix.gnu.org/) or [Nix](https://github.com/NixOS/nix) to compose a set of platform components on operating system level. Engineers define a desired system state in configuration files that isolate the dependencies for software packages and ensure clean and reproducible systems without wrapping application runtimes into virtual machines or container. A functional programming language defines and triggers provisioning processes for purpose build systems with executable templates. The foundation is a strip down version of the linux operating system that only covers the most essential components, communicating with the hardware. A watchdog loads additional packages using templates that match the platform requirements of an application without depending on an orchestrator, additional packaging or specific communication patterns. This enables operation teams to centralize system designs without owning the deployment and to track and to roll back system configurations in a similar way like immutable artifacts without abstraction of the runtime environment, network- and storage interfaces.

### Installation

The layered architecture of the sandbox enables system engineers to develop service blueprints without prescribing an operating model. The first layer covers the definition development tools and the specification of the hardware platform. The later is decoupled from the application set to avoid hardware dependencies. Platform components are defined on the second layer and the third layer addresses the development process and captures service configurations. Provisioning the environment on local machines enables engineers to overwrite the default setup any time on any layer, leaving it to security operator and service architects to test the entire stack with a working model, before moving into staging and production. Local instances also avoid implicit dependencies on orchestrators and/or packaging mechansims, the development process is decentralized and configuration templates shared via git.  

![Technology Stack](./img/techStack.drawio.svg)

Code contributors need access to a Linux environment, a subsystem provided by [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux) is sufficient. The virtual maschine requires enough space to cache the platform components of a project though. A minimum size of *80 to 120GB* is recommended - however, this really depends on the number and the complexity of the service blueprints that are being developed. The setup script contains a default toolset with VS-Code, gh and jq already and uses Github for code sharing. The github client is also used to load default parameter into the configuration. 

```sh
curl -L https://raw.githubusercontent.com/hcops/sandbox/main/setup | sh -s
```

This script installs a set of tools that extend the [Lix](https://lix.systems/)  package manager, a fork from the original nix package manager. System configurations are written in the nix language, which allows engineers to manage dependencies on operating system level and trigger provisioning processes dedicated server or produce virtual artifacts. Storing declaration files in a repository together with the application code fosters the development of consistent blueprints and provides similar advantages like virtual artifacts without introducing the same limitations. Nix was introduced in 2003 by [Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments and the open source project has gained tremendous popularity in the shadow of a broader cloud adotion. Assembling dedicated server programmatically ensures reproducibility, isolation, and atomic upgrades with consistent package deployments without dependencies on a specific vendor or solution. Dependencies and build instructions are specified in configuration files what enables a separation of duties simply by managing directory or file access. To activate these tools after installation, the shell session requires a restart. 

```sh
exec bash && source ~/.bashrc
```

MacOS users cannot rely on the convenience of an isolated subsystem but refer to the [nix-darwin](https://github.com/LnL7/nix-darwin) project to arrive at the same point. Alternatively, a virtual maschine on a hypervisor can be considered. 

### Development Tools

A standard toolset in system engineering is an enabler for long term quality and maintainability of the infrastructure code. In the sandbox it is activated using **[Home-manager](https://nix-community.github.io/home-manager/)**, a nix extension that configures user environments through the `home.nix` file. Home manager supports two ways of deploying applications, programs and packages. For a develoment environment `programs` are the prefered method, nix modules that install the software and configure system wide features. Home manager [option search](https://home-manager-options.extranix.com/) lists all available programs for engineers.

```ǹix
  programs = {
    direnv.enable = true; # https://direnv.net/

    vscode = {
      enable = true; # https://code.visualstudio.com/
      package = pkgs.vscodium;
      enableUpdateCheck = false;
    };

    jq.enable = true;     # https://jqlang.github.io/jq/
    fzf.enable = true;    # https://github.com/junegunn/fzf
    gh.enable = true;     # https://cli.github.com/manual/
  };
```

Packages load additional software without providing configuration options. Nix packages are listed at the [package directory](https://search.nixos.org/packages) and the command `nix-env -qaP` provides a list incl. available attributes for sripting. `Override` and `overrideAttrs` functions enable engineers to build packages from source by processing attributes like `src`, `buildInputs`, `makeFlags`, etc.. Some packages use overrides for fine-tuning like a [fonts package](https://search.nixos.org/packages?channel=unstable&show=nerdfonts&from=0&size=50&sort=relevance&type=packages&query=nerdfonts) that allows to filter default list of fonts, what saves time and space. 

```ǹix
  home.packages = with pkgs; [
    devenv       # https://devenv.sh/
    gnumake      # https://www.gnu.org/software/make/manual/make.html
    # lunarvim   # https://www.lunarvim.org/
    # zed-editor # https://zed.dev/

    # Override example
    # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    (writeShellScriptBin "create_project" ''
      # capture the project name with a first argument
      PROJECT=$1

      # Check whether sync repo already exist
      if [ $(gh api repos/${gituser}/$PROJECT --silent --include 2>&1 | grep -Eo 'HTTP/[0-9\.]+ [0-9]{3}' | awk '{print $2}') -eq 200 ]; then
        echo "project $PROJECT already exists!"
      else
        # Create the new remote repository on GitHub
        gh repo create "${gituser}/$PROJECT" --private
  
        # Check if the repository was created successfully
        if [ $? -ne 0 ]; then
            echo "Failed to create the remote repository on GitHub."
            exit 1
        fi
  
        # create projects directory if it doesn't exist
        mkdir -p ${projectdir} && cd ${projectdir}
  
        # Clone the project repository with gh
        gh repo clone ${gituser}/$PROJECT
  
        # Verify the new remote setup
        cd ${projectdir}/$PROJECT && git remote -v
  
        echo "The $PROJECT repository has been created."
        echo "Remote repository: https://github.com/${gituser}/$PROJECT.git"
    fi
    '')
  ];
```

The package section also enhances the shell with small scripts. E.g. the "project \<name\>" command pulls the code from a project repository. DevOps team can rely on a version control system for the onboarding of new members, which makes it easier to collaborate with external resources in an enterprise environment. It should be mentioned that home-manager is not the only extension that can be used to define a default set of tools, [Flakey](https://github.com/lf-/flakey-profile) is another option, which provides less automation but more control.

### Platform Components

A service delivery platform acts as the building block for service operation. It provides the necessary resources, like application runtimes, databases, and development tools on-demand. Application owners deploy applications on managed infrastructure, developers benefit from features like configuration management, continuous integration/continuous delivery (CI/CD), and monitoring. For them, a platform frees valuable time and effort up and eliminates reliance on the operation team. However, a standardized set of services with well-defined provisioning API is required to simplify the process of deploying applications and accessing third party services. Cloud infrastructre realizes provisioning API, using an orchestrator, and dedicated systems rely on configuration files for service deployments. A ability to trigger the deployment of software packages automatically is an important enabler for automation. It allows to provide a unified interface for for both, distributed and dedicated systems. System configurations are exposed as blueprints that make configurations accessible through an API. Using this mechanism in development, allows engineers to tailor platform compositions to specific needs without defining the entire operating model. A script executes the setup process for all platform components and engineers can quickly get up and running on projects pulling the configuration from a version control system.  

```sh
project my_service
```

The development of system templates is simplified using **[direnv](https://direnv.net/)**, a shell extension that loads and unloads system configurations moving in and out a directory. One of the biggest hurdles for DevOps in large organizations is managing rapid iteration cycles with combined application and operations teams. System management is a horizontal function, and joining multiple Scrum teams can leave operators overloaded, hindering their ability to complete daily tasks. Direnv offers a solution by empowering engineers to provision environments through configuration files. This frees system specialists from attending meetings where their input is limited. Additionally, Direnv provides a convenient way to share platform configurations using a Git service. These configuration files ensure isolation of dependencies between software packages, promoting stability. Direnv utilizes .envrc files to reference configurations that automatically trigger a provisioning process. A streamlined approach reduces the burden on system specialists and allows developers to fulfill their core tasks.

```sh
direnv allow
```

Entering a directory for the first time, a flag needs to be set, that allows direnv to monitor chnages in the configuration and to load the defined tools automatically. It checks for the existence of a .envrc file and if the file exists, the defined variables are captured and made available in the current shell. Nix supports multiple concepts of separating environment definitions, and direnv only requires a rerference to the configuration file in .envrc. Developing services, engineers need the freedom determine a platform configuration together with the system configuration. Therefore [devenv.nix](https://github.com/hcops/template/tree/main/devenv.nix) file combines platform configurations and system definitions in a single file. The default project template includes a [PostgreSQL](https://www.postgresql.org/) server and the [Rust toolchain](https://www.rust-lang.org/). 

```sh
echo "use flake" >> .envrc
```
Once the templates are complete and the configuration is tested, platform components can be moved into a flake and *.envrc* is extended, e.g. to store the configuration without development tools in a service catalog and to prepare the deployment on a production system. Flakes are still classified as experimental feature, a respective flag is appended to `/etc/nix/nix.conf` during the installation process. 

### Service Configuration

**[Devenv.sh](https://devenv.sh/)** is a configuration tool that allows engineers to define development environments declaratively by toggling basic options for nix and process-compose. Devenv leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. A development environment is defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github.

**Process**
1.  Select a runtime
2.  Define the processes
(e.g. watch directory for changes and run a program - cargo watch)
3. Define Precommit Hooks
clippy, rust-formater


```sh
devenv up
```

* devenv test
* devenv container build

Will create the following files in a given repository: `.envrc, devenv.nix, devenv.yaml, .gitignore`. The nix file contains the system software and platform components, required to build an applications. Because the configuration is declarative, the entire system configuration is replicated over git repositories, which allows match the lifecycle and the technical requirements of the application code or binaries. Instantiation is triggered through "actions", configurations are shared across teams.

## Contribution
This is merely a setup script that helps operators to launch a nix based sandbox. The aim is to ease the adoption of a technology that resolves issues,  system administrators experience, migrating enterprise applications to a cloud provider. Any contribution is highly welcome, e.g.:
* *Add features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
