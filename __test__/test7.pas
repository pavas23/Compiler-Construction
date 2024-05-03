program SumOfSquares;
var
  number, sum, i: Integer;
begin
  write('Enter a number to calculate the sum of squares up to that number:');
  read(number);
  sum := 0;
  for i := 1 to number do
  begin
    sum := sum + (i * i);
  end;
  write('The sum of squares up is');
  write(sum);
end.