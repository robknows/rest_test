cp ../rest_test/__init__.py .
mv __init__.py rest_test.py
python3 test.py
result=$?
rm rest_test.py
exit $result
