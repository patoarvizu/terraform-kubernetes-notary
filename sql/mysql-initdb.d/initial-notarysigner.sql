CREATE DATABASE IF NOT EXISTS `notarysigner`;

CREATE USER "signer"@"%" IDENTIFIED BY "%% .Env.SIGNERPASSWORD %%";

GRANT
	ALL PRIVILEGES ON `notarysigner`.* 
	TO "signer"@"%";
