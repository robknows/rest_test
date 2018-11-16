set -e

versionNumber=`cat versionNumber`
echo "Packaging up version $versionNumber."
sed -i "s/VERSION_NUMBER/$versionNumber.0/g" setup.py
python3 setup.py sdist
echo "Created pip package"
sed -i "s/$versionNumber.0/VERSION_NUMBER/g" setup.py
git add .
git commit -am"Deploying version $versionNumber"
git push
echo "Pushed version $versionNumber to Github."
nextVersionNumber="$((1 + $versionNumber)).0"
echo "Next version number would be $nextVersionNumber"

exit 0
