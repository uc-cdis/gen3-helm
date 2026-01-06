apk add git curl vim wget
wget https://go.dev/dl/go1.24.2.linux-arm64.tar.gz
tar -C /usr/local -xzf go1.24.2.linux-arm64.tar.gz
echo 'PATH=$PATH:/usr/local/go/bin:/root/go/bin' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/ohsu-comp-bio/funnel.git
git clone https://github.com/ohsu-comp-bio/funnel-plugins.git
rm -f /app/funnel
cd funnel && git checkout feature/plugins && go build . && go install .




