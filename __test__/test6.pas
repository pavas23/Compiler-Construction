program FactorialCalculation;
var
  number, factorial, i: Integer;
begin
  write('Enter a number to calculate its factorial:');
  read(number);
  factorial := 1;
  for i := number downto 1 do
  begin
    factorial := factorial * i;
  end;
  write('The factorial is: ');
  write(factorial);
end.