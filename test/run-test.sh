rest_test_dir=`readlink -f ../rest_test`
PYTHONPATH=$PYTHONPATH:$rest_test_dir python3 test.py r
