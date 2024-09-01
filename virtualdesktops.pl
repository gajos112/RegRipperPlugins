#! c:\perl\bin\perl.exe
#-----------------------------------------------------------
# virtualdesktops.pl
# Plugin for Registry Ripper, NTUSER.DAT 
# Fake Forum Infection 
#
# Change history
# 20240901 - (2024-09-01) Creation of the plugin
#  
#-----------------------------------------------------------
package virtualdesktops;
use strict;

#use Switch; it doesn't work with PERL2EXE

my %config = (hive          => "NTUSER\.DAT",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20240901);

sub getConfig{return %config}
sub getShortDescr {
	return "Check Virtual Desktops on the system";	
}
sub getDescr{}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

my $VERSION = getVersion();

sub reverse_endian {
    my ($little_endian_string) = @_;
    
    my $big_endian_string;
    
    for (my $i = 0; $i < length($little_endian_string); $i += 2) {
        $big_endian_string = substr($little_endian_string, $i, 2) . $big_endian_string;
    }
    
    return $big_endian_string;
}


sub bytes_to_guid {
    my ($byte_string) = @_;
    
    #die "Invalid byte string length" unless length($byte_string) == 32;

    my $guid = join('-', 
        reverse_endian(substr($byte_string, 0, 8)),
        reverse_endian(substr($byte_string, 8, 4)),
        reverse_endian(substr($byte_string, 12, 4)),
        reverse_endian(substr($byte_string, 16, 4)),
        reverse_endian(substr($byte_string, 20, 12))
    );
    
    return $guid;
}


sub pluginmain {
	
	my $class = shift;	
	my $ntuser = shift;
	::logMsg("Launching virtualdesktops v.".$VERSION);
	my $reg = Parse::Win32Registry->new($ntuser);
	my $root_key = $reg->get_root_key;
	
	::rptMsg("");
 
	my $key;
	my $i = 0;
		
	my $KeyToCheck = "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VirtualDesktops";
		if ($key = $root_key->get_subkey($KeyToCheck)) {
			
			::rptMsg("Key: " . $KeyToCheck);
			::rptMsg("LastWrite Time: ".::getDateFromEpoch($key->get_timestamp())." (UTC)");
			::rptMsg("");
			my @vals = $key->get_list_of_values();
			if (scalar(@vals) > 0) {
				foreach my $v (@vals) {
					my $data = $v->get_data();
					my $value_name = $v->get_name();
						if (index($value_name,"VirtualDesktopIDs") != -1){
							my $data_hex = unpack('H*', $data);
							
							my $max_length = 16 * 2; 
							my $current_position = 0;
							my $virtual_desktop_number = 1;

							while ($current_position < length($data_hex)) {
								my $line_data = substr($data_hex, $current_position, $max_length);
								#::rptMsg("Virtual Desktop $virtual_desktop_number: " . $line_data);
								$current_position += $max_length;

								my $guid = bytes_to_guid($line_data);
								::rptMsg("GUID ".$virtual_desktop_number.": " . $guid);
								$virtual_desktop_number++;
							}
						}
						elsif (index($value_name,"CurrentVirtualDesktop") != -1){
							
							my $data_hex = unpack('H*', $data);
						
						my $max_length = 16 * 2; 
						my $current_position = 0;
						my $virtual_desktop_number = 1;

						while ($current_position < length($data_hex)) {
							my $line_data = substr($data_hex, $current_position, $max_length);
							#::rptMsg(" $virtual_desktop_number: " . $line_data);
							$current_position += $max_length;

							my $guid = bytes_to_guid($line_data);
							::rptMsg("");
							::rptMsg("Current Virtual Desktop: " . $guid);
						}
					}
				}
			}
		}	
}
