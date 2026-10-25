Architectural decisions:

App:
- One ping per request rather than batch handling, makes artificially testing overload, cost testing and scaling and alarms easier down the line.
- Added structured JSON logging using the logging module, chosen so DynamoDB and boto3 errors can be logged with full tracebacks.
- Validation kept minimal as clients are own bots mainly there to showcase the back end monitoring and alerting architecture(Project focus)
- Split requirements with "-dev" to hold only packages needed for testing. EC2 only downloads what's needed to run app no test packages.

Arch:
- Registering own Domain with route53, using this and ACM to allow for HTTPS for encrypted transit of data to APP, Using API key as further validation and security.
- Dynamodb conditional write logic to check if machine already exists and seq is greater than last value. Atomic check-and-write with no separate read, so two pings can’t race.
- Last_seen stored on every write to be used to silent machine check later using lambda and eventbridge.
- CI workflow runs on every PR and performs checks before merge allowed.
- Set up branch restrictions rule set, made repo public and enforced Restrict deletions, Block force pushes, Require status checks to pass and Require a pull request before merging to enforce CI workflow on every merge.
