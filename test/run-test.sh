resttest_dir=`readlink -f ../resttest`
PYTHONPATH=$PYTHONPATH:$resttest_dir python3 test.py r
