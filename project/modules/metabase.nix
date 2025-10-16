{ config, pkgs, ... }:

{
  # 💡 This module defines packages and settings specifically for running
  # local services required by this data analysis project.

  home.packages = with pkgs; [
    # Metabase is installed here so it's available in the devShell.
    metabase
    # Java Runtime Environment is needed to execute the Metabase JAR.
    jre
    # PostgreSQL server binaries are needed to run a local backend database
    # for Metabase configuration during development.
    postgresql
  ];

  # The shell hook provides instructions on how to manually start the
  # Metabase server for local development or testing.
  shellHook = ''
    echo " "
    echo "--------------------------------------------------------"
    echo "Service Status: Metabase, JRE, and PostgreSQL binaries are available."
    echo "To set up a local PostgreSQL database instance for Metabase:"
    echo "  1. Run: 'initdb -D ./metabase_db'"
    echo "  2. Run: 'postgres -D ./metabase_db' (in a separate terminal)"
    echo "To start Metabase locally (ensure DB is running first):"
    echo "  $ java -jar $(metabase-jar-path)"
    echo "--------------------------------------------------------"
    echo " "
  '';
}
