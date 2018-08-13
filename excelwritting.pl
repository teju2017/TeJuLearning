use Excel::Writer::XLSX;

print "Trying the excel writting programe";

print "INC value is @INC \n";

# Create a new Excel workbook
unlink('perl_example.xlsx');
my $workbook = Excel::Writer::XLSX->new( 'Rathyatra_2018.xlsx' );
 
# Add a worksheet
$worksheet = $workbook->add_worksheet();
 
#  Add and define a format
$format = $workbook->add_format();
$format->set_bold();
$format->set_color( 'red' );
$format->set_align( 'center' );

@abc_array=("xcd","xdf","asddf","sdd","sdfdfsd","sdddsf","sdfd","sddfd","sddsf");
@abc_array_2=("xcd","xdf","asddf","sdd","sdfdfsd","sdddsf","sdfd","sddfd","sddsf");
@abc_array_3=("xcd","xdf","asddf","sdd","sdfdfsd","sdddsf","sdfd","sddfd","sddsfs sdadsd sadsad asdad adada asdasdsa  asd               asdsd asdd");
@col_header=("col1","col2","col3","col4","col5","col6","col7","col8","col9");
$array_ref=\@abc_array;
$col_header=\@col_header;
$array_ref1=\@abc_array_2;
$array_ref2=\@abc_array_3;

#Adding formats

my $center = $workbook->add_format( align => 1 ,size=>10,font=>'Arial',border=>1,text_wrap=>1);
my $heading = $workbook->add_format( align => 'center', bold => 3 ,color => 'white',size=>14,bg_color => 'blue',font => 'Arial',border=>1);

print "Array value is @abc_array \n";

eval{
$worksheet->write_row( 'A1', $col_header,$heading);
$worksheet->write_row( 'A2', $array_ref,$center);    # Write a row of data
$worksheet->write_row( 'A3', $array_ref1,$center);    # Write a row of data
$worksheet->write_row( 'A4', $array_ref2,$center);    # Write a row of data
};

if ($@)
{
   print "Handling the exception";   
}
 
# Write a formatted and unformatted string, row and column notation.
$col = $row = 0;
 
$workbook->close();

