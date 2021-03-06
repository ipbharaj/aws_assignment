name=inderpreet
timestamp=$(date '+%d%m%Y-%H%M%S')
filename=${name}-httpd-logs-${timestamp}
s3bucketname=upgrad-inderpreet

echo "Update apt "
sudo apt update -y


echo "-----Install Apache if not exist-----"

if [ `dpkg --get-selections | grep apache2 | wc -l` != 0 ]
then
	echo "Apache 2 is already installed"
else
	echo "Installing Apache 2 server"
	sudo apt install apache2 -y &> /dev/null
fi

echo "-----Check if Apaceh Server is running-----"

if [ `service apache2 status | grep running | wc -l` == 1 ]
then
	echo "Apache2 server is running"
else
	echo "Starting server as it was not running"
	sudo service apache start
fi

echo "-----Check apache enable status-----"

if [ `systemctl apache2 status | grep enables | wc -l` == 1 ]
then
	echo "Apache2 is already enabled"
else
	echo "Enabling Apache2 as its was not enabled"
	sudo systemctl enable apache2
fi

echo "-----Copy compressed logs into temp folder-----"

cd /var/log/apache2/
tar -cvf /tmp/${filename}.tar *.log

echo "-----Copy log tar to s3-----"

aws s3 \
cp /tmp/${filename}.tar \
s3://${s3bucketname}/logfiles/${filename}.tar


if [ -e /var/www/html/inventory.html ]
then
	echo "Inventory html file exists"
else
	echo "file doesnot exist adding inventory.html"
	sudo touch /var/www/html/inventory.html
	sudo echo "LogType    DateCreated    Type    Size" >> /var/www/html/inventory.html
fi

echo "add entry in inventory"
size=$(stat -c '%s' /tmp/${filename}.tar)
echo "https-logs    ${timestamp}    tar    ${size}" >> /var/www/html/inventory.html


echo "add script to cronjob"
if [ -e /etc/cron.d/automation ]
then
	echo "Job already added"
else
	echo " adding cron job, run every 6th hour of day"
	sudo touch /etc/cron.d/automation
	echo "0 0/6 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
	
fi
