#! c:\perl\bin\perl.exe
#-----------------------------------------------------------
# valuesizechecker.pl
# Plugin for Registry Ripper, NTUSER.DAT 
# Fake Forum Infection 
#
# Change history
# 20211103 - (2021-11-03) created by Krzysztof Gajewski
#  
#-----------------------------------------------------------
package valuesizechecker;
use strict;
use Digest::MD5  qw(md5 md5_hex md5_base64);

#use Switch; it doesn't work with PERL2EXE

my %config = (hive          => "NTUSER\.DAT",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20211103);

sub getConfig{return %config}
sub getShortDescr {
	return "Check sizez of the registr values";	
}
sub getDescr{}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

my $VERSION = getVersion();

sub pluginmain {
	
	my $class = shift;
	my $ntuser = shift;
	::logMsg("Launching valuesizechecker v.".$VERSION);
	my $reg = Parse::Win32Registry->new($ntuser);
	my $root_key = $reg->get_root_key;
	
	::rptMsg("");
 
	my $key;
		
	print "\n";
	print "Please provide the registry subkey: ";
	my $subKeyName = <STDIN>;
	chomp $subKeyName;
	print "\n";
	
	my $key_path = "Software\\Microsoft\\" . $subKeyName;  
	

	
	if ($key = $root_key->get_subkey($key_path)) {
		::rptMsg("Checking " .$key_path);
		::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())." (UTC)");
		my @vals = $key->get_list_of_values();		
		::rptMsg("");
			if (scalar(@vals) > 0) {
				foreach my $v (@vals) {
				
					my $name = $v->get_name();
					my @data = $v->get_data();
					my $len  = length($data[0]);
					
					::rptMsg("The value name: " .$name);
					::rptMsg("The value size: " .$len. " bytes");
						::rptMsg("");
						}
			}
			
			else {
				::rptMsg($key." has no values.");
			}	
	}
	
	else {
		::rptMsg($key_path." not found\.");
	}
}

1;
