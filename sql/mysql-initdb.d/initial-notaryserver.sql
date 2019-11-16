CREATE DATABASE IF NOT EXISTS `notaryserver`;

CREATE USER "server"@"%" IDENTIFIED BY "%% .Env.SERVERPASSWORD %%";

GRANT
	ALL PRIVILEGES ON `notaryserver`.* 
	TO "server"@"%";
