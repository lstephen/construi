Feature: Error messages

  Scenario: There is no construi.yml
    When running construi -T
    Then it has an exit code of 1
     And the output is
      """

      Configuration Error: Could not read construi.yml


      """

  Scenario: There is a badly formatted construi.yml
    Given a construi.yml file
      """
      targets
        a: blah
      """
    When running construi -T
    Then it has an exit code of 1
     And the output contains
      """
      Configuration Error: mapping values are not allowed here
      """

  Scenario: There is no target because the chosen target does not exist
    Given a construi.yml file
      """
      targets:
        package: echo "Hello World"
      """
    When running construi build
    Then it has an exit code of 1
     And the output is
      """

      No such target: build


      """

  Scenario: There is no target because there are no targets given
    Given a construi.yml file
      """
      targets:
      """
    When running construi build
    Then it has an exit code of 1
     And the output is
      """

      No such target: build


      """

  Scenario: There is not target because the file is blank
    Given a construi.yml file
      """
      """
    When running construi build
    Then it has an exit code of 1
     And the output is
      """

      No such target: build


      """
