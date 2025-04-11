# Engineering Sandbox

The engineering sandbox establishes an isolated, local environment where service developers can build and test integrations between business applications without affecting production systems. The sandbox focuses on solution compositions that model specific business processes. Relying on a declarative package manager, deployment functions are defined in a functional, system-configuration language and distributed through git repositories, what simplifies the transition from development and testing to production. System declarations eliminate the need for configuration and deployment tools like Ansible and Terraform, and do not obligate the use of a platform orchestrators like Kubernetes but empower operators to decide on the optimal delivery method based on the operational context. Unlike traditional infrastructure-as-code and platform automation tools that merge application requirements, system definitions, and implementation instructions in a single code base, system modules keep application requirements separate from system- and cloud-provider dependencies to enable operators enforcing security policies and validating regulatory compliance before launching a service.

![Technology Stack](./img/schema-sandbox.drawio.svg)

A layered architecture allows system engineers to design service blueprints that integrate host-dependent services, such as databases, with node artifacts deployable as distributed systems in clusters or serverless environments. This architecture maintains deployment model flexibility, allowing decisions to be made later in the process. The first layer defines the hosting platform with a separate hardware- and system configuration module. It remains decoupled from the application set to prevent platform dependencies. Additional modules can be utilized to reflect context specific maschine requirements, like mobility functions, cloud provider settings or company specific monitoring agents. The second layer defines solution components incl. hosted backend services, and the third layer addresses the development toolset and captures configurations for developer services. Local machine provisioning empowers engineers to override default settings at any layer, enabling security operators and service architects to test the entire stack with a functional model before staging and production. Local instances also eliminate implicit dependencies on higher level packaging formats and provider specific orchestrators, fostering a decentralized development process with configuration templates shared via Git. Programmatic assembly of dedicated servers ensures reproducibility, isolation, and atomic upgrades with consistent package deployments, independent of specific vendors or solutions. Dependencies and build instructions are specified in configuration files, facilitating clear separation of duties through simple directory or file access management. 

## System Configuration

The sandbox utilizes a package manager, such as [Nix](https://github.com/NixOS/nix), [Lix](https://lix.systems/) or [Tvix](https://tvix.dev/), to assemble a set of solution components. Engineers define system configurations using declarative files, ensuring isolated dependencies and creating clean, reproducible systems without the overhead of virtual machines or containers. A functional programming language defines and automates provisioning processes for specialized systems via executable templates. At its core, the sandbox employs a minimal Linux operating system, providing only essential hardware communication components. A dynamic package loader, governed by application platform requirements, then adds necessary packages using templates, eliminating the need for external orchestrators, custom packaging, or specific communication patterns. This approach allows operations teams to centrally manage system designs while delegating deployment, and to track and revert system configurations like immutable artifacts, all without abstracting the runtime environment, network, or storage interfaces.

The default system is a NixOS server, however access to a Linux container like the [Windows Subsystem](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS Shell](https://chromeos.dev/en/linux) is sufficient. Virtual environments require enough space to cache the platform components, a minimum size of *80 to 120GB* is recommended. Nevertheless, this really depends on the number and the complexity of the service blueprints that are being developed. MacOS users can either rely on a virtual to maintain an isolated subsystem or utilize to [nix-darwin](https://github.com/LnL7/nix-darwin) project. 

### Platform Compositions

The development of system templates is simplified using **[direnv](https://direnv.net/)**, a shell extension that loads and unloads system configurations moving in and out a directory. One of the biggest hurdles for DevOps in large organizations is managing rapid iteration cycles with combined application and operations teams. System management is a horizontal function, and joining multiple Scrum teams can leave operators overloaded, hindering their ability to complete daily tasks. Direnv offers a solution by empowering engineers to provision environments through configuration files. This frees system specialists from attending meetings where their input is limited. Additionally, Direnv provides a convenient way to share platform configurations using a Git service. These configuration files ensure isolation of dependencies between software packages, promoting stability. Direnv utilizes .envrc files to reference configurations that automatically trigger a provisioning process. A streamlined approach reduces the burden on system specialists and allows developers to fulfill their core tasks.

```sh
direnv allow
```

Entering a directory for the first time, a flag needs to be set, that allows direnv to monitor chnages in the configuration and to load the defined tools automatically. It checks for the existence of a .envrc file and if the file exists, the defined variables are captured and made available in the current shell. Nix supports multiple concepts of separating environment definitions, and direnv only requires a rerference to the configuration file in .envrc. Developing services, engineers need the freedom determine a platform configuration together with the system configuration. Therefore [devenv.nix](https://github.com/hcops/template/tree/main/devenv.nix) file combines platform configurations and system definitions in a single file. The default project template includes a [PostgreSQL](https://www.postgresql.org/) server and the [Rust toolchain](https://www.rust-lang.org/). 

```sh
echo "use flake" >> .envrc
```
Once the templates are complete and the configuration is tested, platform components can be moved into a flake and *.envrc* is extended, e.g. to store the configuration without development tools in a service catalog and to prepare the deployment on a production system. Flakes are still classified as experimental feature, a respective flag is appended to `/etc/nix/nix.conf` during the installation process. 

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
