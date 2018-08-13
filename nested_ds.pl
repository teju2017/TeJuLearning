############################################################
# Author : Thejas HM
# Date   : 13-AUG-2018
# Desc   : Program showing the referencing and dereferencing
#          of the perl variables to understand the complex
#          data structures.
###########################################################

use Data::Dumper;
use strict;

my @abc=qw(First sample array containing some values for us to check);
my @def=qw(second array with some values);
my %hash_var=(
             "life"=>"disaster",
			 "Sports"=>"life long companion",
			 "WORK"=>"Shit"
	      );
		  
		  		  
##### Nested hash values check  ####################
		  
my $hash_abc={
                 "first_val"=>{
                              "life"=>"disaster",
			                  "Sports"=>"life long companion",
			                   "WORK"=>"Shit"
	                        },
		        "Second_val"=>{
		                        "age"=>"thirty four",
			                    "name"=>"thejas"
			              }
		  };
		  
		  
print "Hash reference value for the key \" work \" is : $hash_abc->{'first_val'}->{'WORK'} \n";
print "Hash reference value for the key \"Sports \" is : $hash_abc->{'first_val'}->{'Sports'} \n";
my @key_chk=keys %{$hash_abc->{'Second_val'}};
print "Printing all the keys of the hash : @key_chk \n";


#### Array containing the scalar and the Hashes #####################

print "Value of abc is @abc \n";

my @abc_ns=("acd",\@abc,\@def,\%hash_var);

print "First value of the array abc_ns is : @abc_ns[0] \n";
print "Second value of the array abc_ns is : @{$abc_ns[1]} \n";
print "Third value of the array abc_ns is  : @{$abc_ns[2]} \n";
print "Fourth value of the array abc_ns is : {$abc_ns[3]} \n";


my @val_2_keys= keys $abc_ns[3];
my @val_2_values= values $abc_ns[3];


print "val2 array keys are \" @val_2_keys \" ";
print "val2 array values are \" @val_2_values \"\n";

my @key_val=keys %hash_var;
my @val=values %hash_var;

print "Key value is @key_val and hash value is @val \n";

function_check("its my life","second life","third life");
function_hash_value($abc_ns[3]);


#### Method to show the usage of the shift operator ##################

sub function_check()
{
     my $param1=shift;
	 print "parameter passed is $param1 \n";
}

#### Subroutine to handle the referenced hashes  #################

sub function_hash_value()
{
   my $hash_pointer=$_[0];
   print "hash pointer value is $hash_pointer \n";
   my @hash_key=keys %{$hash_pointer};
   my @hash_values=values %{$hash_pointer};
   print "printing the key values of the hash_pointer: @hash_key \ns";
   print "printing the key values of the hash_pointer: @hash_values \n";
}
