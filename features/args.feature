Feature: Passing args to a target
  Scenario: There are arguments passed
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        echo:
          shell: /bin/sh -c
          run: echo $CONSTRUI_ARGS
      """
    When running construi echo Hello World
    Then it has an exit code of 0
     And the output contains
      """
      (/bin/sh -c)> echo $CONSTRUI_ARGS
      """
     And the output contains
      """
      Hello World

      Done.
      """

  Scenario: There are arguments passed and other environment variables
    Given a construi.yml file
      """
      image: alpine:3.10
      environment:
      - NAME=World
      targets:
        echo:
          environment:
          - PREFIX=Well
          shell: /bin/sh -c
          run: echo $PREFIX $CONSTRUI_ARGS $NAME
      """
    When running construi echo Hello
    Then it has an exit code of 0
     And the output contains
      """
      (/bin/sh -c)> echo $PREFIX $CONSTRUI_ARGS $NAME
      """
     And the output contains
      """
      Well Hello World

      Done.
      """

