cp ../rest_test/__init__.py .
mv __init__.py rest_test.py
python3 test.py r
rm -rf rest_test.py
