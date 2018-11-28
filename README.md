# Rest Test

For lighweight testing of RESTful APIs. There is an example of what a
rest_test looks like at test/test.py.

# Usage

Install with

`pip3 install git+git://github.com/robknows/rest_test.git#egg=rest_test`

Include in your file with

`from rest_test import *`

Write a test like

```python
@test
def can_say_hello():
  res = requests.get("http://localhost:8000/hello")
  assert_that(res.status_code).is_equal_to(200)
  assert_that(res.json()).is_equal_to("hello")
```

If you need to, write code to start and stop your server like

```python
@setup
def start_server():
    os.system("./run-my-server &")

@teardown
def stop_server():
    os.system("pkill -f \"run-my-server\"")
```

Run all the tests (marked by `@test`) in the file by adding the following to the end of the file

```python
main(locals())
```

Finally, run your the test suite you created with the above steps by running from the command line

`python3 my_tests.py`

# Todo

- Create @before_each, @after_each

- Exit code

- Specify a particular test to run

- Binary for running all (rest_test)s in a directory (like test/).
