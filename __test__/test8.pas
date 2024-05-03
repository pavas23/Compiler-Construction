program forif;
var
  i, j: Integer;
begin
  for i := 1 to 20 do
   begin
     if i % 3 = 0 then 
      begin
        j := i + 2; 
        write(j);
      end;
    end;

end.