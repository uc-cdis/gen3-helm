GEN3_SCRIPTS_REPO="https://github.com/chicagopcdc/gen3_etl.git"
GEN3_SCRIPTS_REPO_BRANCH="origin/update-requirments"
ENV_FILE="../.env"
CREDENTIALS_FILE="../credentials.json"

#------------------------------------------------------
# Clean up
#------------------------------------------------------
rm -rf ./gen3_etl
echo "removed old folder"

#------------------------------------------------------
# Clone or Update chicagopcdc/data-simulator repo
#------------------------------------------------------
echo "Clone or Update chicagopcdc/gen3_etl repo from github"

# Does the repo exist?  If not, go get it!
if [ ! -d "./gen3_etl" ]; then
  git clone $GEN3_SCRIPTS_REPO

  cd ./gen3_etl

  git checkout -t $GEN3_SCRIPTS_REPO_BRANCH
  git pull

  cd ..
fi

#here I will set the defaults for the .env file if left blank



#load in files to gen3_load and es_etl_patch
cp $ENV_FILE ./gen3_etl/elasticsearch && cp $ENV_FILE ./gen3_etl/graph && cp $CREDENTIALS_FILE ./gen3_etl/elasticsearch && cp $CREDENTIALS_FILE ./gen3_etl/graph
