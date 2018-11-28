set -e

versionNumber=`cat versionNumber`
nextVersionNumber="$((1 + $versionNumber))"
cowsay "Packaging up version $nextVersionNumber."
sed -i '' "s/$versionNumber.0/$nextVersionNumber.0/g" setup.py
python3 setup.py sdist
cowsay "Created pip package"
cowsay "Saving new version number '$nextVersionNumber' to file 'versionNumber'"
rm versionNumber
echo "$nextVersionNumber" > versionNumber
git add .
git commit -am"Autocommit: Deploying version $nextVersionNumber"
git push
cowsay "Pushed version $nextVersionNumber to Github."

exit 0
