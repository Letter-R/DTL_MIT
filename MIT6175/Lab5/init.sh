git clone https://github.com/cambridgehackers/connectal
curl http://www.dabeaz.com/ply/ply-3.9.tar.gz | tar -zxf -
ln -s ply-3.9/ply/ /opt/connectal/scripts/
sed -i 's/python3 script/python2.7 script/g' connectal/Makefile
