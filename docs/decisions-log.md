Architectural decisions:

App:
- One ping per request rather than batch handling, makes artificially testing overload, cost testing and scaling and alarms easier down the line.
- 

Arch:
- Registering own Domain with route53, using this and ACM to allow for HTTPS for encrypted transit of data to APP, Using API key as fruther validation and security.
- 