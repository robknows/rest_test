# Rest Test

For lighweight testing of RESTful APIs. There is an example of what a
rest_test looks like at test/test.py.

# Usage

Install with

`pip3 install git+git://github.com/robknows/rest_test.git#egg=rest_test`

Include in your file with

`from rest_test import *`

Write a test like

```
@test
def can_say_hello():
  res = requests.get("http://localhost:8000/hello")
  assert_that(res.status_code).is_equal_to(200)
  assert_that(res.json()).is_equal_to("hello")
```

Run all the tests (marked by `@test`) in the file by adding the following to the end of the file

```
main(locals(), start_server, stop_server)
exit(0)
```

Where `start_server` and `stop_server` are functions which start and stop the server, respectively.

Finally, run your the test suite you created with the above steps by running from the command line

`python3 my_tests.py r # 'r' if the test should (r)un the server itself using the provided functions`

Or

`python3 my_tests.py a # 'a' if the server is (a)lready running`

# Coming soon

Run main without needing to specify any kind of setup/teardown to be more fit
for applications which are actually not RESTful APIs.
