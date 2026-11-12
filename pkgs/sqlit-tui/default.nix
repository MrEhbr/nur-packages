{
  fetchFromGitHub,
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "sqlit-tui";
  version = "1.6.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Maxteabag";
    repo = "sqlit";
    tag = "v${version}";
    hash = "sha256-pHKK4JKVSZWZ93k99MqKSZk5PZiPm6KfvopbrY5yfWI=";
  };

  build-system = with python3Packages; [
    hatch-vcs
    hatchling
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    docker
    duckdb
    keyring
    mariadb
    oracledb
    paramiko
    psycopg2
    pymysql
    pyperclip
    sqlparse
    sshtunnel
    textual
    textual-fastdatatable
  ];

  pythonRelaxDeps = [
    "paramiko"
    "textual-fastdatatable"
  ];

  nativeCheckInputs = with python3Packages; [
    pytest-asyncio
    pytz
    pytestCheckHook
  ];

  pythonImportsCheck = [ "sqlit" ];

  disabledTestPaths = [
    "tests/ui/"
  ];

  disabledTests = [
    "test_installer_cancel_terminates_process"
    "test_detect_strategy_pip_user_fallback"
  ];

  meta = {
    description = "Lightweight TUI for SQL Server, PostgreSQL, MySQL, SQLite, and more";
    homepage = "https://github.com/Maxteabag/sqlit";
    changelog = "https://github.com/Maxteabag/sqlit/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    mainProgram = "sqlit";
  };
}
