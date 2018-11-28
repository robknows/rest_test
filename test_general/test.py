from assertpy import assert_that

from rest_test import *


@test
def can_put_two_and_two_together():
    assert_that(2 + 2).is_equal_to(4)


main(locals())
exit(0)
