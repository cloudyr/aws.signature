# CHANGES TO aws.signature 0.3.3

* Fixed a bug in `locate_credentials()` caused by trying to retrieve EC2 instance metadata from a non-EC2 machine on which the **aws.ec2metadata** package was installed.
* Expanded test suite to cover more of `locate_credentials()` behavior.

# CHANGES TO aws.signature 0.3.2

* CRAN Release.
* Added some minor tests.

# CHANGES TO aws.signature 0.3.1

* Changed the precedence of credential sources to: user-supplied values, EC2 instance metadata, environment variables, local credentials file, and global credentials file. (#11)

# CHANGES TO aws.signature 0.3.0

* Added a `locate_credentials()` function to walk through a hierarchy of possible credential locations, beginning with user-supplied values, then environment variables, local then global credentials ".aws/credentials" files, and finally (if applicable) an EC2 role for the currently running instance. (#11)

# CHANGES TO aws.signature 0.2.9

* Modified `read_credentials()` to allow key-value pairs of any form: `KEY=VALUE`, `KEY = VALUE`, `KEY= VALUE`, `KEY =VALUE`. (#15, h/t David Severski)

# CHANGES TO aws.signature 0.2.8

* Corrected the default timestamp format in `signature_v2_auth()`.

# CHANGES TO aws.signature 0.2.7

* `read_credentials()` now looks for the credentials file in a more reasonable location on Windows (#12/#13, h/t user:kadrach)
* roxygenized the documentation (and reorganized the source files slightly). (#9)

# CHANGES TO aws.signature 0.2.6

* Added support for signing requests (using V4 signatures) with temporary security tokens.
* Modified some default arguments to correct unintended behavior. These should not affect any previously correct signing code.

# CHANGES TO aws.signature 0.2.5

* Added functions `read_credentials()` and `use_credentials()` to access AWS access credentials stored in `.aws/credentials` files.

# CHANGES TO aws.signature 0.2.4

* Further fixes to the handling of default arguments from environment variables.

# CHANGES TO aws.signature 0.2.3

* Fixed the handling of default arguments from environment variables.

# CHANGES TO aws.signature 0.2.2

* Added support for (legacy) AWS Signature Version 2.

# CHANGES TO aws.signature 0.2.1

* `canonical_request()` now sets C collate order to properly order query argument and header names across platforms.

# CHANGES TO aws.signature 0.1.4

* Coerce query string arguments to character before passing to `URLencode()`. (#5)

# CHANGES TO aws.signature 0.1.3

* Add standard AWS test suite: http://docs.aws.amazon.com/general/latest/gr/signature-v4-test-suite.html. (#2)
* Expose and set default key, secret, and region values in `signature_v4_auth`.

# CHANGES TO aws.signature 0.1.2

* Fix bug in request body hashing for non-character request bodies (#3).

# CHANGES TO aws.signature 0.1.1

* Allow request body has to be generated from file without loading into memory.

# CHANGES TO aws.signature 0.1.0

* Include patched version of `utils::URLencode` that correctly encodes URLs per RFC 3986.
* Initial release.
