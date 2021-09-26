

sudo apt update -y

if [`dpkg --get-selections | grep apache2 | wc -l` >= 1 ]
then
	echo "apache2 is already installed"
else
	echo "Installing apache server"
	sudo apt install apache2 -y &> /dev/null
fi
