Feature: Getting version

  Scenario Outline: Getting version
    When running <command>
    Then it has an exit code of 0
    Then it outputs the version

    Examples:
        | command            |
        | construi --version |
        | construi -v        |
