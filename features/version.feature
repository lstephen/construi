Feature: Getting version

  Scenario Outline: Getting version
    When running <command>
    Then it outputs the version

    Examples:
        | command            |
        | construi --version |
        | construi -v        |
