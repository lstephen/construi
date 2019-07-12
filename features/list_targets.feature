Feature: List targets

  Scenario: There is a single target
    Given a construi.yml file
      """
      targets:
        single_target:
      """
    When running construi -T
    Then it has an exit code of 0
     And it outputs
      """
      single_target

      """

  Scenario: There are multiple targets
    Given a construi.yml file
      """
      targets:
        b:
        c:
        a:
      """
    When running construi --list-targets
    Then it has an exit code of 0
     And it outputs
      """
      a
      b
      c

      """

  Scenario: There are no targets
    Given a construi.yml file
      """
      targets:
      """
    When running construi -T
    Then it has an exit code of 0
     And it outputs
      """
      """
