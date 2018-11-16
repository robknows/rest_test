set -e

versionNumber=$((1 + `cat versionNumber`))
echo "Packaging up version $versionNumber."
sed -i "s/VERSION_NUMBER/$versionNumber.0/g" setup.py
python3 setup.py sdist
echo "Created pip package"
sed -i "s/$versionNumber.0/VERSION_NUMBER/g" setup.py
git add .
git commit -am"Deploying version $versionNumber"
git push
echo "Pushed version $versionNumber to Github."

exit 0
