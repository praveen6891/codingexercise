package Email;

use strict;
use warnings;
use MIME::Lite;

sub new{
	
	my $class = shift;
	my $self ={};
	bless $self,$class;
	return $self;
	
}


sub send_email{
	
	my ($self,$dbh,$data,$date) =@_;
	
	foreach my $email_data (@$data){
		my $subject = "Product $email_data->[1] for customer id $email_data->[0] expires on $email_data->[3]";
		my $body	= "Hello $email_data->[0]\n\n Your subscription for Product ".$email_data->[1]." and domain ".$email_data->[2]." expires on ".$email_data->[3].".\nPlease renew your subscription.\n\nThanks";
		eval{
			my $msg = MIME::Lite->new(
				From => "noreply\@atg.com",
				To	 => $email_data->[4],
				Subject => $subject,
				Data	=> $body,
			);
			$msg->send or die "Failed to send email\n";
		};
		if($@){
			print "Failed to send email to user $email_data->[4]\n";
			next;
		}
		eval{
			$dbh->update_email_schedule($email_data,$date);
		};
		if($@){
			print "Failed to update email status flag in email schedule table\n";
			next;
		}
		
	}
	return 1;	
}

1;