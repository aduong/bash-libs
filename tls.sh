cn='adr-x1-ca-20181108'

# generate 4096-bit RSA key to stdout
openssl genrsa 4096

# generate a CA cert
openssl req -x509 -key ca.key

# generate CSR using server.key for localhost
openssl req -new -key server.key -subj "/CN=localhost"

# sign server CSR with adr-x1-ca-20180814 key and with validity of 30 days
sudo openssl x509 -CAcreateserial -CA /etc/ssl/certs/$cn.pem -CAkey /etc/ssl/private/$cn.key \
  -req -in server.csr -days 30

# issue self-signed cert (meant to be CA)
openssl req -x509 -newkey rsa:4096 -keyout $cn.key -out $cn.pem -nodes -subj "/CN=$cn"
cp $cn.key /etc/ssl/private/$cn.key

# copy cert to shared location, copy key to private location
sudo cp $cn.key /etc/ssl/private/ && sudo mkdir /usr/share/ca-certificates/extras && sudo cp $cn.pem /usr/share/ca-certificates/extras/$cn.crt

# update ca-certs bundles
sudo dpkg-reconfigure ca-certificates
