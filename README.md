# Rest Test

For lighweight testing of RESTful APIs

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

`python3 my_tests.py`
