#! c:\perl\bin\perl.exe
#-----------------------------------------------------------
# updateshistory.pl
# Plugin for Registry Ripper, SYSTEM 
# Updates/Upgrades History
#
# Change history
# 20220111 - (2022-01-11) created by Krzysztof Gajewski
#  
#-----------------------------------------------------------
package updateshistory;
use strict;
use Digest::MD5  qw(md5 md5_hex md5_base64);

my %config = (hive          => "System",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20220111);

sub getConfig{return %config}
sub getShortDescr {
	return "Check upgardes and updates history of the OS";	
}
sub getDescr{}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

my $VERSION = getVersion();

sub pluginmain {
	
	my $class = shift;
	my $hive = shift;
	::logMsg("Launching updateshistory v.".$VERSION);
	my $reg = Parse::Win32Registry->new($hive);
	my $root_key = $reg->get_root_key;
	
	::rptMsg("");
 
	my $key;
	my $key_path = 'Setup';
	
	my $UpgradePath;
	my $UpgradeTime;
	my $BuildUpdatePath;
	my $BuildUpdateTime;
	
	my $class = shift;
	my $hive = shift;

	if ($key = $root_key->get_subkey($key_path)) {
			::rptMsg("Key: " . $key_path);
			::rptMsg("LastWrite Time: ".::getDateFromEpoch($key->get_timestamp())." (UTC)");
			my @subkeys = $key->get_list_of_subkeys();
			::rptMsg("");
			
			if (scalar(@subkeys) > 0) {
				foreach my $s (@subkeys) { 
					my $lw = $s->get_timestamp();
					my $str = $s->get_name();
					if (index($str,"Source") != -1){
						::rptMsg($str);
						my @vals = $s->get_list_of_values();
							if (scalar(@vals) > 0) {
								foreach my $v (@vals) {
									my $value_name = $v->get_name();									
									my $data = $v->get_data();
									
									if (index($value_name,"BuildBranch") != -1){
										::rptMsg("	 - " . $value_name . ": " .$data );
									}
									
									if (index($value_name,"BuildLab") != -1){
										::rptMsg("	 - " . $value_name . ": " .$data );
									}
									
									if (index($value_name,"CurrentVersion") != -1){
										::rptMsg("	 - " . $value_name . ": " .$data );
									}
									
									if (index($value_name,"EditionID") != -1){
										::rptMsg("	 - " . $value_name . ": " .$data );
									}
									
									if (index($value_name,"InstallDate") != -1){
										::rptMsg("	 - " . $value_name . ": " .$data );
									}
									
									#if (index($value_name,"InstallTime") != -1){
									#	::rptMsg("	 - " . $value_name . ": " . $data );
									#}
									
									if (index($value_name,"ProductName") != -1){
										::rptMsg("	 - " . $value_name . ": " .$data );
									}
									
									if (index($value_name,"ReleaseId") != -1){
										::rptMsg("	 - " . $value_name . ": " .$data );
									}
								}
							}
						::rptMsg("");
					}
					
					if (index($str,"Upgrade") != -1){
						$UpgradePath = "Key: " . "System"."\\".$key_path."\\".$str;
						$UpgradeTime = "LastWrite Time: " . ::getDateFromEpoch($lw);
					}
					
					if (index($str,"BuildUpdate") != -1){
						$BuildUpdatePath = "Key: " . "System"."\\".$key_path."\\".$str;
						$BuildUpdateTime = "LastWrite Time: " . ::getDateFromEpoch($lw);
					}
				}
				::rptMsg($UpgradePath);
				::rptMsg($UpgradeTime);
				
				::rptMsg("");
				
				::rptMsg($BuildUpdatePath);
				::rptMsg($BuildUpdateTime);
			}
	}
	else {
			::rptMsg($key_path." not found\.");
	}
}
1;
