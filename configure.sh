#!bin/bash

while getopts a:s:g: flag
do
    case "${flag}" in
        a) access_key=${OPTARG};;
        s) secret_key=${OPTARG};;
        g) github_pat=${OPTARG};;
    esac
done

user=admin
psw=bindecy

# get secrets and replace them in creds
sed -i "s/access_key/$access_key/g" jenkins/creds/aws_creds.xml
sed -i "s/secret_key/$secret_key/g" jenkins/creds/aws_creds.xml
sed -i "s/github_secret/$github_pat/g" jenkins/creds/github_pat.xml

echo "checking pre-requisites..."
if which jq ; then
    echo "jq exists, can continue"
else
    echo "jq doesn't exist, attempting to install.."
    apt-get install jq -y
fi

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
# add permissions
usermod -aG docker $USER
# build image and run
cd docker
docker build -t jenkins-bindecy:1.0 .
docker run -d --name jenkins-bindecy -p 8080:8080 jenkins-bindecy:1.0
cd -

echo "waiting for container to start..."
sleep 10

# access jenkins api
crumb=$(curl -v -X GET http://localhost:8080/crumbIssuer/api/json --user $user:$psw  \
-H "Cookie: JSESSIONID.56e4b3b7=node0xsbnd4uu2dt41j69vxgq0zfml1.node0; JSESSIONID.fd4e3cc2=node0sv2b0t44x0wq10eyfiohqnomq22.node0" | jq -r '.crumb')

#configure secrets
cd jenkins/creds
for file in *
do
data=$(cat $file)
curl -X POST http://localhost:8080/manage/credentials/store/system/domain/_/createCredentials --user $user:$psw\
    -H "Cookie: JSESSIONID.56e4b3b7=node0xsbnd4uu2dt41j69vxgq0zfml1.node0; JSESSIONID.fd4e3cc2=node0sv2b0t44x0wq10eyfiohqnomq22.node0" \
    -H "Content-Type:application/xml" \
    -H "Jenkins-Crumb: $crumb" \
    --data-raw "$data"
done
cd -

cd jenkins/pipelines
for file in *
do
data=$(cat $file)
curl -X POST http://localhost:8080/createItem?name=${file%.*} --user $user:$psw \
    -H "Cookie: JSESSIONID.56e4b3b7=node0xsbnd4uu2dt41j69vxgq0zfml1.node0; JSESSIONID.fd4e3cc2=node0sv2b0t44x0wq10eyfiohqnomq22.node0" \
    -H "Content-Type:application/xml" \
    -H "Jenkins-Crumb: $crumb" \
    --data "$data"
done
cd -
echo $crumb