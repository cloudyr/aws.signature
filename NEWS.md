# aws.signature 0.4.0

* `read_credentials()` now trims excess whitespace from profile names. (#22, h/t Paul Ingles)
* `locate_credentials()` returns `region = default_region` even when no other credentials are found.
* `canonical_request()` now correctly trims whitespace.
* The test suite was upbdated substantially, though not all tests run on CRAN.

# aws.signature 0.3.7

* On namespace load, the package now checks for the presence of environment variables and, if absent, attempts to call `use_credentials()` (with defaults) to that behavior is more similar to other AWS client libraries. (https://github.com/cloudyr/aws.s3/pull/184, h/t Dan Tenenbaum)
* The `profile` argument of `use_credentials()` now defaults to `Sys.getenv("AWS_PROFILE", "default")` for consistency with other AWS client libraries.

# aws.signature 0.3.6

* `locate_credentials()` now attempts to look in instance metadata for a region, when called from an EC2 instance. (see https://github.com/cloudyr/aws.s3/issues/151)
* The set of fall backs for values of `region` have been standardized and documented for `locate_credentials()`.
* Updated documentation to describe the need for **aws.ec2metadata** on EC2 instances.

# aws.signature 0.3.5

* `signature_v4_auth()` and `signature_v2_auth()` now both return a `Region` value in their response list, as identified by `locate_credentials()`.

# aws.signature 0.3.4

* Fixed a bug related to extracting credentials from environment variables. (https://github.com/cloudyr/aws.s3/issues/142, https://github.com/cloudyr/aws.s3/issues/143)
* Fixed a bug related to extracting credentials from EC2 instance metadata (https://github.com/cloudyr/aws.s3/issues/144, h/t Daniele Rapati, Will Bowditch)
* Bumped aws.ec2metadata suggestion to 0.1.2.

# aws.signature 0.3.3

* Fixed a bug in `locate_credentials()` caused by trying to retrieve EC2 instance metadata from a non-EC2 machine on which the **aws.ec2metadata** package was installed.
* Expanded test suite to cover more of `locate_credentials()` behavior.

# aws.signature 0.3.2

* CRAN Release.
* Added some minor tests.

# aws.signature 0.3.1

* Changed the precedence of credential sources to: user-supplied values, EC2 instance metadata, environment variables, local credentials file, and global credentials file. (#11)

# aws.signature 0.3.0

* Added a `locate_credentials()` function to walk through a hierarchy of possible credential locations, beginning with user-supplied values, then environment variables, local then global credentials ".aws/credentials" files, and finally (if applicable) an EC2 role for the currently running instance. (#11)

# aws.signature 0.2.9

* Modified `read_credentials()` to allow key-value pairs of any form: `KEY=VALUE`, `KEY = VALUE`, `KEY= VALUE`, `KEY =VALUE`. (#15, h/t David Severski)

# aws.signature 0.2.8

* Corrected the default timestamp format in `signature_v2_auth()`.

# aws.signature 0.2.7

* `read_credentials()` now looks for the credentials file in a more reasonable location on Windows (#12/#13, h/t user:kadrach)
* roxygenized the documentation (and reorganized the source files slightly). (#9)

# aws.signature 0.2.6

* Added support for signing requests (using V4 signatures) with temporary security tokens.
* Modified some default arguments to correct unintended behavior. These should not affect any previously correct signing code.

# aws.signature 0.2.5

* Added functions `read_credentials()` and `use_credentials()` to access AWS access credentials stored in `.aws/credentials` files.

# aws.signature 0.2.4

* Further fixes to the handling of default arguments from environment variables.

# aws.signature 0.2.3

* Fixed the handling of default arguments from environment variables.

# aws.signature 0.2.2

* Added support for (legacy) AWS Signature Version 2.

# aws.signature 0.2.1

* `canonical_request()` now sets C collate order to properly order query argument and header names across platforms.

# aws.signature 0.1.4

* Coerce query string arguments to character before passing to `URLencode()`. (#5)

# aws.signature 0.1.3

* Add standard AWS test suite: http://docs.aws.amazon.com/general/latest/gr/signature-v4-test-suite.html. (#2)
* Expose and set default key, secret, and region values in `signature_v4_auth`.

# aws.signature 0.1.2

* Fix bug in request body hashing for non-character request bodies (#3).

# aws.signature 0.1.1

* Allow request body has to be generated from file without loading into memory.

# aws.signature 0.1.0

* Include patched version of `utils::URLencode` that correctly encodes URLs per RFC 3986.
* Initial release.
