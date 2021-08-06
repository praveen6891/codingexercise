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
		if ($input_data[0] !~ /^\w+$/){
			print "Customer id should be alphanumeric only\n";
			next;
		}elsif($input_data[1] !~ /^[A-Za-z]+$/){
			print"Product name should be alphabets only\n";
			next;
		}elsif($input_data[2] !~ /^[A-Za-z]+\.(com|net)$/){
			print "Inavlid Domain name\n";
			next;
		}elsif($input_data[3] !~ /^\d{4}\-\d{2}-\d{2}$/){
			print "Invalid date format. Date format should be YYYY-MM-DD\n";
			next;
		}elsif($input_data[4] !~ /^\d{1,2}$/ && ($input_data[4] < 1 && $input_data[4] >12)){
			print"Duration should be a number between 1-12\n";
			next;
		}else{
			push (@data,[@input_data]);
		}
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