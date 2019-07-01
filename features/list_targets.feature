Feature: List targets

  Scenario: Getting single target
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

  Scenario: Getting multiple targets
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

