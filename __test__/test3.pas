program ReverseNumber;
var
  number, reversedNumber, remainder: Integer;
begin
  write('Enter a number to reverse:');
  read(number);
  reversedNumber := 0;
  while number <> 0 do
  begin
    remainder := number % 10;
    reversedNumber := reversedNumber * 10 + remainder;
    number := number div 10;
  end;
  write('The reversed number is: ');
  write(reversedNumber);
end.