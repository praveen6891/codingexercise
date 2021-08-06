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


1;