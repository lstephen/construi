Feature: Running a single target
  Scenario: There is a single command
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        a: echo "Hello World"
      """
    When running construi a
    Then it has an exit code of 0
     And the output contains
      """
      ** Invoke a

      ** Execute a
      """
     And the output contains
      """
      3.10: Pulling from library/alpine
      """
     And the output contains
      """
      > echo "Hello World"
      """
     And the output contains
      """
      Hello World

      Done.
      """

  Scenario: There is two commands
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        a:
          run:
            - echo "Hello"
            - echo "World"
      """
    When running construi a
    Then it has an exit code of 0
     And the output contains
      """
      Hello

      > echo "World"
      """
     And the output contains
      """
      World

      Done.
      """

  Scenario: There is shell
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        a:
          shell: /bin/sh -c
          run: echo "Hello" && echo "World"
      """
    When running construi a
    Then it has an exit code of 0
     And the output contains
      """
      (/bin/sh -c)> echo "Hello" && echo "World"
      """
     And the output contains
      """
      Hello
      World

      Done.
      """

  Scenario: There is a Dockerfile to build
    Given a construi.yml file
      """
      build: .
      targets:
        a:
          run:
      """
      And a Dockerfile file
      """
      FROM alpine:3.10
      CMD ["echo", "Hello World"]
      """
    When running construi a
    Then it has an exit code of 0
     And the output contains
      """
      Building Images...
      Building a
      Step 1/2 : FROM alpine:3.10
      """
     And the output contains
      """
      Hello World

      Done.
      """

