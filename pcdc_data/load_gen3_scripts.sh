GEN3_SCRIPTS_REPO="https://github.com/chicagopcdc/gen3_scripts.git"
GEN3_SCRIPTS_REPO_BRANCH="origin/gen3-helm"


#------------------------------------------------------
# Clean up
#------------------------------------------------------
rm -rf ./gen3_scripts
echo "removed old folder"

#------------------------------------------------------
# Clone or Update chicagopcdc/data-simulator repo
#------------------------------------------------------
echo "Clone or Update chicagopcdc/gen3-scripts repo from github"

# Does the repo exist?  If not, go get it!
if [ ! -d "./gen3_scripts" ]; then
  git clone $GEN3_SCRIPTS_REPO

  cd ./gen3_scripts

  git checkout -t $GEN3_SCRIPTS_REPO_BRANCH
  git pull

  cd ..
fi

#here I will set the defaults for the .env file if left blank



#load in files to gen3_load
cp ../.env ./gen3_scripts/gen3_load
cp ../credentials.json ./gen3_scripts/gen3_load

#load in files to es_etl_patch
cp ../.env ./gen3_scripts/es_etl_patch
cp ../credentials.json ./gen3_scripts/es_etl_patch