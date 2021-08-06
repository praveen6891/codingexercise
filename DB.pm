package DB;

use strict;
use warnings;
use DBI;


sub new {
	my $class = shift;
    my ($dsn,$user,$pass) = @_;
    my $dbh = DBI->connect( $dsn, $user, $pass) or die "Failed to connect to DB";
	my $self = {_dbh => $dbh};
    bless $self, $class;
    return $self;
}

sub insert_customer {
	my ($self,$data) = @_;
	
	eval{
		$self->{_sth} = $self->{_dbh}->prepare("INSERT INTO CUSTOMER (CUSTOMER_ID,PRODUCT_NAME,DOMAIN,SUB_START_DATE,SUB_END_DATE) VALUES (?,?,?,?,?)");
		$self->{_sth}->execute($data->[0],$data->[1],$data->[2],$data->[3],$data->[4]);
	};
	if($@){
		print "Failed to insert records for customer_id $data->[0] in customer table\n";
	}else{
		$self->{_sth}->finish();
		$self->{_dbh}->commit();
	}
	return 1;
}

sub insert_email_schedule {
	my ($self,$data) = @_;
	
	eval{
		$self->{_sth} = $self->{_dbh}->prepare("INSERT INTO EMAIL_SCHEDULE (CUSTOMER_ID,PRODUCT_NAME,DOMAIN,EMAIL_DATE,EMAIL_ID,EMAIL_STATUS) VALUES (?,?,?,?,?)");
		$self->{_sth}->execute($data->[0],$data->[1],$data->[2],$data->[3],$data->[4],$data->[5]);
	};
	if($@){
		print "Failed to insert records for customer_id $data->[0] in email_schedule table\n";
	}else{
		$self->{_sth}->finish();
		$self->{_dbh}->commit();
	}
	return 1;
}

sub delete_customer {
	my ($self,$data) = @_;
	
	eval{
		$self->{_sth} = $self->{_dbh}->prepare("DELETE FROM CUSTOMER WHERE CUSTOMER_ID = ? AND PRODUCT_NAME = ? AND DOMAIN = ?");
		$self->{_sth}->execute($data->[0],$data->[1],$data->[2]);
	};
	if($@){
		print "Failed to delete records for customer_id $data->[0] from customer table\n";
	}else{
		$self->{_sth}->finish();
		$self->{_dbh}->commit();
	}
	return 1;
	
}

sub delete_email_schedule {
	my ($self,$data) = @_;
	
	eval{
		$self->{_sth} = $self->{_dbh}->prepare("DELETE FROM EMAIL_SCHEDULE WHERE CUSTOMER_ID = ? AND PRODUCT_NAME = ? AND DOMAIN = ?");
		$self->{_sth}->execute($data->[0],$data->[1],$data->[2]);
	};
	if($@){
		print "Failed to delete records for customer_id $data->[0] from email_schedule table\n";
	}else{
		$self->{_sth}->finish();
		$self->{_dbh}->commit();
	}
	return 1;
	
}

sub select_email_list {
	my ($self) = @_;
	my ($data);
	eval{
		$self->{_sth} = $self->{_dbh}->prepare("SELECT CUSTOMER_ID,PRODUCT_NAME,DOMAIN,EMAIL_DATE FROM EMAIL_SCHEDULE ORDER BY EMAIL_DATE");
		$self->{_sth}->execute();
		$data = $self->{_sth}->fetchall_arrayref; 
	};
	if($@){
		print "Failed to fetch records from email_schedule table\n";
	}	
	return $data;
}

sub select_email_data {
	my ($self,$date) = @_;
	my ($data);
	eval{
		$self->{_sth} = $self->{_dbh}->prepare("SELECT C.CUSTOMER_ID,C.PRODUCT_NAME,C.DOMAIN,C.SUB_END_DATE,E.EMAIL_ID FROM CUSTOMER C,EMAIL_SCHEDULE E WHERE C.CUSTOMER_ID=E.CUSTOMER_ID AND C.PRODUCT_NAME=E.PRODUCT_NAME AND C.DOMAIN=E.DOMAIN AND E.EMAIL_STATUS ='N' AND E.EMAIL_DATE = TO_DATE(?,\'YYYY-MM-DD\')"); 
		$self->{_sth}->execute($date);
		$data = $self->{_sth}->fetchall_arrayref; 
	};
	if($@){
		print "Failed to fetch records for from email_schedule and customer table for email date $date\n";
	}	
	return $data;
}

sub update_email_schedule {
	my ($self,$data,$date) = @_;
	
	eval{
		$self->{_sth} = $self->{_dbh}->prepare("UPDATE EMAIL_SCHEDULE SET EMAIL_STATUS=\'Y\' WHERE CUSTOMER_ID=? AND PRODUCT_NAME=? AND DOMAIN=? AND EMAIL_DATE = ?");
		$self->{_sth}->execute($data->[0],$data->[1],$data->[2],$date);
	};
	if($@){
		print "Failed to insert records for customer_id $data->[0] in email_schedule table\n";
	}else{
		$self->{_sth}->finish();
		$self->{_dbh}->commit();
	}
}

1;