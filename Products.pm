package Products;
use strict;
use warnings;
use DateTime;

my %email_config = ('hosting' => [1,-3],
				 'domain'  => [-2],
				 'pdomain' => [-2,-9]
				);


sub new{
	my $class = shift;
	my $self ={};
	bless $self,$class;
	return $self;
}


sub add_product {
	my ($self,$data,$dbh) = @_;
	my ($email_data);
	
	$data->[4] = $self->sub_end_date($data->[3],$data->[4]);
	$dbh->insert_customer($data);
	
	if( exists $email_config{$data->[1]}){
		$email_data = $self->cust_email_data($data,$email_config{$data->[1]});
	}
	foreach my $insert_data (@$email_data){
		$dbh->insert_email_schedule($insert_data);
	}	
	return 1;
}


sub delete_product{
	my ($self,$data,$dbh) = @_;
	$dbh->delete_email_schedule($data);
	$dbh->delete_customer($data);
	return 1;
}


sub cust_email_data{
	my ($self,$data,$product) = @_;
	my (@email_data,$email_date);
	
	foreach my $days (@$product){
		if ($days =~ /^-\d+$/){
			$email_date = $self->add_sub_days($data->[4],$days)
		}elsif($days =~/^\d+/){
			$email_date = $self->add_sub_days($data->[3],$days)
		}
		push(@email_data,[$data->[0],$data->[1],$data->[2],$email_date,$data->[5],'N']);	
	}
	
	return \@email_data;
}

sub add_sub_days{
	my ($self,$date,$days) = @_;
	my ($year,$month,$day) = split/-/,$date;
	my $dt = DateTime->new(year=>$year,month=>$month,day=>$day);
	$dt->add(days=>$days);
	return($dt->ymd);
	
}
sub sub_end_date{
	my ($self,$start_date,$duration) = @_;
	my ($year,$month,$day) = split/-/,$start_date;
	my $dt = DateTime->new(year=>$year,month=>$month,day=>$day);
	$dt->add(months=>$duration);
	return($dt->ymd);
	
}

1;