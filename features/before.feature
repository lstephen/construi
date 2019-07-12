Feature: Target dependencies with before
  Scenario: There is a single dependency
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        a: echo "Hello"
        b:
          before:
          - a
          run: echo "World"
      """
    When running construi b --dry-run
    Then it has an exit code of 0
     And the output is
      """

      ** Invoke b

      ** Invoke a

      ** Execute a (dry run)

      ** Execute b (dry run)

      Build Succeeded.


      """

  Scenario: There is multiple dependencies
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        x: echo "Hello"
        y: echo "World"
        b:
          before:
          - x
          - y
      """
    When running construi b --dry-run
    Then it has an exit code of 0
     And the output is
      """

      ** Invoke b

      ** Invoke x

      ** Execute x (dry run)

      ** Invoke y

      ** Execute y (dry run)

      Build Succeeded.


      """

  Scenario: There is dependencies of dependencies
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        x: echo "Hello"
        y:
          before:
          - x
          run: echo "World"
        b:
          before:
          - y
      """
    When running construi b --dry-run
    Then it has an exit code of 0
     And the output is
      """

      ** Invoke b

      ** Invoke y

      ** Invoke x

      ** Execute x (dry run)

      ** Execute y (dry run)

      Build Succeeded.


      """

  Scenario: There is a single dependency twice
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        a: echo "Hello"
        b:
          before:
          - a
          - a
          run: echo "World"
      """
    When running construi b --dry-run
    Then it has an exit code of 0
     And the output is
      """

      ** Invoke b

      ** Invoke a

      ** Execute a (dry run)

      ** Invoke a

      ** Skipped a

      ** Execute b (dry run)

      Build Succeeded.


      """

  Scenario: There is a cyclic dependency
    Given a construi.yml file
      """
      image: alpine:3.10
      targets:
        a: 
          before:
          - b
          run: echo "Hello"
        b:
          before:
          - a
          run: echo "World"
      """
    When running construi b
    Then it has an exit code of 1
     And it outputs
      """

      ** Invoke b

      ** Invoke a

      ** Invoke b

      Configuration Error: Cyclic dependency detected when invoking b


      """
