Architectural decisions:

App:
- One ping per request rather than batch handling, makes artificially testing overload, cost testing and scaling and alarms easier down the line.
- Added structured JSON logging using through the logging module, chosen so DynamoDB and boto3 errors can be logged with full tracebacks.
- Validation kept minimal as clients are own bots mainly there to showcase the back end monitoring and alerting architetcure(Project focus)

Arch:
- Registering own Domain with route53, using this and ACM to allow for HTTPS for encrypted transit of data to APP, Using API key as further validation and security.
- 