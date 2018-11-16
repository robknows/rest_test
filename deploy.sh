set -e

versionNumber=`cat versionNumber`
cowsay "Packaging up version $versionNumber."
sed -i "s/VERSION_NUMBER/$versionNumber.0/g" setup.py
python3 setup.py sdist
cowsay "Created pip package"
sed -i "s/$versionNumber.0/VERSION_NUMBER/g" setup.py
git add .
git commit -am"Deploying version $versionNumber"
git push
cowsay "Pushed version $versionNumber to Github."
nextVersionNumber="$((1 + $versionNumber)).0"
cowsay "Next version number would be $nextVersionNumber"

exit 0
