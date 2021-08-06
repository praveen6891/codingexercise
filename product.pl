#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw(strftime);
use Text::Table;

use Products;
use DB;

my (@data);

my $dsn = "DBI:oracle:database=TESTDB";
my $userid = "user123";
my $password = "pass#123";

#filename with Path
my $today_dt = strftime "%Y%m%d", localtime;
my $file = "/home/praveen/customer_products_".$today_dt.".DAT";

#Reading the file
open(my $fh,'<',$file) or die "Couldn't open file to read $!\n";

while(<$fh>){
	chomp($_);
	if($_=~/^customer_id/){
		next;
	}
	elsif($_ =~ /^\s+$/){
		next;
	}
	else{
		my @input_data =split/\|/,$_;
		push (@data,[split/\|/,$_]);
	}
}
	
close ($fh);


my $dbh=DB->new($dsn,$userid,$password);

my $products = Products->new();

foreach my $data (@data){
	
	$products->add_product($data,$dbh) if($data->[$#$data] eq 'I');
	$products->delete_product($data,$dbh) if($data->[$#$data] eq 'D');
}

#list email schedule

my $email_schedule=$dbh->select_email_list();

my $tb = Text::Table->new("CustomerID", "ProductName", "Domain", "EmailDate");

foreach (@$email_schedule){
	$tb->load($_);
}

print $tb;

exit 0;