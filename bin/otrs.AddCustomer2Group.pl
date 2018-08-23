#!/usr/bin/perl
# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Time;
use Kernel::System::DB;
use Kernel::System::Main;
use Kernel::System::CustomerUser;
use Kernel::System::CustomerGroup;

my %CommonObject;

# create common objects
$CommonObject{ConfigObject} = Kernel::Config->new(%CommonObject);
$CommonObject{EncodeObject} = Kernel::System::Encode->new(%CommonObject);
$CommonObject{LogObject}    = Kernel::System::Log->new(
    LogPrefix => 'OTRS-otrs.AddCustomer2Group',
    %CommonObject,
);
$CommonObject{TimeObject}          = Kernel::System::Time->new(%CommonObject);
$CommonObject{MainObject}          = Kernel::System::Main->new(%CommonObject);
$CommonObject{DBObject}            = Kernel::System::DB->new(%CommonObject);
$CommonObject{CustomerUserObject}  = Kernel::System::CustomerUser->new(%CommonObject);
$CommonObject{CustomerGroupObject} = Kernel::System::CustomerGroup->new(%CommonObject);

my %Param;
my %Opts;

use Getopt::Std;
getopt( 'guph', \%Opts );

if ( $Opts{h} || !$Opts{g} || !$Opts{u} || !$Opts{p} ) {
    print STDERR
        "Usage: $0 -u customerlogin -g groupname -p ro|rw\n";
    exit;
}

# ID adding the permissions
$Param{UserID} = '1';

# valid id
$Param{ValidID} = '1';

$Param{Permission}->{ $Opts{p} } = 1;
$Param{UID}                      = $Opts{u};
$Param{Group}                    = $Opts{g};

my $CustomerName = $CommonObject{CustomerUserObject}->CustomerName(
    UserLogin => $Param{UID},
);
if ( !$CustomerName ) {
    print STDERR "ERROR: Failed to get Customer data. The login '$Opts{u}' does not exist.\n";
    exit 1;
}

unless ( $Param{GID} = $CommonObject{CustomerGroupObject}->GroupLookup(%Param) ) {
    print STDERR
        "ERROR: Failed to get Group ID. The group '$Param{Group}' does not exist.\n";
    exit;
}

print "GID: $Param{Group}/$Param{GID} \n";
print "Customer: $Param{UID} - '$CustomerName' \n";
print "Permission: $Opts{p} \n";

if ( !$CommonObject{CustomerGroupObject}->GroupMemberAdd(%Param) ) {
    print STDERR "ERROR: Can't add Customer to group\n";
    exit 1;
}
else {
    exit(0);
}