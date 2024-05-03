program NumberOfDigits;
var
  number, count, digit: Integer;
begin
  write('Enter a number:');
  read(number);
  count := 0;
  while number <> 0 do
  begin
    digit := number - (number / 10) * 10;
    
    if digit <> 0 then
      begin
      count:=count+1;
      end;
    number := number / 10;
  end;
  write('The number of digits is: ');
  write(count);
end.